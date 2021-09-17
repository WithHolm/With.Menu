function ConvertTo-BracketString {
    [CmdletBinding()]
    param (
        [String]$String,
        [With_Menu_Setting_ChoiceBracketType]$BracketType
    )
    
    begin {
        if(!$BracketType)
        {
            $Settings = [with_menu_setting]::GetGlobal()
            $BracketType = $Settings.ChoiceBracketType
        }
    }
    
    process {
        $bracket = @()
        switch ($brackettype) {
            'Sqarebracket'{
                $bracket = @('[',']')
            }
            'Curlybracket'{
                $bracket = @('{','}')
            }
            'Parenthesis'{
                $bracket = @('(',')')
            }
            Default {
                throw "No processing for '$BracketType' found"
            }
        }
        return ("{2}{0}{3}{1}" -f $String.Substring(0, 1).ToUpper(), $String.Substring(1),$bracket[0],$bracket[1])
    }
    
    end {
        
    }
}