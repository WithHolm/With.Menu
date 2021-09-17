Function New-UiChar {
    param(
        [Alias("Line")]
        [int]$Y = 0,
        [Alias("StartPos")]
        [int]$X = 0,
        [String]$Key,
        $Text,
        [System.ConsoleColor]$BackgroundColor = ([console]::BackgroundColor),
        [System.ConsoleColor]$TextColor = ([console]::ForegroundColor)
    )
    $SW = [System.Diagnostics.Stopwatch]::StartNew()

    $Item = [UiChar]::new($x, $y, $Text,$BackgroundColor,$TextColor)
    $item.SetUiKey($Key)

    $existing = $global:Ui.buffer.Id -eq $item.id|select -first 1 # .where{$_.x -eq $item.x -and $_.y -eq $item.y}
    if ($existing) {
        $global:Ui.buffer.Where{$_.id -eq $existing}|%{
            $_.value = $item.Value
            $_.BackgroundColor = $BackgroundColor
            $_.TextColor = $TextColor
            $_.reset()
        }
    }
    else {
        [void]$global:Ui.buffer.Add($item)
    }
    Set-UiStatistics -Name add -Value $sw.ElapsedMilliseconds -append
}