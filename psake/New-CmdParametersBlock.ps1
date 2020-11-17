function New-CmdParameter {
    [CmdletBinding()]
    [outputtype([string])]
    param (
        [System.Reflection.PropertyInfo]$member
    )
    
    begin {
        
    }
    
    process {
        Foreach($member in $members|?{$_.name -notin $ignoreProperties})
        {
            $member = [System.Reflection.PropertyInfo]$member
            if($member.CustomAttributes)
            {
                # Write-Verbose "'$($member.name)' has customatributes"
                foreach($attribute in $member.CustomAttributes)
                {
                    Write-verbose "$($member.Name) has $($attribute.AttributeType.Name)"
                    $attribute = [System.Reflection.CustomAttributeData]$attribute
                    switch -Wildcard ($attribute.AttributeType.Name)
                    {
                        "ParameterAttribute"{
                            New-CmdParameterAttribute -attribute $attribute
                        }
                        "Validate*"{
                            New-CmdValidateAttribute -attribute $attribute
                        }
                        default{
                            Throw "Cannot process $($attribute.AttributeType.Name)"
                        }
                    }                    
                }
            }
            "`$$($member.Name)"
        }
    }
    
    end {
        
    }
}