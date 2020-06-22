#NoTrayIcon
SetTitleMatchMode, 2
SetBatchLines, 10ms
SetWinDelay, 10
B = 1

;______Windows not to hide__________________
;These window titles will be immune to the Boss key.
;don't remove 'hid1 = Shell_TrayWnd'
hid1 = Shell_TrayWnd
hid2 = Microsoft Word

;______Apps to launch_______________________

;These apps will be launched when Boss key is pressed.
;Takes care of situation when you were not working at all!
;Syntax: FilePath|WinTitle

;Giving WinTitle will make the script NOT launch an app
;if its window already exists, not giving wintitle will
;make the app be launched unconditionally

Run1 = %windir%\system32\calc.exe|Calculator
Run2 = E:\dos\batch\messages.txt|messages.txt - Notepad

;______Set Hotkeys here_____________________

Hotkey, #z, Boss	;This is the Boss key

^#z::ExitApp		;As the icon is hidden, use this hotkey to exit the script

Exit

Boss:	
	;hides all windows with exceptions
	IfGreater, B, 0
	{
		;get all ids
		WinGet, id, list,,, Program Manager
		;loop for all windows
		Loop, %id%
		{
			StringTrimRight, this_id, id%a_index%, 0
			;get current win title
			WinGetTitle, title, ahk_id %this_id%
			;get current win class
			WinGetClass, class, ahk_id %this_id%
			ToHide = y
			;see if this is NOT to be hidden
			Loop
			{
				StringTrimRight, CWin, hid%A_Index%, 0
				IfEqual, CWin,, Break
				IfInString, title, %CWin%, SetEnv, ToHide, n
				IfInString, class, %CWin%, SetEnv, ToHide, n
				IfEqual, ToHide, n, Break
			}			
			;hide windows and keep a record of windows hidden
			IfEqual, ToHide, y
			{
				WinHide, ahk_id %this_id%
				HWins = %HWins%||%this_id%
			}
		}
	}
	
	;shows hidden windows
	IfLess, B, 0
	{
		;show windows
		Loop, Parse, HWins, ||
			WinShow, ahk_id %A_LoopField%
	}
	;opens work windows
	IfGreater, B, 0
	{
		Loop
		{
			StringTrimLeft, CRun, Run%A_Index%, 0
			IfEqual, CRun,, Break
			StringGetPos, ppos, CRun, |

			StringLeft, fpath, CRun, %ppos%
			IfEqual, fpath,, SetEnv, fpath, %CRun%

			StringTrimLeft, wname, CRun, %ppos%
			StringTrimLeft, wname, wname, 1

			WinShow, %wname%
			IfWinNotExist, %wname%,, IfExist, %fpath%, Run, %fpath%
		}
	}
	B *= -1
Return
