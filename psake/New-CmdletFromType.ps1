function New-CmdletFromType
{
    [CmdletBinding()]
    param (
        $type,
        [string]$CmdletName,
        [String]$OutputFile,
        [string[]]$ignoreProperties
    )
    
    begin
    {
        # $type
        if ($type -is [string])
        {
            if ($type -notmatch "^\[.+\]$")
            {
                $type = "[$type]"
            }
            $type = [scriptblock]::Create($type).invoke()
        }
        elseif ($type -is [type])
        {
            #do nothing. everything is allright :)
        }
        else
        {
            throw "Input is neither type or string. please fix this: $($type.gettype().name)"
        }
    }
    
    process
    {
        $Parameters = @{}
        $members = $Type.DeclaredMembers|?{$_ -is [System.Reflection.PropertyInfo]}

        New-CmdParametersBlock -members ($members|?{$_.name -notin $ignoreProperties})

    }
    
    end
    {
        
    }
}

New-CmdletFromType -type [with_menu_setting] -Verbose
# New-CmdletFromType -type [with_menu_setting] -Verbose