function New-UiCharLine {
    [CmdletBinding()]
    param (
        [String]$Text,
        [ValidateSet("underscore", "dash", "block_full", "block_left_half")]
        [string]$TextTemplate,
        [System.Drawing.Point]$start,
        [System.Drawing.Point]$end
    )
    
    begin {
        $Template = @{
            underscore       = "_"
            dash             = "-"
            block_full       = [char]0x2588
            block_left_half  = [char]0x258C
            block_right_half = [char]0x2590
        }
    }
    
    process {


        if($TextTemplate)
        {
            $Text = $Template[$TextTemplate]
        }

        Get-UiLinePlot -start $start -end $end|%{
            New-UiChar -Y $_.y -X $_.x -Text $Text
        }
    }
    
    end {
        
    }
}