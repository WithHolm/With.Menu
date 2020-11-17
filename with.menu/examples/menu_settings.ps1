New-Menu "Settings menu"{
    # New-MenuStatus -Name k -Type Line -action "settings set on a higher level is traversed down" 
    # New-MenuStatus -name l -type line -action "unless the lower level menu also have setting"
    # New-Menu "Clear screen" {
    #     New-MenuSetting -ClearScreenOn all -WaitAfterExecution
    #     New-MenuStatus -Name "jepp" -Type Line -action "clears screen on a new menu"
    #     New-MenuChoice "Clear screen on execution" -Action {"For this to work correctly you also need to add -WaitAfterExecution if you want the output"}
    # }
    New-Menu "View All Settings" {
        $c = 0
        # [with_menu_setting]::GetGlobal(
        [with_menu_setting]::new().psobject.properties|?{$_.name -notin "id","name","type"}|%{
            # [with_menu_setting]::GetGlobal().$($_.name)
            New-MenuStatus -Name $_.name -action ([scriptblock]::create("[with_menu_setting]::GetGlobal().$($_.name)")) -boolean:([bool]::TryParse([with_menu_setting]::new().$($_.name),[ref]$null))  -line $c
            $c++
        }
    }

    New-Menu "Position" {
        New-Menu "Menu"{
            New-MenuStatus -Name "Default" -action {[with_Menu_Setting]::new().MenuPosition}
            New-MenuStatus -Name "Current" -action {[With_menu_setting]::GetGlobal().MenuPosition} -line 1
            [enum]::GetValues([With_Position])|%{
                $str = [String]::Format('$setting = [With_menu_setting]::GetGlobal();"Setting menu to the {0}";$setting.SetValue("MenuPosition","{0}")',$_)
                New-Menuchoice $_ -Action ([scriptblock]::create($str))
            }
        }
        New-Menu "Status"{
            New-MenuStatus -Name "Default" -action {[with_Menu_Setting]::new().StatusPosition}
            New-MenuStatus -Name "Current" -action {[With_menu_setting]::GetGlobal().StatusPosition} -line 1
            [enum]::GetValues([With_Position])|%{
                $str = [String]::Format('$setting = [With_menu_setting]::GetGlobal();"Setting menu to the {0}";$setting.SetValue("StatusPosition","{0}")',$_)
                New-Menuchoice $_ -Action ([scriptblock]::create($str))
            }
        }
        # New-Menu "Title"{
        #     New-MenuStatus "k" -type line "Middle is default"
        #     "Left","Right","Middle"|%{
        #         New-Menu $_ {
        #             New-MenuSetting -TitlePosition $_
        #             New-MenuStatus -Name "k" -Type Line -action "$_ position"
        #         }
        #     }
        # }
    }
}