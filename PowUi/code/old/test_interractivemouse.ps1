using namespace System.Collections.Generic
using namespace System.Drawing
add-type -AssemblyName System.Drawing
$global:buffer = [System.Collections.ArrayList]::new()
Add-Type -AssemblyName System.Windows.Forms
$ErrorActionPreference = "stop"
# add-type -AssemblyName Windows.Forms
# add-type -AssemblyName "System.Collections.Generic"


# $Script:TickCount = 
#region setup 
Try { 
    [void][Window]
}
Catch {
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Window {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool GetWindowRect(
                IntPtr hWnd, out RECT lpRect);

            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public extern static bool MoveWindow( 
                IntPtr handle, int x, int y, int width, int height, bool redraw);

            [DllImport("user32.dll")] 
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool ShowWindow(
                IntPtr handle, int state);

            [DllImport("kernel32.dll", SetLastError=true)]
            public static extern IntPtr GetConsoleWindow();
    
            [DllImport("kernel32.dll", SetLastError=true)]
            public static extern bool GetConsoleMode(
                IntPtr hConsoleHandle,
                out int lpMode);
    
            [DllImport("kernel32.dll", SetLastError=true)]
            public static extern bool SetConsoleMode(
                IntPtr hConsoleHandle,
                int ioMode);

                /// <summary>
                /// This flag enables the user to use the mouse to select and edit text. To enable
                /// this option, you must also set the ExtendedFlags flag.
                /// </summary>
                const int QuickEditMode = 64;
                
                // ExtendedFlags must be combined with
                // InsertMode and QuickEditMode when setting
                /// <summary>
                /// ExtendedFlags must be enabled in order to enable InsertMode or QuickEditMode.
                /// </summary>
                const int ExtendedFlags = 128;
                
            public void DisableQuickEdit()
            {
                IntPtr conHandle = GetConsoleWindow();
                int mode;
            
                if (!GetConsoleMode(conHandle, out mode))
                {
                    // error getting the console mode. Exit.
                    return;
                }
            
                mode = mode & ~(QuickEditMode | ExtendedFlags);
            
                if (!SetConsoleMode(conHandle, mode))
                {
                    // error setting console mode.
                }
            }
                
            public void EnableQuickEdit()
            {
                IntPtr conHandle = GetConsoleWindow();
                int mode;
            
                if (!GetConsoleMode(conHandle, out mode))
                {
                    // error getting the console mode. Exit.
                    return;
                }
            
                mode = mode | (QuickEditMode | ExtendedFlags);
            
                if (!SetConsoleMode(conHandle, mode))
                {
                    // error setting console mode.
                }
            }
        }

        public struct RECT
        {
            public int Left;        // x position of upper-left corner
            public int Top;         // y position of upper-left corner
            public int Right;       // x position of lower-right corner
            public int Bottom;      // y position of lower-right corner
        }


"@
}
#endregion

#region QuickEditFix
$QuickEditCodeSnippet = @" 
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;


public static class DisableConsoleQuickEdit
{

const uint ENABLE_QUICK_EDIT = 0x0040;

// STD_INPUT_HANDLE (DWORD): -10 is the standard input device.
const int STD_INPUT_HANDLE = -10;

[DllImport("kernel32.dll", SetLastError = true)]
static extern IntPtr GetStdHandle(int nStdHandle);

[DllImport("kernel32.dll")]
static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

[DllImport("kernel32.dll")]
static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

public static bool SetQuickEdit(bool SetEnabled)
{

    IntPtr consoleHandle = GetStdHandle(STD_INPUT_HANDLE);

    // get current console mode
    uint consoleMode;
    if (!GetConsoleMode(consoleHandle, out consoleMode))
    {
        // ERROR: Unable to get console mode.
        return false;
    }

    // Clear the quick edit bit in the mode flags
    if (SetEnabled)
    {
        consoleMode &= ~ENABLE_QUICK_EDIT;
    }
    else
    {
        consoleMode |= ENABLE_QUICK_EDIT;
    }

    // set the new mode
    if (!SetConsoleMode(consoleHandle, consoleMode))
    {
        // ERROR: Unable to set console mode
        return false;
    }

    return true;
}
}

"@

$QuickEditMode = add-type -TypeDefinition $QuickEditCodeSnippet -Language CSharp

