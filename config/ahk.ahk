#SingleInstance force
#include c:\txt\user.ahk   ; include private user & security settings
; this line should be put on top (auto-exec) section of ahk script
SetTimer  SuspendOnRDPMaximized, 500

; this actual code label and the fn can be put anywhere in the script file
SuspendOnRDPMaximized:
If WinActive("ahk_class TscShellContainerClass") {
  WinGet maxOrMin, MinMax, ahk_class TscShellContainerClass
  if (maxOrMin = 0) {
    WinGetPos PosX, PosY, WinWidth, WinHeight, ahk_class TscShellContainerClass
    if (PosY = 0) {  ; it is fully maximized
        Suspend On
        WinWaitNotActive ahk_class TscShellContainerClass
        Suspend Off
    }
  }
}
If WinActive("aWindowsForms10.Window.8.app.0.3d90434_r12_ad1") {
  WinGet maxOrMin, MinMax, ahk_class TscShellContainerClass
  if (maxOrMin = 0) {
    WinGetPos PosX, PosY, WinWidth, WinHeight, ahk_class TscShellContainerClass
    if (PosY = 0) {  ; it is fully maximized
      Suspend On
      WinWaitNotActive ahk_class TscShellContainerClass
      Suspend Off
    }
  }
}
return

:C1*:**DAS::
send %DASID%
return
:C1*:**DAT::
send . D:\
send %DASID%
send \t.ps1
return
;;;;;;;;;; #Hotstring EndChars -()[]{}:;'"/\,.?!`n `t
:C1*:**ID::
send %DASID%
return
;;;;;;;  Hotstrings can't be simple replace, doesn't support variables
:C1*:**WA::
send %DASFULL%
return
:C1*:**HMTX::send Herb.Martin@TXDCS.onmicrosoft.com
:C1*:**CT::
send %CITY%
return
:C1*:**ST::
send %STATE%
return
:C1*:**AD::
send %ADDRESS%
return
:C1*:**QP::
send %QPWD%
return
:C1*:**NQ::
send %NEWQPWD%
return
:C1*:**SF1::
send 204.67.13.42
return
:C1*:**SF2::
send 204.67.13.43
return
:C1*:**WID::
send %winid%
return
:C1*:**HG::
send %HomeEmail%
return
:C1*:**HA::
send %WorkEmail%
return
:C1*:**@W::
send %WorkEmail%
return
:C1*:**HM::
send %@Wme%
return
:C1*:**AI::
send %DASID%
return
:C1*:**PIN::
send %PIN%
return
:C1*:**RM::
send %RBANG%
return
:C1*:**R$::
send %RBANG%
return
:C1*:**SN::
send %ServiceNow%
return
:C1*:**q2::
send %QPWD%
return
:C1*:**AZ::
send %AZURE%
return
;; :~:**::
;; send %%
;; return
:C1*:**RW::
send $Host.PrivateData.ErrorBackgroundColor   = 'DarkRed';$Host.PrivateData.ErrorForegroundColor   = 'White'
return
:C1*:**PW::
send %Password%
return
:C1*:**P1::
send %Password1%
return
:C1*:**PP::
send %Password%
return
:C1*:**Py::
send %Passwordy%
return
:C1*:**PO::
send %PasswordOld%
return
:C1*:**PN::
send %PasswordNew%
return
;; :~:**::
;; send %%
;; return


;;;;;;;;;;;   Hotkeys
;^+a::send %DASID%
;^+!a::send %RBANG%   ; send %DCSBANG%
;^+!p::send %PIN%
;^+g::send %PW2%
;^+h::send herb.martin{tab}%DASPW%
;^+l::send %DASID%{tab}%DASPW%
;^+m::send martinh{tab}%DASPW%
;^+q::send %QPWD%
;+!q::send %NewQPWD%
;^+!q::send %AZURE%
;+!q::send %TXD%
;^+!q::send ibmadmin{tab}%QPWD%  ; not tested after change

