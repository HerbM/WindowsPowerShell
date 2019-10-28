Param(
  [Alias('Source')][Parameter(Mandatory)]
  [string]  $Drive,
  [string[]]$Directories = 'Util','Unx','Bat','ESB', 'Users\martinh\Documents', 'Users\martinh\Downloads',
  [string]  $DestinationRoot = 'C:\'
)

Set-StrictMode -Version Latest
If ($Drive -eq 'O') { $Drive = '\\TSClient\O' }
$XCopySwitches = '/s','/d','/y','/h','/r','/c'
$LogFile       = "$Home\XCopyLog.txt"
ForEach ($Dir in $Directories) {
  $DT          = Get-Date -f 's'
  $Source      = "$Drive\$Dir\*"
  $DirChild    = $Dir.trim('\') -replace '^.*\\' -replace '[^a-z]'
  $DTFile      = $DT -replace '\W'
  $LogFile     = "$Home\XCopyLog$DTFile-$DirChild.txt"
  $Destination = "$DestinationRoot\$Dir\"
  $Destination = $Destination -replace '\bmartinh\b', $Env:UserName
  If (Test-Path $Source -ea Ignore) { 
    Out-File  -in "$DT XCopy.exe $Source $Destination $XCopySwitches"  -File $LogFile -Append
    Write-Warning "$DT XCopy.exe $Source $Destination $XCopySwitches 2>&1 1>>$LogFile"
                       xcopy.exe $Source $Destination @XCopySwitches 2>&1 1>>$LogFile
  } else {
    Out-File  -in "$DT FILE:  $Source does not exist" -File $LogFile -Append
    Write-Warning "$DT ERROR: $Source does not exist" 
  } 
}
$DT = Get-Date -f 's'
Out-File  -in "$DT DONE: XCopy complete"     -File $LogFile -Append
Write-Warning "$DT DONE: XCopy complete, log is in $LogFile"
