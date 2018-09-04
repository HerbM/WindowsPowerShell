<#
  #requires -version 5.1
  This is a copy of:
  CommandType  Name         Version   Source
  -----------  ----         -------   ------
  Cmdlet       Set-Location 3.1.0.0   Microsoft.PowerShell.Management

  Created: 26 April, 2018
  Author : Herb Martin
#>

Set-StrictMode -Version Latest

Function x86 { '(x86)' }

Function Set-Location {
<#
.SYNOPSIS
  Sets the current working location to a specified location.
.DESCRIPTION
  The  cmdlet sets the working location to a specified location. That location could be a directory, a sub-directory, a registry location, or any provider path.
  You can also use the StackName parameter of to make a named location stack the current location stack. For more information about location stacks, see the Notes.
  It enhances the standard Set-Location by allowing the targe to be a file.
  If the target is a file, the location is set to the file's parent directory
.PARAMETER LiteralPath
  Specifies a path of the location. The value of the LiteralPath parameter is used exactly as it is typed. No characters are interpreted as wildcard characters. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any characters as escape sequences.
  Or a file path
.PARAMETER PassThru
  Returns a System.Management.Automation.PathInfo object that represents the location. By default, this cmdlet does not generate any output.
.PARAMETER Path
  Specify the path of a new working location.
  Or a file path
.PARAMETER StackName
  Specifies the location stack name that this cmdlet makes the current location stack. Enter a location stack name. To indicate the unnamed default location stack, type $Null" or an empty string ("").
  The Location cmdlets act on the current stack unless you use the StackName parameter to specify a different stack.
.PARAMETER UseTransaction
  Includes the command in the active transaction. This parameter is valid only when a transaction is in progress. For more information, see Includes the command in the active transaction. This parameter is valid only when a transaction is in progress. For more information, see
.EXAMPLE
  PS C:\> -Path "HKLM:"
  PS HKLM:\>
  This command sets the current location to the root of the HKLM: drive.
.EXAMPLE
  PS C:\> -Path "Env:" -PassThru
  Path
  ----
  Env:\
  PS Env:\>
  This command sets the current location to the root of the Env: drive. It uses the PassThru parameter to direct Windows PowerShell to return a PathInfo object that represents the Env: location.
.EXAMPLE
  PS C:\> C:
  This command sets the current location C: drive in the file system provider.
.EXAMPLE
  PS C:\> -StackName "WSManPaths"
  This command makes the WSManPaths location stack the current location stack.
  The location cmdlets use the current location stack unless a different location stack is specified in the command. For information about location stacks, see the Notes.
.EXAMPLE
  Set-Location $Profile
  Changes to the directory where the PowerShell Profile is located
.NOTES
  The  * cmdlet is designed to work with the data exposed by any provider. To list the providers available in your session, type `Get-PSProvider`. For more information, see about_Providers.
  A stack is a last-in, first-out list in which only the most recently added item can be accessed. You add items to a stack in the order that you use them, and then retrieve them for use in the reverse order. Windows PowerShell lets you store provider locations in location stacks. Windows PowerShell creates an unnamed default location stack. You can create multiple named location stacks. If you do not specify a stack name, Windows PowerShell uses the current location stack. By default, the unnamed default location is the current location stack, but you can use the  cmdlet to change the current location stack.
  To manage location stacks, use the Windows PowerShell Location cmdlets, as follows:
  - To add a location to a location stack, use the Push-Location cmdlet.
  - To get a location from a location stack, use the Pop-Location cmdlet.
  - To display the locations in the current location stack, use the Stack parameter of the Get-Location cmdlet. To display the locations in a named location stack, use the StackName parameter of Get-Location . - To create a new location stack, use the StackName parameter of Push-Location . If you specify a stack that does not exist, Push-Location creates the stack. - To make a location stack the current location stack, use the StackName parameter of  .
  The unnamed default location stack is fully accessible only when it is the current location stack. If you make a named location stack the current location stack, you cannot no longer use Push-Location or Pop-Location cmdlets add or get items from the default stack or use Get-Location to display the locations in the unnamed stack. To make the unnamed stack the current stack, use the StackName parameter of  with a value of $Null or an empty string ("").
  *
  .INPUTS
  System.String
.OUTPUTS
  None, System.Management.Automation.PathInfo, System.Management.Automation.PathInfoStack
.LINK
  http://go.microsoft.com/fwlink/?LinkId=821632
.LINK
  Online Version:
.LINK
  Get-Location
.LINK
  Pop-Location
.LINK
  Push-Location
#>
  [CmdletBinding(DefaultParameterSetName='Path', SupportsTransactions=$true)]
  Param(
    [Parameter(ParameterSetName='Path', Position=0, ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)][string]$Path,
    [Parameter(ParameterSetName='Path', ValueFromRemainingArguments)][string[]]$PathArgs,
    [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')][string]$LiteralPath,
    [switch]$PassThru,
    [Alias('s','pp','providerpath','string')][switch]$Simple,
    [Parameter(ParameterSetName='Stack', ValueFromPipelineByPropertyName=$true)]
      [string]$StackName
  )
  Begin {
    Set-StrictMode -Version Latest
    $P = ''
    If (!(Get-Command LINE -ea Ignore)) { Function LINE { $MyInvocation.ScriptLineNumber }}
    Set-StrictMode -version Latest
    Write-Verbose ("$(LINE) BEGIN Set:$($PSCmdlet.ParameterSetName) " +
                   ($PSBoundParameters | Out-String))
    If ($PSBoundParameters.ContainsKey('Simple')) {
      [Void]$PSBoundParameters.Remove('Simple')
      $Simple = $True
    }
    If ($PSBoundParameters.ContainsKey('PathArgs')) {
      $P = ((@($Path) + $PathArgs).Where{$_} -Join ' ').trim(' \')
      If (Test-Path $P -ea ignore) {
        $Path = $PSBoundParameters.Path = (Resolve-Path $P).path
      }
      Write-Verbose "$(LINE) Path: [$Path] P: [$P]  PathArgs: [$PathArgs]"
      [Void]$PSBoundParameters.Remove('PathArgs')
    }
    ForEach ($Dir in 'Path','LiteralPath') {
      If ($PSBoundParameters.ContainsKey($Dir) -and
          (Test-Path $PSBoundParameters.$Dir -PathType Leaf -ea Ignore)) {
        $PSBoundParameters.$Dir = Split-Path $PSBoundParameters.$Dir -ea ignore
        Write-Verbose "$(LINE) Begin $($Dir): $($PSBoundParameters.$Dir)"
      }
    }
    try {
      $outBuffer = $null
      if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
        $PSBoundParameters['OutBuffer'] = 1
      }
      $Original   = 'Microsoft.PowerShell.Management\Set-Location'
      $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand(
                      $Original,
                      [System.Management.Automation.CommandTypes]::Cmdlet
                    )
      $scriptCmd  = {& $wrappedCmd @PSBoundParameters }
      $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
      $steppablePipeline.Begin($PSCmdlet)
    } catch {
      Write-Verbose ("$(LINE)`n" + ($_           | FL * -Force | Out-String))
      Write-Verbose ("$(LINE)`n" + ($_.Exception | FL * -Force | Out-String))
      throw
    }
  } #begin
  Process {
    try {
      Write-Verbose ("$(LINE) PROCESS Set:$($PSCmdlet.ParameterSetName) `$_=[$_] " +
                     ($PSBoundParameters | Out-String))
      If ($Path -and !$LiteralPath) { $_ = $Path}
      Write-Verbose ("$(LINE) `$_: $($_)" + ($PSBoundParameters | Out-String))
      If ($_ -and (
			  $Dir = Resolve-Path $_ -ea Ignore |
          Where-Object {
					  (Test-Path $_              -PathType container -ea ignore) -or
					  (Test-Path $_.ProviderPath -PathType container -ea ignore)
					} | Select-Object -first 1
			  )
      ) {
        $PSBoundParameters.Path = $Path = $_ = $dir.Path
      } ElseIf ($_ -and (!(Test-Path $_ -PathType Container -ea Ignore)) -and (
                 (Test-Path -literalpath  $_                      -PathType Leaf -ea Ignore) #-or
                 #(Test-Path -literalpath (Resolve-Path $_ -ea 0) -PathType Leaf -ea Ignore)
               )
      ) {
        $_ = (Split-Path $_ -ea ignore)
        Write-Verbose "$(LINE) Process `$_: $_   P:[$P]"
      }
			If ( $Literalpath -and
			    ($P = Resolve-Path -literal $Literalpath -ea ignore) -and
			    ($P = $P.ProviderPath)) {
			  if (test-path -literal $P -ea ignore ) {
          Write-Verbose "$(LINE) Set $_ = [$P]"
          $_ = $Path = $LiteralPath = $P
			  }
	    }

      # $_ = $_ -replace '^[^:]::'
      Write-Verbose "$(LINE) `$_: $($_)"
      Write-Verbose ("$(LINE)" + ($PSBoundParameters | Out-String))
      $Path = try {
			  $p = $steppablePipeline.Process($_)
		  } catch {
        Write-Verbose $_
      }
      # If ($Path) { Microsoft.PowerShell.Management\Set-Location -literalpath $Path -ea Ignore }
      If ($p) {
        $P
      } ElseIf ($p -and $Simple) {
        Write-Verbose "$(LINE) P: $P  `$_: $($_)"
        $p.providerpath
			} ElseIf (($P = (get-location -ea ignore)) -and ($P = $P.ProviderPath)) {
			  if (test-path $P -ea ignore ) {
          Write-Verbose "$(LINE) Process using ProviderPath:  cd [$P]"
			    # $P
			  }
      }
    } catch {
      Write-Verbose ("$(LINE)`n" + ($_           | FL * -Force | Out-String))
      Write-Verbose ("$(LINE)`n" + ($_.Exception | FL * -Force | Out-String))
      throw
    }
  } #process
  End {
    try {
      $steppablePipeline.End()
			If (($P = (get-location -ea ignore)) -and ($P = $P.ProviderPath)) {
			  if (test-path $P -ea ignore ) {
          Write-Verbose "End:  cd [$P]"
			    & $Original $P -ea 0
			  }
	    }
    } catch {
      throw
    }
    If ($Pwd.ToString() -match '::') {
      Write-Warning "Check `$Pwd: $Pwd"
      $Pwd.psobject.get_properties() | ForEach-Object {
        $_.Name -match 'Path' -and  $_.value -notmatch '::'
      } | Select -first 1 | ForEach-Object { & $Original $_.value }
    }
  } #end
} #end function Set-Location
