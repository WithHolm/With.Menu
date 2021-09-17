function Write-UiStatistics {
    [CmdletBinding()]
    param (
        [switch]$Enabled,
        [int]$X = 3,
        [int]$Y = 0
    )
    
    begin {
        
    }
    
    process {
        if ($Enabled) {
            $StatisticTextDiff = 0
            $statPad = 6
            $keys = $global:Ui.statistics.Keys|%{"$_"} #(Get-UiStatistics).keys
            $keys | % {
                if($global:Ui.Statistics.$_ -isnot [string])
                {
                    $val = [math]::Round($global:Ui.Statistics.$_).tostring().padleft($statPad, "0")
                }
                else {
                    $val = $global:Ui.Statistics.$_ 
                }
                $StatToScreen = ($_, $val) -join ":"

                $Xdiff = ($X + $StatisticTextDiff)
                $Statparam = @{
                    y = $Y
                    x = $Xdiff
                    text = $StatToScreen
                    BackgroundColor = "red"
                    TextColor = "black"
                    Key = "stat_$_"
                }
                New-UiChar @Statparam
                $StatisticTextDiff += $StatToScreen.Length + 1
            }
        }
    }
    
    end {
        
    }
}