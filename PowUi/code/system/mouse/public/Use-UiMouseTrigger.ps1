function Use-UiMouseTrigger {
    [CmdletBinding()]
    param (
        [ValidateSet(
            "left_down","left_up",
            "right_down","right_up",
            "xbutton2_down","xbutton2_up"
        )]
        [String[]]$Trigger,
        [scriptblock]$Action
    )
    
    begin {
        if($global:Ui.mouse.click.Count -ne 0)
        {
            return
        }
    }
    
    process {
        $trig = $false -in $Trigger.foreach{$_ -in $global:Ui.mouse.click}
        
        if(!$trig)
        {
            # New-UiChar -X 8 -y 5 -text "hey"
            try{
                $Action.Invoke()
            }
            catch{
                throw $_
            }
        }
    }
    
    end {
        
    }
}