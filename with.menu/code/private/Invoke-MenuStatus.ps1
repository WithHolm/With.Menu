function Invoke-MenuStatus
{
    [CmdletBinding()]
    [Outputtype([With_Menu_LineItem])]
    param (
        [System.Collections.Generic.List[with_Menu_Status]]$Status
    )
    
    begin{}
    
    process
    {
        $Status | % {
            #KEY
            $Key = [With_menu_LineItem]::new()
            $Key.Text = "$($_.Name): "
            $Key.type = "Status"
            
            
            #VALUE
            $Val = $_.GetActionString()
            $Value = [With_menu_LineItem]::new()
            $Value.Text = $val
            $Value.type = "Status"

            if ($_.Boolean)
            {
                if ([bool]::Parse($val))
                {
                    $Value.color = [System.ConsoleColor]::Green 
                }
                else 
                { 
                    $Value.color = [System.ConsoleColor]::red 
                }
            }
            elseif ($_.Color -ne $((get-host).ui.rawui.ForegroundColor))
            {
                $Value.color = $_.Color
            }

            Write-Output $Key
            Write-Output $Value
        }
    }
    end{}
}