function New-MenuStatus {
    [CmdletBinding()]
    param (
        [parameter(mandatory)]
        [String]$Name,
        [with_StatusType]$Statustype,
        [parameter(mandatory)]
        $action,
        [switch]$Boolean,
        [System.ConsoleColor]$Color = ((get-host).ui.rawui.ForegroundColor),
        $line = 0
    )
    
    begin {
        $out = [with_Menu_Status]::new()
    }
    
    process {
        $out.name = $Name
        $out.description = ""
        $out.action = $action
        # $out.id = $Name
        $out.statustype = $Statustype
        $out.line = $line
        $out.Boolean = $Colour.IsPresent
        $out.color = $Color
        return $out
    }
    
    end {
        
    }
}