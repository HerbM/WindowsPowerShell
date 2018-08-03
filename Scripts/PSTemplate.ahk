:*B:*dtx::  ; This hotstring replaces "]d" with the current date and time via the commands below.
FormatTime, CurrentDateTime,, yyyy/MM/dd HH:mm:ss  ; It will look like 9/1/2005 3:53 PM
SendInput %CurrentDateTime%
return

::text1::
(
Any text between the top and bottom parentheses is treated literally, including commas and percent signs.
By default, the hard carriage return (Enter) between the previous line and this one is also preserved.
    By default, the indentation (tab) to the left of this line is preserved.
  Begin { }
See continuation section for how to change these default behaviors.
)

:*B:*fun::
(
  Function T {
    [CmdletBinding()]param(
    
    `)
    Begin {  }
    Process {
    
    }
    End {  }
  }
)
