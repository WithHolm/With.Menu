function invoke-Menu {
    [CmdletBinding()]
    param (
        [with_Menu]$Menu
    )
    
    begin {
        if($Menu.IsRoot)
        {   
            if(!$Menu.Settings)
            {
                Write-Verbose "$Menu`: no settings avalible, adding new ones"
                $Menu.Settings = New-MenuSetting
            }
            else {
                Write-verbose "$Menu`: Setting Currently defined settings as global"
                $menu.Settings.SetGlobal()
            }
        }
        else {
            Write-Verbose "$Menu`: Getting global settings"
            $menu.Settings = [with_menu_Setting]::GetGlobal()
        }

        $script:CurrentMenu = $Menu 
        $global:_Statuses = @()
    }
    
    process {
        
        $Found = $false
        while($Found -eq $false)
        {
            $ThisRunID = [guid]::NewGuid().Guid
            Write-Verbose $ThisRunID
            $SelectionWait = $false
            $Writer = [With_Menu_Writer]::new()

            #Clear screen if defined in options
            if($menu.settings.ClearScreenOn -in "All","Menu")
            {
                Clear-Host
            }

            #TITLE
            $Writer.Add($Menu.GetTile())
            
            #figure out filters
            if($menu.filters.Count)
            {
                $Filters = $menu.Filters|ConvertTo-MenuFilterHash
                $Status = Invoke-MenuFilter -filterHash $Filters -Items $menu.status
                $Choices = Invoke-MenuFilter -filterHash $Filters -Items $Menu.choices
                $Messages = @(Invoke-MenuFilter -filterHash $Filters -Items $Menu.Message)
            }
            else{
                $Status = $menu.status
                $Choices = $menu.choices
                $Messages = $Menu.Message
            }


            if($Messages.count)
            {
                $Messages|%{
                    $Writer.Add((Invoke-MenuMessage $_))
                }
                $Writer.add((New-Divideline))
            }
            #Concatonate statuses
            $Status.line|select -unique|sort|%{
                $Linenum = $_
                $line = $Writer.nextline()

                #Create list of applicable statuses
                $UsingStatuses = [System.Collections.Generic.List[with_Menu_Status]]::new()

                #add statues for currently defined status.line
                $status.where{$_.line -eq $Linenum}|%{
                    $UsingStatuses.Add($_)
                }

                #invoke them and add key+value to line dict with correct coloring
                Invoke-MenuStatus -Status $UsingStatuses|%{
                    $Writer.Add($line,$_)
                }
            }

            if($status.Count)
            {
                $Writer.add((New-Divideline))
            }
            Write-Menu -writer $Writer
            
            $optParam = @{
                OptionalInputs = @("refresh","quit")
            }
            if(!$menu.IsRoot)
            {
                $optParam.OptionalInputs += "back"
            }

            #write menuselection to screen
            $selection = Write-MenuSelection -Definition $Choices -DefinitionKey 'name' -ReturnType object @optParam -AsMenu -PauseOnWrongAnswer
            
            #if returnvalue is any of the optional returns
            if($selection -is [with_MenuReturn])
            {
                switch($selection)
                {
                    "back"{
                        $Menu.Returncode = [with_MenuReturn]::Back
                        $found = $true
                    }
                    "quit"{
                        $Menu.Returncode = [with_MenuReturn]::quit
                        $found = $true
                    }
                    "refresh"{
                        $found = $false
                    }
                }
            }
            #if return is a menu
            elseif($selection -is [with_Menu]){
                $MenuReturn = Invoke-Menu -menu $selection
                $script:CurrentMenu = $Menu 
                if($MenuReturn.returncode -eq [with_MenuReturn]::Error)
                {
                    throw "Error happened!"
                }
                elseif($MenuReturn.returncode -eq [with_MenuReturn]::Quit)
                {
                    $Menu.returncode = [with_menureturn]::quit
                    $found = $true
                }
            }
            #if return is a choice
            elseif($selection -is [with_Menu_Choice])
            {
                #start choice
                Invoke-Menuchoice -Choice $selection -parent $Menu

                #if setting to pause after exection is set.
                if($menu.Settings.WaitAfterChoiceExecution)
                {
                    Write-Debug "Wait after execution enabled. sending wait message"
                    $Writer = [With_Menu_Writer]::new()
                    New-MenuMessage -Message "Execution of '$($selection.name)' ended. press enter to continue'" -Wait|Invoke-MenuMessage|%{
                        $AnswerWriter.Add($_)
                    }
                    Write-Menu -writer $Writer
                }
            }
            else {
                Throw "Havent added code to handle selection of type '$($selection.GetType().name)'"
            }
        }

        #as long as the current menu is not root, 
        if(!$Menu.isroot)
        {
            return $Menu
        }
    }
    
    end {
    }
}