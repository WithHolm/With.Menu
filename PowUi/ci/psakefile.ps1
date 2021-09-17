param(
    $Root
)

Properties{
    $ModuleName = "PowUi"
    $Cmdlets = "public", "private"| % {$Foldername = $_;gci "$root/code" -Recurse -File -Filter "*.ps1" | ? { $_.Directory.Name -eq $Foldername -and $_.BaseName -notlike "*.tests"}}
}

Task default 
Task Build -depends Build_Generate_LogStreamMap
Task QOL -depends Add_Tests_To_All_Scripts
# Task Build -depends 

task Build_Generate_LogStreamMap{
    $LogStreamFile = Join-Path $Root "code\system\log\public\LogStreamMap.ini"
    $map = @{}
    $Cmdlets|%{
        $Name = (command $_.FullName).ScriptBlock.ast.EndBlock.Statements.name
        $stream = "Default"

        $Content = [system.io.file]::ReadAllLines($_.FullName)
        $LogStreamComment = $content -like "#LogStream:*"|select -first 1
        if($LogStreamComment -match "^#LogStream:(?'logstream'.*)$")
        {
            $Stream = $Matches["logstream"]
        }
        $map.$name = $stream
    }
    $map.GetEnumerator()|%{"{0}={1}" -f $_.Key,$_.Value}|Out-File -Encoding utf8NoBOM -Force -FilePath $LogStreamFile
}

task Add_Tests_To_All_Scripts{
    $Cmdlets|%{
        $Script = $_
        # $TestFileName = "$($Script.BaseName).Tests.ps1"
        $PesterFile = [System.IO.FileInfo](join-path $Script.Directory.FullName "$($Script.BaseName).Tests.ps1")
        # $PesterFile.Exists
        if(!$PesterFile.Exists)
        {
            $a = "y"#Read-Host "Create testfile for $($Script.BaseName)`? (y/n)"
            if($a -eq 'y')
            {

                $Command = command $Script.FullName
                $cmdletName = $Command.ScriptBlock.ast.EndBlock.Statements.name|select -first 1
                $parameters = $Command.ScriptBlock.ast.EndBlock.Statements.body.ParamBlock.parameters
                # $tab = "`t"
                #TODO FIND A BETTER SOLUTION TO WRITING METASCRIPT
                $Content = @"
Describe $cmdletName{
`tInModuleScope $ModuleName -Tag 'Cmdlet'{
`t`tBeforeDiscovery{
`t`t`t#Add Testcase stuff here. testcase should be hashtable
`t`t}
$(
$parameters|foreach{
    $Name = $_.name.VariablePath.UserPath
    if($_.Attributes.Typename.fullname -eq "switch" -or $_.Attributes.Typename.fullname -eq "Bool")
    {
        "`t`tIt ""Parameter '$name' True/Enabled""{`n"
        "`t`t}`n"
        "`t`tIt ""Parameter '$name' False/NotEnabled""{`n"
        "`t`t}`n"
    }
    else {
        "`t`tIt ""Parameter '$name'""{`n"
        "`t`t}`n"
    }
}  
)
`t}
}
"@
                New-Item -Path $PesterFile.FullName -Force -Value $Content -ItemType File|Out-Null
            }
        }
    }
}