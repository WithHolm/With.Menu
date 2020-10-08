function New-Menu {
    [CmdletBinding()]
    param (
        [string]$id,
        [parameter(mandatory)]
        [string]$Name,
        [parameter(mandatory)]
        [string]$Description,
        [int]$TitleWidth,

        [parameter(ParameterSetName="items")]
        [Menuitem[]]$Items,

        [parameter(ParameterSetName="define")]
        [scriptblock]$Definition
    )
    
    begin {
        if([string]::IsNullOrEmpty($id))
        {
            $id = $Name
        }
        Write-verbose "Menu $Name"

        if($PSCmdlet.ParameterSetName -eq "items")
        {
            Write-verbose "Menu '$id': getting items from array"
            $UsingItems = @($Items|?{$_ -is [Menuitem]})|%{
                Write-verbose "Menu choice $_"
                $_.parentId = $id
                $_
            }
        }
        elseif($PSCmdlet.ParameterSetName -eq "define")
        {
            Write-Verbose "Menu '$id': Getting items from scriptblock"
            $UsingItems = @($Definition.invoke()|?{$_ -is [Menuitem]})|%{
                Write-verbose "Menu choice $_"
                $_.parentId = $id
                $_
            }

        }

        Write-verbose "Found $($UsingItems.Count) items"
        if($UsingItems.count -eq 0)
        {
            throw "The menu '$id' doesent have any choices"
        }        
    }
    
    process {
        $Menu = [Menu]::new()
        $Menu.choices = $UsingItems
        $Menu.Name = $Name
        $Menu.description = $Description
        $Menu.id = $id
        $Menu.parentId = ""
        if($TitleWidth)
        {
            $Menu.TitleWidth = $TitleWidth
        }
        return $Menu


    }
    
    end {}
}