#LogStream:S-runspace
function Stop-UiRunspace {
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = "Name")]
        [String]$Name,
        [Parameter(ParameterSetName = "All")]
        [switch]$All
    )
    
    begin {
        
    }
    
    process {
        $EndRunspaces = @()

        if($PSCmdlet.ParameterSetName -eq "Name")
        {
            $EndRunspaces += $Name 
        }

        if($PSCmdlet.ParameterSetName -eq "All")
        {
            $global:UiRunspaces.Runspaces|%{
                $EndRunspaces += $_.name
            }
        }

        $global:UiRunspaces.Runspaces|?{
            $EndRunspaces -eq $_.name
        }|%{
            Write-UiLog -severity Information -message "Stopping runspace '$($_.name)'"
            $_.pipe.EndStop($_.pipe.BeginStop($null,$_.status))
            # $ps.EndStop($ps.BeginStop($null,$asyncObject))
        }
    }
    
    end {
        
    }
}