#LogStream:S-base
<#
.SYNOPSIS
Sets the name of the UI

.DESCRIPTION
Sets the name of the UI. Will be used to define log names, but could possibly be used for other stuff in the future as well

.PARAMETER Name
what do you want the ui to be called?
Excluded characters: ':'
Length: 1 to 10 chars

.EXAMPLE
Set-UiSettingName "UiMcUiface"
#>
function Set-UiSettingName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [ValidateLength(1,10)]
        [String]$Name
    )
    
    begin {
        #TODO Add more name checks?
        $NotAllowedchar = @(
            ":"
        )
        foreach($char in $NotAllowedchar)
        {
            if($name -like "*$char*")
            {
                $msg = "Name cannot contain '$char'"
                Write-UiLog -message $msg -severity Error
                Throw $msg
            }
        }
    }
    
    process {
        $Global:Ui.Settings.Name = $Name
    }
    
    end {
        
    }
}