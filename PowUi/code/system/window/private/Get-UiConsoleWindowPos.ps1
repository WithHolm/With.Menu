#LogStream:SSetup
Function Get-UiConsoleWindowPos {
    [OutputType([RECT])]
    param()

    if ($env:TERM_PROGRAM -eq 'vscode') {
        throw "Cannot find the window when process is running under vscode"
    }

    $ThisProc = Get-Process -Id $PID


    $Rectangle = New-Object RECT
    $Handle = $ThisProc.MainWindowHandle

    if($Handle -eq 0)
    {
        if ($env:TERM_PROGRAM -eq 'vscode') {
            throw "Cannot find the window handle when process is running under vscode. hopefully i will figure this out later"
        }
        else {
            throw "Cannot find the handle for this window (the identity windows uses to identify the actual application frame)."
        }
    }
    
    $CanGetRect = [Window]::GetWindowRect($Handle, [ref]$Rectangle)
    if (!$CanGetRect) {

        throw "Could not get the the position of window"
    }
    $TopOffset = (@(
            [Windows.Forms.SystemInformation]::CaptionHeight,
            [Windows.Forms.SystemInformation]::HorizontalResizeBorderThickness,
            [Windows.Forms.SystemInformation]::Border3DSize.Height
        ) | Measure -Sum).sum

    #Assign sum to all three variables
    $BottomOffset = $RightOffset = $LeftOffset = (@(
            [Windows.Forms.SystemInformation]::VerticalResizeBorderThickness,
            [Windows.Forms.SystemInformation]::Border3DSize.Width
        ) | Measure -Sum).sum

    #if there is a scrollbar on the right
    if ([console]::bufferheight -gt [console]::windowheight) {
        $RightOffset -= [Windows.Forms.SystemInformation]::HorizontalScrollBarThumbWidth;
    }

    #if there is a scrollbar in the bottom
    if ([console]::bufferwidth -gt [console]::windowwidth) {
        $BottomOffset -= [Windows.Forms.SystemInformation]::VerticalScrollBarThumbHeight;
    }

    #Append offsets to rectangle
    $Rectangle.Bottom -= $BottomOffset
    $Rectangle.Top += $TopOffset
    $Rectangle.Left += $LeftOffset
    $Rectangle.Right += $RightOffset

    return $Rectangle
}