function invoke-Menu {
    [CmdletBinding()]
    param (
        [with_Menu]$Menu
    )
    
    begin {}
    
    process {
        if(@($Menu).count -gt 1)
        {
            if([string]::IsNullOrEmpty($id))
            {
                throw "Found several menues defined as main menu. please fix this"
            }
            else {
                Throw "Found several menues with id '$id': $($Menu|select name,description|convertto-json -compress). please fix this."
            }
        }
        elseif(@($Menu).count -eq 0)
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
            Write-host $Menu.WithPadding($menu.name,"-")
            write-host $Menu.WithPadding($Menu.description," ")
            Invoke-MenuStatus -Status $Menu.status -parent $Menu

            # Invoke-MenuStatus -Status $Menu.status


            # Write-host "Please select your option"
            $count = 1
            # $Menu
            $Menu.choices|%{
                Write-Verbose $($_|select name,description,id,type|convertto-json -Compress)
                Write-host "$count. $($_.name)"
                $count++
            }
            $ReadHostText = @()
            if($Menu.choices)
            {
                $ReadHostText += "Select your option"
            }

            if($Menu.parentid -eq "")
            {
                $ReadHostText += " or 'q' to quit"
            }
            else
            {
                $ReadHostText += ", 'b' to go back or 'q' to quit"
            }

            $answer = read-host ($ReadHostText -join "")
            if($answer -match "^[0-9]{1,2}$")
            {
                if(([int]$answer) -le $Menu.choices.count -and ([int]$answer) -ne 0)
                {
                    $selection = $Menu.choices[(([int]$answer)-1)]
                    Write-verbose "Selected choice $answer`: $selection"
                    if($selection -is [with_Menu])
                    {
                        # $MenuReturn = Start-Menu -menu ($Menu.choices|?{$_ -is [Menu]}) -id $selection.id
                        $MenuReturn = Invoke-Menu -menu @($selection) -id $selection.id
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
                    }
                }
                else
                {
                    write-host -ForegroundColor red "you need to select a number within the range (1-$($Menu.choices.count))"
                }
            }
            elseif($answer -eq "b")
            {
                $Menu.Returncode = [with_MenuReturn]::Back
                $found = $true
            }
            elseif($answer -eq "q")
            {
                $Menu.Returncode = [with_MenuReturn]::quit
                $found = $true
            }
            elseif($answer -in "one","two","three","four","five","six","seven","eight","nine")
            {
                write-host -ForegroundColor red "cheeky devil. No, A PROPER number. digits 1-$($Menu.choices.count)"
            }
            else {
                write-host -ForegroundColor red "You need to select a number"
            }
        }

        if($Menu.parentid -eq "")
        {
            return 
        }
        else {
            return $Menu
        }
    }
    
    end {
        
    }
}