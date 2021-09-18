using namespace System.Management.Automation.Host 

$Prod = [ChoiceDescription]::new('&Prod', 'Environment:Prod') 
$Test = [ChoiceDescription]::new('&Test', 'Environment:Test') 
$Dev = [ChoiceDescription]::new('&Dev', 'Environment:Dev') 

$Envs = [ChoiceDescription[]]($prod, $Test, $Dev) 

$choice = $host.ui.PromptForChoice("Select Environment", "Prod?, Dev?, Test?", $envs, 0) 
switch ($choice) { 
    0 { Write-Host "`nYou have selected a Prod Environment" } 
    1 { Write-Host "`nYou have selected a Test Environment" } 
    2 { Write-Host "`nYou have selected a Dev Environment" } 
}