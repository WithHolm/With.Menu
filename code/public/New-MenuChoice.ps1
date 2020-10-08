function New-MenuChoice {
    [CmdletBinding()]
    param (
        [parameter(mandatory)]
        [String]$Name,
        [string]$description,
        [parameter(mandatory)]
        $action
    )
    
    begin {
        $out = [MenuChoice]::new()
    }
    
    process {
        $out.name = $Name
        $out.description = $description
        $out.action = $action
        $out.id = $Name
        return $out
    }
    
    end {
        
    }
}