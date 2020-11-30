<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ClearScreenOn
Parameter description

.PARAMETER MenuWidt
Parameter description

.PARAMETER MenuTabChoice
Parameter description

.PARAMETER MenuPosition
Parameter description

.PARAMETER ChoiceWaitAfter
Parameter description

.NOTES
General notes
#>
function New-MenuSetting {
    [CmdletBinding()]
    [outputtype([with_Menu_Setting])]
    param (
        [parameter(HelpMessage="When to clear screen. Default is none")]
        [With_ClearScreenOn]$ClearScreenOn = "None",
        
        [parameter(HelpMessage="Default padding char for menu")]
        [ValidateLength(1,1)]
        [string]$DefaultPadChar = "-",
        
        [parameter(HelpMessage="How wide the menu is")]
        [Int]$MenuWidth = 40,

        [switch]$AutoAjustMenuDisabled,

        [System.Management.Automation.ParameterAttribute(HelpMessage = "If console is too small for the menu, what to do")]
        [with_menu_setting_ConsoleTooSmall]$ConsoleTooSmall = "RetryOnce",
        
        [parameter(HelpMessage="where on the screen to show the menu")]
        [With_Position]$MenuPosition = "Left",
        
        [parameter(HelpMessage="Appends a 'press enter to continue' after execution of choices")]
        [Switch]$WaitAfterChoiceExecution,
        
        [parameter(HelpMessage="where on the screen to show the menu")]
        [With_Position]$StatusPosition = "Middle",

        [parameter(HelpMessage="where on the screen to show the menu")]
        [With_Position]$TitlePosition = "Middle",
        
        [parameter(HelpMessage="where on the screen to show the menu")]
        [With_Position]$ChoicePosition = "Left",

        [parameter(HelpMessage = "Value that defines colors for true/false. default is green/red")]
        [ValidateCount(2,2)]
        [System.ConsoleColor[]]$StatusBoolColor = @("Green","Red")

    )
    begin {
        $Setting = [with_menu_setting]::new()
    }
    process {
        $Setting.ClearScreenOn = $ClearScreenOn
        $setting.PadChar = $DefaultPadChar
        $Setting.MenuWidth = $MenuWidth
        $Setting.MenuPosition = $MenuPosition
        $Setting.WaitAfterChoiceExecution = $ChoiceWaitAfterExecution
        $Setting.TitlePosition = $TitlePosition
        $Setting.StatusPosition = $StatusPosition
        $Setting.ChoicePosition = $ChoicePosition
        $setting.AutoAjustMenu = !$AutoAjustMenuDisabled.IsPresent
        $Setting.ConsoleTooSmall = $ConsoleTooSmall
        $setting.StatusBoolColor = $StatusBoolColor
    }
    end {
        return $Setting
    }
}