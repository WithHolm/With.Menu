function Request-MenuFilters {
    [CmdletBinding()]
    [outputtype([with_menu_filter])]
    param (
        [array]$Array
    )
    $Array|?{$_ -is [with_menu_filter]}|%{
        Write-verbose "found $_"
        # $_.value = Invoke-Scriptblock -InputItem $_.filter -Identificator $_.tostring()
        Write-Output $_
    }
}