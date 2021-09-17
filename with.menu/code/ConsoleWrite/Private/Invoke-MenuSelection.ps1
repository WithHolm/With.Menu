<#
.SYNOPSIS
Writes menuselection to screen.
.DESCRIPTION
Takes a menuselection 

.PARAMETER Selection
Parameter description

.EXAMPLE
An example

.NOTES
This is a private cmdlet and not intended for public use. If you want to use selection as part of your script, use 'Write-MenuSelection'
#>
function Invoke-MenuSelection {
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
        while (!$Found) {   
            #Setup writer everything written to console is written to this and this is again processed to show console output
            $writer = [With_Menu_Writer]::new()

            #if name is defined add title type to start of writer
            if (![string]::IsNullOrEmpty($Selection.Name)) {
                #Add Title: 
                #-------------------Title----------------------
                $ch = [With_menu_LineItem]::new()
                $ch.type = "title"
                $ch.Text = $Selection.Name
                $Writer.Add($ch)
            }
            
            #figure out what kind of input this is and set it up as an loopable array
            if ($selection.Definition -is [scriptblock]) {
                Write-Verbose "$selection Definition is scriptblock. invoking and getting results as an array"
                $Choices = @(Invoke-Scriptblock -InputItem $Selection.Definition)
            }
            elseif ($selection.Definition -is [array]) {
                Write-Verbose "$selection Definition is array"
                $Choices = $selection.Definition
            }
            elseif ([string]::IsNullOrEmpty($selection.Definition)) {
                #do nothing
                $Choices = @()
            }
            else {
                Write-Verbose "$selection Definition is $($selection.Definition.gettype().name). forcing it to act like a array"
                $Choices = @($selection.Definition)
            }

            #Loop through the selections to choose from. will create a string array
            $WriteChoices = @($Choices | % {
                    $val = ""
                    # $valset = $false
                    if (![string]::IsNullOrEmpty($selection.DefinitionKey)) {
                        $val = $_.$DefinitionKey
                        # $valset = $true
                        if ([string]::IsNullOrEmpty($val)) {
                            Write-Verbose "$selection The .$DefinitionKey value for the item was empty. using .tostring() instead: $($_|convertto-json -compress)"
                        }
                    }
                    elseif ($_ -is [hashtable] -or $_ -is [System.Collections.Specialized.OrderedDictionary]) {
                        if ($_.keys -contains "name") {
                            $val = $_.name
                        }
                        elseif ($_.keys -contains "n") {
                            $val = $_.n
                        }
                    }
                    elseif ($_.psobject.properties.name -contains "name" -or $_.psobject.properties.name -contains "n") {
                        if ($_.psobject.properties.name -contains "name") {
                            $val = $_.name
                        }
                        elseif ($_.psobject.properties.name -contains "n") {
                            $val = $_.n
                        }
                        # $val = $_.name
                    }
                

                    if ([string]::IsNullOrEmpty($val)) {
                        $_.ToString()
                    }
                    else {
                        $val
                    }
                })

            switch ($Selection.Style) {
                "classic" {
                    <# classic choice style

                                    1. firstItem
                                    2. SecondItem
                    Select from 1-2, (R)efresh, (Q)uit, (B)ack: 1
                    #>
                    #Add each selected item to writer
                    $count = 1
                    $Line = $Writer.NextLine()
                    Foreach ($WriteChoice in $WriteChoices) {
                        $ch = [With_menu_LineItem]::new()
                        $ch.Text = "$count. $WriteChoice"
                        $ch.type = "Choice"
                        $Writer.Add($Line, $ch)
                        $count++
                    }

                    #If divideline is selected. the charater to use for divideline is stored in settings. '-' by default
                    if ($selection.OptionalInput -contains "divideline") {
                        $line = [With_menu_LineItem]::new()
                        $Line.type = "divideline"
                        $writer.Add($Line)
                    }

                    #Add array to add text that is appended as a question at the end
                    $ReadHostText = @()
                    if ($WriteChoices.Count) {
                        $ReadHostText += "Select from 1..$($Choices.Count)"
                    }
    
                    #adding (R)efresh, (Q)uit, (B)ack
                    $ReadHostText += $Selection.OptionalInput |Where-Object{ $_ -ne "divideline" } | ForEach-Object {
                        Write-Verbose "$selection adding optional input '$_'"
                        ConvertTo-BracketString -String $_.ToString()
                    }

                    $Question = [With_menu_LineItem]::new()
                    $Question.Text = $ReadHostText -join ", "
                    $Question.type = "question"
                    $Writer.Add($Question)
        
                    $answer = ""
                    try {
                        $Answer = Write-Menu -writer $writer #-settings $menu.Settings
                    }
                    catch [System.ArgumentOutOfRangeException] {
                        Write-Verbose "Catched a out of range exception for setcursorposition. refreshing"
                        $answer = "r"
                    }
                    catch {
                        throw $_
                    }
                }
                "prompt" {
                    $Selection.OptionalInput = $Selection.OptionalInput | where-object { $_ -ne "divideline" }
                    $OptionalLetters = $Selection.OptionalInput | ForEach-Object {
                        @{
                            FullName = $_.ToString()
                            Letter   = $_.tostring().Substring(0, 1)
                        }
                    }

                    #if there are more than 5 items in the selection array
                    if ($WriteChoices.Count -ge 5) {
                        Write-Verbose "$Selection BAD UI WARNING: The current selection style does NOT lend itself to more than 5 items. currently $($WriteChoices.Count) items"
                    }

                    #if any items in the selection array has same letter as any of the optional inputs
                    if ($WriteChoices | ? { $_.substring(0, 1) -in $OptionalLetters.Letter }) {
                        Write-Verbose "$Selection BAD UI WARNING: There are items in the current selection that does not go well with the optional inputs (Same first letter):"
                        
                        #For each selection that has the same first letter as one of the optional inputs
                        $WriteChoices.where | where-object { $_.substring(0, 1) -in $OptionalLetters } | ForEach-Object {
                            $badSelection = $_
                            $badSelectionLetter = $badselection.Substring(0, 1)
    
                            #for each optional input that matches the bad input
                            $OptionalLetters | ? { $_.Letter -like $badSelectionLetter } | % {
                                Write-Verbose "$badSelection ~ $($_.Fullname)"
                            }
                        }
                    }
                    $PromptChoice = $WriteChoices | % {
                        # $ch = [With_menu_LineItem]::new()
                        ConvertTo-BracketString -String $_
                        # "({0}){1}" -f $opt.Substring(0, 1).ToUpper(), $opt.Substring(1)
                        # $ch.type = "Choice"
                        # $Writer.Add($Line,$ch)
                    } -join " "
    
                    $ReadHostText += $Selection.OptionalInput | ? { $_ -ne "divideline" } | % {
                        Write-Verbose "$selection adding optional input '$_'"
                        $opt = $_.ToString()
    
                        #back = [B]ack
                        "({0}){1}" -f $opt.Substring(0, 1).ToUpper(), $opt.Substring(1)
                    }
                }
            }
            # if ($Selection.Style -eq "classic") {
            #     $count = 1
            #     $Line = $Writer.NextLine()
            #     $WriteChoices | % {
            #         $ch = [With_menu_LineItem]::new()
            #         $ch.Text = "$count. $_"
            #         $ch.type = "Choice"
            #         $Writer.Add($Line, $ch)
            #         $count++
            #     }

            #     $ReadHostText = @()
            #     if ($WriteChoices.Count) {
            #         $ReadHostText += "Select from 1-$($Choices.Count)"
            #     }
    
            #     if ($selection.OptionalInput -contains "divideline") {
            #         $line = [With_menu_LineItem]::new()
            #         $Line.type = "divideline"
            #         $writer.Add($Line)
            #         # $Selection.OptionalInput.Remove("divideline")
            #     }
    
            #     $ReadHostText += $Selection.OptionalInput | ? { $_ -ne "divideline" } | % {
            #         Write-Verbose "$selection adding optional input '$_'"
            #         $opt = $_.ToString()
            #         $opt = "({0}){1}" -f $opt.Substring(0, 1).ToUpper(), $opt.Substring(1)
            #         $opt
            #     }
            #     $Question = [With_menu_LineItem]::new()
            #     $Question.Text = $ReadHostText -join ", "
            #     $Question.type = "question"
            #     $Writer.Add($Question)
        
            #     $answer = ""
            #     try {
            #         $Answer = Write-Menu -writer $writer #-settings $menu.Settings
            #     }
            #     catch [System.ArgumentOutOfRangeException] {
            #         Write-Verbose "Catched a out of range exception for setcursorposition. refreshing"
            #         $answer = "r"
            #     }
            #     catch {
            #         throw $_
            #     }
            # }
            # elseif ($Selection.Style -eq "prompt") {

            #     $OptionalLetters = $Selection.OptionalInput | ? { $_ -ne "divideline" } | % {
            #         @{
            #             FullName = $_.ToString()
            #             Letter   = $_.tostring().Substring(0, 1)
            #         }
            #     }
            #     if ($WriteChoices.Count -gt 5) {
            #         Write-Verbose "$Selection BAD UI WARNING: The current selection style does NOT lend itself to more than 5 items. currently $($WriteChoices.Count) items"
            #     }
            #     elseif ($WriteChoices | ? { $_.substring(0, 1) -in $OptionalLetters.Letter }) {
            #         Write-Verbose "$Selection BAD UI WARNING: There are items in the current selection that does not go well with the optional inputs (Same first letter):"
                    
            #         #For each selection that has the same first letter as one of the optional inputs
            #         $WriteChoices | ? { $_.substring(0, 1) -in $OptionalLetters } | % {
            #             $badSelection = $_
            #             $badSelectionLetter = $badselection.Substring(0, 1)

            #             #for each optional input that matches the bad input
            #             $OptionalLetters | ? { $_.Letter -like $badSelectionLetter } | % {
            #                 Write-Verbose "$badSelection ~ $($_.Fullname)"
            #             }
            #         }
            #     }
            #     $PromptChoice = $WriteChoices | % {
            #         $ch = [With_menu_LineItem]::new()
            #         "({0}){1}" -f $opt.Substring(0, 1).ToUpper(), $opt.Substring(1)
            #         # $ch.type = "Choice"
            #         # $Writer.Add($Line,$ch)
            #     } -join " "

            #     $ReadHostText += $Selection.OptionalInput | ? { $_ -ne "divideline" } | % {
            #         Write-Verbose "$selection adding optional input '$_'"
            #         $opt = $_.ToString()

            #         #back = [B]ack
            #         "({0}){1}" -f $opt.Substring(0, 1).ToUpper(), $opt.Substring(1)
            #     }
            # }
  


            Write-Verbose "$selection Answer: '$answer'"
            #New writer. used to write in any exeptions (ie, write correct number etc)
            $AnswerWriter = [With_Menu_Writer]::new()

            #if answer is 0-99
            if ($Answer -match "^[0-9]{1,2}$") {
                $Answer = [int]$Answer
                #if answer is within range of the choices to make
                if ($Answer -le $Choices.count -and $Answer -ne 0) {
                    switch ($Selection.ReturnType) {
                        "int" {
                            $return = $answer - 1
                            $found = $true
                        }
                        "string" {
                            $found = $true
                            $return = $WriteChoices[$answer - 1]
                        }
                        "object" {
                            $found = $true
                            $return = $Choices[$answer - 1]
                        }
                    }
                    Write-verbose "$selection Selected choice $answer`: $return"
                }
                else {
                    $msg = New-MenuMessage -Message "you need to select a number within the range (1-$($choices.count))" -Color Red -Wait:($Selection.PauseOnWrongAnswer)
                    $msg | Invoke-MenuMessage | % {
                        $AnswerWriter.Add($_)
                    }
                }
            }
            elseif ($answer -ieq "b" -and $Selection.OptionalInput -contains "back") {
                if ($selection.ProcessAsMenu) {
                    $return = [with_MenuReturn]::Back
                }
                $found = $true
            }
            elseif ($answer -ieq "q" -and $Selection.OptionalInput -contains "quit") {
                if ($selection.ProcessAsMenu) {
                    $return = [with_MenuReturn]::quit
                }
                $found = $true
            }
            elseif ($answer -ieq "r" -and $Selection.OptionalInput -contains "refresh") {
                if ($selection.ProcessAsMenu) {
                    $return = [with_MenuReturn]::refresh
                }
                # $return 
                $found = $true
                #do nothing/refresh
            }
            else {
                # $SelectionWait = $true
                $msg = New-MenuMessage -Message "You need to select a number" -Color Red -Wait:($Selection.PauseOnWrongAnswer)
                $msg | Invoke-MenuMessage | % {
                    $AnswerWriter.Add($_)
                }
                # Write-MenuString -Message "You need to select a number" -Parameters @{ForegroundColor="red"} @setParam
            }
            if ($AnswerWriter.Lines.count) {
                [void](Write-Menu -writer $AnswerWriter)
            }
            # $found = $true
        }

        return $return
    }
    
    end {
        
    }
}