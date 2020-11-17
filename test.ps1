ipmo "$PSScriptRoot\with.menu" -Force -Verbose

$global:testing = $false
New-Menu "Main Menu" {
    New-MenuFilter MenuEnabled {$global:testing -eq $true}
    
    New-MenuStatus "Menu enabled" {$Global:testing} -Boolean -Type KeyValue
    New-MenuStatus -Name "Elevated" -Type KeyValue -Boolean -line 4 -action {
        [Security.Principal.WindowsPrincipal]::Current.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } -FilterName MenuEnabled

    New-MenuChoice "Enable Menu" -Action {$Global:testing = $true} -FilterName Menuenabled -FilterValue $false

    New-Menu "Menu" -FilterName "MenuEnabled" -Action {
        New-MenuFilter "MenuEnabled" {$global:testing}
        New-MenuStatus "Menu enabled" {$Global:testing} -Boolean -Type KeyValue
        New-MenuChoice "Disable Menu" -Action {
            3..1|%{
                Write-host "Disabling menu in $_"
                Start-Sleep -Seconds 1
            }
            $Global:testing = $false
        } -FilterName MenuEnabled
    }
} -Verbose -Debug|Start-Menu -Verbose
#|Start-Menu