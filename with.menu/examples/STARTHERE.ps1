# & "$PSScriptRoot\load.ps1"

ipmo "$(split-path $PSScriptRoot -Parent)" -Force

# module
New-Menu "main" {
    New-MenuSetting -ChoicePosition Middle -MenuPosition Middle #-WaitAfterChoiceExecution:$true -ClearScreenOn All
    New-MenuMessage -Message "Select your option"
    gci $psscriptroot -Filter "menu_*.ps1"|%{
        & $_.FullName
    }
}|Start-Menu