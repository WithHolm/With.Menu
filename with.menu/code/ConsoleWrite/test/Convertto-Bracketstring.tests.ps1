describe "Convertto-BracketString"{
    it "Should deliver a string with <brackettype> enclosing first character" -TestCases @(
        @{
            brackettype = 'Curlybracket'
            answer = "{P}ester"
        }
        @{
            brackettype = 'Parenthesis'
            answer = "(P)ester"
        }
        @{
            brackettype = 'Sqarebracket'
            answer = "[P]ester"
        }
    ) {
        param(
            $brackettype,
            $string,
            $answer
        )
        $Settings = New-MenuSetting -ChoiceBracketType $brackettype
        $Settings.SetGlobal()
        Convertto-BracketString -String $string|should -be $answer
    }
}