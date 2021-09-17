function Write-MenuSelection {
    [CmdletBinding()]
    param (
        [Alias("InputObject")]
        $Definition,
        [string]$Name,

        [Alias("ListProperty")]
        [string]$DefinitionKey,

        [with_menu_selection_returntype]$ReturnType = "int",

        [with_menu_selection_optionalInput[]]$OptionalInputs = @([with_menu_selection_optionalInput]::back),

        # [with_menu_selection_acceptedInput]$AcceptedInput = "int",

        [with_menu_selection_style]$style = "classic",

        [switch]$AsMenu,
        [switch]$PauseOnWrongAnswer
    )
    
    begin {
        # $waitparam = @{wait = $PauseOnWrongAnswer.IsPresent}
    }
    
    process {
        # write-host ($PSBoundParameters|ConvertTo-Json)
        New-MenuSelection @PSBoundParameters|Invoke-MenuSelection # -Verbose
    }
    
    end {
        
    }
}