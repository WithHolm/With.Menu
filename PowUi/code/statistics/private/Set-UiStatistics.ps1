#LogStream:Sbase
Function Set-UiStatistics {
    param(
        [validateset("wrt", "tot", "cln", "buf", "add", "fps", "usr", "dim")]
        [string]$Name,
        $Value,
        [switch]$append,
        [switch]$average,
        [Alias('Init')]
        [switch]$Clean
    )

    if ($global:Ui.statistics.Keys.Count -eq 0 -and !$Clean) {
        Write-Verbose "Initiating new statistics"
        $ParameterList = (Get-Command -Name $MyInvocation.MyCommand).Parameters
        $ParameterList["Name"].Attributes.ValidValues | % {
            $global:Ui.statistics.$_ = 0
        }
    }

    if ($Clean) {
        if ($name) {
            Set-UiStatistics $Name -Value 0
        }
        else {
            $ParameterList = (Get-Command -Name $MyInvocation.MyCommand).Parameters
            $ParameterList["Name"].Attributes.ValidValues | % {
                $global:Ui.statistics.$_ = 0
            }
        }
    }
    elseif ($name -in $global:Ui.statistics.Keys) {
        if ($append) {
            $global:Ui.statistics.$name += $Value
        }
        elseif ($average) {
            $global:Ui.statistics.$name = (($value + $global:Ui.statistics.$name) / 2)
        }
        else {
            $global:Ui.statistics.$name = $Value
        }
    }
    else {
        throw "Could not set stat '$name'. its not a part of the defined statistics"
    }
}