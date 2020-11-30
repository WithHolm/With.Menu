function Get-FilterHash {
    [CmdletBinding()]
    param (
        [System.Collections.Generic.List[With_menu_filter]]$Filter,
        [string]$RunID
    )
    $return = @{}
    # Write-Verbose "Invoking filters"
    $script:RunID = $RunID
    $filter|%{
        $Test = Invoke-Scriptblock -InputItem $_.filter -Identificator "$_`:[Test]"
        Write-Verbose "$_ returned $test"
        $return.($_.name) = [boolean]::Parse($Test)
        # Write-Verbose "$_`:$($usingFilter.($_.name))"
    }
    return $return
}