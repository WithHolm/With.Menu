
# gci "$PSScriptRoot\code\class" -File -Filter "*class.ps1"|%{
#     Write-host $_.FullName
#     . $_.FullName
# }

gci "$PSScriptRoot\code" -File -Filter "*.ps1" -Recurse | ? { $_.Directory.name -in "public", "private" } | % {
    . $_.FullName
}

# $Global:WithMenuSettings = $null
# $settings = [with_menu_setting]::new()
# $settings.SetGlobal()
$Global:_MenuSettings = @{}