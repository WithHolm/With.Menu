$global:ShowHidden = $false 
New-Menu "Filters" {
    New-MenuMessage "a quick example using "
    New-MenuStatus -Name "Hiddden menues shown" -action {$global:ShowHidden} -Boolean
    New-MenuStatus -Name "Long running status" {Start-Sleep -Seconds 3;$true} -Boolean
    New-MenuFilter -Name "testing" -Filter {$global:ShowHidden} -OnTrue {
        New-Menu -Title "Hidden Menu" {
            New-MenuChoice "Some Choice" {"Somescript"}
        }
        New-MenuChoice "Disable hidden menues" {$global:ShowHidden = $false}
    } -OnFalse {
        New-MenuChoice "Show Hidden Menu" -Action {$global:ShowHidden = $true} -FilterName ShowMenu -FilterValue $false
    }

    New-MenuFilter -Name "testing2" -Filter {$global:ShowHidden} -OnTrue {
        New-MenuChoice "testing yes" -Action {} -FilterName "testing4" -FilterValue $true
    }

    New-MenuFilter -Name "testing4" -Filter {$true}

} #-Verbose #|Start-Menu