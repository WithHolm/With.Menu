#LogStream:S-Setup
Function Set-UiConsoleEncoding {
    param()
    dynamicparam {
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        # $ParamAttrib.Mandatory = $true
        $ParamAttrib.ParameterSetName = '__AllParameterSets'
        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $Encodings = [System.Text.Encoding]::GetEncodings().Name
        # Write-Debug "found $($Encodings.count) encodings"
        # $configurationFileNames = Get-ChildItem -Path 'C:\ConfigurationFiles' | Select-Object -ExpandProperty  Name
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($Encodings)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Encoding', [string], $AttribColl)
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Encoding', $RuntimeParam)

        return  $RuntimeParamDic
    }
    begin{

    }
    process {
        $Encoding = $PSBoundParameters.Encoding
        if(!$Encoding)
        {
            $Encoding = "utf-8"
        }

        $UseEncoding = [System.Text.Encoding]::GetEncodings()|Where-Object{$_.Name -eq $Encoding}

        if(!$UseEncoding)
        {
            throw "The encoding '$encoding' cannot be used for console encoding as its not part of 'System.Text.Encoding' on this machine"
        }

        #setting all possible encodings for this console to utf8
        $OutputEncoding = [console]::InputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::UTF8
    }
    end{

    }
}