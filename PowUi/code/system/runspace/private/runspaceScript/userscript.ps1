param(
    [hashtable]$Ui,
    [string]$PowUiPath,
    [scriptblock]$Script
)
$Global:Ui = $Ui
$env:InRunspace = $true
ipmo $PowUiPath
while($Global:Ui.Quit -eq $false)
{
    $Usr_SW = [System.Diagnostics.Stopwatch]::StartNew()
    $script.Invoke()
    Set-UiStatistics -Name usr -Value $Usr_SW.ElapsedMilliseconds -average
    Start-Sleep -Milliseconds 0.1
}