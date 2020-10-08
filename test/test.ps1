ipmo "$PSScriptRoot\with.menu.psm1" -Force

$Menues = New-Menu -Name "Main menu" -description "This is the main menu" -Definition {
    New-MenuChoice -Name "Get Items" -action {& .\Dostufff.ps1}
    New-MenuChoice -Name "Do something else" -action "tet"
    New-Menu -Name "sub menu" -description "details" -Definition {
        New-MenuChoice -Name "Something" -action "something"
        New-MenuChoice -Name "Get Items" -action {gci}
    }
}

Start-Menu -menu $Menues -Verbose
