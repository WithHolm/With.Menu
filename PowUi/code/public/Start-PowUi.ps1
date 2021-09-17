function Start-PowUi {
    [CmdletBinding()]
    param (
        [Switch]$Statistics,
        [Switch]$MouseEnabled,
        [switch]$RunspaceEnabled,
        [Scriptblock]$Settings,
        [Scriptblock]$Ui
    )
    
    begin {

        if($settings)
        {
            Invoke-Command -ScriptBlock $Settings|Out-Null
        }

        if ($MouseEnabled) {
            $MouseEnabled = $env:TERM_PROGRAM -ne 'vscode'
        }


        Set-UiQuickEditMode -DisableQuickEdit
        Set-UiConsoleEncoding -Encoding utf-8
        Set-UiStatistics -Clean
        [System.Console]::CursorVisible = $false
        $Global:Ui.ResetSettings.buffer = [System.Console]::BufferHeight
        Clear-Host
        $MouseOnScreen = $false
        $Global:Ui.buffer = [System.Collections.ArrayList]::new()
        
        #Create runspace for user script
        if ($RunspaceEnabled -and !$env:InRunspace) {
            #Init runspace factory
            # $global:UiRunspaces = @{
            #     Pool      = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS + 1)
            #     Runspaces = @()
            # }

            # # $script:UiRunspaces = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS+1)
            # $global:UiRunspaces.Pool.ApartmentState = "MTA"
            # $global:UiRunspaces.Pool.Open()

            #Setup this runspace
            $AppBootStrap = [scriptblock]::Create((gc "$PSScriptRoot/runspace/userscript.ps1" -Raw))
            Start-UiRunspace -Code $AppBootStrap -Name "Application" -Parameters @{
                ui = $Global:Ui
                PowUiPath = (get-module PowUi).path
                Script = $Ui
            }
            # $runspace = [PowerShell]::Create()
            # $runspace.RunspacePool = $global:UiRunspaces.Pool

            # #Add script to run and parameters
            # [void]$runspace.AddScript($Userscript)
            # [void]$runspace.AddParameter('Ui', $Global:Ui)
            # [void]$runspace.AddParameter('PowUiPath', (get-module PowUi).path)
            # [void]$runspace.AddParameter("Script", $ui)

            # #start that shit
            # $global:UiRunspaces.Runspaces += [PSCustomObject]@{ 
            #     Pipe   = $runspace
            #     Status = $runspace.BeginInvoke() 
            # }
        }
        # $runspace.AddScript({$env:InRunspace = $true}.ToString())
    }
    
    process {

        $SW = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            # $count = 0
            while ($true) {
                Set-UiStatistics -Name dim -Value (@([console]::WindowHeight, [console]::WindowWidth) -join "X")
                if ([System.Console]::BufferHeight -ne [console]::WindowHeight) {
                    [System.Console]::BufferHeight = [console]::WindowHeight
                }
                $sw.Restart()
                

                if ($MouseEnabled) {
                    Register-UiMouseClick
                    $Global:Ui.mouse.pos = Get-UiConsoleMousePos
                        
                    if ($MouseOnScreen -eq $false -and $null -ne $Global:Ui.mouse.pos) {
                        Clear-Host
                        $MouseOnScreen = $true
                    }
                    else {
                        $MouseOnScreen = $null -ne $Global:Ui.mouse.pos
                    }
                }

                if (!$RunspaceEnabled) {
                    $Usr_SW = [System.Diagnostics.Stopwatch]::StartNew()
                    $ui.Invoke()
                    Set-UiStatistics -Name usr -Value $Usr_SW.ElapsedMilliseconds
                }

                #Set statistics for the buffer
                Set-UiStatistics -Name buf -Value $global:Ui.buffer.Count

                Write-UiStatistics -enabled:$Statistics

                New-UiChar -Text ($Global:Ui.buffer.Where{ $_.state -eq 0 }).count -X 0 -Y 14
                New-UiChar -Text ($Global:Ui.buffer.Where{ $_.state -ne 0 }).count -X 0 -Y 15

                #Remove all items with state 0
                
                Resize-UiBuffer
                # Start-Sleep -Seconds 0.5
                #write all item to screen
                Write-UiBuffer
                # Start-Sleep -Seconds 0.5
                

                #update fps
                Set-UiStatistics -Name fps -Value (1000 / ($sw.ElapsedMilliseconds + 0.1))
                Set-UiStatistics -Name add -Value 0
                    
                #update total time per frame
                Set-UiStatistics -Name tot -Value $sw.ElapsedMilliseconds -average

                if (
                    $true -in $script:UiRunspaces.Runspaces.Status.IsCompleted -and 
                    $true -in $global:UiRunspaces.Runspaces.pipe.HadErrors
                ) {
                    Throw "Found errors in runspace. please check it out"
                }

                # Start-Sleep -Milliseconds 0.1
            }
        }
        catch {
            
            Write-Warning $_
            throw $_
        }
        finally {
            [System.Console]::ResetColor()
            [System.Console]::BufferHeight = $Global:Ui.ResetSettings.buffer
            [System.Console]::SetCursorPosition(0, 0)
            [System.Console]::CursorVisible = $true
            # Clear-Host
            Set-UiQuickEditMode

            #Send quit message and wait for them to exit
            if ($RunspaceEnabled) {
                Stop-UiRunspace -All
                # Write-host "Exit runspace"
                # $Global:Ui.Quit = $true
                # # while ($script:UiRunspaces.Runspaces.Status.IsCompleted -notcontains $true) {
                # #     Write-host ($script:UiRunspaces.Runspaces.Status)
                # # }
    
                # #Cleanup Runspaces
                # Write-host "cleanup runspace"
                # foreach ($runspace in $global:UiRunspaces.Runspaces) {
                #     # EndInvoke method retrieves the results of the asynchronous call
                #     $runspace.Pipe.EndInvoke($runspace.Status)
                #     $runspace.Pipe.Dispose()
                # }
                # $global:UiRunspaces.Pool.Close() 
                # $global:UiRunspaces.Pool.Dispose()
            }
        }
        
    }
    
    end {
    }
}