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
        #Init status object
        $Status = [with_Menu_Status]::new()
    }
    
    process {
        $Status.name = $Name
        $Status.action = $action

        #if status is a boolean, set statustype 
        if($Boolean)
        {
            $Status.statustype = [with_StatusType]::KeyBool
        }
        else {
            $Status.statustype = [with_StatusType]::KeyVal
        }
        
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