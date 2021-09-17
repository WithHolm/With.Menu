function Assert-XyPosition {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [int]$Value,

        [parameter(Mandatory)]
        [ValidateSet("x","y")]
        [String]$Dimention
    )
    
    begin {
        $abs = switch ($Dimention) {
            "x" { (Get-UiBoundary -Position Right) }
            "y" { (Get-UiBoundary -Position Bottom) }
        }
    }
    
    process {
        if($Value -ge $abs)
        {
            return $absX
        }
        return $Value
    }
    
    end {
        
    }
}