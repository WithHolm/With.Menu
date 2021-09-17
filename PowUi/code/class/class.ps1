class UiChar {
    [string]$type = $this.GetType().Name
    [string]$UiKey = ""
    [int]$Y
    [int]$X
    [bool]$ShouldDelete = $false
    [System.ConsoleColor]$BackgroundColor = ([console]::BackgroundColor)
    [System.ConsoleColor]$TextColor = ([console]::ForegroundColor)
    [string]$Value
    [string]$Id
    [int]$State
    [int]$InitState
    [System.Int64]$AddedMs
    
    UiChar() {}

    UiChar([int]$X, [int]$Y, [String]$Value) {
        $This.InitState = 1
        $this.Value = $Value
        $this.init($x, $y)
    }
    UiChar([int]$X, [int]$Y, [String]$Value,[System.ConsoleColor]$BackgroundColor,[System.ConsoleColor]$TextColor) {
        $This.InitState = 1
        $this.Value = $Value
        $this.init($x, $y)
        $this.TextColor = $TextColor
        $this.BackgroundColor = $BackgroundColor
    }

    init([int]$X, [int]$Y) {

        $this.x = $x|Assert-XyPosition -Dimention x
        $this.y = $y|Assert-XyPosition -Dimention y
        $this.AddedMs = [datetime]::Now.Ticks / 10000
        $this.State = $this.InitState
        $this.GenerateId()
        $this.ShouldDelete = $false
    }

    [string]ToString() {
        return ("[$($this.Id)]State:" + $this.State)
    }

    SetUiKey([String]$Key)
    {
        $this.UiKey = $Key
        $this.GenerateId()
    }

    GenerateId()
    {
        $this.Id = @(
            $this.type,
            $this.x,
            $this.Y,
            $this.UiKey?$this.UiKey:$this.Value
        ) -join "-"
    }

    [bool]IsMatch([int]$X, [int]$Y, [string]$Text) {
        if ($y -eq $this.y -and $x -eq $this.X -and $this.text) {
            return $true
        }
        return $false
    }

    [void]Cleanup() {
        $this.Write((" " * $this.value.Length))
        # $coords = $this.Coords()
        # [console]::ResetColor()
        # [System.Console]::SetCursorPosition(
        #     ($coords.X), 
        #     $coords.Y
        #     )
        # [System.Console]::Write((" " * $this.value.Length))

    }

    [void] Reset() {
        $this.init($this.x, $this.Y)
    }

    [void] Write() {
        $this.Write($this.Value)
    }

    [System.Drawing.Point]Coords()
    {
        $_x = $this.x
        $_y = $this.Y
        # $coords = [System.Drawing.Point]::new($_x,$_y)

        $YBoundary = (Get-UiBoundary -Position Right)
        if ($_x -ge $YBoundary) {
            $_x = $YBoundary
        }
        elseif ($_x -lt 0) {
            $_x = 0
        }

        $YBoundary = (Get-UiBoundary -Position Bottom)
        if ($_y -ge $YBoundary) {
            $_y = $YBoundary
        }
        elseif ($_y -lt 0) {
            $_y = 0
        }
        return ([System.Drawing.Point]::new($_x,$_y))
    }

    [void] Write([String]$Value) {
        $coords = $this.Coords() 
        $colorchange = $false
        if($this.State -ne 0)
        {
            if([console]::BackgroundColor -ne $this.BackgroundColor)
            {
                $colorchange = $true
                [console]::BackgroundColor = $this.BackgroundColor
            }
            if([console]::ForegroundColor -ne $this.TextColor)
            {
                $colorchange = $true
                [console]::ForegroundColor = $this.TextColor
            }
            [console]::ForegroundColor = $this.TextColor
        }
        else {
            [console]::ResetColor()
        }
        [System.Console]::SetCursorPosition(
            ($coords.X|Assert-XyPosition -Dimention x), 
            ($coords.Y|Assert-XyPosition -Dimention y)
        )
        [System.Console]::Write($Value)
        if($colorchange){
            [console]::ResetColor()
        }
    }

    Update([string]$text) {
        $this.Write()
        $this.State--
    }

    Update() {
        $this.Write()
        $this.State--
    }
}

class UiCharAnimated:UiChar {
    [string[]]$Frames
    # how many frames a second do you want?
    [double]$speed = 10
    [int]$State = 0
    [int]$TimeLength = 1000

    # 0 = dont; -1 = infinate; all others: reset from state 0 to initstate and remove 1 from loop
    [int]$Loop = 0

    UiCharAnimated() {

    }

    InitAnimate([int]$X, [int]$Y, [string[]]$Frames, [double]$Speed, [int]$TimeLength, [int]$loop){
        $This.InitState = $Frames.count
        $this.Frames = $Frames
        $this.value = $this.Frames[-1]
        $this.speed = $Speed
        $this.TimeLength = $TimeLength
        $this.Loop = $loop
        $this.init($x, $y)
    }

    #Init by setting x,y and all the frames. will use the default speed for this object
    UiCharAnimated([int]$X, [int]$Y, [string[]]$Frames, [int]$loop) {
        $this.InitAnimate($x,$y,$Frames,$this.speed,$this.TimeLength,$loop)
        # $this.InitAnimate()
        # $This.InitState = $Frames.count
        # $this.value = $this.Frames[-1]
        # $this.Frames = $Frames
        # $this.init($x, $y)
    }

    #init by setting the frames and the speed you want
    UiCharAnimated([int]$X, [int]$Y, [string[]]$Frames, [double]$Speed,[int]$loop) {
        $this.InitAnimate($x,$y,$Frames,$speed,$this.TimeLength,$loop)
        # $This.InitState = $Frames.count
        # $this.Frames = $Frames
        # $this.value = $this.Frames[-1]
        # $this.speed = $Speed
        # $this.TimeLength = 1000
        # $this.init($x, $y)
    }

    #init by setting chars/second and how many seconds.
    UiCharAnimated([int]$X, [int]$Y, [string[]]$Frames, [double]$Speed, [int]$TimeLength,[int]$loop) {
        $this.InitAnimate($x,$y,$Frames,$speed,$TimeLength,$loop)
        # $This.InitState = $Frames.count
        # $this.Frames = $Frames
        # $this.value = $this.Frames[-1]
        # $this.speed = $Speed
        # $this.TimeLength = $TimeLength
        # $this.init($x, $y)
    }

    [string]ActiveFrame() {
        return $this.frames[($this.state - 1)]
    }

    Update() {
        <#
            get how many ms the diffs should be
            get current time in ms
            get diff
        #>

        #how often should i update? gives a int of Ms
        $UpdateFrequency = $this.TimeLength / $this.speed
        [int64]$NowMs = [datetime]::Now.Ticks / 10000
        [int64]$TimeSinceLastCharUpd = $NowMs - $this.AddedMs

        #if the time since i last updated is equal or more than how often i should update, run.
        if ($TimeSinceLastCharUpd -ge $UpdateFrequency) {
            $this.state--
            $this.AddedMs = [datetime]::Now.Ticks / 10000
            $_Val = $this.ActiveFrame()
            $this.Value = $_Val
            $this.Write()
        }

        #reset status if loop is defined
        if (($this.State -eq 0) -and ($this.Loop -ne 0))
        {
            $this.State = $this.InitState
            if($this.Loop -gt 0)
            {
                $this.Loop--
            }
        }
    }
}