function Write-MenuString
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$Message,
        [parameter(Mandatory)]
        [with_menu_setting]$settings
    )
    
    begin
    {
        $Writer = [With_Menu_Writer]::new()
        $msg = New-MenuMessage -Message $Message
        $msg2 = Invoke-MenuMessage -Message $msg
        $Writer.Add($msg2)
        Write-Menu -writer $Writer -Settings $settings
    }
    
    end
    {
        
    }
}