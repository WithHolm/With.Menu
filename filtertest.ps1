ipmo "$PSScriptRoot\with.menu" -Force
$global:ShowHidden = $false 
$k = New-Menu "Filters" -Description "Filters can be used to hide or show specific elements" {
    New-MenuFilter -Name "ShowMenu" -Action {$global:ShowHidden}


    New-MenuChoice "Hidden Menu" -Action {$global:ShowHidden = $true} -FilterName ShowMenu -FilterValue $false
    New-MenuChoice "Menu" -Action {$global:ShowHidden = $true} -FilterName ShowMenu -FilterValue $true

    # #on showhidden = false
    # New-MenuStatus -Name "Hiddden menues shown" -Type KeyValue -action {$global:ShowHidden} -Boolean
    # New-MenuChoice "Show Hidden Menu" -Action {$global:ShowHidden = $true} -FilterName ShowMenu -FilterValue $false
    
    # #on showhidden = true
    # New-Menu "Hidden Menu" -FilterName ShowMenu {
    #     New-MenuStatus "stat" -Type Line "nothing here, go back"
    # }
    # New-MenuChoice "Hidden Choice" -FilterName ShowMenu {"Somescript"}
    # New-MenuChoice "Disable hidden menues" -FilterName ShowMenu {$global:ShowHidden = $false}
}
Invoke-MenuFilter -items $k.choices -filter $k.Filters -Verbose 