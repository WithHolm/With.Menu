function New-MenuChoice {
    [CmdletBinding()]
    [outputtype([with_Menu_Choice])]
    param (
        [parameter(mandatory,Position=0)]
        [String]$Name,
        # [string]$description,
        [parameter(mandatory,Position=1)]
        $Action,
        [string]$FilterName,
        [Boolean]$FilterValue = $true
    )
    
    begin {
        $Choice = [with_Menu_Choice]::new()
    }
    
    process {
        $Choice.name = $Name
        # $Choice.description = $description
        $Choice.action = $action

        if(![string]::IsNullOrEmpty($FilterName))
        {
            $Choice.filter = $FilterName
            $Choice.FilterValue = $FilterValue
        }
    }
    end {
        return $Choice
    }
}