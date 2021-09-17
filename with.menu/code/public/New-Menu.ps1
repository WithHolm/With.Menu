function New-Menu {
    [CmdletBinding()]
    [outputtype([with_menu])]
    param (
        [parameter(mandatory, Position=0)]
        [string]$Title,
        
        [parameter(mandatory, Position=1)]
        [Scriptblock]$Definition
    )
    
    begin {
        $Menu = [with_Menu]::new()
        
        $Menu.Name = $Title
        $Menu.IsRoot = $true
    }
    
    process {
        #Get Menu Items
        $MenuItems = @((Invoke-Scriptblock -InputItem $Definition -Identificator $Menu.ToString()))

        #Get Menu Filters
        $MenuItems|?{$_ -is [with_menu_filter]}|%{
            Write-verbose "found $_"

            $Flt = $_

            #extract items that should come forwards on true
            if(![string]::IsNullOrEmpty($_.onTrue))
            {
                $Menuitems += Invoke-Scriptblock -inputitem $Flt.ontrue -Identificator "$flt`:[onTrue]"|?{$_ -is [with_menu_showitem]}|%{
                    $_.Filter = $flt.name
                    $_.filtervalue = $true
                    $_
                }
            }

            #extract items that should come forwards on false
            if(![string]::IsNullOrEmpty($Flt.onFalse))
            {
                $Menuitems += Invoke-Scriptblock -inputitem $Flt.onFalse -Identificator "$flt`:[onFalse]"|?{$_ -is [with_menu_showitem]}|%{
                    $_.Filter = $flt.name
                    $_.filtervalue = $false
                    $_
                }
            }
            $Menu.Filters.Add($Flt)
            # $Flt
        }
        
        #test that names are unique
        $MenuItems.name|select -Unique|%{
            $name = $_
            #if there are more than 1 item with the same name, throw
            if(($MenuItems.where{$_.name -eq $name}).count -gt 1)
            {
                throw "You cannot have multiple menu items named '$name': $(($MenuItems.where{$_.name -eq $name}) -join ", ")"
            }
        }

        #STATUS
        Request-MenuStatus -Array $MenuItems|%{
            $Menu.Status.Add($_)
        }

        #CHOICES
        $Menu.choices = Request-MenuChoices -Array $MenuItems

        #SETTINGS
        $Menu.Settings = Request-MenuSetting -Array $MenuItems

        #MESSAGE
        Request-MenuMessage -Array $MenuItems|%{
            $Menu.Message.add($_)
        }
    }
    
    end {
        return $Menu
    }
}