using System.Collections.Generic;
using System.Drawing;
using System;

public interface IUiChar
{
    string Type { get; }

    string UiKey { get; set; }

    List<point> Coords { get; set; }

    point NowCoord { get; set; }

    bool shouldDelete { get; set; }

    ConsoleColor BackgroundColor { get; set; }
    ConsoleColor TextColor { get; set; }

    string Value { get; set; }

    string id { get; set; }

    int state { get; set; }

    int initstate { get; set; }

    Int64 AddedMs { get; set; }

    void NextFrame();
    void GenerateId();
    void update();
    void cleanup();
}

public enum AnsiColor
{
    Default = 0,
    NoBright = 22
}

