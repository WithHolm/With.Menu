enum with_MenuReturn
{
    NotFinished
    Quit
    Back
    Error
    Refresh
}

enum with_Menutype
{
    Choice
    Menu
    Status
    Filter
    Setting
    Selection
}

enum With_ClearScreenOn
{
    None
    Execution
    Menu
    All
}

enum With_Position
{
    Left
    Middle
    Right
}

enum with_WidthType
{
    Standard
    Precentage
}

class with_menu_item
{
    [With_Menutype]$Type
    [String]$Name
    [string]ToString()
    {
        return "[$($this.Type)]:[$($this.name)]"
    }
}

class With_Menu_ShowItem:with_menu_item
{
    [string]$Filter
    [bool]$FilterValue
}

class With_Menu_Writer
{
    [System.Collections.Generic.Dictionary[[int],[With_menu_LineItem[]]]]$Lines = [System.Collections.Generic.Dictionary[[int],[With_menu_LineItem[]]]]::new()

    [int]CurrentLine()
    {
        $ln = $this.Lines.count-1
        
        #if its empty, count will show 0 meaning ln will be -1
        #correct if it happens
        if($ln -lt 0)
        {
            $ln = 0
        }
        return $ln
    }

    [int]NextLine()
    {
        return $this.Lines.count
    }

    Add([With_menu_LineItem]$item)
    {
        $this.add($this.NextLine(),$item)
    }

    Add([int]$Line,[With_menu_LineItem]$item)
    {
        if($this.Lines.ContainsKey($Line))
        {
            if(@($this.Lines[$Line].type|select -Unique).count -gt 1)
            {
                throw "Cannot mix different status types on the same line: $($this.Lines[$Line].type -join ", ")"
            }
            $this.Lines[$Line] += $item
        }
        else {
            $this.Lines.Add($Line,$item)
        }
    }
}

Enum With_menu_lineItem_Type
{
    Divideline
    Title
    Choice
    Status
    Question
    Message
}



class With_menu_LineItem
{
    [With_menu_lineItem_Type]$type
    [string]$Text
    [System.ConsoleColor] $color = $((get-host).ui.rawui.ForegroundColor)
    [String]ToString()
    {
        return "[$($this.type)]:'$($this.text)'"
    }
}

Enum With_Menu_Setting_ConsoleTooSmall
{
    RetryOnce
    Error
    Ignore
}

enum With_Menu_Setting_ChoiceBracketType
{
    Sqarebracket
    Curlybracket
    Parenthesis
}

class with_menu_setting:with_menu_item
{
    [parameter(DontShow)]
    [String]$Name = "Settings"

    [parameter(DontShow)]
    [with_Menutype]$Type = [with_Menutype]::Setting
    
    [parameter(DontShow)]
    [string]$Id = [System.IO.Path]::GetRandomFileName() 

    hidden [Hashtable]$Hash = @{}
    
    #? When to clear screen.
    [parameter(HelpMessage="when to clear screen")]
    [With_ClearScreenOn]$ClearScreenOn = "None"
    
    #? What character to use as padding

    [parameter(HelpMessage="defines padding to use")]
    [ValidateLength(1,1)]
    [String]$PadChar = "-"
    
    #? Defines width or minimum width of -AutoAjustMenu is set to true 
    [parameter(HelpMessage="Defines width of menu. is overridden if one item in menu is wider and -AutoAjustMenu is set to true.")]
    [ValidateRange(10,999)]
    [int]$MenuWidth = 40

    #? Ajusts width of menu to match the longest string of characters in menu
    [parameter(HelpMessage="Automatically adjust size of menu if one of the items is wider than the menu")]
    [bool]$AutoAjustMenu = $true

    # #? If console is too small for the menu, what to do
    [parameter(Mandatory,HelpMessage = "If console is too small for the menu, what to do")]
    [With_Menu_Setting_ConsoleTooSmall]$ConsoleTooSmall = "RetryOnce"

    #? Where to position the menu in the console
    [parameter(HelpMessage="where on the screen to show the menu")]
    [With_Position]$MenuPosition = "Left"

    #? where to position the status in the menu
    [parameter(HelpMessage="where on the menu to show the status")]
    [With_Position]$StatusPosition = "Middle"
    
    #? Where to position the Title in the menu
    [parameter(HelpMessage="where on the menu to show the title")]
    [With_Position]$TitlePosition = "Middle"
    
    #? where to position choices in the menu
    [parameter(HelpMessage="where on the menu to show the choices")]
    [With_Position]$ChoicePosition = "Left"
    
    #? where to align the choices
    [parameter(HelpMessage="How to allign the choices on the menu")]
    [With_Position]$ChoiceAlignment = "Left"
    
    # [ValidateCount(2,2)]
    [With_Menu_Setting_ChoiceBracketType]$ChoiceBracketType = [With_Menu_Setting_ChoiceBracketType]::Sqarebracket

    [parameter(HelpMessage="Enable pester",DontShow)]
    [bool]$PesterEnabled = $false

    [parameter(HelpMessage = "Value that defines colors for true/false. default is green/red")]
    [ValidateCount(2,2)]
    [System.ConsoleColor[]]$StatusBoolColor = @("Green","Red")
    
    #? show 'press ok to continue' after execution of choices? Exists because of clearscreen
    [parameter(HelpMessage = "show 'press ok to continue' after execution of choices? Exists because of clearscreen")]
    [bool]$WaitAfterChoiceExecution = $true

