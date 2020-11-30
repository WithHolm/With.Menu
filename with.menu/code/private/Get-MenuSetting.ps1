function Get-MenuSetting {
    [CmdletBinding()]
    [Outputtype([With_menu_setting])]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        return [With_menu_setting]::GetGlobal()
    }
    
    end {
        
    }
}