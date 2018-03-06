# My idiosyncratic PowerShell utilities and profile -- much of this is junky but I need to get it under source control.

# Use the following to download Git if not present:

```
[CmdLetBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
param (
  [Alias('Url','Link')] [string]$uri='https://git-scm.com/download/win', # Windows Git page 
  [Alias('Directory')][string[]]$Path="$Home\Downloads",                 # downloaded file to path 
  [Alias('bit32','b32','old')][switch]$Bits32
)

$VersionPattern = If ($bits32) { 'git-.*-32-bit.exe' } else { 'git-.*-64-bit.exe' }  
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

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

Exit
```
