# My idiosyncratic PowerShell utilities and profile
(tested on Windows PowerShell 5+ & 7+)

## Use the following line to download & install Git if not present:

```
If ($PWD -match '\b(System32|Windows|Program\sFile.*$|C:\\)') { Push-Location (Join-Path $Home 'Downloads') }; Invoke-WebRequest https://raw.githubusercontent.com/HerbM/WindowsPowerShell/master/Scripts/Get-WindowsGit.ps1 -out Get-WindowsGit.ps1; ./Get-WindowsGit -install; cd $Home\Documents; & 'c:\Program Files\Git\bin\git' clone https://github.com/HerbM/WindowsPowerShell
```

## The command above downloads the following script:

```ps
<#
.Synopsis
  Get git for Windows and clone WindowsPowerShell to profile directory

.Notes
# INITIAL git clone repo from GitHub
# Install git (source below) --

  where.exe git ## will find git if on path

  Get-WindowsGit.ps1  ## will download it (to $Home\Downloads by default)

#   Find project on GitHub -- search "Herb Martin" USERS WindowsPowerShell
#    Clone (green button) copy URL, which is also on next line:
#      https://github.com/HerbM/WindowsPowerShell



  git remote -v      # will show:
  #  origin     https://github.com/HerbM/WindowsPowerShell
  #  origin     https://github.com/HerbM/WindowsPowerShell

  #  Eventually you will need a decent .gitprofile, usually in $Home
  #    $Home/.gitprofile
  #    but `$Env:Home may point somewhere else: [$($Env:Home)]

  md  (Split-Path) $Profile -ea 0 # OR:  md $Home\Documents\WindowsPowerShell -ea 0
  cd  (Split-Path) $Profile -ea 0 # OR:  cd $Home\Documents\WindowsPowerShell
  git clone https://github.com/HerbM/WindowsPowerShell . # DOT IF in Profile directory

# Subsequent git merge:

  cd  (Split-Path) $Profile    # OR:   cd $ProfileDirectory
  git status
  # git commit -a -m"Save my changes"   # git stash push FILENAME # -a save or commit your changes
  git pull    # all you need if you cloned

#  C:\Program Files\Git\cmd\git.exe             # maybe
#  C:\ProgramData\chocolatey\bin\notepad++.exe
#  Is git installed? URL?
#  C:\ProgramData\chocolatey\bin\notepad++.exe
#  What's the repo URL?  (https://github.com/HerbM/WindowsPowerShell but how to find it)

git remote -v      # will show:
#  HerbProfile     https://github.com/HerbM/WindowsPowerShell
#  HerbProfile     https://github.com/HerbM/WindowsPowerShell

#  where.exe git # to find git, 'Where' alias points to 'Where-Object', so where.exe is hidden by default

#>
[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param (
  [Alias('Url','Link')] [string]$uri='https://git-scm.com/download/win', # Windows Git page
  [Alias('Directory')][string[]]$Path="$Home\Downloads",                 # downloaded file to path
  [Alias('GitInstall')][switch]$Install,
  [Alias('bit32','b32','old')][switch]$Bits32
)

$VersionPattern = If ($bits32) { 'git-.*-32-bit.exe' } else { 'git-.*-64-bit.exe' }
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
<#
$VimHelp = @'

  # By default Git runs Vim to edit commits automatically
  # How to Exit Vim (with & without saving changes)
  #   :w - write (save) the file, but don't exit
  #   :w !sudo tee % - write out the current file using sudo
  #   :wq or :x or ZZ - write (save) and quit
  #   :q - quit (fails if there are unsaved changes)
  #   :q! or ZQ - quit and throw away unsaved changes
  #   :wqa - write (save) and quit on all tabs
  #
  #  https://vim.rtorr.com/
  #  http://www.viemu.com/vi-vim-cheat-sheet.gif
  #  http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html
  #  https://github.com/hackjutsu/vim-cheatsheet  Text, you can paste or git
  #  http://vimsheet.com/
  #  http://vimsheet.com/advanced.html
  #    "The best possible resource on vim is the book Practical Vim.
  #    https://www.amazon.com/Practical-Vim-Thought-Pragmatic-Programmers/dp/1934356980

'@   # <<<<<<<<<<<<<<< do NOT INDENT, must be a left margin
write-host $VimHelp -fore yellow -back darkblue
#>

If ($PWD -match '\b(System32|Windows|Program\sFile.*)$') {
  $Local:OldDir = $Pwd
  Write-Warning "Changing out of $PWD to prevent loading this accidentally in a bad place"
  Write-Warning ""
  Push-Location Join-Path $Home 'Downloads'
  Write-Warning "To return to $OldDir type:  popd"
}
Write-Verbose "Uri: $Uri"
$Page = Invoke-WebRequest -Uri $Uri -UseBasicParsing -verbose:$false # get the web page
$InstallerUri = ($page.links | where outerhtml -match $VersionPattern | Select -first 1 *).href                                 # download link latest 64-bit version
Write-Verbose "Installer Uri: $InstallerUri"
$FileName = Split-Path $InstallerUri -leaf                          # split out the filename
Write-Verbose "Filename: $filename"
$InstallerlPath = Join-Path -Path $path -ChildPath $filename         # construct a filepath for the download
Write-Verbose "Download save path: $InstallerlPath"
if ($PSCmdlet.ShouldProcess("$InstallerUri", "Saving: $InstallerlPath`n")) {
  Invoke-WebRequest -uri $InstallerUri -OutFile $InstallerlPath -UseBasicParsing -verbose:$false # download file
}
Get-item $InstallerlPath | ForEach { "$($_.length) $($_.lastwritetime) $($_.fullname)" }

# $PSVersionTable.PSVersion -gt [Version]'6.0'

if (Test-Path $InstallerlPath) {
  If ($Install) {
    Write-Warning "Running git install: $InstallerlPath /verysilent"
    & $InstallerlPath /verysilent
    If (!(Get-Command git -CommandType Application -ea Ignore) -and
         ($Env:Path -notmatch 'C:.Program Files.*\bGit.cmd')) {
      If ($Bits32) { $Env:Path += ';C:\Program Files\Git\cmd' }
      Else         { $Env:Path += ';C:\Program Files (x86)\Git\cmd' }
    }
  }
  # $InstallerlPath /verysilent # To install Git"
  Write-Host (' ' * 72) -fore white -back darkcyan
  $Instructions = @"

    # RUN THESE COMMANDS IF you don't already have a PowerShell profile:
    `$Env:Path += ';C:\Program Files\Git\cmd'   # or restart PowerShell
    cd `$Home\Documents -ea ignore              # if you don't have a Profile
    # Windows PowerShell through 5.x
    git clone https://github.com/HerbM/WindowsPowerShell WindowsPowerShell

    # PowerShell 7+
    git clone https://github.com/HerbM/WindowsPowerShell PowerShell

    # To load new profile the first time, or reload later
    . `$Profile            # or restart PowerShell console to autoload profile

"@
  Write-Host $Instructions -fore white -back darkblue
  Write-Host (' ' * 72) -fore white -back darkcyan
  Write-Host ''
} else {
  "Download FAILED to $InstallerlPath"
}

<#
# https://www.ssllabs.com/ssltest/index.html
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&latest
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&s=104.20.12.91&latest

#>

```