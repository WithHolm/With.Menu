$global:ShowHidden = $false 
New-Menu "Filters" {
    New-MenuMessage "a quick example using "
    New-MenuStatus -Name "Hiddden menues shown" -action {$global:ShowHidden} -Boolean
    New-MenuFilter -Name "testing" -Filter {$global:ShowHidden} -OnTrue {
        New-Menu -Title "Hidden Menu" {
            New-MenuChoice "Some Choice" {"Somescript"}
        }
        New-MenuChoice "Disable hidden menues" {$global:ShowHidden = $false}
    } -OnFalse {
        New-MenuChoice "Show Hidden Menu" -Action {$global:ShowHidden = $true} -FilterName ShowMenu -FilterValue $false
    }
}