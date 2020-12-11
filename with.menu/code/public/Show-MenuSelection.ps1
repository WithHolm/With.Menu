function Show-MenuSelection {
    [CmdletBinding()]
    param (
        $Definition,
        [string]$Name,
        [string]$DefinitionKey,
        [with_menu_selection_returntype]$ReturnType = "int",
        [with_menu_selection_optionalInput[]]$OptionalInputs = @([with_menu_selection_optionalInput]::back),
        [with_menu_selection_acceptedInput]$AcceptedInput = "int",
        [switch]$AsMenu,
        [switch]$PauseOnWrongAnswer
    )
    
    begin {
        # $waitparam = @{wait = $PauseOnWrongAnswer.IsPresent}
    }
    
    process {
        New-MenuSelection @PSBoundParameters|Write-MenuSelection -Verbose
    }
    
    end {
        
    }
}

# $items = @(
#     @{
#         n = "test"
#         v = "jeoo"
#     }
#     @{
#         n = "test"
#         v = "jeoo"
#     }
#     @{
#         n = "test"
#         v = "jeoo"
#     }
# )
# # $items = @(
#     #     New-MenuChoice "test" "test"
#     #     New-MenuChoice "test2" "test"
#     #     New-MenuChoice "test3" "test"
#     #     New-MenuChoice "test4" "test"
#     # )
# #     (New-MenuSetting).SetGlobal()
# Show-MenuSelection -Definition $items -ReturnType int -OptionalInputs divideline,back -AcceptedInput int -Verbose