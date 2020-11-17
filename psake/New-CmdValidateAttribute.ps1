function New-CmdValidateAttribute {
    [CmdletBinding()]
    param (
        [System.Reflection.CustomAttributeData]$attribute
    )
    
    begin {
        if($attribute.AttributeType.Name -notlike 'Validate*')
        {
            throw "can only process 'Validate*' attributes. you delivered a '$($attribute.AttributeType.Name)'"
        }
    }
    
    process {
        $out = @(
            "[",
            "$($attribute.AttributeType.Name)",
            "(",
            "$(($k.ConstructorArguments|%{Convertto-String -value $_.value}) -join ", ")",
            ")]"
        )
        return $out -join ""
    }
    
    end {
        
    }
}