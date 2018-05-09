Function Enable-PSTranscription {
  [CmdletBinding()]param(
    [Alias('LogPath','Path','Directory','TranscriptionPath')]$OutputDirectory,
    [switch]$IncludeInvocationHeader
  )
  $basePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
  If (!(Test-Path $basePath)) {
    $Null = New-Item $basePath -Force ## Ensure the base path exists
  }
  Set-ItemProperty $BasePath -Name EnableTranscripting -Value 1   ## Enable 
  If ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("OutputDirectory")) {
    Set-ItemProperty $basePath -Name OutputDirectory -Value $OutputDirectory
  }
  If ($IncludeInvocationHeader) {
    Set-ItemProperty $basePath -Name IncludeInvocationHeader -Value 1 ## Set header
  }
}

Function Disable-PSTranscription {
  $BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
  Remove-Item $BasePath -Force -Recurse
}

Function Get-PSTranscription {
  $BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
  Get-ChildItem $BasePath -Recurse
}

Function Enable-PSScriptBlockInvocationLogging {
  $BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
  If(!(Test-Path $BasePath)) {
    $Null = New-Item $BasePath -Force
  }
  Set-ItemProperty $basePath -Name EnableScriptBlockInvocationLogging -Value "1"
}

Function Disable-PSScriptBlockInvocationLogging {
  $BasePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
  If(!(Test-Path $BasePath)) {
    $Null = New-Item $BasePath -Force
  }
  Set-ItemProperty $basePath -Name EnableScriptBlockInvocationLogging -Value "0"
}

<#
The OutputDirectory setting lets you collect transcripts to a central location (UNC path) for later review. If you implement this policy, ensure that access to the central share is limited to prevent users from reading previously-written transcripts. The following PowerShell script creates a “Transcripts” SMB share on a server that follows this best practice.

md c:\Transcripts

## Kill all inherited permissions
$acl = Get-Acl c:\Transcripts
$acl.SetAccessRuleProtection($true, $false)

## Grant Administrators full control
$administrators = [System.Security.Principal.NTAccount] “Administrators”
$permission = $administrators,“FullControl”,“ObjectInherit,ContainerInherit”,“None”,“Allow”
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Grant everyone else Write and ReadAttributes. This prevents users from listing
## transcripts from other machines on the domain.
$everyone = [System.Security.Principal.NTAccount] “Everyone”
$permission = $everyone,“Write,ReadAttributes”,“ObjectInherit,ContainerInherit”,“None”,“Allow”
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Deny “Creator Owner” everything. This prevents users from
## viewing the content of previously written files.
$creatorOwner = [System.Security.Principal.NTAccount] “Creator Owner”
$permission = $creatorOwner,“FullControl”,“ObjectInherit,ContainerInherit”,“InheritOnly”,“Deny”
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Set the ACL
$acl | Set-Acl c:\Transcripts\

## Create the SMB Share, granting Everyone the right to read and write files. Specific
## actions will actually be enforced by the ACL on the file folder.
New-SmbShare -Name Transcripts -Path c:\Transcripts -ChangeAccess Everyone
#>