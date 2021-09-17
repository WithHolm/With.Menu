#LogStream:S-runspace
function Start-UiRunspace {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [scriptblock]$Code,

        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [hashtable]$Parameters
    )
    
    begin {
        Write-UiLog -message "Starting Runspace $name. Parameters: $($Parameters|ConvertTo-Json -Compress)" -severity Information
    }
    
    process {
        #Setup this runspace
        # $Userscript = [scriptblock]::Create((gc "$PSScriptRoot/runspace/userscript.ps1" -Raw))
        $runspace = [PowerShell]::Create()
        $runspace.RunspacePool = $global:UiRunspaces.Pool
        
        #Add script to run and parameters
        [void]$runspace.AddScript($Code)
        if($Parameters)
        {
            #Todo add check of parameters and throw if not correct
            [void]$runspace.AddParameters($Parameters)
        }
        
        #start that shit
        $global:UiRunspaces.Runspaces += [PSCustomObject]@{ 
            Name = $Name
            Pipe   = $runspace
            Status = $runspace.BeginInvoke() 
        }
    }
    
    end {
        
    }
}