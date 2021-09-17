<#
.SYNOPSIS
Gets position of mouse on desktop

.DESCRIPTION
Gets position of mouse on desktop

.EXAMPLE
Get-UiMousePos

.NOTES
General notes
#>
Function Get-UiMousePos {
    [OutputType([System.Drawing.Point])]
    param()
    
    return [System.Windows.Forms.Cursor]::Position
}

# [Microsoft.PowerShell.PSConsoleReadLine]::