<#
.SYNOPSIS
Gets mouse position in console seen as char X,Y
#>
Function Get-UiConsoleMousePos {
    [OutputType([System.Drawing.Point])]
    param(
    )
    $ConsoleWindowPos = Get-UiConsoleWindowPos
    $MousePos = Get-UiMousePos
    $BoundaryHeight = (Get-UiBoundary -Position Bottom)
    $BoundaryWidth = (Get-UiBoundary -Position Right)

    if (
        $MousePos.X -ge $ConsoleWindowPos.Left -and
        $MousePos.x -le $ConsoleWindowPos.Right -and 
        $MousePos.Y -gt $ConsoleWindowPos.Top -and 
        $MousePos.Y -lt $ConsoleWindowPos.Bottom
    ) {
        #gets coordinates relative to the active console window
        $MousePos.X = $MousePos.X - $ConsoleWindowPos.Left
        $MousePos.Y = $MousePos.Y - ($ConsoleWindowPos.Top)

        #Gets the max values for Lower the resolution so if fits with the avalible char tiles in the console
        $MaxMouseX = $ConsoleWindowPos.Right - $ConsoleWindowPos.Left
        $MaxMouseY = $ConsoleWindowPos.Bottom - ($ConsoleWindowPos.Top)
        
        #how many mousepixels are in a char tile?
        #todo: is this the correct way? count of chars/total pixels?
        $PixelToCharX = $BoundaryWidth / $MaxMouseX
        $PixelToCharY = $BoundaryHeight / $MaxMouseY

        #gets the correct console char, the mouse pointer sits at
        $MousePos.X = $PixelToCharX * $MousePos.X
        $MousePos.Y = $PixelToCharY * $MousePos.Y

        if ($MousePos.y -gt $BoundaryHeight) {
            $MousePos.y = $BoundaryHeight - 1 
        }
        if ($MousePos.x -ge $BoundaryWidth) {
            $MousePos.x = $BoundaryWidth - 1
        }

        return $MousePos
    }
    else {
        [System.Drawing.Point]::Empty
    }
}