<#
.Notes
  How to Change PowerShell Console Font and Background Colors -- Jeff Hicks
  https://www.petri.com/change-powershell-console-font-and-background-colors
  Colors https://github.com/lukesampson/concfg
#>
[CmdletBinding()]param(
  [Object[]]$Object, 
  [switch]$ShowPSReadLine,
  [switch]$Main,
  [switch]$Private
) 
  
Function Get-ColorOption {
  [CmdletBinding()]param(
    [Object[]]$Object, 
    [switch]$ShowPSReadLine,
    [switch]$Main,
    [switch]$Private
  ) 
  ForEach ($O in $Object) {
    $PropertyNames = ($O | gm -member *property* *color*).name
    ForEach ($Name in $PropertyNames) {
      $Fore = $Null
      If ($Name -match 'Fore') {
        $Other = 'Back'        
      } else {
        $Other = 'Fore'
      }
      $OtherName = $Name -replace 'Fore|Back', $Other 
      Write-Verbose "$(LINE) ColorName: $Name $($O.$Name) OtherName: $OtherName $($O.$OtherName)"
      $Fore = $O.$Name
      $Back = $O.$OtherName
      If (!$Fore) { $Fore = 'White' } 
      If (!$Back) { $Back = 'Black' }
      Write-Warning "$(LINE) ColorName: $Name $($O.$Name) OtherName: $OtherName $($O.$OtherName)"
      Write-Host    "         $(LINE) ColorName: $Name $Fore OtherName: $OtherName $Back" -Fore $Fore -Back $Back
    }
  }
}  

$Token      = [tokenkind]::GetNames([tokenkind]) # |gm -me method -static
If ($Main) { 
  $MainColors = ($Host.UI.RawUI  | gm -member *property* *color*).name # fore / back
  $MainColors 
}
If ($Private) { 
  $Private    = ($host.PrivateData | gm -member *property* *color*).name # all colors Error,Warning,Debug,Verbose,Progress  Fore/Back color
  $Private 
}
get-ColorOption $host.PrivateData
If ($ShowPSReadLine) {
  $PSreadlineOptions = (get-psreadlineoption | gm -member *property* *color*).name
  $PSreadlineOptions
  (gcm -syn set-psreadlineoption) -replace '<\w+>' -split '\W+' | ? { $_ -match 'Color$' }
}

<#
https://blogs.msdn.microsoft.com/commandline/2017/06/20/understanding-windows-console-host-settings/
Windows 10 https://blogs.msdn.microsoft.com/commandline/2017/08/02/updating-the-windows-console-colors/

Hierarchy of loaded settings
  Hardcoded settings in conhostv2.dll
  'HKCU\Console' User's configured Console defaults, stored as values in 
  'HKCU\Console\<sub-key>' 
      Per-Console-application registry settings, stored as sub-keys,  
      using one of two sub-key names:
      Console application path (replacing '\' with '_')
      Console title
  Windows shortcut (.lnk) files

    
ContinuationPromptForegroundColor
ContinuationPromptBackgroundColor
EmphasisForegroundColor
EmphasisBackgroundColor
ErrorForegroundColor
ErrorBackgroundColor
ForegroundColor
BackgroundColor

Windows 10 https://blogs.msdn.microsoft.com/commandline/2017/08/02/updating-the-windows-console-colors/
Color Name 	Console Legacy RGB Values 	New Default RGB Values
BLACK 	0,0,0 	12,12,12
DARK_BLUE 	0,0,128 	0,55,218
DARK_GREEN 	0,128,0 	19,161,14
DARK_CYAN 	0,128,128 	58,150,221
DARK_RED 	128,0,0 	197,15,31
DARK_MAGENTA 	128,0,128 	136,23,152
DARK_YELLOW 	128,128,0 	193,156,0
DARK_WHITE 	192,192,192 	204,204,204
BRIGHT_BLACK 	128,128,128 	118,118,118
BRIGHT_BLUE 	0,0,255 	59,120,255
BRIGHT_GREEN 	0,255,0 	22,198,12
BRIGHT_CYAN 	0,255,255 	97,214,214
BRIGHT_RED 	255,0,0 	231,72,86
BRIGHT_MAGENTA 	255,0,255 	180,0,158
BRIGHT_YELLOW 	255,255,0 	249,241,165
WHITE 	255,255,255 	242,242,242

 
ContinuationPromptForegroundColor      : DarkYellow
ContinuationPromptBackgroundColor      : DarkMagenta
DefaultTokenForegroundColor            : Yellow
CommentForegroundColor                 : Green
KeywordForegroundColor                 : Green
StringForegroundColor                  : Cyan
OperatorForegroundColor                : White
VariableForegroundColor                : Green
CommandForegroundColor                 : Yellow
ParameterForegroundColor               : Cyan
TypeForegroundColor                    : White
NumberForegroundColor                  : White
MemberForegroundColor                  : White
DefaultTokenBackgroundColor            : DarkMagenta
CommentBackgroundColor                 : DarkBlue
KeywordBackgroundColor                 : DarkMagenta
StringBackgroundColor                  : DarkMagenta
OperatorBackgroundColor                : DarkMagenta
VariableBackgroundColor                : DarkMagenta
CommandBackgroundColor                 : DarkMagenta
ParameterBackgroundColor               : DarkMagenta
TypeBackgroundColor                    : DarkMagenta
NumberBackgroundColor                  : DarkMagenta
MemberBackgroundColor                  : DarkMagenta
EmphasisForegroundColor                : Cyan
EmphasisBackgroundColor                : DarkMagenta
ErrorForegroundColor                   : Red
ErrorBackgroundColor                   : DarkMagenta

Unknown
Variable
SplattedVariable
Parameter
Number
Label
Identifier
Generic
NewLine
LineContinuation
Comment
EndOfInput
StringLiteral
StringExpandable
HereStringLiteral
HereStringExpandable
LParen
RParen
LCurly
RCurly
LBracket
RBracket
AtParen
AtCurly
DollarParen
Semi
AndAnd
OrOr
Ampersand
Pipe
Comma
MinusMinus
PlusPlus
DotDot
ColonColon
Dot
Exclaim
Multiply
Divide
Rem
Plus
Minus
Equals
PlusEquals
MinusEquals
MultiplyEquals
DivideEquals
RemainderEquals
Redirection
RedirectInStd
Format
Not
Bnot
And
Or
Xor
Band
Bor
Bxor
Join
Ieq
Ine
Ige
Igt
Ilt
Ile
Ilike
Inotlike
Imatch
Inotmatch
Ireplace
Icontains
Inotcontains
Iin
Inotin
Isplit
Ceq
Cne
Cge
Cgt
Clt
Cle
Clike
Cnotlike
Cmatch
Cnotmatch
Creplace
Ccontains
Cnotcontains
Cin
Cnotin
Csplit
Is
IsNot
As
PostfixPlusPlus
PostfixMinusMinus
Shl
Shr
Colon
Begin
Break
Catch
Class
Continue
Data
Define
Do
Dynamicparam
Else
ElseIf
End
Exit
Filter
Finally
For
Foreach
From
Function
If
In
Param
Process
Return
Switch
Throw
Trap
Try
Until
Using
Var
While
Workflow
Parallel
Sequence
InlineScript
Configuration
DynamicKeyword
Public
Private
Static
Interface
Enum
Namespace
Module
Type
Assembly
Command
Hidden
Base

#>
