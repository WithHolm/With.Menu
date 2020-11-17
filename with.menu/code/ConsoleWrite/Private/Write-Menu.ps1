function Write-Menu
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [With_Menu_Writer]$writer
    )
    
    begin
    {
        $Settings = [with_menu_setting]::GetGlobal()
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    }
    
    process
    {
        $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
        $MaxCharWidth = ($writer.Lines.keys | % {
                if("choice" -in $writer.Lines[$_].type)
                {
                    ($writer.Lines[$_].Text | measure -Maximum length).Maximum
                }
                else{
                    ($writer.Lines[$_].Text | measure -Sum length).sum
                }
            } | measure -Maximum).Maximum


        #what happens when screen size is too small
        if ($MaxCharWidth -gt $ConsoleWidth)
        {
            Write-Verbose "Encountered state where console size is too small. need:$MaxCharWidth, have:$ConsoleWidth"
            Write-Verbose "Setting is: $($setting.ConsoleTooSmall)"
            Switch ($Settings.ConsoleTooSmall)
            {
                "RetryOnce"
                {
                    Write-host "Your console size is too small for the menu."
                    $a = Read-Host "please resize your powershell window and press enter"
                    if ($MaxCharWidth -gt $Host.UI.RawUI.WindowSize.Width)
                    {
                        Throw "Your window is $($Host.UI.RawUI.WindowSize.Width) charaters wide, but i need $MaxCharWidth"
                    }
                    $ConsoleWidth = $Host.UI.RawUI.WindowSize.Width
                }
                "Error"
                {
                    if ($MaxCharWidth -gt $Host.UI.RawUI.WindowSize.Width)
                    {
                        Throw "Your window is $($Host.UI.RawUI.WindowSize.Width) charaters wide, but i need $MaxCharWidth"
                    }
                }
                "Ignore"
                {
                    #ignoring
                }
            }
        }

        #if menu is too small and 
        if ($MaxCharWidth -gt $Settings.MenuWidth -and $Settings.AutoAjustMenu)
        {
            Write-Debug "Updating MenuWidth from $($Settings.MenuWidth) to $MaxCharWidth"
            $settings.SetValue("MenuWidth",$MaxCharWidth)
        }
        elseif ($MaxCharWidth -gt $Settings.MenuWidth)
        {
            Write-Verbose "width of menu items is too large for the menu, but autoajust is not enabled. i bet it will look silly now"
        }


        # MaxLength = $ConsoleWidth 
        # ItemLength = $MenuWidth 
        # position = $settings.MenuPosition

        $MenuPad = Get-PadLength -MaxLength $Host.UI.RawUI.WindowSize.Width -ItemLength $Settings.MenuWidth -Position $settings.MenuPosition
        Write-debug "Paddig for the 'menu': $($MenuPad -join ", ")"
        $LeftMenuPad = $(" " * $Menupad[0])
        $RightMenuPad = $(" " * $Menupad[1])

        foreach ($key in $writer.Lines.Keys)
        {
            
            $WriteItems = $writer.Lines[$key]
            $ItemLength = ($WriteItems | % { $_.Text.Length } | measure -sum).sum
            $Itemtype = ($WriteItems | select -first 1).type 
            switch ($Itemtype)
            {
                "Title"
                {
                    $Color = $writer.Lines[$key].color | select -first 1
                    $Text = $writer.Lines[$key].Text -join ""
                    $ItemPad = Get-PadLength -MaxLength $Settings.MenuWidth -ItemLength $ItemLength -Position $settings.TitlePosition
                    
                    Write-debug "Title padding: $($itempad -join ", ")"
                    Out-Console -Message $LeftMenuPad -NoNewLine
                    Out-Console -message ($Settings.padchar * $itempad[0]) -NoNewline
                    Out-Console -message $text -Color $Color -NoNewline
                    Out-Console -message $($Settings.padchar * $itempad[1])
                }
                "Status"
                {
                    $ItemPad = Get-PadLength -MaxLength $Settings.MenuWidth -ItemLength $ItemLength -Position $settings.StatusPosition
                    $count = 0
                    Write-debug "Status padding: $($itempad -join ", ")"
                    Write-Host $LeftMenuPad -NoNewline
                    Write-host (" " * $itempad[0]) -NoNewline
                    $WriteItems | % {
                        $count++
                        Write-host -Object $_.Text -ForegroundColor $_.color -NoNewline
                        if ($count % 2 -eq 0 -and $count -ne $WriteItems.count)
                        {
                            Write-host -Object ", " -NoNewline
                        }
                    }
                    Write-host ""
                }
                "DivideLine"
                {
                    $WriteItems|%{
                        if([string]::IsNullOrEmpty($_.Text))
                        {
                            $_.Text = $Settings.PadChar
                        }
                        Write-debug "Divideline: $($_.Text)"
                        
                        Out-Console -Message $LeftMenuPad -NoNewLine
                        Out-Console -Message ($_.Text*$settings.MenuWidth) -Color $_.color
                        # Write-Host $LeftMenuPad -NoNewline
                        # Write-Host ($_.Text*$settings.MenuWidth) -ForegroundColor $_.color
                    }
                }
                "Choice"
                {
                    $LongestItem = ($WriteItems.Text|measure -Maximum Length).Maximum
                    $ItemPad = Get-PadLength -MaxLength $settings.MenuWidth -ItemLength $LongestItem -Position $Settings.ChoicePosition
                    Write-debug "Status padding: $($itempad -join ", ")"
                    $WriteItems|%{
                        out-console $LeftMenuPad -NoNewLine
                        # Write-Host $LeftMenuPad -NoNewline
                        out-console (" "*$ItemPad[0]) -NoNewline
                        out-console $_.Text -Color $_.color
                    }
                }
                "Question"
                {
                    $ItemPad = Get-PadLength -MaxLength $settings.MenuWidth -ItemLength $_.text.length -Position $Settings.ChoicePosition
                    $stopwatch.Stop()
                    Out-Console -Message $LeftMenuPad -NoNewLine
                    Out-Console -Message $WriteItems.Text -Question
                    # Read-Host -Prompt "$LeftMenuPad$($WriteItems.text)"
                    $stopwatch.Start()
                }
                "Message"
                {
                    $LongestItem = ($WriteItems.Text|measure -Maximum Length).Maximum
                    $ItemPad = Get-PadLength -MaxLength $settings.MenuWidth -ItemLength $LongestItem -Position Middle
                    Write-debug "Message padding: $($itempad -join ", ")"
                    $WriteItems|%{
                        Write-Host $LeftMenuPad -NoNewline
                        Write-host (" "*$ItemPad[0]) -NoNewline
                        Write-host $_.Text -ForegroundColor $_.color
                    }
                }
            }
        }
        $stopwatch.Stop()
        Write-Verbose "Created menu with $($writer.Lines.values.text.Count) items in $($stopwatch.ElapsedMilliseconds) ms"
    }
    
    end
    {
        
    }
}