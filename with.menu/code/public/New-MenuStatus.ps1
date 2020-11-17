function New-MenuStatus {
    [CmdletBinding(DefaultParameterSetName="Boolean")]
    [outputtype([with_Menu_status])]
    param (
        [parameter(mandatory, Position=0)]
        [String]$Name,
        
        [parameter(mandatory, Position = 1)]
        $action,
        
        [parameter(ParameterSetName="Boolean")]
        [switch]$Boolean,
        
        [parameter(ParameterSetName="Color")]
        [System.ConsoleColor]$Color,
        
        $line = 0,

        [string]$FilterName,
        [Boolean]$FilterValue = $true
    )
    
    begin {
        $Status = [with_Menu_Status]::new()
    }
    
    process {
        $Status.name = $Name
        $Status.action = $action
        $Status.statustype = [with_StatusType]::KeyValue
        $Status.line = $line
        $Status.Boolean = $Boolean.IsPresent
        
        if(![string]::IsNullOrEmpty($FilterName))
        {
            $Status.filter = $FilterName
            $Status.FilterValue = $FilterValue
        }

        if($Color)
        {
            $Status.color = $Color
        }
    }
    end {
        return $Status   
    }
}