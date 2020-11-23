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
        # $Menu.description = "$Description"
        $Menu.IsRoot = $true
        # if(![string]::IsNullOrEmpty($FilterName))
        # {
        #     $Menu.filter = $FilterName
        #     $Menu.FilterValue = $FilterValue
        # }

        # Write-verbose "$menu Processing"
    }
    
    process {
        $MenuItems = (Invoke-Scriptblock -InputItem $Definition -Identificator $Menu.ToString())

        #FILTERS
        $Menu.Filters = @(Request-MenuFilters -Array $MenuItems)|%{
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

            $Flt
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

        #TESTS


        # return $menu
        # return $Menu
        # $Menu.choices = request-MenuChoices -input $Array

        # $Setting = $using|?{$_ -is [with_menu_setting]}
        # if($setting)
        # {
        #     $menu.settings = $Setting|select -first 1
        # }

        # $Menu.filters = [System.Collections.Generic.List[with_Menu_Filter]]::new()
        # $using|?{$_ -is [with_menu_filter]}|%{
        #     Write-verbose "status $_"
        #     $menu.filters.Add($_)
        # }

        
            
        # # = [System.Collections.Generic.List[with_Menu_Status]]::new((Request-MenuStatus -))
        # # $using|?{$_ -is [with_Menu_status]}|%{
        # #     Write-verbose "status $_"
        # #     $menu.Status.Add($_)
        # # }

        # Foreach($filt in $menu.filters)
        # {
        #     if(@($menu.filters|?{$_.name -eq $filt.name}).count -gt 1)
        #     {
        #         Throw "Cannot have multiple filters with the same name"
        #     }
        # }

        # foreach($status in $Menu.status)
        # {
        #     #check for conflicting statuses (statuses that have the same line, but not the same type)
        #     $conflictingStatus = ($Menu.status|?{$_.line -eq $status.line -and $_.StatusType -ne $status.StatusType})
        #     if(($Menu.status|?{$_.line -eq $status.line -and $_.StatusType -ne $status.StatusType}))
        #     {
        #         throw "'$($status.Name)' Keyvalue status cannot share a line with line statuses: $($conflictingStatus.name -join ", ")"
        #     }

        #     #check if defined filter exists for item
        #     if(![string]::IsNullOrEmpty($status.filter))
        #     {
        #         if(!$menu.filters.where{$_.name -eq $status.filter})
        #         {
        #             throw "Cannot find filter '$($status.filter)' defined for $status"
        #         }
        #     }
        # }

        # foreach($item in $menu.choices)
        # {
        #     #check if defined filter exists for item
        #     if(![string]::IsNullOrEmpty($item.filter))
        #     {
        #         if(!$menu.filters.where{$_.name -eq $item.filter})
        #         {
        #             throw "Cannot find filter '$($status.filter)' defined for $item"
        #         }
        #     }
        # }

        # Write-verbose "Found $($Menu.choices.Count) choices and $($menu.status.Count) statuses"
        # # if($Menu.choices.count -eq 0 -and $Menu.status.count -eq 0)
        # # {
        # #     throw "The menu '$name' doesent have any choices or statuses"
        # # }        
        # return $Menu
    }
    
    end {
        return $Menu
    }
}