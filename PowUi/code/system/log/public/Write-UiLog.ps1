function Write-UiLog {
    [CmdletBinding()]
    param (
        $message,
        [ValidateSet(
            "Trace",
            "Debug",
            "Verbose",
            "Information",
            "Warning",
            "Error"
        )]
        [String]$severity,
        $stream
    )
    
    begin {
        if(!$stream)
        {
            $Caller = (Get-PSCallStack)[1].Command
            $Stream = $Global:Ui.Log.StreamMap[$Caller]
            if(!$stream)
            {
                $stream = "Application"
            }
        }
    }
    
    process {
        $logfile = "$env:TEMP\log\$streamname.log"

        $logfile
    }
    
    end {
        
    }
}