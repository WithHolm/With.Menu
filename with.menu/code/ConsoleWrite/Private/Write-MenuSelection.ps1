function Write-MenuSelection {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [with_menu_selection]$Selection   
    )
    
    begin {
        
    }
    
    process {
        $found = $false
        $return = ""
        while(!$Found)
        {
            $writer = [With_Menu_Writer]::new()
            if(![string]::IsNullOrEmpty($Selection.Name))
            {
                $ch = [With_menu_LineItem]::new()
                $ch.type = "title"
                $ch.Text = $Selection.Name
                $Writer.Add($ch)
            }
            
            if($selection.Definition -is [scriptblock])
            {
                Write-Verbose "$selection Definition is scriptblock. invoking and getting results as an array"
                $Choices = @(Invoke-Scriptblock -InputItem $Selection.Definition)
            }
            elseif($selection.Definition -is [array])
            {
                Write-Verbose "$selection Definition is array"
                $Choices = $selection.Definition
            }
            elseif([string]::IsNullOrEmpty($selection.Definition))
            {
                #do nothing
                $Choices = @()
            }
            else {
                Write-Verbose "$delection Definition is $($Definition.gettype().name). forcing it to act like a array"
                $Choices = @($selection.Definition)
            }

            $WriteChoices = @($Choices|%{
                $val = ""
                # $valset = $false
                if(![string]::IsNullOrEmpty($selection.DefinitionKey))
                {
                    $val = $_.$DefinitionKey
                    # $valset = $true
                    if([string]::IsNullOrEmpty($val))
                    {
                        Write-Verbose "$selection The .$DefinitionKey value for the item was empty. using .tostring() instead: $($_|convertto-json -compress)"
                    }
                }
                elseif($_ -is [hashtable] -or $_ -is [System.Collections.Specialized.OrderedDictionary])
                {
                    if($_.keys -contains "name")
                    {
                        $val = $_.name
                    }
                    elseif($_.keys -contains "n")
                    {
                        $val = $_.n
                    }
                }
                elseif($_.psobject.properties.name -contains "name" -or $_.psobject.properties.name -contains "n")
                {
                    if($_.psobject.properties.name -contains "name")
                    {
                        $val = $_.name
                    }
                    elseif($_.psobject.properties.name -contains "n")
                    {
                        $val = $_.n
                    }
                    # $val = $_.name
                }
                

                if([string]::IsNullOrEmpty($val))
                {
                    $_.ToString()
                }
                else {
                    $val
                }
            })

            $count = 1
            $Line = $Writer.NextLine()
            $WriteChoices|%{
                $ch = [With_menu_LineItem]::new()
                $ch.Text = "$count. $_"
                $ch.type = "Choice"
                $Writer.Add($Line,$ch)
                $count++
            }
  
            $ReadHostText = @()
            if($WriteChoices.Count)
            {
                $ReadHostText += "Select from 1-$($Choices.Count)"
            }

            if($selection.OptionalInput -contains "divideline")
            {
                $line = [With_menu_LineItem]::new()
                $Line.type = "divideline"
                $writer.Add($Line)
                # $Selection.OptionalInput.Remove("divideline")
            }

            $ReadHostText += $Selection.OptionalInput|?{$_ -ne "divideline"}|%{
                Write-Verbose "$selection adding optional input '$_'"
                $opt = $_.ToString()
                $opt = "({0}){1}" -f $opt.Substring(0,1).ToUpper(),$opt.Substring(1)
                $opt
            }

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

            Write-Verbose "$selection Answer: '$answer'"
            #New writer. used to write in any exeptions (ie, write correct number etc)
            $AnswerWriter = [With_Menu_Writer]::new()

            #if answer is 0-99
            if($Answer -match "^[0-9]{1,2}$")
            {
                $Answer = [int]$Answer
                #if answer is within range of the choices to make
                if($Answer -le $Choices.count -and $Answer -ne 0)
                {
                    switch($Selection.ReturnType)
                    {
                        "int"{
                            $return = $answer-1
                            $found = $true
                        }
                        "string"{
                            $found = $true
                            $return = $WriteChoices[$answer-1]
                        }
                        "object"{
                            $found = $true
                            $return = $Choices[$answer-1]
                        }
                    }
                    Write-verbose "$selection Selected choice $answer`: $return"
                }
                else
                {
                    
                    $msg = New-MenuMessage -Message "you need to select a number within the range (1-$($choices.count))" -Color Red -Wait:($Selection.PauseOnWrongAnswer)
                    $msg|Invoke-MenuMessage|%{
                        $AnswerWriter.Add($_)
                    }
                }
            }
            elseif($answer -ieq "b" -and $Selection.OptionalInput -contains "back")
            {
                if($selection.ProcessAsMenu)
                {
                    $return = [with_MenuReturn]::Back
                }
                $found = $true
            }
            elseif($answer -ieq "q" -and $Selection.OptionalInput -contains "quit")
            {
                if($selection.ProcessAsMenu)
                {
                    $return = [with_MenuReturn]::quit
                }
                $found = $true
            }
            elseif($answer -ieq "r" -and $Selection.OptionalInput -contains "refresh")
            {
                if($selection.ProcessAsMenu)
                {
                    $return = [with_MenuReturn]::refresh
                }
                # $return 
                $found = $true
                #do nothing/refresh
            }
            else {
                # $SelectionWait = $true
                $msg = New-MenuMessage -Message "You need to select a number" -Color Red -Wait:($Selection.PauseOnWrongAnswer)
                $msg|Invoke-MenuMessage|%{
                    $AnswerWriter.Add($_)
                }
                # Write-MenuString -Message "You need to select a number" -Parameters @{ForegroundColor="red"} @setParam
            }
            if($AnswerWriter.Lines.count)
            {
                [void](Write-Menu -writer $AnswerWriter)
            }
            # $found = $true
        }

        return $return
    }
    
    end {
        
    }
}