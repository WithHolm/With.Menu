function Start-Menu {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipeline)]
        [with_Menu]$Menu
        # [switch]$ShowDescription
    )
    

    begin {}
    process{
        invoke-Menu -Menu $Menu
    }
    end{}
}