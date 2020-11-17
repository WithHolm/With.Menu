<#
.SYNOPSIS
Returns either a list of strings of items that can be used 
or 
returns a hashtable of filterkeys and results from invokactions

.PARAMETER items
array of with_menu_item items

.PARAMETER filter
list of with_menu_filter or hashtable of already computed filters 

.PARAMETER ReturnFilterHash
returns hashtable of computed filters
#>
function Invoke-MenuFilter {
    [CmdletBinding()]
    param (
        [hashtable]$filterHash,
        $Items
        # [switch]$ReturnFilterHash
    )
    begin {}
    
    process {
        return $items|?{$_ -is [With_Menu_ShowItem]}|?{
            if(![string]::IsNullOrEmpty($_.filter))
            {
                if($filterHash.$($_.filter) -eq $_.FilterValue)
                {
                    return $true     
                }
                else {
                    Write-Verbose "removing $_ because filter '$($_.filter)' returned $($filterHash.$($_.filter)), expected $($_.FilterValue)"
                    return $false
                }
            }
            return $true
        }
    }
    
    end {}
}