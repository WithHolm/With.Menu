function Add-UiElement {
    [CmdletBinding()]
    param (
        $Element
    )
    
    begin {
        
    }
    
    process {
        $existing = $global:Ui.buffer.where{$_.x -eq $Element.x -and $_.y -eq $Element.y -and $Element.text -eq $_.text}
        if ($existing) {
            # $existing.
            # $index = $global:Ui.buffer.IndexOf($existing)
            # $global:Ui.buffer[$index] = $Element
            # $existing.value = $Text
            # $global:Ui.buffer.Where{$_.id -eq "UiChar-$x-$y-$text"}
            $existing.reset()
        }
        else {
            # $Item = [UiChar]::new($x, $y, $Text,$BackgroundColor,$TextColor)
            [void]$global:Ui.buffer.Add( $Element)
        }
    }
    
    end {
        
    }
}