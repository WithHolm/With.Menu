function New-MenuMessage {
    [CmdletBinding()]
    [outputtype([with_menu_message])]
    param (
        [object[]]$Message,
        [System.ConsoleColor]$Color,
        [switch]$Wait
    )
    begin {
        
    }
    
    process {
        # $msg = $Message -join ""
        $out = [with_menu_message]::new()
        $out.Message = $Message -join ""
        $out.Name = "Message_$([System.IO.Path]::GetRandomFileName())"
        if($Color)
        {
            $out.Color = $Color
        }
        else{
            $out.Color = $((get-host).ui.rawui.ForegroundColor)
        }
        $out.wait = $Wait.IsPresent
        return $out
    }
    
    end {
        
    }
}