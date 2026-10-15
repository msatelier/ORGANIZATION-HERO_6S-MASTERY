param(
    [string]$GodotExecutable = 'C:\Dev\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Graphics
)
$ErrorActionPreference = 'Stop'
$taskProject = Split-Path -Parent $PSScriptRoot
$taskLogDir = Join-Path $taskProject 'build\validation'
New-Item -ItemType Directory -Path $taskLogDir -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $taskProject 'build\.gdignore'), '')
if (-not (Test-Path -LiteralPath $GodotExecutable)) { throw 'No se encontró Godot. Indicá -GodotExecutable.' }
$taskVersion = & $GodotExecutable --headless --version
if ($taskVersion -notmatch '^4\.7\.2\.stable') { throw "Versión no fijada: $taskVersion" }
function Invoke-GameCheck {
    param([string]$Name, [string[]]$Arguments)
    $taskLogFile = Join-Path $taskLogDir ($Name + '.log')
    & $GodotExecutable @Arguments *> $taskLogFile
    $taskProcessExit = $LASTEXITCODE
    $taskErrors = Select-String -LiteralPath $taskLogFile -Pattern '^ERROR:|^SCRIPT ERROR:|instances were leaked'
    if ($taskProcessExit -ne 0 -or $taskErrors) {
        Get-Content -LiteralPath $taskLogFile -Tail 50
        throw "Falló $Name (código $taskProcessExit)."
    }
    Write-Output "OK $Name"
    Select-String -LiteralPath $taskLogFile -Pattern 'RESULT:|PC RENDER:|PC DRAW CALLS:' | ForEach-Object { $_.Line }
}
Invoke-GameCheck -Name 'import' -Arguments @('--headless', '--path', $taskProject, '--editor', '--import', '--quit')
Invoke-GameCheck -Name 'run' -Arguments @('--headless', '--path', $taskProject, '--quit-after', '60', '--', '--no-save')
Invoke-GameCheck -Name 'domain' -Arguments @('--headless', '--path', $taskProject, '--script', 'tests/domain_tests.gd')
Invoke-GameCheck -Name 'assets' -Arguments @('--headless', '--path', $taskProject, '--script', 'tests/asset_tests.gd')
Invoke-GameCheck -Name 'rooms' -Arguments @('--headless', '--path', $taskProject, '--script', 'tests/rooms_tests.gd')
if ($Graphics) {
    Invoke-GameCheck -Name 'layout' -Arguments @('--path', $taskProject, '--script', 'tests/layout_tests.gd', '--', '--no-save')
    foreach ($taskRenderer in @('mobile', 'gl_compatibility')) {
        foreach ($taskSize in @('432x960', '960x432')) {
            $taskSaveDirectory = 'res://build/input-' + [Guid]::NewGuid().ToString('N')
            $taskPreviewDirectory = "res://build/previews-$taskRenderer-$taskSize"
            Invoke-GameCheck -Name "input-$taskRenderer-$taskSize" -Arguments @('--path', $taskProject, '--rendering-method', $taskRenderer, '--script', 'tests/interaction_smoke.gd', '--', "--save-dir=$taskSaveDirectory", "--preview-dir=$taskPreviewDirectory", "--test-size=$taskSize")
            $taskKitchenSave = 'res://build/kitchen-input-' + [Guid]::NewGuid().ToString('N')
            Invoke-GameCheck -Name "kitchen-$taskRenderer-$taskSize" -Arguments @('--path', $taskProject, '--rendering-method', $taskRenderer, '--script', 'tests/interaction_smoke.gd', '--', "--save-dir=$taskKitchenSave", "--preview-dir=res://build/previews-kitchen-$taskRenderer-$taskSize", "--test-size=$taskSize", '--test-room=kitchen')
        }
    }
}
Write-Output 'Verificación completada. Esto no acredita pruebas en hardware móvil.'
