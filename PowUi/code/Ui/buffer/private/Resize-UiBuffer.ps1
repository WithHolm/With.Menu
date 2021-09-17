function Resize-UiBuffer {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        $SW = [System.Diagnostics.Stopwatch]::StartNew()
        $global:Ui.buffer.where{ $_.State -le 0 }.foreach{
            $_.Cleanup()
            $global:ui.buffer.Remove($_)
        }
        Set-UiStatistics -Name cln -Value $sw.ElapsedMilliseconds
        $SW.Stop()
    }
    
    end {
        
    }
}