Properties{
    $ModuleName = (gci $psake.build_script_dir -Recurse -Filter "*.psm1"|select -first 1).basename

}

Task Default -depends Generate_SettingsCmdlet

task Generate_SettingsCmdlet{
    ipmo (join-path $psake.build_script_dir $modulename) -Force
    $ClassPath = "$($psake.build_script_dir)\$modulename\code\class\main.class.ps1"
    $Path = "$($psake.build_script_dir)\$modulename\code\public\New-Menusetting2.ps1"
    $ignore = @("Name","Type")
    $Type = [with_menu_setting]
    $Properties = $($Type.DeclaredMembers|?{$_ -is [System.Reflection.PropertyInfo]})
    $RemoveProperties = ($Properties|?{$_.customattributes.namedarguments.membername -eq "dontshow"}).name
    Write-host "Ignoring properties $($RemoveProperties -join ", ")"
    $properties = $properties|?{$_.name -notin $RemoveProperties}
    $obj = New-Object -TypeName $type.Name
    # $obj
    #(($k.DeclaredMembers|?{$_ -is [System.Reflection.PropertyInfo]})|?{$_.CustomAttributes}).CustomAttributes.namedarguments
    # $Properties
    $out = @(
        "Function New-MenuSetting"
        "{"
        "`t[CmdletBinding()]"
        "`t[outputtype([$($Type.name)])]"
        "`tParam("
    )
    $Properties|%{
        $param = @{
            OverParam = $_.customattributes|%{"$_"}
            type = $_.propertytype
            name = $_.name
            value = ""
        }

        $val = $obj.$($_.name)
        if(![string]::IsNullOrEmpty($val))
        {
            if($val -is [System.Enum] -or $val -is [string])
            {
                $param.value += """$val"""
            }
            elseif($val -is [int])
            {
                $param.value += "$val"
            }
            elseif($val -is [bool])
            {
                $param.value += "`$$val"
            }
            else {
                throw "Unhandled type for $_.name: $($val.gettype())"
            }
        }
        $o = @()
        if($param.overparam)
        {
            $o += "$($param.overparam -join "`n")`n"
        }
        $o += "[$($param.type)]","`$$($param.name)","=$($param.value)" -join ""
        # $o
        $out += "`t`t$($o -join '')"
    }


    $out += "`t)"

    $out += "}"
    $out -join "`n"
}