class Menuitem{
    [Menutype]$Type
    [string]$id
    [String]$Name
    [string]$description
    [string]$parentId
    [string]ToString()
    {
        return "[$($this.Type)]:[$($this.id)]"
    }
}

class MenuChoice:Menuitem{
    $action
    [Menutype]$Type = [Menutype]::Choice
    new(){}
}

class Menu:Menuitem{
    [Menutype]$Type = [Menutype]::Menu
    [Menureturn]$Returncode
    [int]$TitleWidth = 40
    [array]$choices
    new(){}

    [string]WithPadding([string]$String)
    {
        $_String = $String
        if($_String.length -lt $this.TitleWidth)
        {
            $Padding = [math]::Round(($this.TitleWidth-$String.length)/2)
            $_String = "$('-'*$Padding)$String$('-'*$Padding)"
        }
        return $_String
    }
    [string]GetTitle()
    {
        return $this.WithPadding($this.Name)
    }
}

enum MenuReturn{
    NotFinished = 0
    Quit = 1
    Back = 2
    Error = 3
}

enum Menutype{
    Choice = 0
    Menu = 1
}

gci "$PSScriptRoot\code" -File -Filter "*.ps1" -Recurse|?{$_.Directory.name -in "public","private"}|%{
    . $_.FullName
}