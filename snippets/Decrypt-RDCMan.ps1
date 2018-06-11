<#
.Synopsis
  Extract user credentials from RDCMan XML Files
.Description
  Extract user credentials from RDCMan XML Files
.Parameter Path
  Not implemented -- currently hard code
#>
#region    Parameters
[CmdletBinding(DefaultParameterSetName='String',PositionalBinding=$True)]param(
  
  [Parameter(
    Position                        = 0, 
    ParameterSetName                = 'String',
    ValueFromPipeline               = $true,
    ValueFromPipelineByPropertyName = $true
  )]
  [Alias('ProgramName','ScriptName')][string[]]$path = @(
    Join-Path "$Home\Documents" "*.rdg" -Resolve | Get-Item | Sort LastWriteTime -descending
  ),

  [Parameter(
    Position=0,
    ParameterSetName                = 'FileInfo',
    Mandatory=$true,                
    ValueFromPipeline               = $true,
    ValueFromPipelineByPropertyName = $true
  )]
  [Alias('LiteralPath')][System.IO.FileInfo]$FullName,
  
  [Alias(      'IncludeRawPassword', 'RawPassword')]       [switch]$Raw,
  [Alias('IncludeEncryptedPassword', 'EncryptedPassword')] [switch]$Encrypted,
  [Alias(            'BothPasswords',      'AllPasswords')][switch]$All
  
)
#endregion Parameters


try {            
  #region    Script scope Outer Try          
  #region    Initialization and Setup for Pester testing
  $Excluded = @()
  If ($Raw       -or $All) { $Excluded += 'Raw'       } 
  If ($Encrypted -or $All) { $Excluded += 'Encrypted' }  
  $Paths    = @('C:\Program*\*\R*D*C*Man*','C:\Program*\R*D*C*Man*')
  $RDCMan   = Join-Path $Paths 'RDCMan.exe' -Resolve -EA 0 | Select -First 1 # Path to RDG file
  $RDGFiles = $Path
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
      [pscustomobject]@{
        Domain    = $_.Node.domain
        Username  = $_.Node.userName
        Password  = $(
          Try { 
            [RdcMan.Encryption]::DecryptString($_.Node.password, $EncryptionSettings)
          } Catch { 
            "DECRYPTION_FAILED"; Write-Error $_
          } 
        )
        File      = $RDGFile
        Raw       = $_.Node.password
        Encrypted =  [RdcMan.Encryption]::EncryptString($_.Node.password, $EncryptionSettings) 
      } | Select-Object * -Exclude $Excluded
        #Group    = $_.Node.Group
        #Server   = $_.Node.Server
    } 
  }

  #endregion Script scope Outer Try
  #region    Outer Catch & Finally
} Catch { 
  Write-Warning "Caught error in outer Try of tests" 
  Throw                           # Just warn & rethrow error/exception
} Finally {
  # Pop-Location -StackName Script  # popd 
}         
  #region    Script scope Outer Catch & Finally
  
<#
        Raw       = If ($Raw -or $All) { $_.Node.password } Else { '' }
        Encrypted = If ($Raw -or $All) { 

https://smsagent.wordpress.com/2017/01/26/decrypting-remote-desktop-connection-manager-passwords-with-powershell
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