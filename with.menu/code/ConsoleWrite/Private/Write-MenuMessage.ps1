function Write-MenuMessage {
    [CmdletBinding()]
    param (
        [string]$message,
        [System.ConsoleColor]$Color
    )
    
    begin {
        
    }
    
    process {
        $param = @{
            message = $message
        }
        if($Color)
        {
            $param.color = $Color
        }
        $msg = New-MenuMessage @param
        $writer = [With_Menu_Writer]::new()
        $writer.Add((Invoke-MenuMessage -Message $msg))
        Write-Menu -writer $writer
    }
    
    end {
        
    }
}