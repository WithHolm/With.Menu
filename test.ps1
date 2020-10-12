ipmo "$PSScriptRoot\with.menu" -Force -Verbose

$menu = New-Menu -Name "Main menu" -description "This is the main menu" -Definition {
    New-MenuStatus -Name "Online" -Statustype KeyValue -action {$true} -colour
    New-MenuStatus -Name "Admin Enabled" -Statustype KeyValue -action {$false} -colour
    New-MenuStatus -Name "Connected to" -Statustype KeyValue -action "Contoso.com" -line 1
    New-MenuStatus -Name "compname"  -Statustype Line -action "name of the computer is '$env:COMPUTERNAME'"
    New-MenuChoice -Name "Get Items" -action {& .\Dostufff.ps1}
    New-Menu -Name "sub menu" -description "details" -Definition {
        New-MenuChoice -Name "throw" -action {throw "this is an error"}3
        New-MenuChoice -Name "Something" -action "something"
        New-MenuChoice -Name "Get Items" -action {gci}
    }
} -Verbose | Start-Menu