function Set-QuickEdit() {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "This switch will disable Console QuickEdit option")]
        [switch]$DisableQuickEdit = $false
    )


    if ([DisableConsoleQuickEdit]::SetQuickEdit($DisableQuickEdit)) {
        # Write-Output "QuickEdit settings has been updated."
    }
    else {
        Write-Output "Something went wrong."
    }
}
#endregion

class UiChar {
    [string]$type = $this.GetType().Name
    [string]$UiKey = ""
    [int]$Y
    [int]$X
    [string]$Value
    [int]$State
    [int]$InitState
    [System.Int64]$AddedMs
    
    UiChar() {}

    UiChar([int]$X, [int]$Y, [String]$Value) {
        $This.InitState = 1
        $this.Value = $Value
        $this.init($x, $y)
    }

    init([int]$X, [int]$Y) {
        $this.x = $x
        $this.y = $y
        $this.AddedMs = [datetime]::Now.Ticks / 10000
        $this.State = $this.InitState
    }

    [string]ToString() {
        return ("[$($this.gettype().name)]St:" + $this.State)
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
        $this.Write($this.Value)
    }
    [void] Write([String]$Value) {
        $_x = $this.x
        $_y = $this.Y
        if ($_x -ge [System.Console]::BufferWidth - 1) {
            $_x = [System.Console]::BufferWidth - 1
        }
        elseif ($_x -lt 0) {
            $_x = 0
        }

        if ($_y -ge [System.Console]::WindowHeight) {
            $_y = [System.Console]::WindowHeight
        }
        elseif ($_y -lt 0) {
            $_y = 0
        }
        [System.Console]::SetCursorPosition($_x, $_y)
        [System.Console]::Write($Value)
    }

