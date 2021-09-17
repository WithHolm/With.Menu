function Get-UiBoundary {
    [CmdletBinding()]
    param (
        [ValidateSet("Left","Right","Top","Bottom")]
        $Position
    )
    
    begin {
        
    }
    
    process {
        switch ($Position) {
            "Top" { return 0 }
            "Bottom" {return ([System.Console]::BufferHeight - 2)}
            "Left" {return 0}
            "Right" {return ([System.Console]::BufferWidth - 2)}
            Default { return 0}
        }
    }
    
    end {
        
    }
}