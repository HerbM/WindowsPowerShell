# Git              https://git-scm.com/download/win
# Aria2            https://github.com/aria2/aria2/releases/tag/release-1.33.1
# Git Windows      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy              
# Git Windows      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy              
# PoSh-Git         https://github.com/PoshCode/PSGit/wiki/Command-Proposals 
# WinMerge 2011    https://portableapps.com/apps/utilities/winmerge-2011-portable    
# WinMerge /w Git? http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
# GitHubGist       Øyvind Kallstad https://gist.github.com/gravejester?page=2, https://gist.github.com/toenuff/6715170
# Babun (CygWin)   http://babun.github.io/
# qWinSta          mstsc /shadow:6 /noconsentprompt /control 
# Translate C#->PS https://github.com/LaurentDardenne/ExtensionMethod
# Recuva, CCleaner https://www.techradar.com/news/software/applications/the-best-free-system-utilities-and-tools-1323949
# NirSoft Pwd      https://lifehacker.com/5178222/top-10-tiny--awesome-windows-utilities
# NirSoftUtilities https://www.nirsoft.net/utils/index.html
#                  https://portableapps.com/
# Portable Apps    https://portableapps.com/redirect/?a=PAcPlatform&t=http%3A%2F%2Fdownloads.portableapps.com%2Fportableapps%2Fpacplatform%2FPortableApps.com_Platform_Setup_14.4.3.paf.exe
#   Apps           https://portableapps.com/apps
#   AkelPad Editor https://downloads.sourceforge.net/portableapps/AkelPadPortable_4.9.8.paf.exe
#   IrFanView      https://portableapps.com/apps/graphics_pictures/irfanview_portable
#   Links Portable https://portableapps.com/apps/internet/links-portable      
#   Lynx Portable  https://portableapps.com/apps/internet/lynx-portable
#   2X RDP         https://portableapps.com/apps/utilities/2x_client_portable
# SysInternals     https://download.sysinternals.com/files/SysinternalsSuite.zip Updated: February 13, 2018Feb 13, 2018
# SysInternalsNano https://download.sysinternals.com/files/SysinternalsSuite-Nano.zip
#   Forums         https://forum.sysinternals.com/
#                  Troubleshooting with the Windows Sysinternals Tools
# Gnu Win32        http://gnuwin32.sourceforge.net/
# UnxUtils         http://unxutils.sourceforge.net/
# Curl             https://curl.haxx.se/download.html
# Curl 7.58        https://bintray.com/artifact/download/vszakats/generic/curl-7.58.0-win64-mingw.7z
# Strawberry Perl  http://strawberryperl.com/download/5.26.1.1/strawberry-perl-5.26.1.1-64bit.msi
# Exiting Vim      Git brings up Vim by default to edit
#   :w - write (save) the file, but don't exit
#   :w !sudo tee % - write out the current file using sudo
#   :wq or :x or ZZ - write (save) and quit
#   :q - quit (fails if there are unsaved changes)
#   :q! or ZQ - quit and throw away unsaved changes
#   :wqa - write (save) and quit on all tabs
#
## Posh-Git
# Load posh-git example profile
# . 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1'
#if(Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}
Rename-Item Function:\Prompt PoshGitPrompt -Force
function Prompt() {if(Test-Path Function:\PrePoshGitPrompt){++$global:poshScope; New-Item function:\script:Write-host -value "param([object] `$object, `$backgroundColor, `$foregroundColor, [switch] `$nonewline) " -Force | Out-Null;$private:p = PrePoshGitPrompt; if(--$global:poshScope -eq 0) {Remove-Item function:\Write-Host -Force}}PoshGitPrompt}
# Load posh-git example profile
if (Test-Path 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1') { 
  . 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1' 

  
<#
# git reset --hard HEAD^   # delete commit  HEAD~2 (or higher number)
$env:psmodulepath -split ';'

$ProfileDirectory = Split-Path $Profile
If (! (Test-Path $ProfileDirectory)) { md $ProfileDirectory }
If ((Test-Path $ProfileDirectory -ea 0) -and (cd $ProfileDirectory -pass -ea 0) -and
  (Resolve-Path $ProfileDirectory -ea 0).Path -eq (Resolve-Path .).Path) { 
  cd $ProfileDirectory
  where.exe git
  if (where.exe 2>$null) {
    git --version
    if (!(Test-Path .git)) { git init }
    dir -force    # to see hidden .gitconfig file .git directory
    git remote add -t master HerbProfile https://github.com/HerbM/Profile-Utilities # name the remote
    git remote add -t master origin      https://github.com/HerbM/Profile-Utilities
    git remote -v
    git fetch --all
    git reset --hard HerbProfile/master
    git pull HerbProfile master
  }
}

set-psrepository  PSGallery -InstallationPolicy trusted

???
git ls-remote --heads origin
git fetch origin <branch>
git reset --hard <ref>
git clean -dfq

#From Toro
where.exe git
git --version
dir -force    # to see hidden .gitconfig file .git directory
git remote add HerbProfile https://github.com/HerbM/Profile-Utilities # name the remote
git remote -v
git init
git remote add HerbProfile https://github.com/HerbM/Profile-Utilities # name the remote
git fetch --all  # Force to current directory:
git reset --hard Herb Profile/master
git pull origin master

We did most of this on your 2016 server, maybe better.
move .\essential-git-sample.pdf .\books\Git\
git --version
where.exe git
.\Git-2.16.1.2-64-bit.exe
git init .
# git remote add -f github https://github.com/HerbM/Profile-Utilities
git remote add github https://github.com/HerbM/Profile-Utilities
git status
type .gitignore
git remote -v
git fetch --all
git reset --hard github/master
git pull github master
git config --global
function Select-History {param($Pattern) (h).commandline -match $Pattern }
new-alias sh Select-History -force -scope Global

#>
