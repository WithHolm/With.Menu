#Region DRY1

#gjennbruk av lignenes variables
$Name = "navn navesen"
$Name2 = "navn2 navesen"
$Name3 = "navn3 navesen"

#if checks er ikke good
if ($name -eq "navn navesen" -or $name2 -eq "navn navesen" -or $navn3 -eq "navn navesen") {
    Write-host "OK"
}


#DRY
$names = @(
    "navn navesen",
    "navn2 navesen",
    "navn3 navesen"
)

if ($names -like "navn *") {
    write-host "OK"
}
#Endregion

#Region DRY2
do {
    Write-Host "`n============= Pick the Server environment=============="
    Write-Host "`ta. 'P' for the Prod servers"
    Write-Host "`tb. 'T' for the Test servers"
    Write-Host "`tc. 'D for the Dev Servers'"
    Write-Host "`td. 'Q to Quit'"
    Write-Host "========================================================"
    $choice = Read-Host "`nEnter Choice"
} until (($choice -eq 'P') -or ($choice -eq 'T') -or ($choice -eq 'D') -or ($choice -eq 'Q') )
 
switch ($choice) {
    'P' {
        Write-Host "`nYou have selected a Prod Environment"
    }
    'T' {
        Write-Host "`nYou have selected a Test Environment"
    }
    'D' {
        Write-Host "`nYou have selected a Dev Environment"
    }
    'Q' {
        Return
    }
}

#DRY.. ish
$Environments = @{
    Dev  = { Write-Host "MY CODE GOES HERE" }
    Prod = { Write-Host "MY CODE GOES HERE" }
    Test = { Write-Host "MY CODE GOES HERE" }
    QA = {Write-host "QA"}
}

do{
    Write-Host ("="*15) "Pick the Server environment"  ("="*15)
    $Environments.GetEnumerator() | % {
        $Letter = $($_.key.substring(0,1).toupper())
        Write-host "'$Letter' for the $($_.Key) servers"
    }
    Write-host "'Q' to quit"
    Write-Host ("="*56)
    $choice = Read-Host "`nEnter Choice"

    $AllKeyChoices = @($Environments.keys.substring(0,1))
    $AllKeyChoices += "Q"
}until($AllKeyChoices -eq $choice)

if($Environments.keys.substring(0,1) -eq $choice)
{
    $key = $Environments.keys|?{$_ -like "$choice*"}
    $Selection = $Environments.$key
    Write-Host "You have selected $key Environment"
    $Selection.invoke()
}
else {
    return
}
#Endregion
