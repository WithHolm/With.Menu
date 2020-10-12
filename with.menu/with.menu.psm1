class with_Menu_item{
    [With_Menutype]$Type
    [string]$id
    [String]$Name
    [string]$description
    [string]$parentId
    [string]ToString()
    {
        return "[$($this.Type)]:[$($this.id)]"
    }
}

class with_Menu:with_Menu_item{
    [with_Menutype]$Type = [with_Menutype]::Menu
    [with_Menureturn]$Returncode
    [int]$TitleWidth = 40
    [array]$choices
    [System.Collections.Generic.List[with_Menu_Status]]$Status
    new(){}
    
    [string]WithPadding([string]$String,[string]$pad="-")
    {
        $_String = $String
        if($_String.length -lt $this.TitleWidth)
        {
            $Padding = $this.PadLength($String.length) # [math]::Round(($this.TitleWidth-$String.length)/2)
            $addPadding = $("$pad"*$Padding)
            $_String = "$addPadding $String $addPadding"
        }
        return $_String
    }

    [int]PadLength([int]$LineLength)
    {
        $return = ([math]::Round(($this.TitleWidth-$LineLength)/2))
        if($return -lt 0)
        {
            $return = 0
        }
        return $return
    }

    [string]GetTitle()
    {
        return $this.Padding($this.Name,"-")
    }
}

class with_Menu_Choice:with_Menu_item{
    $action
    [with_Menutype]$Type = [with_Menutype]::Choice
    new(){}
}

class with_Menu_status:with_Menu_item{
    $action
    [with_Menutype]$Type = [with_Menutype]::Status
    [with_StatusType]$StatusType
    [int]$Line = 0
    [bool]$Colour = $false
    new(){}

    [string]ToString()
    {
        return "[$($this.Type)/$($this.StatusType)]:[$($this.id)]"
    }
}

enum with_StatusType{
    KeyValue = 0
    Line = 1
}

enum with_MenuReturn{
    NotFinished = 0
    Quit = 1
    Back = 2
    Error = 3
}

enum with_Menutype{
    Choice = 0
    Menu = 1
    Status = 2
}

gci "$PSScriptRoot\code" -File -Filter "*.ps1" -Recurse|?{$_.Directory.name -in "public","private"}|%{
    . $_.FullName
}