function Get-LogStreamMap {
    [CmdletBinding()]
    param (
    )
    
    begin {
        
    }
    
    process {
        $content = gc "$PSScriptRoot/logstreamMap.ini"
        $map = @{}
        $content|%{
            $spl = $_.split("=")
            $map.($spl[0]) = $spl[1]
        }
        return $map
    }
    
    end {
        
    }
}
# Get-LogStreamMap