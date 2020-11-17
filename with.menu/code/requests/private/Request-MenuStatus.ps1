function Request-MenuStatus {
    [CmdletBinding()]
    [Outputtype([with_menu_status])]
    param (
        [array]$Array
    )
    
    begin {
        
    }
    
    process {
        $Array|?{$_ -is [with_Menu_status]}|%{
            Write-verbose "Found $_"
            write-output $_
        }
    }
    
    end {
        
    }
}