function New-MenuChoice {
    [CmdletBinding()]
    # [outputtype([with_Menu_Choice])]
    param (
        [parameter(mandatory)]
        [String]$Name,
        [string]$description,
        [parameter(mandatory)]
        $action
    )
    
    begin {
        $out = [with_Menu_Choice]::new()
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