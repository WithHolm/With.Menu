Describe "New-MenuStatus"{
    InModuleScope "with.menu"{
        it "can create a <statustype> status item" -TestCases @(
            @{statustype = "Line"}
            @{statustype = "KeyValue"}
        ) {
            param(
                $statustype
            )
            $test = New-MenuStatus -Name "pester" -Statustype $statustype -action {$true}
            $answer = [with_Menu_Status]::new()
            $answer.action = {$true}
            $answer.id = 'pester'
            $answer.Name = 'pester'
            $answer.StatusType = $statustype
            $test.type|should -Be $answer.Type
            $test.action.tostring()|should -Be $answer.action.ToString()
            $test.Name|should -Be $answer.Name
            $test.StatusType|should -Be $answer.StatusType
        }
    }
}