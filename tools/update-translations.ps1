param()
$ErrorActionPreference = 'Stop'
$taskProject = Split-Path -Parent $PSScriptRoot
$taskRows = @(Import-Csv -LiteralPath (Join-Path $taskProject 'localization\strings.csv'))
$taskNewline = [string][char]10
foreach ($taskLocale in @('es', 'en')) {
    $taskMessages = @()
    foreach ($taskRow in $taskRows) {
        $taskKey = ConvertTo-Json -InputObject $taskRow.keys -Compress
        $taskValue = ConvertTo-Json -InputObject ($taskRow.$taskLocale.Replace('\n', $taskNewline)) -Compress
        $taskMessages += $taskKey + ': ' + $taskValue
    }
    $taskSource = '[gd_resource type="Translation" format=3]' + $taskNewline + $taskNewline + '[resource]' + $taskNewline + 'locale = "' + $taskLocale + '"' + $taskNewline + 'messages = {' + $taskNewline + ($taskMessages -join (',' + $taskNewline)) + $taskNewline + '}' + $taskNewline
    $taskDestination = Join-Path $taskProject "localization\$taskLocale.tres"
    [IO.File]::WriteAllText($taskDestination, $taskSource, [Text.UTF8Encoding]::new($false))
}
Write-Output 'Traducciones nativas actualizadas desde strings.csv.'
