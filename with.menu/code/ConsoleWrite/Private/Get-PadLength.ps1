<#
.SYNOPSIS
gives you coordinates to position you on a line

.DESCRIPTION
Gives you an array of to that defines the start and end [count from start,count to end] used to figure out padding for write-host

.PARAMETER MaxLength
Length of whole (ie consolewindow charlength)

.PARAMETER ItemLength
Length of item (ie "hey".length)

.PARAMETER Position
Left, Right, Middle

.EXAMPLE
$length = 100
$Pad = Get-Padlength -Maxlength 100 -ItemLength "Hey".length -position "Middle"
# returns @(48,49)
Write-host "$("-"*$pad[0])hey$("-"*$pad[1])"
# returns "------------------------------------------------hey-------------------------------------------------"
"-"*$length
# returns "----------------------------------------------------------------------------------------------------"
#>
function Get-PadLength {
    [CmdletBinding()]
    param (
        [parameter(HelpMessage = "Length of Parent")]
        [Int]$MaxLength,
        [parameter(HelpMessage = "Length of Item")]
        [Int]$ItemLength,
        [With_Position]$Position = "left"
    )
    
    begin {
        Write-debug "Padding. Maxlength: $MaxLength, ItemLength: $itemlength, Position: $position"
    }
    
    process {
        switch($Position)
        {
            "Left"{
                $return = @(0,($MaxLength-$ItemLength))
            }
            "Middle"{
                $Half = [int]([math]::Round(($MaxLength - $ItemLength) / 2))
                $return = @($Half,$Half)
            }
            "Right"{
                #Width of parent - current item
                $return = @(($MaxLength-$ItemLength),0)
            }
        }

        #Append missing characters to last part of array if the total line count is not equal to the expected linecount 
        $MissingChars = $MaxLength - ($return[0]+$return[1]+$ItemLength)
        if($MissingChars -ne 0)
        {
            $return[1] = $return[1] + $MissingChars
        }
        
        $return = $return|%{
            if ($_ -lt 0)
            {
                0
            }
            else {
                $_
            }
        }
    }
    
    end {
        return $return
    }
}