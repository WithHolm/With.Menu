function Invoke-MenuStatus
{
    [CmdletBinding()]
    param (
        [System.Collections.Generic.List[with_Menu_Status]]$Status,
        [with_menu]$parent
    )
    
    begin
    {
        
    }
    
    process
    {
        if($Status.count)
        {
            write-host $parent.WithPadding("Status", "-")
        }

        $KeyStatuses = $Status | ? { $_.statustype -eq [with_StatusType]::KeyValue }
        $LineStatus = $Status | ? { $_.statustype -eq [with_StatusType]::Line }
        Write-Verbose "status: $($LineStatus.count) line, $($KeyStatuses.count) keyvalue"
        
        $writelines = @{}

        Foreach($Line in $KeyStatuses|select -Unique line)
        {
            ($KeyStatuses.where{$_.line -eq $Line}).foreach{
                $param = 
            }
            
        }
        foreach($stat in $KeyStatuses|Sort-Object line)
        {
            $process = 
            #execute scriptblock if action is a script
            if ($stat.action -is [scriptblock])
            {
                try
                {
                    $String = $stat.action.invoke()

                }
                catch
                {
                    Write-warning "Error happened when processing option '$($Status.name)':$($Status.description)"
                    Write-Error -ErrorRecord $_.Exception.InnerException.InnerException.ErrorRecord -RecommendedAction "Fix choice '$($Status.name)'"
                }
            }
            else{
                $string = $stat.action
            }

            if($stat.)
            #if keyhas does not have a array for the current line i want to display the status in
            if(!$KeyHash.ContainsKey($stat.Line))
            {
                $KeyHash.$($stat.Line) = @()
            }

            #add it to the array for the current line 
            $KeyHash.$($stat.Line) += @{
                Key = $($stat.name)
                val = $String
                length = $stat.name.length + $String.length
                colour = $stat.colour
            }
        }

        if($KeyStatuses.count)
        {
            foreach($line in $KeyHash.Keys)
            {
                $Element = $KeyHash.$i
                $Length = ($line.length|measure -sum).sum
                $pad = " "*$parent.PadLength($Length)
                $WriteLine = @()

                #start of line
                $WriteLine += @{
                    NoNewline = $true
                    object = $pad
                }

                foreach($item in $Element)
                {

                }

            }
            for ($i = 0; $i -lt $KeyHash.Count; $i++) {
                $Element = $KeyHash.$i   
                $Length = ($Element.Keys|%{$_.length + "$($element.$_.val)".Length}|measure -sum).sum
                $pad = " "*$parent.PadLength($Length)
                if(![string]::IsNullOrEmpty($pad))
                {
                    write-host $pad -NoNewline
                }

                $CountElements = $element.count

                foreach($key in $Element.keys)
                {
                    Write-Verbose "Writing keyvalue $($key):$($Element.$key.val) to screen"
                    $valueparam = @{
                        NoNewline=$true
                    }
                    write-host "$($key):" -NoNewline

                    if ($kv.value.colour)
                    {   
                        $valueparam.ForegroundColor = "green"
                        if (!$kv.value.val)
                        {
                            $valueparam.ForegroundColor = "red"
                        }
                    }


                }
                foreach($kv in $element.GetEnumerator())
                {
                    Write-Verbose "Writing keyvalue $($kv.key):$($kv.value.val) to screen"
                    write-host "$($kv.key):" -NoNewline
                    $valueparam = @{
                        NoNewline=$true
                    }
                    if ($kv.value.colour)
                    {   
                        if ($kv.value.val)
                        {
                            $valueparam.ForegroundColor = "green"
                        }
                        else
                        {
                            $valueparam.ForegroundColor = "red"
                        }
                    }
                    # Write-Host -Object
                    Write-Host $kv.value.val @valueparam
                    if($CountElements -gt 1)
                    {
                        Write-Host ", " -NoNewline
                    }
                    $CountElements--
                }
                if(![string]::IsNullOrEmpty($pad))
                {
                    write-host $pad -NoNewline
                }
                write-host ""
            }
        }

        if($LineStatus.count)
        {
            $LineStatus|%{
                Write-host $parent.WithPadding($_.action, " ")
            }
            # $usingMenu.Status | ? { $_.statustype -eq [with_StatusType]::Line } | % {
                
            # }
        }

        if($Status.count)
        {
            write-host $parent.WithPadding(".", ".")
        }
    }
    
    end
    {
        
    }
}