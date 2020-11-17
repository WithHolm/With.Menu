function Out-Console {
    [CmdletBinding()]
    param (
        [string[]]$Message,
        [System.ConsoleColor]$Color,
        [Switch]$NoNewLine,
        [switch]$Question
    )
    
    begin {
        $Setting = [with_menu_setting]::GetGlobal()
    }
    process {
        if($Setting.PesterEnabled)
        {
            if([string]::IsNullOrEmpty($Global:_Pester))
            {
                $Global:_Pester = @()
            }
            $Global:_Pester += @{
                Command = "Out-Console"
                Parameters = @{
                    Message = $Message -join ""
                    Question = $Question.IsPresent
                    NoNewLine = $NoNewLine.IsPresent
                }
            }
            if($Color)
            {
                $Global:_Pester[-1].parameters.Color = $Color
            }
        }
        if(!$color)
        {
            #Get default message color
            $Color = [with_menu_message]::new().Color
        }

        if($Question)
        {
            # Write-host "$($message -join '')" -NoNewline -ForegroundColor $Color
            Read-Host -Prompt "$($message -join '')"
        }
        else 
        {
            Write-host $Message -NoNewline:$NoNewLine.IsPresent -ForegroundColor $Color
        }
    }
    
    end {
        
    }
}