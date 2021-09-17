function Use-UiMousePosition {
    [CmdletBinding()]
    [outputType([int])]
    param (
        [parameter(ParameterSetName="x")]
        [switch]$x,
        [parameter(ParameterSetName="y")]
        [switch]$y
    )
    
    begin {
        
    }
    
    process {
        if($x)
        {
            return $Global:Ui.mouse.pos.X
        }
        if($y)
        {
            return $Global:Ui.mouse.pos.y
        }
    }
    
    end {
        
    }
}