# [CmdletBinding()] 
# Param([Parameter(ValueFromRemainingArguments)]$args)
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

Function Get-FileVersion {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsTransactions)] 
  [Alias('gfv','fv')]Param(
    [Parameter(ParameterSetName='Path', Position=0, 
      ValueFromPipeline, ValueFromPipelineByPropertyName)][string[]]$Path,
    [Parameter(ParameterSetName='LiteralPath', Mandatory, 
      ValueFromPipeline, ValueFromPipelineByPropertyName)]
      [Alias('PSPath','PathName')]                        [string[]]$LiteralPath,
    [Parameter(ParameterSetName='Service', Mandatory, ValueFromPipeline)]
      [System.Management.ManagementObject[]]                        $Service,
                                                            [Switch]$WriteTime = $Null,
    [Parameter(ParameterSetName='LiteralPath')]             
    [Parameter(ParameterSetName='Path')]                    [Switch]$Recurse   = $Null
  )
  Begin { 
    Function CleanPath {
      [CmdletBinding()]Param(
        [string[]]$Path
      )
      @(
        ForEach ($N in $Path) {
          If ($N -match '^\s+' -and 
            (!(Test-path -Literal $N)) -and
            (!(Test-path -Path    $N))) {
            @($N -replace '^[^a-z]+(am|pm)?[^a-z]+(?=[A-Z]:[\\/])')
            Write-Verbose "$(LINE) [$N]"
          } Else {
            Write-Verbose "$(LINE) [$N]"
            $N
          } 
        }
      )      
    }
    Function Get-ServicePath {
      [CmdletBinding()]Param(
        [System.Management.ManagementObject[]]$Service
      )
      @(
        ForEach ($S in $Service) {
          try {
            $Name = $Service.PathName -replace '^[''"](.+)[''"]$', '$1' 
            $Name = $Name -replace '\.exe\s+.*$', '.exe'
            Write-Verbose "Service: $Name"
            $Name
          } catch {
            Write-Verbose "Not a service with PathName???"  
          }
        }
      )      
    }
  }
  Process {
    # Write-Warning "Type: $($Path; $LiteralPath; $Service)"
    $ItemName = ''
    $Recurse  = If ($Recurse) { @{Recurse = $True} } Else { @{} }
    $Names    = @(If     ($Path)        { CleanPath $Path        } 
                  ElseIf ($LiteralPath) { CleanPath $LiteralPath }
                  ElseIf ($Service)     { $ItemName = $Service.Name
                                          Get-ServicePath $Service                
                  }
                  Else                  { Write-Error 'No input';         RETURN  }
    )
    Write-Verbose "PropertySet: $($PSCmdlet.ParameterSetName)"
    $PSDefaultParameterSet = @{}
    Get-ChildItem @Names -ea Ignore @Recurse | ForEach-Object {
      Write-Verbose $_.Fullname; $_ | ForEach {
        # es 7z.exe | dir | ForEach { $LWT = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm'); $Len=$_.Length; $_ } | Select -expand VersionInfo | Select  ProductVersion,@{N='LastWriteTime';E={$LWT}}, @{N='Length';E={$Len}},FileName | Sort LastWriteTime
        $LWT  = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
        $Len  = $_.Length; 
        $_ 
      } | Select -expand VersionInfo | ForEach {
        If ($WriteTime) {
          [PSCustomObject]@{
            Product       = $_.ProductVersion
            LastWriteTime = $LWT 
            Length        = $Len
            Name          = $ItemName
            FullName      = $_.FileName
          }  
        } Else { $_ }  
      } 
    }
  }
  End {}  
}

<#
$Width, $Height = ($host.ui.rawui.WindowSize).Width,($host.ui.rawui.WindowSize).Height
Get-Content .\Microsoft.PowerShell_profile.ps1 | ForEach {$Line = 0} {
  If (!((++$Line + 1) % $Height)) {
   $host.ui.rawui.flushinputbuffer(); $host.ui.rawui.readkey(2+8) | ft *; 
   $_ 
}
 AllowCtrlC     = 1
 IncludeKeyDown = 2  #<<<<  2 is NoEcho
 IncludeKeyUp   = 4
 NoEcho         = 8  #<<<<  4 & 9 are key up/down, not sure which is which
  While (1){$host.ui.rawui.flushinputbuffer(); $host.ui.rawui.readkey(2)} 
#>

Write-Verbose "Command line: [$($MyInvocation.Line | Out-String -stream)]"
If ($MyInvocation.Line -notmatch '^\W*\.\W') {
  Get-FileVersion @PSBoundParameters
}

# tmlbl/TypedFunctions.jl
# marius311/SelfFunctions.jl
# Pkg.clone("https://github.com/swadey/LispSyntax.jl")