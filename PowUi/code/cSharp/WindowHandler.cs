using System;
using System.Runtime.InteropServices;
using System.Collections;

public class Window {
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(
        IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public extern static bool MoveWindow( 
        IntPtr handle, int x, int y, int width, int height, bool redraw);

    [DllImport("user32.dll")] 
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(
        IntPtr handle, int state);

    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr GetConsoleWindow();

    //Enum windows, so i can support getting windows that might be out of scope due to third pary (non microsoft) window frameworks (thanx, electron)
    // if this can be sped up in some way, please let me know
    public delegate bool EnumedWindow(IntPtr handleWindow, ArrayList handles);

      [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
      [return: MarshalAs(UnmanagedType.Bool)]
      public static extern bool EnumWindows(EnumedWindow lpEnumFunc, ArrayList lParam);

      public static ArrayList GetWindows()
      {    
     ArrayList windowHandles = new ArrayList();
     EnumedWindow callBackPtr = GetWindowHandle;
     EnumWindows(callBackPtr, windowHandles);

        return windowHandles;    
      }

      private static bool GetWindowHandle(IntPtr windowHandle, ArrayList windowHandles)
      {
     windowHandles.Add(windowHandle);
     return true;
      }
}

public struct RECT
{
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}