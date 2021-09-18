$Root = (split-path $PSScriptRoot)
ipmo (join-path $Root "with.menu") -Force
$menustate = @{
    1 = 0
}
New-Menu -Title "Powershell Menu" -Definition {
    New-MenuSetting -ClearScreenOn None -AutoAjustMenuDisabled -MenuWidth 70 -MenuPosition Middle -WaitAfterChoiceExecution -ChoiceBracketType Curlybracket
    New-MenuFilter -name "0" -Filter {$Menustate.1 -eq 0} -OnTrue {
        New-MenuMessage "En liten demo for en menu modul"
        New-MenuChoice "La oss starte"{
            $Menustate.1 = 1
        }
    }
    
    New-MenuFilter -name "1" -Filter {$Menustate.1 -eq 1} -OnTrue {
        New-MenuMessage "Hvorfor bruke en modul for dette?"
        New-Menu "håndtering" {
            New-MenuChoice "'write-host', 'read-host'" {
                Code "$PSScriptRoot/eks1.ps1"
                $Menustate.1 = 2
            }
            New-MenuChoice ".NET Choice description" {
                code "$PSScriptRoot/eks2.ps1"
                $Menustate.1 = 2
            }
            New-MenuChoice "neste slide" {
                $Menustate.1 = 2
            }
        }
    }
    New-MenuFilter -name "2" -Filter {$Menustate.1 -eq 2} -OnTrue {
        New-MenuMessage "ok, så da er en modul bedre?"
        New-Menu "ja" {
            New-Menuchoice "DRY konseptet.. kind of" {
                code "$PSScriptRoot/dry.ps1"
                $Menustate.1 = 3
            }
            New-MenuChoice "'oversiktlighet'"{
                code "$PSScriptRoot/oversikt.ps1"
                $Menustate.1 = 3
            }
            New-MenuChoice "portabilitet"{
                $Menustate.1 = 3
            }
        }
    } 
    New-MenuFilter -name "3" -Filter {$Menustate.1 -eq 3} -OnTrue {
        New-MenuMessage "så få se da"
        New-MenuChoice "jada" {
            $Menustate.1 = 4
            start-process -FilePath "powershell" -ArgumentList "-file $Root/with.menu\examples/starthere.ps1"
        }
    } 
    New-MenuFilter -name "4" -Filter {$Menustate.1 -eq 4} -OnTrue {
        New-MenuMessage "ekstra, hvis vi har tid"
        New-MenuChoice "jepp" {
            start-process -FilePath "pwsh" -ArgumentList "-file $Root/PowUi\example.ps1"
            # $Menustate.1 = 3
        }
    } 
}|Start-Menu