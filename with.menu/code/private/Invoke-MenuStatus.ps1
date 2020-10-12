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
        $KeyStatuses = $Status | ? { $_.statustype -eq [with_StatusType]::KeyValue }
        Write-Verbose "$($KeyStatuses.count) key statuses"
        $LineStatus = $Status | ? { $_.statustype -eq [with_StatusType]::Line }
        Write-Verbose "$($LineStatus.count) line statuses"
        
        $KeyHash = @{}
        foreach($stat in $KeyStatuses)
        {
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
            $using = @{$stat.name = $String }
            if ($KeyHash.ContainsKey($stat.Line))
            {
                $KeyHash.$($stat.Line).$($stat.name) = @{
                    val = $String
                    colour = $stat.colour
                }
            }
            else
            {
                $KeyHash.$($stat.Line) = @{
                    $stat.name = @{
                        val = $String
                        colour = $stat.colour
                    }
                }
            }
        }

        if($Status.count)
        {
            write-host $parent.WithPadding("Status", "-")
        }

        if($KeyStatuses.count)
        {
            for ($i = 0; $i -lt $KeyHash.Count-1 ; $i++) {
                $Element = $KeyHash.$i   
                $Length = $Element.Keys|%{
                    $_.length + "$($element.$_.val)".Length
                }|measure -sum|select -ExpandProperty sum
                $pad = " "*$parent.PadLength($Length)
                # $Length = ($element.GetEnumerator()|%{
                #     $_.key.length+($_.value.val|%{$_.tostring().length}|measure -sum).sum
                # }|measure -sum).sum
                # write-host $Length
                # $pad  = ($parent.WithPadding((";"*$Length),"-").split(";")|select -first 1).trim().replace("-"," ")
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

            # foreach($element in $KeyHash.GetEnumerator())
            # {
            #     $Length = ($element.Value.GetEnumerator()|%{
            #         $_.key.length+($_.value.val|%{$_.tostring().length}|measure -sum).sum
            #     }|measure -sum).sum
            #     # write-host $Length
            #     $pad  = ($parent.WithPadding((";"*$Length),"-").split(";")|select -first 1).trim().replace("-"," ")
            #     if(![string]::IsNullOrEmpty($pad))
            #     {
            #         write-host $pad -NoNewline
            #     }

            #     $CountElements = $element.value.count
            #     foreach($kv in $element.Value.GetEnumerator())
            #     {
            #         Write-Verbose "Writing keyvalue $($kv.key):$($kv.value.val) to screen"
            #         write-host "$($kv.key):" -NoNewline
            #         $valueparam = @{
            #             NoNewline=$true
            #         }
            #         if ($kv.value.colour)
            #         {   
            #             if ($kv.value.val)
            #             {
            #                 $valueparam.ForegroundColor = "green"
            #             }
            #             else
            #             {
            #                 $valueparam.ForegroundColor = "red"
            #             }
            #         }
            #         # Write-Host -Object
            #         Write-Host $kv.value.val @valueparam
            #         if($CountElements -gt 1)
            #         {
            #             Write-Host ", " -NoNewline
            #         }
            #         $CountElements--
            #     }
            #     if(![string]::IsNullOrEmpty($pad))
            #     {
            #         write-host $pad -NoNewline
            #     }
            #     write-host ""
            # }
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