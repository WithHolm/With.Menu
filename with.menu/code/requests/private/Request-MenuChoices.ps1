function Request-MenuChoices {
    [CmdletBinding()]
    [Outputtype([with_Menu_Choice],[with_Menu])]
    param (
        [array]$Array
    )
    
    $Array|?{$_ -is [with_Menu_Choice] -or $_ -is [with_Menu]}|%{
        if($_ -is [with_menu])
        {
            $_.isroot = $false
        }
        Write-verbose "$_"
        Write-Output $_
    }
}