#LogStream:SSetup
function Get-AllWindows {
    [CmdletBinding()]
    param (
    )
    
    begin { 
    }
    
    process {
        [Window]::GetWindows()|%{
            #Id referenced by windows api
            $hWnd = $_


            #window name
            $sb = [System.Text.StringBuilder]::new(1024) 
            [void]([WndSearcher]::GetWindowText($hWnd,$sb,$sb.Capacity) -ne 0)
            

            #window class
            $sb2 = [System.Text.StringBuilder]::new(1024) 
            [void]([WndSearcher]::GetClassName($hWnd,$sb2,$sb2.Capacity))
            

            #cordinates of window rectangle on screen
            $rect = New-Object RECT;
            [void]([Window]::GetWindowRect($hWnd, [ref]$Rect))
            

            Write-output ([pscustomobject]@{
                hWnd = $hWnd
                name = $sb.ToString() 
                rect = $rect
                class = $sb2.ToString() 
            })
        }
    }
    
    end {
        
    }
}