    Update() {
        #[UiChar]
        $this.Write()
        $this.State--
        # return $this
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

#Gets position of mouse on desktop
Function Get-MousePos {
    [OutputType([Point])]
    param()
    
    return [System.Windows.Forms.Cursor]::Position
}

#Get position of console window on screen. returns a rect (Left,Top,Right,Bottom)
Function Get-ConsoleWindowPos {
    [OutputType([RECT])]
    param()
    if ($env:TERM_PROGRAM -eq 'vscode') {
        throw "Cannot find windowprocess when process is running under vscode"
    }

    $ThisProc = Get-Process -Id $PID
    $Rectangle = New-Object RECT
    $Handle = $ThisProc.MainWindowHandle
    $CanGetRect = [Window]::GetWindowRect($Handle, [ref]$Rectangle)
    if (!$CanGetRect) {

        throw "Could not get the the position of window"
    }
    $TopOffset = (@(
            [Windows.Forms.SystemInformation]::CaptionHeight,
            [Windows.Forms.SystemInformation]::HorizontalResizeBorderThickness,
            [Windows.Forms.SystemInformation]::Border3DSize.Height
        ) | Measure -Sum).sum

    #Assign sum to all three variables
    $BottomOffset = $RightOffset = $LeftOffset = (@(
            [Windows.Forms.SystemInformation]::VerticalResizeBorderThickness,
            [Windows.Forms.SystemInformation]::Border3DSize.Width
        ) | Measure -Sum).sum

    #if there is a scrollbar on the right
    if ([console]::bufferheight -gt [console]::windowheight) {
        $RightOffset -= [Windows.Forms.SystemInformation]::HorizontalScrollBarThumbWidth;
    }

    #if there is a scrollbar in the bottom
    if ([console]::bufferwidth -gt [console]::windowwidth) {
        $BottomOffset -= [Windows.Forms.SystemInformation]::VerticalScrollBarThumbHeight;
    }

    #Append offsets to rectangle
    $Rectangle.Bottom -= $BottomOffset
    $Rectangle.Top += $TopOffset
    $Rectangle.Left += $LeftOffset
    $Rectangle.Right += $RightOffset

    return $Rectangle
}

#Gets position of mouse while inside console
Function Get-ConsoleMousePos {
    [OutputType([Point])]
    param(
    )
    $ConsoleWindowPos = Get-ConsoleWindowPos
    $MousePos = Get-MousePos

    if (
        $MousePos.X -ge $ConsoleWindowPos.Left -and
        $MousePos.x -le $ConsoleWindowPos.Right -and 
        $MousePos.Y -gt $ConsoleWindowPos.Top -and 
        $MousePos.Y -lt $ConsoleWindowPos.Bottom
    ) {
        #gets coordinates relative to the active console window
        $MousePos.X = $MousePos.X - $ConsoleWindowPos.Left
        $MousePos.Y = $MousePos.Y - ($ConsoleWindowPos.Top)

        #Lower the resolution so if fits with the avalible char tiles in the console
        $MaxMouseX = $ConsoleWindowPos.Right - $ConsoleWindowPos.Left
        $MaxMouseY = $ConsoleWindowPos.Bottom - ($ConsoleWindowPos.Top)
        
        #how many mousepixels are in a char tile?
        #todo: is this the correct way? count of chars/total pixels?
        $PixelToCharX = $Host.ui.RawUI.WindowSize.Width / $MaxMouseX
        $PixelToCharY = $Host.ui.RawUI.WindowSize.Height / $MaxMouseY

        #
        $MousePos.X = $PixelToCharX * $MousePos.X
        $MousePos.Y = $PixelToCharY * $MousePos.Y

        if ($MousePos.y -gt $host.UI.RawUI.WindowSize.Height) {
            $MousePos.y = $host.UI.RawUI.WindowSize.Height - 1 
        }
        if ($MousePos.x -ge $host.UI.RawUI.WindowSize.Width) {
            $MousePos.x = $host.UI.RawUI.WindowSize.Width - 1
        }

        return $MousePos
    }
    else {
        # "Out of bounds"
    }
}

Function Add-ConsoleBuffer {
    param(
        [int]$Line = 0,
        [int]$StartPos = 0,
        $Text
    )
    $SW = [System.Diagnostics.Stopwatch]::StartNew()
    
    $Item = [UiChar]::new($StartPos, $Line, $Text)
    $existing = $global:buffer.where{ $_.x -eq $Item.x -and $_.y -eq $Line }
    if ($existing.value -eq $item.Value) {
        $existing.reset()
    }
    else {
        [void]$global:buffer.Add($item)
    }
    Set-Statistics -Name add -Value $sw.ElapsedMilliseconds -append
}

function New-UiAnimatedChar {
    param (
        [int]$Y = 0,
        [int]$X = 0,
        [ValidateSet("Star")]
        $Animation,
        [ValidateRange(-1,99)]
        [int]$loopCount = 0,
        [String]$UiKey
    )
    $SW = [System.Diagnostics.Stopwatch]::StartNew()
    Switch ($Animation) {
        "star" {
            $Frames = @("·", "+", "o", "¤", "O", "¤", "+", "·")
            #x,y,the frames to animate,frames/second,how many seconds max,loopcount
            $Out = [UiCharAnimated]::new($x, $y, $Frames, 40, 1000,$loopCount)
        }
    }
    if ($out) {
        if($UiKey)
        {
            $out.UiKey = $UiKey
        }
        if (!($global:buffer.where{ $_ -is [UiCharAnimated] }.where{ $_.x -eq $x -and $_.y -eq $y })) {
            [void]$global:buffer.Add($out)
        }
    }
    Set-Statistics -Name add -Value $sw.ElapsedMilliseconds -append
}

Function Write-TextBuffer {
    $SW = [System.Diagnostics.Stopwatch]::StartNew()
    
    # $count = 0
    for ($i = $global:buffer.Count - 1; $i -gt 0; $i--) {
        $global:buffer[$i].update() | Out-Null
        # $global:buffer[$i] = $global:buffer[$i].update()
        # $global:buffer[$i].state = 0
    }
    Set-Statistics -Name wrt -Value $sw.ElapsedMilliseconds
    # $script:Statistics.Write = $sw.ElapsedMilliseconds
    $SW.Stop()
}

Function Limit-Buffer {
    $SW = [System.Diagnostics.Stopwatch]::StartNew()
    # $global:buffer.where{ $_ -isnot [UiChar] } | % {
    #     $global:buffer.Remove($_)
    # }
    $global:buffer.where{ $_.State -le 0 }.foreach{
        # $Char = $_
        # if($global:buffer.where{$_.x -eq $Char.x -and $_.y -eq $Char.y})
        # {
        #     #don't clean up
        # }
        # else {
        # }
        $_.Cleanup()
        $global:buffer.Remove($_)
    }
    Set-Statistics -Name cln -Value $sw.ElapsedMilliseconds
    $SW.Stop()
}

Function Set-QuickEditMode {
    param(
        [ValidateSet("disable", "Enable")]
        $mode
    )

    if ($mode -eq "disable") {
        [Window]::DisableQuickEdit()
    }
    if ($mode -eq "Enable") {
        [Window]::EnableQuickEdit()
    }
}

Function Set-Statistics {
    param(
        [validateset("wrt", "tot", "cln", "buf", "add")]
        [string]$Name,
        [double]$Value,
        [switch]$append,
        [switch]$Clean
    )

    if ($Clean) {
        if ($name) {
            Set-Statistics $Name -Value 0
        }
        else {
            $global:Statistics = @{
                wrt = 0
                tot = 0
                cln = 0
                buf = 0
                add = 0
            }
        }
    }
    elseif ($name -in $global:Statistics.keys) {
        if ($append) {
            $global:Statistics.$name += $Value
        }
        else {
            $global:Statistics.$name = $Value
        }
    }
    else {
        throw "Could not set stat '$name'. its not a part of the defined statistics"
    }
}

Function Get-statistics {
    ($global:Statistics.keys | % {
            $_, $global:Statistics.$_ -join ":"
        }) -join "/"
    
}

Function Set-ConsoleEncoding {
    param()
    dynamicparam {
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        # $ParamAttrib.Mandatory = $true
        $ParamAttrib.ParameterSetName = '__AllParameterSets'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $Encodings = [System.Text.Encoding]::GetEncodings().Name
        # Write-Debug "found $($Encodings.count) encodings"
        # $configurationFileNames = Get-ChildItem -Path 'C:\ConfigurationFiles' | Select-Object -ExpandProperty  Name
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Encodings)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Encoding', [string], $AttribColl)
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Encoding', $RuntimeParam)

        return  $RuntimeParamDic
    }
    begin{

    }
    process {
        $Encoding = $PSBoundParameters.Encoding
        if(!$Encoding)
        {
            $Encoding = "utf-8"
        }

        $UseEncoding = [System.Text.Encoding]::GetEncodings()|Where-Object{$_.Name -eq $Encoding}

        if(!$UseEncoding)
        {
            throw "The encoding '$encoding' cannot be used for console encoding as its not part of 'System.Text.Encoding' on this machine"
        }

        #setting all possible encodings for this console to utf8
        $OutputEncoding = [console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8
    }
    end{

    }
}

Function Remove-UiKeyElements{
    param(
        [string]$UiKey
    )
    $global:buffer|?{$_.uikey -eq $UiKey}|%{$_.state = 0}
}

# WindowPos
Set-ConsoleEncoding -Encoding utf-8
$Script:SleepMs = 0
$script:Oldbuffer = $global:buffer
$OldMousePos = Get-ConsoleMousePos
$OldMousePos.y = -1
[System.Console]::CursorVisible = $false
$OldBuffer = @{}
# $buffer = @{}
$k = $true
$MouseOnScreen = $false
Set-QuickEdit -DisableQuickEdit
Set-Statistics -Clean
# Register-ObjectEvent -
try {

    while ($k -eq $true) {
        $SW = [System.Diagnostics.Stopwatch]::StartNew()
        $CurrentMousePos = Get-ConsoleMousePos
        if ($MouseOnScreen -eq $false -and $null -ne $CurrentMousePos) {
            cls
            $MouseOnScreen = $true
        }
        else {
            $MouseOnScreen = $null -ne $CurrentMousePos
        }
    
        Add-ConsoleBuffer -Line 3 -StartPos 5 -Text $($CurrentMousePos)
        # Add-ConsoleBuffer -Line 1 -StartPos 0 -Text ($global:buffer.where{$_ -is [UiCharAnimated]}|ConvertTo-Json -Compress)
        # Add-ConsoleBuffer -Line 2 -StartPos 5 -Text $($CurrentMousePos)
        # $co = 0
        # 1..10|%{
        #     |%{
        #         Add-ConsoleBuffer -Line (9+$co) -StartPos 0 -Text $_
        #         $co++
        #     }
        # }
        # $k = $global:buffer|?{$_ -is [UiCharAnimated]}|%{"$_"}
        
        # @(0..($global:buffer.count-1))|%{
        #     # [System.Console]::SetCursorPosition(0, $_)
        #     # [System.Console]::Write(($global:buffer[$_]|ConvertTo-Json -Compress))
        #     Add-ConsoleBuffer -Line (7+$_) -StartPos 0 -Text $global:buffer[$_]
        # }
        # Add-ConsoleBuffer -Line 7 -StartPos 5 -Text ($global:buffer.state -join "")
        # Add-ConsoleBuffer -Line 7 -StartPos 5 -Text "$($Host.ui.RawUI.WindowSize)"
        # Add-ConsoleBuffer -Line 8 -StartPos 5 -Text ([System.Windows.Forms.UserControl]::MouseButtons)
    
        if ([System.Windows.Forms.UserControl]::MouseButtons -eq [System.Windows.Forms.MouseButtons]::Left) {
            New-UiAnimatedChar -Y $CurrentMousePos.y -X $CurrentMousePos.x -Animation Star -loopCount 99 -UiKey "Animate_Star"
        }

        if ([System.Windows.Forms.UserControl]::MouseButtons -eq [System.Windows.Forms.MouseButtons]::Right) {
            Remove-UiKeyElements -UiKey "Animate_Star"
            # New-UiAnimatedChar -Y $CurrentMousePos.y -X $CurrentMousePos.x -Animation Star -loopCount -1 -UiKey "Animate_Star"
        }

        # 1..10|get-random|?{$_ -eq 4}|%{
        #     # New-UiAnimatedChar -Y $CurrentMousePos.y -X (0..$Host.UI.RawUI.WindowSize.Width|get-random) -Animation Star
        #     New-UiAnimatedChar -Y $CurrentMousePos.y -X $CurrentMousePos.x -Animation Star
        # }
    

        # if (($OldMousePos -ne $CurrentMousePos -and $null -ne $CurrentMousePos)) {
        #     Add-ConsoleBuffer -Line $CurrentMousePos.Y -Text "*"
        #     Add-ConsoleBuffer -Line 0 -StartPos $CurrentMousePos.X -Text "*"
        #     @(0..($CurrentMousePos.Y)).foreach{
        #         Add-ConsoleBuffer -Line $_ -StartPos $CurrentMousePos.X -Text "|"
        #     }
        #     Add-ConsoleBuffer -Line $CurrentMousePos.Y -StartPos 1 -Text ("=" * $CurrentMousePos.X)
        #     Add-ConsoleBuffer -Line $CurrentMousePos.Y -StartPos $CurrentMousePos.X -Text "*"
        # }
        
        Set-Statistics -Name buf -Value $global:buffer.Count
        

        Add-ConsoleBuffer -Line 5 -StartPos 5 -Text (Get-statistics)



        Limit-Buffer
        Write-TextBuffer
        # Set-Statistics -name add -Clean
        Set-Statistics -Name tot -Value $sw.ElapsedMilliseconds
        # $script:Statistics.Total = $sw.ElapsedMilliseconds
        Start-Sleep -Milliseconds $Script:SleepMs
        # $keypress = [Windows.Forms.KeyPressEventHandler]:: {
        #     if($_.KeyChar -eq [System.Windows.Forms.Keys]::Q)
        #     {
        #         $k = $false
        #     }
        # }
        # Add-ConsoleBuffer -Text ($keypress|ConvertTo-Json -Compress) -StartPos 0 -Line 10
        
        # $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        # if(console)
    }
}
catch {
    Write-Warning $_
    throw $_
}
finally {
    Set-QuickEdit
    # Set-QuickEditMode -mode Enable
    # $ConsolePos = $Host.UI.RawUI.CursorPosition
    # $ConsolePos.X = 0
    # $ConsolePos.Y = 0
    [System.Console]::SetCursorPosition(0, 10)
    [System.Console]::CursorVisible = $true
}


#test to see what character dings
# 0..9999|
#     %{
#         $code = $_.tostring().padleft(4,"0")
#         $sb = [scriptblock]::Create("[char]0x$code")
#         Write-Host "$code`:"($sb.Invoke()) -NoNewline
#         [console]::write($($sb.Invoke()))
#         Start-Sleep -Milliseconds 500
#         Write-host ""
#     }