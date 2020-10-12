function New-MenuStatus {
    [CmdletBinding()]
    param (
        [parameter(mandatory)]
        [String]$Name,
        [with_StatusType]$Statustype,
        [parameter(mandatory)]
        $action,
        [switch]$Colour,
        $line = 0
    )
    
    begin {
        $out = [with_Menu_Status]::new()
    }
    
    process {
        $out.name = $Name
        $out.description = ""
        $out.action = $action
        $out.id = $Name
        $out.statustype = $Statustype
        $out.line = $line
        $out.colour = $Colour.IsPresent
        return $out
    }
    
    end {
        
    }
}