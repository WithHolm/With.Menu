function Invoke-Scriptblock {
    [CmdletBinding()]
    param (
        [Scriptblock]$InputItem,
        [String]$Identificator
    )
    
    begin {
        
    }
    
    process {
        Write-Verbose "$Identificator`: Getting items from scriptblock"
        Invoke-Command -ScriptBlock $InputItem -ErrorAction Stop
        # try{
        # }
        # catch{
        #     Write-warning $_
        #     $record = $_.Exception.ErrorRecord
        #     Write-Error -ErrorRecord $record
        # }
    }
    
    end {
        
    }
}