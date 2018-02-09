<# gcm, help, gm  (get-member, get-help, get-command)

SOMETHING | foreach-object %, where-object ?, sort-object  # main work horses to pipe to these functions

The truth about ForEach is VERY UGLY.  Their are 4 or 5 ForEach's -- and they aren't the same
  Don't tell people at first (until they are ready)

	What is ForEach
		CmdLet?  	        ForEach-Object is a CmdLet (with alias foreach)
		alias?              YES!!!!!!!!!!!!!!!!!!  (maybe)
		function?
		method?
		control-structure?
		operator?           (fortunately not but could be -replace does this)
		
#>

$myarray3 = 1, 4, 0, 9, 3 
foreach ($n in $myarray3) { 
  "The value is: " + $n
}

$myarray,$myarray2,$myarray3 |
Foreach-Object {
  Foreach ($x in $_) {
   "ForEach Keyword say: $x" 
  };
  "-" * 50
}

<#	
0. Open a PowerShell prompt every time you logon to any machine
1. STOP USING EXPLORER


if (SOMETHING) { DO_THIS }  # if is a Language Element:  Control structure (key word, reserved)

Dnn't tell NEW people this unless they are already programmers
	PowerShell all variables have a $ up front
	------------
	Perl variables start with one of:   $, %, @   $scalar, @array, %hash
#>

	