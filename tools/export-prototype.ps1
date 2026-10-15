param(
    [string]$GodotExecutable = 'C:\Dev\Godot\4.7.2\Godot_v4.7.2-stable_win64_console.exe',
    [switch]$Android,
    [switch]$Graphics,
    [string]$JavaHome = 'C:\Dev\GameDevelopment\Tools\Java\jdk-17.0.20.1+1',
    [string]$AndroidBuildTools = 'C:\Dev\GameDevelopment\Tools\AndroidSdk\build-tools\36.0.0'
)
$ErrorActionPreference = 'Stop'
$taskProject = Split-Path -Parent $PSScriptRoot
$taskBuild = Join-Path $taskProject 'build'
$taskLogs = Join-Path $taskBuild 'validation'
New-Item -ItemType Directory -Path $taskLogs -Force | Out-Null
[IO.File]::WriteAllText((Join-Path $taskBuild '.gdignore'), '')
function Invoke-ExportCheck {
    param([string]$Name, [string[]]$Arguments)
    $taskLog = Join-Path $taskLogs ($Name + '.log')
    & $GodotExecutable @Arguments *> $taskLog
    $taskExit = $LASTEXITCODE
    if ($taskExit -ne 0 -or (Select-String -LiteralPath $taskLog -Pattern '^ERROR:|^SCRIPT ERROR:|instances were leaked')) {
        Get-Content -LiteralPath $taskLog -Tail 35
        throw "Falló $Name (código $taskExit)."
    }
    Write-Output "OK $Name"
    Select-String -LiteralPath $taskLog -Pattern 'RESULT:' | ForEach-Object { $_.Line }
}
Invoke-ExportCheck -Name 'export-windows' -Arguments @('--headless', '--path', $taskProject, '--export-debug', 'Windows Desktop', (Join-Path $taskBuild 'OrganizationHero.exe'))
$taskPack = Join-Path $taskBuild 'OrganizationHero.pck'
Invoke-ExportCheck -Name 'export-data' -Arguments @('--headless', '--main-pack', $taskPack, '--script', (Join-Path $taskProject 'tests\export_data_tests.gd'))
Invoke-ExportCheck -Name 'packed-run' -Arguments @('--headless', '--main-pack', $taskPack, '--quit-after', '60', '--', '--no-save')
if ($Graphics) {
    foreach ($taskSize in @('432x960', '960x432')) {
        $taskSaveDirectory = 'user://packed-input-' + [Guid]::NewGuid().ToString('N')
        $taskPreviewDirectory = (Join-Path $taskBuild "previews-packed-$taskSize").Replace('\', '/')
        Invoke-ExportCheck -Name "input-packed-$taskSize" -Arguments @('--main-pack', $taskPack, '--script', (Join-Path $taskProject 'tests\interaction_smoke.gd'), '--', "--save-dir=$taskSaveDirectory", "--preview-dir=$taskPreviewDirectory", "--test-size=$taskSize")
    }
}
if ($Android) {
    $taskApk = Join-Path $taskBuild 'OrganizationHero-debug.apk'
    Invoke-ExportCheck -Name 'export-android' -Arguments @('--headless', '--path', $taskProject, '--export-debug', 'Android', $taskApk)
    $taskPreviousJavaHome = $env:JAVA_HOME
    try {
        $env:JAVA_HOME = $JavaHome
        & (Join-Path $AndroidBuildTools 'apksigner.bat') verify --verbose $taskApk
        if ($LASTEXITCODE -ne 0) { throw 'La firma de la APK no se pudo verificar.' }
    } finally {
        $env:JAVA_HOME = $taskPreviousJavaHome
    }
}
Write-Output 'Exportaciones de depuración. Las pruebas físicas de Android siguen pendientes.'
