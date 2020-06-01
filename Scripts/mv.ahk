#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetCapsLockState AlwaysOff

Movement  := { h:"Left", j:"Down", k:"Up",   l:"Right", u:"PgUp", m:"PgDn", y:"Home", n:"End"  }
ShiftKeys := ["LShift","RShift","LCtrl","RCtrl","RAlt","LAlt","LWin","RWin"]

SendKeyWithState(Key) {
  Global ShiftKeys
  Global Movement
  If (Move := Movement[Key]) {
    KeyPrefix := KeyPostfix := ""
    For index, ModKey in ShiftKeys {
      If GetKeyState(ModKey, "P") {
        KeyPrefix := KeyPrefix "{" ModKey " Down}"
        KeyPostfix := "{" ModKey " Up}" KeyPostfix
      }
    }
    KeyState := KeyPrefix "{" Move "}" KeyPostfix
    Send %KeyState%   
  } 
} 

;ModeSwitch := {CapsLock}
;%ModeSwitch% & h::SendKeyWithState("h")
CapsLock & h::SendKeyWithState("h")
CapsLock & j::SendKeyWithState("j")
CapsLock & k::SendKeyWithState("k")
CapsLock & l::SendKeyWithState("l")
CapsLock & u::SendKeyWithState("u")
CapsLock & m::SendKeyWithState("m")
CapsLock & y::SendKeyWithState("y")
CapsLock & n::SendKeyWithState("n")

#If (A_PriorHotkey = "Capslock" and A_TimeSincePriorHotkey < 1000)
CapsLock::
SetCapsLockState Off
SetCapsLockState AlwaysOff
Send {ESC}
OutPutDebug, "This is a test"
return
#If