;^+'::send {Space}{tab}168.44.245.24{tab}255.255.254.0{tab}168.44.244.1{tab}168.44.244.61+{tab}+{tab}+{tab}{end}
;^+2::send  168.44.245.2
;^+3::send  168.44.245.38
;^+d::send .\DCSADmin 

; following just left for reference (for now)
;;<+^i::Send ^a%CID%{tab}{tab}^a%Password%+{tab}^a%Password%
;<^+o::Send %PasswordOld%
;<^+p::Send %Password%

;<^+n::Send %PasswordNew%
;<+^l::Send %CID%{tab}%Password%{enter}
;^+o::msgbox %CID%

;*^o::Send This is O  ;  This works but *CapsLock doesn't
;;;;;;;;;;;;;  Fix capsLock
;;;; SetCapsLockState AlwaysOff
;;;;  Capslock & j::
;;;;    Send {down}
;;;;    sleep 5
;;;;  return  
;;;;  Capslock & h::Send {left}
;;;;  Capslock & k::Send {up}
;;;;  Capslock & l::Send {right}
;;;;  #capsLock::shift        ; capsLock -> shift  ; formerly: CapsLock::Ctrl       
>^>+CapsLock::Capslock   ; if we need CapsLock: right-shift-CapsLock -> Capslock
;;;; #If (A_PriorHotkey = "Capslock" and A_TimeSincePriorHotkey < 1000)
;;;; CapsLock::Send {ESC}
;;;; #If
;;;; Capslock::SetCapsLockState Off
;;;; #If (A_PriorHotkey = "Capslock" and A_TimeSincePriorHotkey < 8000)
;;;;;;;;;;  Reload this script on hotkey ctrl-alt-r
^!+r::
Reload     ; Assign Ctrl-Alt-R as a hotkey to restart the script.
Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
MsgBox 4,, "The script could not be reloaded. Would you like to open it for editing?"
IfMsgBox Yes, Edit
return

::**sw::| Sort-Object LastWriteTime
::**sc::| Sort-Object CreationTime
::**sa::| Sort-Object LastAccessTime
::**sfl:: -file | Sort-Object Length
::**so::| Sort-Object 
::**wo::| Where-Object `{  `}
::**?::| Where-Object  `{  `} 
::**wb::| Where-Object `{ $_. `}{Left}{Left}{Left}
::**wn::| Where-Object `{ $_ `} 
::**wm::| Where-Object `{ $_. -match '' `}
::**fe::| ForEach-Object `{ $_ `}
::**fs::| ForEach-Object `{  `}
::**sl::| Select-Object 
::**sf::| Select-Object -First 
::**sl::| Select-Object -Last 
::**su::| Select-Object -Unique 
::**sl::| Select-Object -Last 
::**sp::| Select-Object -Skip 
::**ep::| Select-Object -Expand 
::**xc::| Select-Object -Exclude 
::**xp::| Select-Object -Expand 
::**ec::| Select-Object -Exclude 
::**sz::| Select-Object -SkipLast 
::**ss::| Select-String ''{Left}
::**sls::| Select-String ''{Left}
::**ta::| Format-Table 
::**ft::| Format-Table 
::**fl::| Format-List -Force *  
::**li::| Format-List -Force * 
::**fi::ForEach () "`{`}"{Left} 
::**fo::For ($i`+`+`; $i -le `; $i++) `{`}{Left} 
::**of::| Out-File -encoding ASCII 
::| fl::| Format-List -Force *
::**sy::Get-Command -syntax  
::**syn::Get-Command -syntax  
;;#If
:*C1:##fun::{Enter}Function Get-XYZ {{}{Enter}  [CmdletBinding()]Param({Enter}){Enter}Begin {{}{}}{Enter}Process {{}{}}{Enter}End {{}{}}{Enter}{BackSpace 2}

