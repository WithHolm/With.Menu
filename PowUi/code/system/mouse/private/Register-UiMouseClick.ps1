function Register-UiMouseClick {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        
    }
    
    process {
        if ([System.Windows.Forms.UserControl]::MouseButtons -ne [System.Windows.Forms.MouseButtons]::None) {
            [System.Windows.Forms.UserControl]::MouseButtons -split ","|ForEach-Object{
                $button = $_.ToString().ToLower().Trim()
                $clickString = [string]::Join("_", $button, "down")
                if(!$global:Ui.mouse.click.Contains($clickString))
                {
                    [void]$global:Ui.mouse.click.add($clickString)
                }
            }
        }
        else {
            for ($i = 0; $i -lt $global:Ui.mouse.click.Count; $i++) {
                $click = $global:Ui.mouse.click[$i]
                if($click  -like "*_down")
                {
                    $ClickButton = $click.Split("_")[0]
                    $global:Ui.mouse.click[$i] = [string]::Join("_", $ClickButton, "up")
                }
                else {
                    $global:Ui.mouse.click.RemoveAt($i)
                }
            }
        }
    }
    
    end {
        
    }
}