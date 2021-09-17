#LogStream:SSetup
function Update-UiConsoleBuffer {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        if([System.Console]::BufferHeight -ne [System.Console]::WindowHeight)   
        {
            [System.Console]::BufferHeight = [System.Console]::WindowHeight
        }
    }
    
    end {
        
    }
}