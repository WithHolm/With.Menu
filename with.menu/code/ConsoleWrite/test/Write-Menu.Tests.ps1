Describe "Write-Menu" -Tag "cmdlet","write-menu"{
    InModuleScope With.menu{
        $settings = [with_menu_setting]::new()
        $settings.MenuWidth = 20
        $settings.pesterEnabled = $true
        $settings.SetGlobal()
        
        BeforeEach {
            $writer = [with_menu_writer]::new()
            $Global:_Pester = @()
            $DebugPreference = "Continue"
            mock write-host {}
            mock read-host {}
        }
        <#
            Divideline
            Title
            Choice
            Status
            Question
            Message
        #>
        it "Can write <Explain>" -TestCases @(
            @{
                Explain = "Divideline (default)"
                Type    = "Divideline"
                Text    = ""
                Answer = "-"*20
            }
            @{
                Explain = "Divideline (Custom)"
                Type    = "Divideline"
                Text    = "*"
                Answer = "*"*20
            }
            @{
                explain = "title"
                type = "Title"
                Text = "Title"
                Answer = "--------Title-------"
            }
        ) { 
            param(
                $Explain,
                $Name,
                $Text,
                $answer
            )

            $Line = [With_menu_LineItem]::new()
            $Line.Text = $Text
            $Line.type = $Type
            $writer.Add($Line)
            Write-Menu -writer $writer
            $($Global:_Pester.values.message -join '')|should -Be $answer
            ($($Global:_Pester.values.message -join '').split("")|?{$_}).length|should -be $settings.MenuWidth -Because "settings have defined menu length to be $($settings.MenuWidth)"
            $Global:_Pester.values.color|%{
                $_|should -be $line.color
            }
        }
    }
}