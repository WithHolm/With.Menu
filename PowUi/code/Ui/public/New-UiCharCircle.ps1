using namespace System.Collections.Generic
using namespace System.Drawing
using namespace System
function New-UiCharCircle {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [int]$X,
        [ValidateNotNullOrEmpty()]
        [int]$Y,
        [ValidateNotNullOrEmpty()]
        [int]$Radius,

        [string]$Character = "x",

        [parameter(
            HelpMessage = "How many points per circle? larger = more detailed and slow"
        )]
        [ValidateNotNullOrEmpty()]
        [int]$points = 4,

        [switch]$Passthru
    )
    
    begin {

    }
    
    process {
        $steps = 360 / $points


        #how many ponints around the circle do you want to 
        # $step = 0.2 #1/($radius+0.1)

        #add processed array so i dont send several chars to the same xy
        $processed = [List[Point]]::new()

        $CircPointX = $x + ($Radius * [Math]::Cos(0))
        $CircPointY = $y + ($Radius * [Math]::Sin(0))

        $OldPoint = [Point]::new($CircPointX, $CircPointY)
        # $processed.Add($OldPoint)
        for ($i = $steps; $i -lt 360; $i += $steps) {

            #Get cords of new point
            $CircPointX = $x + ($Radius * [Math]::Cos($i))
            $CircPointY = $y + ($Radius * [Math]::Sin($i))
            $Point = [Point]::new($CircPointX, $CircPointY)
            Write-Verbose "Circle point $Point"

            #Get line from old to current point
            (Get-UiLinePlot -start $OldPoint -end $Point).where{
                -not $processed.Contains($_)
            }.foreach{
                $processed.Add($_)
            }
            #set point as old point
            $OldPoint = $Point
            # Start-Sleep -Milliseconds 500
        }

        $processed.ForEach{
            New-UiChar -X $_.x -Y $_.y -Text $Character
        }
        # if($Passthru)
        # {
        #     $processed
        # }
    }
    
    end {
        
    }
}