Numpad0 & p::Send "{space}| ForEach-Object {{} $_ {}}{space}{Left}{Left}{Left}"
Numpad0 & f::Send "ForEach-Object {{} $_ {}}{space}{Left}{Left}{Left}"
Numpad0 & v::SendPlay %clipboard% ; SuperPaste:  ctrl-shift-alt-V paste clipboard by typing 
Numpad0::Send {Numpad0}
^+!v::Send %clipboard%            ; SuperPaste:  ctrl-shift-alt-V paste clipboard by typing 
SC121::Home
SC110::End
SC122::PgUp
SC119::PgDn

:*:**dt::  ; replace "**dt" with current date & time
FormatTime,CurrentDateTime,,yyyy-MM-ddTHH:mm:ss
FormatTime,DayOfWeek,,ddd             ; couldn't get DOW appended to format above
SendInput %CurrentDateTime% %DayOfWeek%
return 
:C1*:**dw::Send "Get-ChildItem | Sort-Object LastWriteTime{space}"  ; Hotstring replaces "**dw" 
:C1*:**fe::Send "ForEach-Object {{} $_ {}}{space}{Left}{Left}{Left}" 
:C1*:**gm::
Send %GMailAddress%
return
:C1*:**ghpw::
Send %GitHubWP%
return
:C1*:**bp::
Send %BothPhoneSMS%
return
:C1*:**wp::
Send %WorkPhoneSMS%
return
:C1*:**hp::
Send %HomePhoneSMS%
return
:C1*:**spw::
Send %Simple%
return
:C1*:**r9::
Send %Ok%
return
:C1*:**r$::
:C1*:**r4::
Send %Better%
return
:C1*:**opw::
Send %PasswordOld%
return
:C1*:**pwb::
Send %Better%
return

;ClipSaved := ClipboardAll   
;Clipboard := ClipSaved   
;ClipSaved =   ;

;;;^{MButton}{Home}::send ^{Home}  
;;;^+m::MsgBox 4 "The value in the variable named DASPW is " . DASPW . "."  

;; ^+!::
;;   while (1) {
;;     if ()
;;     return
;;   }
;; return

;^>+i::msgbox Ctrl right-shift i

SetTitleMatchMode, 2
SetTitleMatchMode, Slow
#IfWinActive, ahk_class ConsoleWindowClass  ; just for Console CMD/PowerShell windows
{        
  f7::f8                          ; F7 is worthless, map to F8, avoids typos
 +f7::+f8                         ; F7 is worthless, map to F8, avoids typos
  f9::f8                          ; F9 is worthless, map to F8, avoids typos
 +f9::+f8                         ; F9 is worthless, map to F8, avoids typos
}    

; just for Console CMD windows
SetTitleMatchMode, 2
SetTitleMatchMode, Slow
#IfWinActive Prompt
^v::send {Escape}{RButton}               ; add 'paste' to console
^!c::RButton                    ; add special 'copy' to console 
;^!v::send {RButton}{RButton}    ; copy & paste in one keypress
return

;ahk_class WindowsForms10.Window.8.app.0.2a125d8_r12_ad1
#IfWinActive , .*Remote.*Desktop.*  
F7::F8
F9::F8

#IfWinActive ahk_class WindowsForms10.Window.8.app.0.2a125d8_r12_ad1
F7::F8
F9::F8

#IfWinActive, "^Less(\s.*)*"
^c::q
^C::q

#IfWinActive, ahk_class ConsoleWindowClass  ; just for Console CMD/PowerShell windows

; Replicate the CTRL + D "duplicate line" functionality I'm used to from Visual Studio:
; make ctrl+d duplicate line in SQL
SetTitleMatchMode, 2
#IfWinActive, Microsoft SQL Server Management Studio
^d::    
    ; save clipboard
    SavedClipboard = %clipboard%
    Send {Home}
    Send +{End}
    Send ^c
    ClipWait
    Send {End}
    Send {Enter}
    Send ^v
    clipboard = %SavedClipboard%
    return

; make ctrl+d duplicate line in SQL
;SetTitleMatchMode, 2
;#IfWinActive, Microsoft SQL Server Management Studio
;^d::    
;    ; save clipboard
;    Send ^c
;    ClipWait
;    Send ^v
;    Send ^v
;    return 

