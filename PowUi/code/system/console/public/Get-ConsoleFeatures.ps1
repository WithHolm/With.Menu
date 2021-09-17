using namespace System.Collections.Generic
function Get-ConsoleFeatures {
    [CmdletBinding()]
    [outputType([ConsoleFeature])]
    param ()
    
    begin {
    }
    
    process {
        $Output = [List[ConsoleFeature]]::new()
        @([ConsoleInputMode], [ConsoleOutputMode]) | % {
            [System.Enum]::GetValues($_) | % {
                $Output.Add([ConsoleFeature]::new($_))
            }
        }
        foreach ($Handle in $Output.Handle | select -Unique) {
            $ConsoleFeatures = [ConsoleModifier]::GetConsoleFatures($Handle)
            Write-Verbose "Feature int for $Handle is $ConsoleFeatures"
            $SortedFeatures = $Output|
                                Where-Object{ $_.Handle -eq $Handle } | 
                                    Sort-Object ModeInt -Descending
            Foreach($Feature in $SortedFeatures)
            {
                if($ConsoleFeatures-$feature.ModeInt -gt 0)
                {
                    $Feature.Enabled = $true
                    $ConsoleFeatures-=$feature.ModeInt
                }
                Write-Output $Feature
            }
        }
        # return $Output
    }
    
    end {
        
    }
}