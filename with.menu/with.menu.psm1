gci "$PSScriptRoot\code" -File -Filter "*.ps1" -Recurse | ? { $_.Directory.name -in "class" } | % {
    . $_.FullName
}
gci "$PSScriptRoot\code" -File -Filter "*.ps1" -Recurse | ? { $_.Directory.name -in "public", "private" } | % {
    . $_.FullName
}

$Global:_MenuSettings = @{}