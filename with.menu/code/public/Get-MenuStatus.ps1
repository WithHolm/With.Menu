function Get-MenuStatus {
    [CmdletBinding()]
    [outputtype([bool])]
    param (
        [string]$Name,
        [switch]$wildcard,
        $ExpectedValue = $true
    )
    
    begin {
        
    }
    
    process {
        try{ 
            if([string]::IsNullOrEmpty($Script:runid))
            {
                $Script:runid = [guid]::NewGuid().Guid
                Write-Verbose "Generating new runID for status invocation: $Script:runid"
            }

            $Status = ($Script:currentmenu.Status.Where{
                if($wildcard)
                {$_.name -like $Name}
                else
                {$_.name -eq $Name}
            })

            $statusname = "$($Script:runid)_$status"

            if($global:_Statuses|?{$_.statusname -eq $statusname})
            {
                $using = $global:_Statuses|?{$_.statusname -eq $statusname}
            }
            else {
                $using = @{
                    StatusName = $statusname
                    StatusValue = $Status.GetActionString()
                }
                $global:_Statuses = $using
            }
            Write-Verbose ($using|convertto-json -compress)

            if($using.StatusValue -eq $ExpectedValue)
            {
                $true
            }
            else {
                $false
            }
        }
        catch{
            return $false
        }
    }
    
    end {
        
    }
}