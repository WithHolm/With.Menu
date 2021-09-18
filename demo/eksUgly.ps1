# Menu for CLI (Save this excerpt in a new script file and run it in the CLI.)

# We usually clear the screen prior to displaying menus.

cls

# These next three linefeed [ESC] sequences move us down a bit from the top.

“`n`n`n”

<# Now, we need to position our choices in columns on the screen. We’ll use -f formatting. Note that column numbers begin with 1, but spacing from the left begins with 0. In this example, 40 columns are reserved for the first item (index 0) in our list. The second item (index 1) requires no extra spaces, and thus begins at column 41. Once we start framing our menu later, we’ll notice the off-by-one issue this causes. The “`t” is the TAB [ESC] character to give us a little left margin space.

#>

Write-Host (“{0,-40}{1,-0}” -f “`tA) Check free space on (C:)”,”C) Check BIOS version”) -ForegroundColor Yellow

Write-Host (“{0,-40}{1,-0}” -f “`tB) Check System Model Number”,”D) Check amount of installed RAM”) -ForegroundColor Yellow

# These next three linefeed (new line) [ESC] sequences move us down a bit from the menu.

“`n`n`n”

# Next, we ask the user to chose a menu item:

Write-Host “`tEnter Choice, or X to Exit: ” -ForegroundColor Yellow -NoNewline

# As in our previous example, we’ll use a WHILE loop, but this time, we’ll expect a single character.

while ($true) {

# Notice that the input opportunity comes within the WHILE loop. One advantage

# of using the ReadKey() method is that it moves forward after a single keypress. The

# ReadKey() method stores the single keypress character in its key property.

$choice = (([console]::ReadKey()).key)

# Some more line spacing for readability and appearance:

“`n`n”

# As in our previous example, we’ll use a SWITCH construct to evaluate the input.

# In this case, I’ve used some universally available real-world code for illustration.

# Notice that the character being compared matches our two-column menu created above.

Switch ($choice) {

“A” {“`r`t$([math]::round((get-volume c).SizeRemaining /1gb, 2)) GB`n”;exit}

“B” {“`r`t$((Get-WmiObject win32_computersystem)|

foreach{$_.Manufacturer+”–“+$_.model})`n”;exit}

“C” {“`r`t$((Get-WmiObject win32_bios).biosversion) `n”;exit}

“D” {“`r`t$((Get-WmiObject Win32_physicalmemory).capacity / 1gb) GB`n”;exit}

“X” {“`r`tBye!  `n`n” ;exit}

Default {Write-Host “`tInvalid choice. Try again:  ” `

-ForegroundColor Yellow -NoNewline}

}

}

# END