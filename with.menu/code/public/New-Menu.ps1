function New-Menu {
    [CmdletBinding()]
    # [outputtype([with_Menu])]
    param (
        # [string]$id,
        [parameter(mandatory)]
        [string]$Name,
        # [parameter(mandatory)]
        [string]$Description,
        [int]$TitleWidth,

        [parameter(ParameterSetName="items")]
        [with_Menu_item[]]$Items,

        [parameter(ParameterSetName="define")]
        [scriptblock]$Definition
    )
    
    begin {
        if([string]::IsNullOrEmpty($id))
        {
            $id = $Name
        }

        $Menu = [with_Menu]::new()
        
        $Menu.Name = $Name
        $Menu.description = "$Description"
        # $Menu.id = $id
        # $Menu.parentId = ""
        if($TitleWidth)
        {
            $Menu.TitleWidth = $TitleWidth
        }


        Write-verbose "Menu $Name"
    }
    
    process {
        if($PSCmdlet.ParameterSetName -eq "items")
        {
            Write-verbose "Menu '$name': getting items from array"
            $UsingItems = @($Items|?{$_ -is [with_Menu_item]})|%{
                Write-verbose "Menu choice $_"
                $_
            }
        }
        elseif($PSCmdlet.ParameterSetName -eq "define")
        {
            Write-Verbose "Menu '$id': Getting items from scriptblock"
            try{
                $invoke = $Definition.invoke()
                $Menu.choices = @($invoke|?{$_ -is [with_Menu_Choice] -or $_ -is [with_Menu]}|%{
                    Write-verbose "Menu $_"
                    $_
                })

                $menu.status = @($invoke|?{$_ -is [with_Menu_status]}|%{
                    Write-verbose "status $_"
                    $_
                })
            }
            catch{
                $record = $_.Exception.InnerException.ErrorRecord
                Write-Error -ErrorRecord $record
            }
        }

        foreach($status in $Menu.status)
        {
            $conflictingStatus = ($Menu.status|?{$_.line -eq $status.line -and $_.StatusType -ne $status.StatusType})
            if(($Menu.status|?{$_.line -eq $status.line -and $_.StatusType -ne $status.StatusType}))
            {
                throw "'$($status.Name)' Keyvalue status cannot share a line with line statuses: $($conflictingStatus.name -join ", ")"
            }
        }

        Write-verbose "Found $($Menu.choices.Count) choices and $($menu.status.Count) statuses"
        if($Menu.choices.count -eq 0 -and $Menu.status.count -eq 0)
        {
            throw "The menu '$name' doesent have any choices or statuses"
        }        
        return $Menu
    }
    
    end {
    }
}