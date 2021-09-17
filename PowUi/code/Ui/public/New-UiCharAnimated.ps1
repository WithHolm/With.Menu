function New-UiCharAnimated {
    param (
        [int]$Y = 0,
        [int]$X = 0,
        [ValidateSet("Star")]
        $Animation,
        [ValidateRange(-1,99)]
        [int]$loopCount = 0,
        [String]$UiKey
    )
    $SW = [System.Diagnostics.Stopwatch]::StartNew()
    Switch ($Animation) {
        "star" {
            $Frames = @("·", "+", "o", "¤", "O", "¤", "+", "·")
            #x,y,the frames to animate,frames/second,how many seconds max,loopcount
            $Out = [UiCharAnimated]::new($x, $y, $Frames, 40, 1000,$loopCount)
        }
    }
    if ($out) {
        if($UiKey)
        {
            $out.UiKey = $UiKey
        }
        if (!($global:Ui.buffer.where{ $_ -is [UiCharAnimated] }.where{ $_.x -eq $x -and $_.y -eq $y })) {
            [void]$global:Ui.buffer.Add($out)
        }
    }
    Set-UiStatistics -Name add -Value $sw.ElapsedMilliseconds -append
}