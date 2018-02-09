# Git              https://git-scm.com/download/win
# Aria2            https://github.com/aria2/aria2/releases/tag/release-1.33.1
# Git Windows      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy              
# Git Windows      http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy              
# PoSh-Git         https://github.com/PoshCode/PSGit/wiki/Command-Proposals 
# WinMerg          http://developeronfire.com/blog/configuration-of-git-on-windows-to-make-life-easy
# GitHubGist       Øyvind Kallstad https://gist.github.com/gravejester?page=2, https://gist.github.com/toenuff/6715170
# Babun (CygWin)   http://babun.github.io/

#WinMerge with Git
# Posh-Git
# Load posh-git example profile
# . 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1'
#if(Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}
Rename-Item Function:\Prompt PoshGitPrompt -Force
function Prompt() {if(Test-Path Function:\PrePoshGitPrompt){++$global:poshScope; New-Item function:\script:Write-host -value "param([object] `$object, `$backgroundColor, `$foregroundColor, [switch] `$nonewline) " -Force | Out-Null;$private:p = PrePoshGitPrompt; if(--$global:poshScope -eq 0) {Remove-Item function:\Write-Host -Force}}PoshGitPrompt}
# Load posh-git example profile
if (Test-Path 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1') { 
  . 'C:\tools\poshgit\dahlbyk-posh-git-a1795ab\profile.example.ps1' 

  
<#
$env:psmodulepath -split ';'
md WindowsPowerShell
cd .\WindowsPowerShell\
where.exe git
git --version
dir -force
git remote add HerbProfile https://github.com/HerbM/Profile-Utilities
git remote -v
git fetch --all
git reset --hard HerbProfile/master
git pull HerbProfile master
cd S:\Programs\Portable\

???
git ls-remote --heads origin
git fetch origin <branch>
git reset --hard <ref>
git clean -dfq


From Toro
git init
git remote add -f github https://github.com/HerbM/Profile-Utilities

git fetch --all  # Force to current directory:
git reset --hard origin/master
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
