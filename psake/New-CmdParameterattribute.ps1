function New-CmdParameterAttribute {
    [CmdletBinding()]
    param (
        [System.Reflection.CustomAttributeData]$attribute
    )
    
    begin {
        if($attribute.AttributeType.Name -ne 'ParameterAttribute')
        {
            throw "can only process 'parameterattribute' type. you delivered a '$($attribute.AttributeType.Name)'"
        }
    }
    
    process {
        $out = @(
            "[Parameter"
            "("
        )
        $out+=($attribute.NamedArguments.foreach{
            $value = Convertto-String -value $_.TypedValue.Value
            [string]::Format("{0} = {1}",$_.Membername,$value)
        }) -join ", "
        $out += ")","]"
        return $out -join ""
    }
    
    end {
        
    }
}