function invoke-Menu {
    [CmdletBinding()]
    param (
        [with_Menu]$Menu
        # [with_menu_Setting]$Settings
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
    }
    
    process {
        
        $Found = $false
        while($Found -eq $false)
        {
            $SelectionWait = $false
            $Writer = [With_Menu_Writer]::new()
            
            # $Lines = [System.Collections.Generic.List[With_menu_Line]]::new()

            if($menu.settings.ClearScreenOn -in "All","Menu")
            {
                Clear-Host
            }
            #TITLE
            $Writer.Add($Menu.GetTile())
            


            # $Line = 2

            #figure out filters
            if($menu.filters.Count)
            {
                $Filters = Get-FilterHash -filter $Menu.Filters
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
            
            if( $Choices.count)
            {
                $count = 1
                $Line = $Writer.NextLine()
                $Choices|%{
                    $ch = [With_menu_LineItem]::new()
                    $ch.Text = "$count. $($_.name)"
                    $ch.type = "Choice"
                    $Writer.Add($Line,$ch)
                    $count++
                }
            }
            
            #QUESTION
            $ReadHostText = @()
            if($Choices.Count)
            {
                $ReadHostText += "Select from 1-$($Choices.Count)"
            }

            if(!$Menu.IsRoot)
            {
                $ReadHostText += "(b)ack"
            }

            $ReadHostText += "(q)uit"
            $ReadHostText += "(r)efresh"
            $Question = [With_menu_LineItem]::new()
            $Question.Text = $ReadHostText -join ", "
            $Question.type = "question"
            $Writer.Add($Question)

            $answer = ""
            try{
                $Answer = Write-Menu -writer $writer #-settings $menu.Settings
            }
            catch [System.ArgumentOutOfRangeException] {
                Write-Verbose "Catched a out of range exception for setcursorposition. refreshing"
                $answer = "r"
            }
            catch{
                throw $_
            }

            Write-Verbose "Answer: '$answer'"
            $AnswerWriter = [With_Menu_Writer]::new()
            if($Answer -match "^[0-9]{1,2}$")
            {
                $Answer = [int]$Answer
                if($Answer -le $Choices.count -and $Answer -ne 0)
                {
                    $selection = $Choices[($Answer-1)]
                    Write-verbose "Selected choice $answer`: $selection"
                    if($selection -is [with_Menu])
                    {
                        $MenuReturn = Invoke-Menu -menu $selection
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
                    elseif($selection -is [with_Menu_Choice])
                    {
                        Invoke-Menuchoice -Choice $selection -parent $Menu
                        if($menu.Settings.WaitAfterChoiceExecution)
                        {
                            Write-Debug "Wait after execution enabled. sending wait message"
                            New-MenuMessage -Message "" -Wait|Invoke-MenuMessage|%{
                                $AnswerWriter.Add($_)
                            }
                        }
                    }
                }
                else
                {
                    $msg = New-MenuMessage -Message "you need to select a number within the range (1-$($choices.count))" -Color Red -Wait
                    $msg|Invoke-MenuMessage|%{
                        $AnswerWriter.Add($_)
                    }
                    # $SelectionWait = $true
                    # Write-MenuString -Message "you need to select a number within the range (1-$($usingChoices.count))" -Parameters @{ForegroundColor="red"} @setParam
                }
            }
            elseif($answer -ieq "b")
            {
                $Menu.Returncode = [with_MenuReturn]::Back
                $found = $true
            }
            elseif($answer -ieq "q")
            {
                $Menu.Returncode = [with_MenuReturn]::quit
                $found = $true
            }
            elseif($answer -ieq "r")
            {
                $found = $false
                #do nothing/refresh
            }
            elseif($answer -in "one","two","three","four","five","six","seven","eight","nine")
            {
                # $SelectionWait = $true
                $msg = New-MenuMessage -Message "cheeky devil. No, A PROPER number. digits 1-$($Menu.choices.count)" -Color Red -Wait
                $msg|Invoke-MenuMessage|%{
                    $AnswerWriter.Add($_)
                }
                # Write-MenuString -Message "cheeky devil. No, A PROPER number. digits 1-$($Menu.choices.count)" -Parameters @{ForegroundColor="red"} @setParam
            }
            else {
                # $SelectionWait = $true
                $msg = New-MenuMessage -Message "You need to select a number" -Color Red -Wait
                $msg|Invoke-MenuMessage|%{
                    $AnswerWriter.Add($_)
                }
                # Write-MenuString -Message "You need to select a number" -Parameters @{ForegroundColor="red"} @setParam
            }

            [void](Write-Menu -writer $AnswerWriter)
            # $found = $true
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