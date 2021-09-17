function Start-Menu {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [with_Menu]$Menu
    )
    

    begin {}
    process{
        Write-Verbose "Starting menu $menu"
        invoke-Menu -Menu $Menu
    }
    end{}
}