function Request-MenuMessage {
    [CmdletBinding()]
    [Outputtype([with_menu_Message])]
    param (
        [array]$Array
    )
    
    begin {
        
    }
    
    process {
        $Array|?{$_ -is [with_Menu_Message]}|%{
            Write-verbose "Found $_"
            write-output $_
        }
    }
    
    end {
        
    }
}