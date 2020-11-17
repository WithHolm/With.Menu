function Request-MenuSetting {
    [CmdletBinding()]
    [outputtype([with_menu_setting])]
    param (
        [array]$Array
    )
    $settings = $Array|?{$_ -is [with_menu_setting]}
    if($settings.Count -gt 1)
    {
        Throw "There are several settings defined. There can only be one: $($settings.ToString() -join ", ")"
    }
    return $settings
}