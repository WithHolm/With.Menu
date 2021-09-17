# Enable-UiDebug

ipmo $PSScriptRoot -Force

# if ([System.Windows.Forms.UserControl]::MouseButtons -eq [System.Windows.Forms.MouseButtons]::Left) {
#     New-UiCharAnimated -Y  $global:Ui.mouse.pos.Y -X $global:Ui.mouse.pos.x -Animation Star -loopCount 0 -UiKey "Animate_Star"
# }
$Global:ThisI = @{
    M_R_triggerPos   = $null
}
Start-PowUi -settings {
    Set-UiSettingName "TestUi"
    # Set-UiSettingLogPath ""
    # Set-UiSettingUiVariables @{
    #     M_R_triggerPos   = $null
    # }
} -Ui {
    # Write-Host "hey"
    # New-UiCharAnimated -Animation Star -loopCount -1 -x 1 -y 1
    # New-UiCircle -X 20 -Y 20 -Radius 10 -Character "*"
    New-UiChar -y 8 -x 1 -Text $global:Ui.mouse.pos
    New-UiChar -y 7 -x 1 -Text ([datetime]::Now.ToString("s"))
    New-UiChar -y 9 -x 1 -Text $global:Ui.mouse.click
    Use-UiMouseTrigger -Trigger left_down -Action {
        New-UiCharAnimated -Y (Use-UiMousePosition -y) -X (Use-UiMousePosition -x) -Animation Star -loopCount 10 -UiKey "Animate_Star"
        # New-UiChar -Y (Use-UiMousePosition -y) -X (Use-UiMousePosition -x) -Text "X" #-Animation Star -loopCount 10 #-UiKey "Animate_Star"
    }
    Use-UiMouseTrigger -Trigger right_down -Action {
        try{
            if($null -eq $Global:ThisI.M_R_triggerPos)
            {
                $Global:ThisI.M_R_triggerPos = $Global:Ui.mouse.pos #@((Use-UiMousePosition -x),(Use-UiMousePosition -y))
            }
            $Startpos = $Global:ThisI.M_R_triggerPos
            New-UiCharLine -start $Startpos -end $Global:Ui.mouse.pos -Text X
            # New-UiCharCircle -X $Startpos[0] -Y $Startpos[1] -Character "*" -Radius ((Use-UiMousePosition -x)-$Startpos[0])
        }
        catch{
            throw $_
        }
    }
    Use-UiMouseTrigger -Trigger right_up -Action {
        $Global:ThisI.M_R_triggerPos = $null
    }
} -MouseEnabled -Statistics