function Get-UiLinePlot {
    [CmdletBinding()]
    param (
        [System.Drawing.Point]$start,
        [System.Drawing.Point]$end
    )
    
    begin {
        Write-Verbose "Line from $start to $end"
        #https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
        $LineBuffer = [System.Collections.Generic.List[System.Drawing.Point]]::new()
        $x0 = $start.X
        $y0 = $start.Y
        $x1 = $end.x
        $y1 = $end.Y
    }
    
    process {

        $dx = [System.Math]::Abs($x1 - $x0)
        
        # Step of x.. should it move right or left?
        $sx = -1
        if($x0 -lt $x1)
        {
            $sx = 1
        }
        elseif($x0 -eq $x1)
        {
            $sx = 0
        }

        $dy = -([System.Math]::Abs($y1 - $y0))

        # Step of y.. should it move up or down?
        $sy = -1
        if($y0 -lt $y1)
        {
            $sy = 1
        }
        elseif($y0 -eq $y1)
        {
            $sy = 0
        }

        $err = $dx+$dy

        :lineLoop while ($true) {
            $Point = [System.Drawing.Point]::new($x0,$y0)
            Write-Verbose "$Point, Err is $err"
            $LineBuffer.Add($Point)
            if($x0 -eq $x1 -and $y0 -eq $y1)
            {
                break :lineLoop
            }
            $e2 = 2*$err
            if($e2 -ge $dy)
            {
                $err+=$dy
                $x0+=$sx
            }
            if($e2 -le $dx)
            {
                $err+=$dx
                $y0 += $sy
            }
            # Start-Sleep -Milliseconds 500
        }
    }
    
    end {
        return $LineBuffer
    }
}

# $param = @{
#     start = [System.Drawing.Point]::new(0,15)
#     end = [System.Drawing.Point]::new(4,10)
# }
# Get-UiPointLine @param -Verbose