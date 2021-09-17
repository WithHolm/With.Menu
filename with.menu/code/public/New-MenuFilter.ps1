function New-MenuFilter {
    [CmdletBinding()]
    [outputtype([with_Menu_filter])]
    param (
        [parameter(Mandatory,Position=0)]
        [String]$Name,

        [parameter(Mandatory,Position=0)]
        [scriptblock]$Filter,

        [Scriptblock]$OnTrue,
        
        [scriptblock]$OnFalse
    )
    
    begin {}
    process {
        $Flt = [with_menu_filter]::new()   
        $Flt.Name = $Name
        # $Filter.description = $description
        $Flt.Filter = $Filter
        $Flt.OnTrue = $OnTrue
        $Flt.OnFalse = $OnFalse

        Write-debug "$flt Testing that it returns a bool"
        $test = $Filter.Invoke()
        try {
            [void] [bool]::Parse($test)
        }
        catch {
            throw "Filter '$name' should return boolean: $_"
        }
    }
    end {
        return $Flt
    }
}