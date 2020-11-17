function Invoke-MenuMessage {
    [CmdletBinding()]
    [Outputtype([with_menu_lineitem])]
    param (
        [parameter(ValueFromPipeline)]
        [with_menu_message]$Message
    )
    process {
        $line = [with_menu_lineitem]::new()
        $line.color = $Message.color
        $line.Text = $Message.message
        $line.type = "Message"

        Write-Output $line
        if($Message.wait)
        {
            $Wait = [with_menu_lineitem]::new()
            $Wait.text = "Press enter to continue"
            $Wait.type = "Question"
            Write-Output $Wait
        }
    }
}