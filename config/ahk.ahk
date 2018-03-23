#SingleInstance force
#include c:\txt\user.ahk   ; include private user & security settings

;;;;;;;;;; #Hotstring EndChars -()[]{}:;'"/\,.?!`n `t
:*B:*ID::
send DASID
return

;;;;;;;  Hotstrings can't be simple replace, doesn't support variables
;:*:*WA::
send %DASFULL%
return
	;:*:*CT::
	;send %CITY%
	;return
	;:*:*ST::
	;send %STATE%
	;return
:*:*ADDR::
send %ADDRESS%
return

;;;;;;;;;;;   Hotkeys
^+a::send %DASID%
^+g::send %DASPW%
;^+h::send  herb.martin{tab}%DASPW%
^+l::send  %DASID%{tab}%DASPW%
^+m::send  martinh{tab}%DASPW%
^+q::send  q2cxHop@dmin
^+!q::send ibmadmin{tab}q2cxHop@dmin
^+r::send  river999
;^+s::send  S@pphire01$
^+w::send  %winid%
^+e::send  %Email%
^+n::send  %Name%


;^+'::send {Space}{tab}168.44.245.24{tab}255.255.254.0{tab}168.44.244.1{tab}168.44.244.61+{tab}+{tab}+{tab}{end}
;^+2::send  168.44.245.2
;^+3::send  168.44.245.38
;^+d::send  root{tab}calvin{Enter}  ; Dell hardware console
;^+e::send  Em3rald01$            


; following just left for reference (for now)
;;<+^i::Send ^a%CID%{tab}{tab}^a%Password%+{tab}^a%Password%
<^+p::Send %Password%
;<+^l::Send %CID%{tab}%Password%{enter}
;^+o::msgbox %CID%

;;;;;;;;;;;;;  Fix capsLock
; capsLock::shift        ; capsLock -> shift  ; formerly: CapsLock::Ctrl       
capsLock::Send {Home}        ; capsLock -> shift  ; formerly: CapsLock::Ctrl       
+capsLock::Send {End}
^capsLock::Send {PageUp}      
^+capsLock::Send {PageDown}      
!capsLock::Send {Up}  
+!capsLock::Send {Down}
>+CapsLock::Capslock   ; if we need CapsLock: right-shift-CapsLock -> Capslock
^+!v::Send %clipboard% ; SuperPaste:  ctrl-shift-alt-V paste clipboard by typing 


:*B:*dt::  ; This hotstring replaces "]d" with the current date and time via the commands below.
FormatTime, CurrentDateTime,, yyyy/MM/dd HH:mm:ss  ; It will look like 9/1/2005 3:53 PM
SendInput %CurrentDateTime%
return

;;;;;;;;;;  Reload this script on hotkey ctrl-alt-r
^!r::
Reload     ; Assign Ctrl-Alt-R as a hotkey to restart the script.
Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
IfMsgBox, Yes, Edit
return


#IfWinActive, ahk_class ConsoleWindowClass  ; just for Console CMD/PowerShell windows
{        
	f7::f8                         ; F7 is pretty worthless so map to F8 to avoid typos
	+f7::+f8                       ; F7 is pretty worthless so map to F8 to avoid typos
	f9::f8                         ; F9 is pretty worthless so map to F8 to avoid typos
	+f9::+f8                       ; F9 is pretty worthless so map to F8 to avoid typos
	^v::send {Escape}{RButton}     ; add 'paste' to console
	^!c::RButton                   ; add special 'copy' to console 
	^!v::send {RButton}{RButton}   ; copy & paste in one keypress
}		

;;;^{MButton}{Home}::send ^{Home}	
^+m::MsgBox 4 "The value in the variable named DASPW is " . DASPW . "."  


^>+i::
  msgbox Ctrl right-shift i
return	


 