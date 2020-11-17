function New-Divideline {
    [CmdletBinding()]
    [Outputtype([With_menu_LineItem])]
    param (
        [string]$DivideLine = ""
    )
    
    begin {
        
    }
    
    process {
        $return = [With_menu_LineItem]::new()
        $return.Text = $DivideLine
        $return.type = "Divideline"
        return $return
    }
    
    end {
        
    }
}