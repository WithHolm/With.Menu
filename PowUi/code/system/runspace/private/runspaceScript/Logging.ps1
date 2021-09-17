param(
    $PollingInterval = 1000
)


function Start-Logging
{
    param(
        $Interval
    )
    $loggingTimer = new-object Timers.Timer
    $action = {Write-UIlogBackend}
    $loggingTimer.Interval = $Interval
    $null = Register-ObjectEvent -InputObject $loggingTimer -EventName elapsed -Sourceidentifier loggingTimer -Action $action
    $loggingTimer.start()
}

Function Write-UIlogBackend
{
    foreach($QueueName in $Global:Ui.Log.Queues)
    {
        $FileName = "$QueueName`_$($Global:Ui.Log.RunId).log"
        $LogFile = [System.IO.FileInfo](join-path $Global:Ui.Settings.logPath $FileName)


        if($LogFile.Exists -eq $false)
        {
            [void] (New-item -ItemType File -Path $LogFile.FullName -Force)
        }
        # $logFile = New-Item -ItemType File -Name "$($env:COMPUTERNAME)_$([DateTime]::UtcNow.ToString(`"yyyyMMddTHHmmssZ`")).log" -Path $logLocation
        
        $CurrQueue = $Global:Ui.Log.Queues.$QueueName
        if($CurrQueue.IsEmpty -eq $false)
        {
            try{
                $LogWrite = $LogFile.OpenWrite()
                $StreamWrite = [System.IO.StreamWriter]::new($LogWrite,[System.Text.Encoding]::UTF8)
                while (-not $CurrQueue.IsEmpty)
                {
                    $entry = ''
                    $null = $logEntries.TryDequeue([ref]$entry)
                    $StreamWrite.WriteLine($entry)
                }
            }
            finally{
                $StreamWrite.Close()
                $LogWrite.Close()
            }
        }
    }
}

function logging
{
    $sw = $logFile.AppendText()
    while (-not $logEntries.IsEmpty)
    {
        $entry = ''
        $null = $logEntries.TryDequeue([ref]$entry)
        $sw.WriteLine($entry)
    }
    $sw.Flush()
    $sw.Close()
}

$logFile = New-Item -ItemType File -Name "$($env:COMPUTERNAME)_$([DateTime]::UtcNow.ToString(`"yyyyMMddTHHmmssZ`")).log" -Path $logLocation

Start-Logging -Interval $PollingInterval