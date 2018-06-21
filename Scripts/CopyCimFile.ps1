<#
.Notes
  Once you’ve imported the function into your PowerShell session, you can easily invoke the function, 
  using the following syntax.
  ### Create a new CIM Session against the local system
  $MyCimSession = New-CimSession -ComputerName localhost
  ### Copy a file from the local system to the remote system
  Copy-FileByCim -CimSession $MyCimSession -LocalFile c:\windows\write.exe -RemoteFile c:\ArtofShell\write.exe
#>
function Copy-FileByCim {
  [CmdletBinding()]param(
    [Microsoft.Management.Infrastructure.CimSession]$CimSession, 
    [string]$LocalFile, 
    [string]$RemotePath
  )
  $Process = $Cim.GetClass('root\cimv2', 'Win32_Process')
  $Base64File = [System.Convert]::ToBase64String((Get-Content -Path $LocalFile -Encoding Byte -Raw))
  $Arguments = @{
    CommandLine = 'powershell.exe -Command "Set-Content -Path ''{0}'' -Value ([System.Convert]::FromBase64String(''{1}'')) -Encoding Byte; sleep 3"' -f $RemotePath, $Base64File
  }
  Write-Verbose -Message $Arguments.CommandLine
  $Result = Invoke-CimMethod -CimSession $CimSession -ClassName Win32_Process -MethodName Create -Arguments $Arguments
  Write-Output -InputObject $Result
}