    static [with_menu_setting] GetGlobal()
    {
        $Setting = [with_menu_setting]::new()
        if($setting.GlobalVar().Count -eq 0)
        {
            Write-debug "Could not find global settings. creating new"
            $Setting = New-MenuSetting
            $Setting.SetGlobal()
            # return (New-MenuSetting )
        }
        $Global = $Setting.GlobalVar()
        $global.keys|%{
            $Setting.$_ = $global.$_
        }
        $setting.Hash = $Setting.GlobalVar()
        return $Setting
    }

    hidden [hashtable] GlobalVar()
    {
        if($null -eq $Global:_MenuSettings)
        {
            $Global:_MenuSettings = @{}
        }
        return $Global:_MenuSettings
    }

    SetValue([string]$Key, $value)
    {
        if($this.Hash.ContainsKey($Key) -or $this.psobject.properties.name -contains $key)
        {
            $this.$key = $value
            $this.Hash.$key = $value
        }
        else {
            Throw "Cannot update settings. Could not find setting '$key'"
        }
    }

    SetGlobal()
    {
        $this.Hash.Clear()
        Foreach($item in $this.psobject.properties)
        {
            $this.Hash.$($item.name) = $item.value
        }
        $global = $this.GlobalVar()
        if($global.id -ne $this.id)
        {
            Write-verbose "Changing global options id from '$($global.id)' to '$($this.id)'"
        }
        $Global:_MenuSettings = $this.Hash
        # $global = $this.Hash
    }
}

class with_menu:With_Menu_ShowItem
{
    [with_Menutype]$Type = [with_Menutype]::Menu
    [with_Menureturn]$Returncode = [with_Menureturn]::NotFinished
    [array]$choices = @()
    [boolean]$IsRoot = $true
    [System.Collections.Generic.List[with_Menu_Message]]$Message = [System.Collections.Generic.List[with_Menu_Message]]::new()
    [System.Collections.Generic.List[with_Menu_Status]]$Status = [System.Collections.Generic.List[with_Menu_Status]]::new()
    [System.Collections.Generic.List[with_menu_filter]]$Filters = [System.Collections.Generic.List[with_menu_filter]]::new()
    [with_menu_setting]$Settings
    [guid]$_RunId
    new() {}

    NewRunId()
    {
        $this._RunId = [guid]::NewGuid()
    }

    [string]GetRunID()
    {
        if([string]::IsNullOrEmpty($this._RunId.Guid))
        {
            $this.NewRunId()
        }
        return $this._RunId.Guid
    }

    [With_menu_LineItem]GetTile()
    {
        $Item =[With_menu_LineItem]::new()
        $Item.type = "Title"
        $item.Text = $this.name
        return $item
    }
}

enum with_menu_selection_returnType
{
    int
    string
    object
}

enum with_menu_selection_optionalInput
{
    quit
    back
    refresh
    divideline
}

# enum with_menu_selection_acceptedInput
# {
#     int
# }

enum with_menu_selection_style
{
    classic
    prompt
}

class with_menu_selection:With_Menu_ShowItem
{
    $Definition
    [string]$Definitionkey
    # [System.Collections.Generic.List[with_menu_choice]]$action
    [with_Menutype]$Type = [with_Menutype]::Selection
    [with_menu_selection_returntype]$ReturnType = [with_menu_selection_returntype]::int
    [with_menu_selection_optionalInput[]]$OptionalInput = @()
    # [with_menu_selection_acceptedInput]$AcceptedInput = @()
    [with_menu_selection_style]$Style = [with_menu_selection_style]::classic
    [with_MenuReturn]$ReturnCode
    [bool]$ProcessAsMenu
    [bool]$PauseOnWrongAnswer
    new(){}
    [string]ToString()
    {
        return "[$($this.type)]"
    }
}

class with_menu_choice:With_Menu_ShowItem
{
    $action
    [with_Menutype]$Type = [with_Menutype]::Choice
    new() {}
}

class with_menu_message:With_Menu_ShowItem
{
    [System.ConsoleColor]$Color =  $((get-host).ui.rawui.ForegroundColor)
    [String]$Message
    [bool]$Wait = $false
}

enum with_StatusType
{
    keyVal = 0
    keyBool = 1
}

class with_menu_status:With_Menu_ShowItem
{
    $action
    [with_Menutype]$Type = [with_Menutype]::Status
    [with_StatusType]$StatusType = [with_StatusType]::keyVal
    [int]$Line = 0
    [System.ConsoleColor]$Color =  $((get-host).ui.rawui.ForegroundColor)
    [bool]$Boolean = $false
    new() {}

    [string]ToString()
    {
        return "[$($this.Type)/$($this.StatusType)]:[$($this.name)]"
    }

    [string] GetActionString()
    {
        $return = ""
        if ($this.action -is [scriptblock])
        {
            try
            {
                $return = Invoke-command $this.action -ErrorAction stop
            }
            catch
            {
                Write-warning "Error happened when processing option '$($this.name)':$($this.description)"
                Write-Error -ErrorRecord $_.Exception.InnerException.InnerException.ErrorRecord -RecommendedAction "Fix choice '$($this.name)'"
            }
        }
        else
        {
            $return = $this.action
        }
        return $return
    }
}

class with_menu_filter:with_menu_item
{
    [with_Menutype]$Type = [with_Menutype]::Filter
    [Scriptblock]$Filter
    [Scriptblock]$OnTrue
    [Scriptblock]$OnFalse
}