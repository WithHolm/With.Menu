#LogStream:Sbase
Function Get-Uistatistics {
    param(
        [Switch]$AsOut
    )
    if ($AsOut) {
        ($global:Ui.statistics.keys | % {
                ($_, ([math]::Round($global:Ui.Statistics.$_).tostring().padleft(6,"0")) -join ":")
            }) -join "`t"
    }
    else {
        $global:Ui.statistics
    }
    
}
