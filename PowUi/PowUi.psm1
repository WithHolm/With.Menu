using namespace System.Collections.Generic

add-type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

$cSharpFolder = "$PSScriptRoot\code\csharp"
#region Window handler 
Add-Type -TypeDefinition (Get-Content -Raw "$cSharpFolder\windowhandler.cs") -Language CSharp
Add-Type -TypeDefinition (Get-Content -Raw "$cSharpFolder\windowfinder.cs") -Language CSharp
Add-Type -TypeDefinition (Get-Content -Raw "$cSharpFolder\ConsoleHook.cs") -Language CSharp

#region QuickEditFix
$QuickEditMode = add-type -TypeDefinition (Get-Content -Raw "$cSharpFolder\QuickEdit.cs") -Language CSharp

#endregion
#gets all items inside folders named below
"class", "public", "private"| % {
    $Foldername = $_
    gci "$PSScriptRoot/code" -Recurse -File -Filter "*.ps1" | ? { $_.Directory.Name -eq $Foldername } |?{$_.basename -notlike "*.tests"}| % {
        . $_.FullName
    }
}

#Only init if you are the main module, and not sub runspace
if(!$env:InRunspace)
{
    $_sync= @{
        Settings = @{
            logPath = Join-Path $env:TEMP "PowUi/Log"
            Name = "UI"            
        }
        Log = @{
            StreamMap = Get-LogStreamMap
            RunId = [System.DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
            Queues = @{
                "system" = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
            }
        }
        ResetSettings = @{}
        buffer = [System.Collections.ArrayList]::new()
        mouse = @{
            pos = [System.Drawing.Point]::Empty
            click_raw = [System.Windows.Forms.MouseButtons]::None
            click = [System.Collections.ArrayList]::new()
        }
        color = @{
            Background = [console]::BackgroundColor
            Foreground = [console]::ForegroundColor
        }
        statistics = [ordered]@{}
        Events = @{}
        Quit = $false        
    }
    $global:Ui = [System.Collections.Hashtable]::Synchronized($_sync)


    $global:UiRunspaces = @{
        Pool      = [RunspaceFactory]::CreateRunspacePool(1, [int]$env:NUMBER_OF_PROCESSORS + 1)
        Runspaces = @()
    }
    $global:UiRunspaces.Pool.ApartmentState = "MTA"
    $global:UiRunspaces.Pool.Open()
}

if ($env:TERM_PROGRAM -eq 'vscode') {
    Write-warning " The module is loaded, but interractive UI (start-PowUi) will not work with mouse in VsCode as i cannot find the actual console window via Windows API. hopefully i will figure this out some day. please use Pwsh or powershell exe."
}