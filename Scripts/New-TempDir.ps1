function New-TemporaryDirectory {
  [CmdletBinding()]
  param(
    [Alias('Parent','Container')][string]$Path=([IO.Path]::GetTempPath()),
    [switch]$Force
  )
  if (!(Test-Path $Path)) { MkDir $Path -ea Stop }   # Stop if invalid path
  if (!(Test-Path $Path)) { throw "Path doesn't exit, cannot create: $Path"}
  do {
    write-verbose "Path/Temp1: [$Path] -> [$Temp]"
    $Temp = Join-Path $Path ([IO.Path]::GetRandomFileName())
    write-verbose "Path/Temp2: [$Path] -> [$Temp]"
    if ($Verbose) { Start-Sleep 3 }
  } while (Test-Path $Temp)
  (mkdir $Temp).FullName    #create directory with generated path
}

# ($Error.Exception)| % { $_.GetType().FullName } | group |sort count |select count, name
 
#function New-TemporaryDirectory ([string]$Path = '.\temp', [switch]$Create) {
#  if (!$Path) { $Path = '.' }
#  $tempDir = join-path $Path ([System.IO.Path]::GetRandomFileName())
#  if ($Create) {$dirResult = mkdir $tempDir -force -ea 0 -wa 0}
#  If (Test-Path $tempDir) { $tempDir } else { '.' }
#}  

#rd -force -recurse $tempDir
#function cmddir () {  
#}