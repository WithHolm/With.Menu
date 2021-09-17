using System.Collections.Generic;
using System;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;
public class ConsoleModifier
{
    //https://docs.microsoft.com/en-us/windows/console/setconsolemode
    [DllImport("kernel32.dll", SetLastError = true)]
    static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll")]
    static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll")]
    static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);

    public static IntPtr GetConsoleFatures(ConsoleFeatureHandle UsingHandle)
    {
        return GetStdHandle((int)UsingHandle);
    }
    private static void SetConsoleFeature(List<System.UInt32> Features, ConsoleFeatureHandle UsingHandle, bool Enable)
    {
        IntPtr consoleHandle = GetStdHandle((int)UsingHandle);

        uint consoleMode;
        if (!GetConsoleMode(consoleHandle, out consoleMode))
        {
            throw new System.Exception($"Unable to get consoleMode using handle {UsingHandle}");
        }

        if (Enable)
        {
            Features.ForEach(
                m =>
                    consoleMode &= ~m
            );
        }
        else
        {
            Features.ForEach(
                m =>
                    consoleMode |= m
            );

        }

        // set the new mode
        if (!SetConsoleMode(consoleHandle, consoleMode))
        {
            throw new System.Exception($"Unable to set consoleMode using handle {UsingHandle}");
        }
    }
    public static void EnableConsoleInput(List<ConsoleInputMode> ConsoleModes)
    {
        var PassUint = new List<System.UInt32>();
        ConsoleModes.ForEach(
            m =>
                PassUint.Add((System.UInt32)m)
        );
        SetConsoleFeature(PassUint, ConsoleFeatureHandle.INPUT_HANDLE, true);
    }
    public static void EnableConsoleOutput(List<ConsoleOutputMode> ConsoleModes)
    {
        var PassUint = new List<System.UInt32>();
        ConsoleModes.ForEach(
            m =>
                PassUint.Add((System.UInt32)m)
        );
        SetConsoleFeature(PassUint, ConsoleFeatureHandle.OUTPUT_HANDLE, true);
    }
    public static void DisableConsoleInput(List<ConsoleInputMode> ConsoleModes)
    {
        var PassUint = new List<System.UInt32>();
        ConsoleModes.ForEach(
            m =>
                PassUint.Add((System.UInt32)m)
        );
        SetConsoleFeature(PassUint, ConsoleFeatureHandle.INPUT_HANDLE, false);
    }
    public static void DisableConsoleOutput(List<ConsoleOutputMode> ConsoleModes)
    {
        var PassUint = new List<System.UInt32>();
        ConsoleModes.ForEach(
            m =>
                PassUint.Add((System.UInt32)m)
        );
        SetConsoleFeature(PassUint, ConsoleFeatureHandle.OUTPUT_HANDLE, false);
    }
}

public class ConsoleFeature
{
    public Enum Handle;
    public Enum Mode;
    public Boolean Enabled;
    public int ModeInt;

    public ConsoleFeature(ConsoleInputMode Mode)
    {
        this.Handle = ConsoleFeatureHandle.INPUT_HANDLE;
        this.Mode = Mode;
        this.Enabled = false;
        this.ModeInt = (int)Mode;
    }
    public ConsoleFeature(ConsoleOutputMode Mode)
    {
        this.Handle = ConsoleFeatureHandle.OUTPUT_HANDLE;
        this.Mode = Mode;
        this.Enabled = false;
        this.ModeInt = (int)Mode;
    }
}

public enum ConsoleFeatureHandle
{
    INPUT_HANDLE = -10,
    OUTPUT_HANDLE = -11
}

public enum ConsoleInputMode
{
    ENABLE_PROCESSED_INPUT = 1,
    ENABLE_LINE_INPUT = 2,
    ENABLE_ECHO_INPUT = 4,
    ENABLE_WINDOW_INPUT = 8,
    ENABLE_MOUSE_INPUT = 16,
    ENABLE_INSERT_MODE = 32,
    ENABLE_QUICK_EDIT_MODE = 64,
    ENABLE_VIRTUAL_TERMINAL_INPUT = 512
}

public enum ConsoleOutputMode
{
    ENABLE_PROCESSED_OUTPUT = 1,
    ENABLE_WRAP_AT_EOL_OUTPUT = 2,
    ENABLE_VIRTUAL_TERMINAL_PROCESSING = 4,
    DISABLE_NEWLINE_AUTO_RETURN = 8,
    ENABLE_LVB_GRID_WORLDWIDE = 16
}