function Invoke-MenuChoice {
    [CmdletBinding()]
    param (
        [With_Menu_Choice]$Choice 
    )
    
    begin {
        
    }
    
    process {
        if($choice.action -is [scriptblock])
        {
            write-host ($parent.WithPadding("Executing '$($choice.name)'"))
            try{
                $choice.action.invoke()|%{
                    write-host $_
                } 
            }
            catch{
                Write-warning "Error happened when processing option '$($choice.name)':$($choice.description)"
                Write-Error -ErrorRecord $_.Exception.InnerException.InnerException.ErrorRecord -RecommendedAction "Fix choice '$($choice.name)'"
            }
                
            write-host ""
            # write-host ($usingMenu.WithPadding("End Execution $($selection.name)"))
        }
        else 
        {
            write-verbose ($choice|convertto-json)
            $choice.action
        }
    }
    
    end {
        
    }
}