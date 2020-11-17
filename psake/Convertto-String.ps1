function Convertto-String {
    [CmdletBinding()]
    [Outputtype([string])]
    param (
        $value
    )
    
    begin {
        
    }
    
    process {
        if($value -is [bool] -or $value -is [enum])
        {
            return "`$$value"
        }
        elseif($value -is [string])
        {
            return """$value"""
        }
        elseif($value -is [int])
        {
            return "$value"
        }
        else {
            Throw "Havent added $($value.gettype()) yet"
        }
    }
    
    end {
        
    }
}