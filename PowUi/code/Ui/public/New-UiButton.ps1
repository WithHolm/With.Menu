function New-UiButton {
    [CmdletBinding()]
    param (
        [int]$X,
        [int]$Y,
        [ValidateRange(3, 999)]
        [int]$Width = 3,
        [ValidateRange(3, 999)]
        [int]$Height = 3,
        [string]$Text
    )
    
    begin {
        if ($Text) {
            $Width = $text.Length + 2
        }
    }
    
    process {
        # $map = @{
        #     #right side
        #     rs  = "|"
        #     #right upper corner
        #     ruc = "o"
        #     #right lower corner
        #     rlc = "o"

        #     #left side
        #     ls  = "|"
        #     #left upper corner
        #     luc = "o"
        #     #left lower corner
        #     llc = "o"

        #     #top
        #     t   = "=" 
        #     #bottom
        #     b   = "=" 
        # }
        # $map2 = @{
        #     top    = "o-o"
        #     middle = "| |"
        #     bottom = "o-o"
        # }

        # #top of button
        # $ta = $map2['top']
        # New-UiChar -X $x -y $y -Text @($ta[0], ($ta[1].ToString() * $($Width - 2)), $ta[2]) -join ""

        # #middle
        # $mid = $map2['middle']
        # New-UiChar -X $x -y ($y + 1) -Text @($mid[0], $Text, $mid[2]) -join ""

        # #bottom
        # $bot = $map2['bottom']
        # New-UiChar -X $x -y ($y + 2) -Text @($bot[0], ($bot[1].ToString() * $($Width - 2)), $bot[2]) -join ""
    }
    
    end {
        
    }
}