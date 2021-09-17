#LogStream:S-Setup
function Set-UiQuickEditMode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "This switch will disable Console QuickEdit option")]
        [switch]$DisableQuickEdit = $false
    )


    if ([DisableConsoleQuickEdit]::SetQuickEdit($DisableQuickEdit)) {
        # Write-Output "QuickEdit settings has been updated."
    }
    else {
        Write-Output "Something went wrong."
    }
}