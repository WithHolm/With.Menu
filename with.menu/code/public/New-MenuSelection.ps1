function New-MenuSelection {
    [CmdletBinding()]
    param (
        $Definition,
        [string]$Name,
        [string]$DefinitionKey,
        [with_menu_selection_returntype]$ReturnType = "int",
        [with_menu_selection_optionalInput[]]$OptionalInputs = @([with_menu_selection_optionalInput]::back),
        # [with_menu_selection_acceptedInput]$AcceptedInput = "int",
        [with_menu_selection_style]$style = "classic",
        [switch]$AsMenu,
        [switch]$PauseOnWrongAnswer
    )
    
    begin {
        
    }
    
    process {
        $selection = [with_menu_selection]::new()
        $selection.Name = $Name
        $selection.Definitionkey = $DefinitionKey
        # $selection.AcceptedInput = $AcceptedInput
        $selection.OptionalInput = $OptionalInputs
        $selection.Definition = $Definition
        $selection.ReturnType = $ReturnType
        $selection.ProcessAsMenu = $AsMenu
        $selection.Style = $style
        $selection.PauseOnWrongAnswer = $PauseOnWrongAnswer
        return $selection
    }
    
    end {
        
    }
}