describe "Get-PadLength" -tag "Pad" {
    InModuleScope "With.menu" {
        # beforeEach {

        # }
        $testcases = @(30..70 | % {
            @{
                MaxLength = 50
                ItemLength = $_
                Position = $(@("Left", "Middle", "Right") | get-random)
            }
        })
        it "Should always deliver array with 2 int when given <MaxLength>,<ItemLength>,<Position>" -testcases $testcases {
            param(
                [Int]$MaxLength,
                [Int]$ItemLength,
                $Position
            )
            $return = Get-PadLength -MaxLength $MaxLength -ItemLength $ItemLength -Position $Position
            $return.gettype().name | should -Be 'Object[]'
            $return|should -havecount 2
            $return | should -beoftype [int]
        }
    }
}