New-Menu "status menu"{
    # New-MenuSetting -MenuPosition Middle -StatusPosition Middle -MenuWidth 100 -ClearScreenOn Menu
    New-Menu "Basic"{
        #select a name, status type and value to show
        New-MenuStatus -Name "Keyvalue" -action {$true}
        New-MenuStatus -Name "Other Keyvalue" -action {$true}
        New-MenuStatus -Name "Other Keyvalue on different line" -action {$true} -line 1
        # New-MenuStatus -Name "Line" -Type Line -action "Some status line" -line 1
    }
    New-Menu "Boolean keyvalue switch"{
        New-MenuStatus "FalseValue" -action {$false} -Boolean
        New-MenuStatus "TrueValue" -action {$true} -Boolean
    }
    New-Menu "keyvalue Colour" {
        New-MenuMessage '"Here is a selection of coloured statuses"'
        [enum]::GetNames([System.ConsoleColor])|%{
            New-MenuStatus -Name "$_" -action "value" -Color $_ -line ([int][System.ConsoleColor]$_)

        }
    }
}#|Start-Menu #-Verbose