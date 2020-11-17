function Invoke-MenuChoice {
    [CmdletBinding()]
    param (
        [With_Menu_Choice]$Choice,
        [with_menu]$parent
    )
    
    begin {
        
    }
    
    process {
        if($choice.action -is [scriptblock])
        {
            $Writer = [With_Menu_Writer]::new()
            $Msg = [with_menu_lineitem]::new()
            $msg.Text = "Executing '$($choice.name)'"
            $msg.type = "Title"
            $Writer.Add($Msg)
            Write-Menu -writer $Writer #-Settings $parent.Settings

            
            try{
                $choice.action.invoke()|%{
                    $writer.Lines.Clear()
                    # Write-MenuString -Message $_ -settings $parent.settings
                    $Msg = [with_menu_lineitem]::new()
                    $msg.Text = $_
                    $msg.type = "Choice"
                    $Writer.Add($Msg)
                    Write-Menu -writer $Writer #-Settings $parent.Settings
                } 
            }
            catch{
                Write-warning "Error happened when processing option '$($choice.name)'"
                Write-Error -ErrorRecord $_.Exception.InnerException.InnerException.ErrorRecord -RecommendedAction "Fix choice '$($choice.name)'"
            }
            
            # write-host ($usingMenu.WithPadding("End Execution $($selection.name)"))
        }
        else 
        {
            $Writer = [With_Menu_Writer]::new()
            $Msg = [with_menu_lineitem]::new()
            $msg.Text = "Selected '$($choice.name)'"
            $msg.type = "Title"
            $Writer.Add($Msg)
            Write-Menu -writer $Writer
            # Write-MenuString -Message "selected '$($choice.name)'" #-settings $parent.settings
            # write-host ($parent.WithPadding("selected '$($choice.name)'","#"))
            write-verbose ($choice|convertto-json)
            $Msg = [with_menu_lineitem]::new()
            $msg.type = "Choice"
            $choice.action|%{
                $writer.Lines.Clear()
                $msg.Text = $_
                $Writer.Add($Msg)
                Write-Menu -writer $Writer
            }
            
            # Write-MenuString -Message $choice.action #-settings $parent.settings
            # write-host $choice.action
        }
        write-host ""
    }
    
    end {
        
    }
}