[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param (
  [Alias('Url','Link')] [string]$uri='https://git-scm.com/download/win', # Windows Git page 
  [Alias('Directory')][string[]]$Path="$Home\Downloads",                 # downloaded file to path 
  [Alias('bit32','b32','old')][switch]$Bits32
)
# https://www.ssllabs.com/ssltest/index.html
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&latest
# https://www.ssllabs.com/ssltest/analyze.html?d=git-scm.com&s=104.20.12.91&latest
                               
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
Get-item $out | ForEach { "$($_.length) $($_.lastwrittentime) $($_.fullname)" }

