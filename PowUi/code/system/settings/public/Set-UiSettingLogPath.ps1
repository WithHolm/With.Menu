#LogStream:S-base
<#
.SYNOPSIS
Set Logpath for UI

.DESCRIPTION
Set Logpath for UI. This will create all log files for the current session in this logfolder

.PARAMETER Path
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Set-UiSettingLogFolder {
    [CmdletBinding()]
    param (        
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )
    
    begin {
        $item = get-item $Path -ErrorAction SilentlyContinue
        if($item -and $item.PSIsContainer -eq $false)
        {
            throw "Cannot log to path '$path' as there is already a file at that path"
        }
    }
    
    process {
        $Global:Ui.Settings.logPath = $Path
    }
    
    end {
        
    }
}