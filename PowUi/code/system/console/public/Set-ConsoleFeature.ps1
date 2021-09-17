function Set-ConsoleFeature {
    [CmdletBinding(DefaultParameterSetName="Feature")]
    param (
        [parameter(
            ParameterSetName = "Feature",
            Mandatory,
            ValueFromPipeline
        )]
        [ConsoleFeature[]]$Feature,
        [parameter(
            ParameterSetName = "ConsoleInput",
            Mandatory
        )]
        [ConsoleInputMode[]]$ConsoleInput,

        [parameter(
            ParameterSetName = "ConsoleOutput",
            Mandatory
        )]
        [ConsoleOutputMode[]]$ConsoleOutput,
            
        [parameter(
            ParameterSetName = "ConsoleInput",
            Mandatory
        )]
        [parameter(
            ParameterSetName = "ConsoleOutput",
            Mandatory
        )]
        [System.Boolean]$Enabled
    )
    
    begin {
        $ProcessFeatures = @()
    }
    
    process {
        if($PSCmdlet.ParameterSetName -eq "ConsoleInput")
        {
            $ProcessFeatures += $ConsoleInput|%{
                $T = [ConsoleFeature]::new($_)
                $T.Enabled = $Enabled
                $T
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq "ConsoleOutput") {
            $ProcessFeatures += $ConsoleOutput|%{
                $T = [ConsoleFeature]::new($_)
                $T.Enabled = $Enabled
                $T
            }
        }
        else {
            $ProcessFeatures += $Feature
        }
        
    }
    
    end {
        Write-Verbose "Handing $($ProcessFeatures.Count) items"
        $ProcessFeatures|Group-Object Handle|%{
            $Group = $_
            Switch($Group.Name)
            {
                "OUTPUT_HANDLE"{
                    $Enable = $Group.group|Where-Object{$_.enabled}
                    $Disable = $Group.group|Where-Object{!$_.enabled}

                    if($Enable.count)
                    {
                        Write-Verbose "Enabling $($enable.count) console outputs"
                        [ConsoleModifier]::EnableConsoleOutput($Enable.Mode)
                    }
                    if($Disable.count)
                    {
                        Write-Verbose "Disabling $($enable.count) console outputs"
                        [ConsoleModifier]::DisableConsoleOutput($Disable.Mode)
                    }
                }
                "INPUT_HANDLE"{
                    $Enable = $Group.group|Where-Object{$_.enabled}
                    $Disable = $Group.group|Where-Object{!$_.enabled}

                    if($Enable.count)
                    {
                        Write-Verbose "Enabling $($enable.count) console inputs"
                        [ConsoleModifier]::EnableConsoleInput($Enable.Mode)
                    }
                    if($Disable.count)
                    {
                        Write-Verbose "Disabling $($enable.count) console inputs"
                        [ConsoleModifier]::DisableConsoleInput($Disable.Mode)
                    }
                }
            }
        }
    }
}

# Set-ConsoleFeature -ConsoleInput ENABLE_ECHO_INPUT -Enabled 1 -Verbose