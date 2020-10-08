function Start-Menu {
    [CmdletBinding()]
    param (
        [System.Collections.Generic.List[Menu]]$Menu,
        [string]$id,
        [switch]$ShowDescription
    )
    
    begin {
    }
    
    process {
        if([string]::IsNullOrEmpty($id))
        {
            Write-verbose "No id defined. finding main menu"
            $UsingMenu = $Menu.where{[string]::IsNullOrEmpty($_.parentId)}|select -first 1

        }
        else {
            Write-verbose "Finding menu with id '$id' in menu items"
            $UsingMenu = $Menu.where{$_.id -eq $id}|select -first 1
        }

        if(@($UsingMenu).count -gt 1)
        {
            if([string]::IsNullOrEmpty($id))
            {
                throw "Found several menues defined as main menu. please fix this"
            }
            else {
                Throw "Found several menues with id '$id': $($UsingMenu|select name,description|convertto-json -compress). please fix this."
            }
        }
        elseif(@($UsingMenu).count -eq 0)
        {
            if([string]::IsNullOrEmpty($id))
            {
                throw "Could not find any main menu. i need a menu without a parent to be the first menu"
            }
            else {
                throw "Could not find any menues with id '$id'. please fix this"
            }
        }

        $Found = $false
        while($Found -eq $false)
        {
            Write-host $UsingMenu.GetTitle()
            write-host $UsingMenu.description
            # Write-host "Please select your option"
            $count = 1
            # $UsingMenu
            $UsingMenu.choices|%{
                Write-Verbose $($_|select name,description,id,type|convertto-json -Compress)
                Write-host "$count. $($_.name)"
                $count++
            }
    
            if($UsingMenu.parentid -eq "")
            {
                $ReadHostText = "Select your option or 'b' or 'q' to quit"
            }
            else
            {
                $ReadHostText = "Select your option, 'b' to go back or 'q' to quit"
            }

            $answer = read-host $ReadHostText
            if($answer -match "[0-9]{1,2}")
            {
                if(([int]$answer) -le $UsingMenu.choices.count -and ([int]$answer) -ne 0)
                {
                    $selection = $UsingMenu.choices[(([int]$answer)-1)]
                    Write-verbose "Selected choice $answer. $selection"
                    if($selection -is [menu])
                    {
                        $MenuReturn = Start-Menu -menu ($UsingMenu.choices|?{$_ -is [Menu]}) -id $selection.id
                        if($MenuReturn.returncode -eq [MenuReturn]::Error)
                        {
                            throw "Error happened!"
                        }
                        elseif($MenuReturn.returncode -eq [MenuReturn]::Quit)
                        {
                            $UsingMenu.returncode = [menureturn]::quit
                            $found = $true
                        }
                    }
                    elseif($selection -is [MenuChoice])
                    {
                        if($selection.action -is [scriptblock])
                        {
                            write-host ($usingMenu.WithPadding("Executing '$($selection.name)'"))
                            $selection.action.invoke()|%{
                                write-host $_
                            } 
                                
                            write-host ""
                            # write-host ($usingMenu.WithPadding("End Execution $($selection.name)"))
                        }
                        else 
                        {
                            write-verbose ($selection|convertto-json)
                            $selection.action
                        }
                    }
                }
                else
                {
                    write-host -ForegroundColor red "you need to select a number within the range (1-$($UsingMenu.choices.count))"
                }
            }
            elseif($answer -eq "b")
            {
                $UsingMenu.Returncode = [MenuReturn]::Back
                $found = $true
            }
            elseif($answer -eq "q")
            {
                $UsingMenu.Returncode = [MenuReturn]::quit
                $found = $true
            }
            else {
                write-host -ForegroundColor red "You need to select a number"
            }
        }

        if($UsingMenu.parentid -eq "")
        {
            return 
        }
        else {
            return $UsingMenu
        }
    }
    
    end {
        
    }
}