<#
.Synopsis 
  Get git for Windows and clone Profile-Utilities to profile directory

.Notes
# INITIAL git clone repo from GitHub
# Install git (source below) -- 

  where.exe git ## will find git if on path

  Get-WindowsGit.ps1  ## will download it (to $Home\Downloads by default)
  
#   Find project on GitHub -- search "Herb Martin" USERS Profile-Utilities
#    Clone (green button) copy URL, which is also on next line:
#      https://github.com/HerbM/Profile-Utilities

  md  (Split-Path) $Profile -ea 0 # OR:  md $Home\Documents\WindowsPowerShell -ea 0
  cd  (Split-Path) $Profile -ea 0 # OR:  cd $Home\Documents\WindowsPowerShell   
  git clone https://github.com/HerbM/Profile-Utilities . # DOT IF in Profile directory

# Subsequent git merge:  

  cd  (Split-Path) $Profile    # OR:   cd $ProfileDirectory  
  git status
  # git commit -a -m"Save my changes"   # git stash push FILENAME # -a save or commit your changes
  git pull    # all you need if you cloned 
  
#  C:\Program Files\Git\cmd\git.exe             # maybe
#  C:\ProgramData\chocolatey\bin\notepad++.exe
#  Is git installed? URL?
#  C:\ProgramData\chocolatey\bin\notepad++.exe  
#  What's the repo URL?  (https://github.com/HerbM/Profile-Utilities but how to find it)

git remote -v      # will show:
#  HerbProfile     https://github.com/HerbM/Profile-Utilities
#  HerbProfile     https://github.com/HerbM/Profile-Utilities

#  where.exe git # to find git, 'Where' alias points to 'Where-Object', so where.exe is hidden by default  

#>
[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param (
  [Alias('Url','Link')] [string]$uri='https://git-scm.com/download/win', # Windows Git page 
  [Alias('Directory')][string[]]$Path="$Home\Downloads",                 # downloaded file to path 
  [Alias('bit32','b32','old')][switch]$Bits32
)
                               
$VersionPattern = If ($bits32) { 'git-.*-32-bit.exe' } else { 'git-.*-64-bit.exe' }  
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$VimHelp = @'
  
  #
  # Exiting Vim - Git brings up Vim by default to edit
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

write-verbose "Uri: $Uri"    
$page = Invoke-WebRequest -Uri $uri -UseBasicParsing -verbose:$false # get the web page 
$dl   = ($page.links | where outerhtml -match $VersionPattern | 
  select -first 1 *).href                                 # download link latest 64-bit version
write-verbose "Link: $dl"  
$filename = split-path $dl -leaf                          # split out the filename
write-verbose "Filename: $filename"    
$out = Join-Path -Path $path -ChildPath $filename         # construct a filepath for the download 
write-verbose "Download save path: $out"    
if ($PSCmdlet.ShouldProcess("$dl", "Saving: $out`n")) {
  Invoke-WebRequest -uri $dl -OutFile $out -UseBasicParsing -verbose:$false # download file 
}  
Get-item $out | ForEach { "$($_.length) $($_.lastwritetime) $($_.fullname)" }

if (Test-Path $Out) {
  $Instructions = @"
    
    # $out to install Git"
    
    $out /verysilent
    $Env:Path += ';C:\Program Files\Git\cmd'
    cd  $Home\Documents -ea 0 # OR:  cd `$Home\Documents\WindowsPowerShell   
    git clone https://github.com/HerbM/Profile-Utilities WindowsPowerShell
        
    git remote -v      # will show:
    #  origin     https://github.com/HerbM/Profile-Utilities
    #  origin     https://github.com/HerbM/Profile-Utilities
 
    #  You will need a decent .gitprofile, usually in `$Home 
    #    $Home/.gitprofile
    #    but `$Env:Home may point somewhere else: [$($Env:Home)]
"@
  Write-Host $Instructions -fore white -back darkred
} else {
  "Download FAILED to $Out"
}

<#
# https://www.ssllabs.com/ssltest/index.html
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&latest
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&s=104.20.12.91&latest
                              
#>