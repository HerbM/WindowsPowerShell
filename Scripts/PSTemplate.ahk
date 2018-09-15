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

; Microsoft Outlook Security Notice
; ahk_class NUIDialog
; ahk_exe OUTLOOK.EXE

; Screen:	712, 466 (less often used)
; Window:	283, 188 (default)
; Client:	280, 166 (recommended)
; Color:	D4D0C8 (Red=D4 Green=D0 Blue=C8)

; ClassNN:	NetUIHWND1
; Text:	
; x: 3	y: 22	w: 444	h: 186
; Client:	x: 0	y: 0	w: 444	h: 186
; 
; x: 429	y: 278	w: 450	h: 211
; Client:			w: 444	h: 186
