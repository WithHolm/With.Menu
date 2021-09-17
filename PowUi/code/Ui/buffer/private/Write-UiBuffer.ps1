function Write-UiBuffer {
    [CmdletBinding()]
    param ()
    
    begin {
        $SW = [System.Diagnostics.Stopwatch]::StartNew()
    }
    
    process {
        # $written = [System.Collections.ArrayList]::new()
        for ($i = $global:ui.buffer.Count - 1; $i -gt 0; $i--) {
            $this = $global:ui.buffer[$i]
            # $this.tostring()
            [void]($this.update())
            # $thiscoords = "$($this.x)_$($this.y)"
            # if(-not ($written -eq $thiscoords))
            # {
            #     $written += $thiscoords
            # }
        }
        set-UiStatistics -Name wrt -Value $sw.ElapsedMilliseconds
    }
    
    end {
        $SW.Stop()
    }
}