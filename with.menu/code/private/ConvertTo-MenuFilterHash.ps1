<#
.SYNOPSIS
returns a hashtable of filters from current list of filters

.DESCRIPTION
Invokes all of the filters in the specified 

.PARAMETER Filter
Parameter description

.PARAMETER RunID
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function ConvertTo-MenuFilterHash {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [System.Collections.Generic.List[With_menu_filter]]$Filter,
        [string]$RunID
    )
    begin{
        $return = @{}
        $script:RunID = $RunID
    }
    Process{
        $filter|%{
            $Test = Invoke-Scriptblock -InputItem $_.filter -Identificator "$_`:[Test]"
            Write-Verbose "$_ returned $test"
            $return.($_.name) = [boolean]::Parse($Test)
        }
    }
    end{
        return $return

    }
}