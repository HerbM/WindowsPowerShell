$Paths    = @('C:\Program*\*\R*D*C*Man*','C:\Program*\R*D*C*Man*')
$RDCMan   = Join-Path $Paths 'RDCMan.exe' -Resolve -EA 0 | Select -First 1 # Path to RDG file
$RDGFiles = Join-Path "$Home\Documents" "*.rdg" -Resolve | dir | Sort LastWriteTime -descending
$RDCDll   = Join-Path "$($Env:temp)" 'RDCMan.dll'
if (!(Test-Path $RDCDll)) { 
  Copy-Item $RDCMan $RDCDll -force -ea 0 
}
Write-Verbose "RDCMan: $RDCMan"
Import-Module $RDCDll
$EncryptionSettings = New-Object -TypeName RdcMan.EncryptionSettings 
ForEach ($RDGFile in $RDGFiles) {
  $XML = New-Object -TypeName XML
  $XML.Load($RDGFile)
  $logonCredentials = Select-XML -Xml $XML -XPath '//logonCredentials'   
  $Credentials      = New-Object System.Collections.Arraylist
  $logonCredentials | foreach {
    [void]$Credentials.Add([pscustomobject]@{
      Username  = $_.Node.userName
      Password  = $(Try { 
        [RdcMan.Encryption]::DecryptString($_.Node.password, $EncryptionSettings)
      } Catch { "FAILED"; Write-Verbose $_.Exception.Message } )
      Raw       = $_.Node.password
      Encrypted = [RdcMan.Encryption]::EncryptString($_.Node.password, $EncryptionSettings)
      Domain    = $_.Node.domain
      File      = $RDGFile
    })
  } | Sort UserName 
  $Credentials | Sort Username
}

<#
https://smsagent.wordpress.com/2017/01/26/decrypting-remote-desktop-connection-manager-passwords-with-powershell/

# Path to RDCMan.exe
$RDCMan = "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe"
# Path to RDG file
$RDGFile = "$env:USERPROFILE\Documents\RDPConnections.rdg"
$TempLocation = "C:\temp"
Copy-Item $RDCMan "$TempLocation\RDCMan.dll"
Import-Module "$TempLocation\RDCMan.dll"
$EncryptionSettings = New-Object -TypeName RdcMan.EncryptionSettings
 
$XML = New-Object -TypeName XML
$XML.Load($RDGFile)
$logonCredentials = Select-XML -Xml $XML -XPath '//logonCredentials'
 
$Credentials = New-Object System.Collections.Arraylist
$logonCredentials | foreach {
    [void]$Credentials.Add([pscustomobject]@{
    Username = $_.Node.userName
    Password = $(Try{[RdcMan.Encryption]::DecryptString($_.Node.password, $EncryptionSettings)}Catch{$_.Exception.InnerException.Message})
    Domain = $_.Node.domain
    })
    } | Sort Username 
$Credentials | Sort Username
#>