Class PsLogger
{
    #what stream to use
    [String]$Stream

    #PollingInterval
    [int]$PolTime


    # hidden $_loggingRunspace = [runspacefactory]::CreateRunspace()
    # hidden $_logEntries = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
    # hidden $_processId = $pid
    # hidden $_processName
    # hidden $_logLocation = $env:temp
    # hidden $_fqdn
    # hidden [SyslogFacility]$_facility = [SyslogFacility]::local7
    
    PsLogger([string]$logLocation)
	{
        $this._logLocation = $logLocation
        $this._processName = (Get-process -Id $this._processId).processname
        $comp = Get-CimInstance -ClassName win32_computersystem
        $this._fqdn = "$($comp.DNSHostName).$($comp.Domain)"

        # Add Script Properties for all severity levels
        foreach ($enum in [SyslogSeverity].GetEnumNames()) 
        {
            $this._AddSeverities($enum)
        }

        # Start Logging runspace
        $this._StartLogging()
    }
    
    hidden _LogMessage([string]$message, [string]$severity)
    {
        $addResult = $false
        while ($addResult -eq $false)
        {
            $msg = '<{0}>1 {1} {2} {3} {4} - - {5}' -f ($this._facility*8+[SyslogSeverity]::$severity), [DateTime]::UtcNow.tostring('yyyy-MM-ddTHH:mm:ss.fffK'), $this._fqdn, $this._processName, $this._processId, $message
            $addResult = $this._logEntries.TryAdd($msg)
        }
    }

    hidden _StartLogging()
    {
        $this._LoggingRunspace.ThreadOptions = "ReuseThread"
        $this._LoggingRunspace.Open()
        $this._LoggingRunspace.SessionStateProxy.SetVariable("logEntries", $this._logEntries)
        $this._LoggingRunspace.SessionStateProxy.SetVariable("logLocation", $this._logLocation)
        $cmd = [PowerShell]::Create().AddScript($this.loggingScript)
      
        $cmd.Runspace = $this._LoggingRunspace
        $null = $cmd.BeginInvoke()
    }

    hidden _AddSeverities([string]$propName)
    {
        $property = new-object management.automation.PsScriptMethod $propName, {param($value) $propname = $propname; $this._LogMessage($value, $propname)}.GetNewClosure()
        $this.psobject.methods.add($property)
    }
}