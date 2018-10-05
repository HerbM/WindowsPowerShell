[CmdletBinding()] 
Param([Parameter(ValueFromRemainingArguments)]$args)

Function Get-FileVersion {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsTransactions)] 
  [Alias('gfv','fv')]Param(
    [Parameter(ParameterSetName='Path', Position=0, 
      ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [string]$Path,
    [Parameter(ParameterSetName='LiteralPath', Mandatory, 
      ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [Alias('PSPath','PathName')][string]$LiteralPath,
    [Parameter(ParameterSetName='LiteralPath')]
    [Parameter(ParameterSetName='Path')]
    [Switch]$WriteTime = $Null,
    [Parameter(ParameterSetName='LiteralPath')]
    [Parameter(ParameterSetName='Path')]
    [Switch]$Recurse = $Null
  )
  Begin {
  }
  Process {
    $Recurse = If ($Recurse) { @{Recurse = $True} } Else { @{} }
    $Names   = If     ($Path)        { @{Path        = $Path}        } 
               ElseIf ($LiteralPath) { @{LiteralPath = $LiteralPath} }
               Else                  { '*'                           }
    Write-Verbose "PropertySet: $($PSCmdlet.ParameterSetName)"
    Get-ChildItem @Names -file -ea Ignore @Recurse | ForEach-Object {
      Write-Verbose $_.Fullname; $_ |    
      ForEach { 
        # es 7z.exe | dir | ForEach { $LWT = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'); $Len=$_.Length; $_ } | Select -expand VersionInfo | Select  ProductVersion,@{N='LastWriteTime';E={$LWT}}, @{N='Length';E={$Len}},FileName | Sort LastWriteTime
        $LWT = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        $Len=$_.Length; $_ 
      } | Select -expand VersionInfo | ForEach {
        If ($WriteTime) {
          [PSCustomObject]@{
            Product       = $_.ProductVersion
            LastWriteTime = $LWT 
            Length        = $Len
            FullName      = $_.FileName
          }  
        } Else { $_ }  
      } 
    }
  }
  End {}  
}

Write-Verbose "Command line: [$($MyInvocation.Line | Out-String -stream)]"
If ($MyInvocation.Line -notmatch '^\W*\.\W') {
  Get-FileVersion @args
}
