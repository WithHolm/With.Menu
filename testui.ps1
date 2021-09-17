class UiChar {
    [int]$Y
    [int]$X
    [string]$Value
    [int]$State = 0
    [int]$InitState = 0
    [System.Int64]$AddedMs
    
    UiChar(){}

    init([int]$X, [int]$Y) {
        $this.x = $x
        $this.y = $y
        $this.AddedMs = [datetime]::Now.Ticks / 10000
        $this.State = $this.InitState
    }

    UiChar([int]$X, [int]$Y, [String]$Value) {
        $This.InitState = 1
        $this.Value = $Value
        $this.init($x, $y)
    }

    [bool]IsMatch([int]$X, [int]$Y, [string]$Text) {
        if ($y -eq $this.y -and $x -eq $this.X -and $this.text) {
            return $true
        }
        return $false
    }

    [void]Cleanup() {
        $this.Value = (" " * $this.value.Length)
        $this.Write()
    }

    [void] Reset() {
        $this.init($this.x, $this.Y)
        # $this.State = $this.InitState
    }

    [void] Write() {
        [System.Console]::SetCursorPosition($This.X, $this.Y)
        [System.Console]::Write($this.Value)
    }

    [UiChar] Update() {
        $this.Write()
        $this.State--
        return $this
    }
}

class UiCharAnimated:UiChar{
    [string[]]$Buff
    [double]$speed

    #speed = how many charupdates per second?
    UiCharAnimated([int]$X, [int]$Y, [string[]]$Value, [double]$Speed) {
        $This.InitState = $Value.count
        $this.Buff = $Value
        $this.value = $this.Buff[-1]
        # $this.init($x, $y)
    }

    [UiChar] Update() {
        <#
            get how many ms the diffs should be
            get current time in ms
            get diff
        #>
        $UpdateFrequency = 1000/$this.speed
        [int64]$NowMs = [datetime]::Now.Ticks / 10000
        [int64]$TimeSinceLastCharUpd = $NowMs-$this.AddedMs
        if($TimeSinceLastCharUpd -gt $UpdateFrequency)
        {
            $this.Value = $this.Buff[($this.State-1)]
            $this.Write()
            $this.State--
        }
        return $this
    }
}


$Value = @("˖","∙","•","ᴥ","*","ѻ","҉","o","҈","Ѻ",,"Ο")
$Out = [UiCharAnimated]::new(1,1,$Value,4)
$Out