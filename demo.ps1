ipmo .\with.menu -Force
$menustate = @{
    1 = 0
}
New-Menu -Title "Powershell Menu" -Definition {
    New-MenuMessage "En liten demo for en menu modul"
    New-Menu "1. why" {
        New-MenuMessage "Hvorfor bruke modul for dette?"
        New-MenuChoice "håndtering" -Action {
            "menu håndtering i powershell har vært veldig manuelt"
            "og du har hatt generelt sett 2 måter å gjøre dette på:"
            pause
            "1: Skriv masse 'write-host' og read-host kommandoer som må:"
            "* sanitere input"
            "* finne ut av hvor man skal senere"
            "eksempel:"
            pause
            Code 
        } -FilterValue ($Menustate.1 -ge 0)
        # New-MenuMessage "Fordi menu håndtering i powershell har generelt sett vært ganske sucky"
        # New-MenuMessage "Fordi menu håndtering i powershell har generelt sett vært ganske sucky"
    }    
}|Start-Menu