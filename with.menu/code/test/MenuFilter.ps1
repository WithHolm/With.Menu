Describe "Menu filter"{
    InModuleScope "with.menu"{
        it "hides items that are affected by the filter"{
            $test = New-Menu pester {
                New-MenuFilter "show" -Action {$true}
                New-MenuChoice -Name "shown" -Action {$ture} -FilterName show -FilterValue $true
                New-MenuChoice -Name "hidden" -Action {$ture} -FilterName show -FilterValue $false
            }
            $Result = Invoke-MenuFilter -items $test.choices -filter $test.Filters
            $Result|should -havecount 1
            $Result|should -be "shown"
        }
    
        It "Cannot have several filters with the same name"{
            {
                New-Menu test {
                    New-MenuFilter "test" -action {$true}
                    New-MenuFilter "test" -action {$true}
                }
            }|should -throw
        }
    }
}