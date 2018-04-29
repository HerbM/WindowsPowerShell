<#
   #requires -version 5.1
   This is a copy of:
   CommandType  Name         Version   Source             
   -----------  ----         -------   ------             
   Cmdlet       Set-Location 3.1.0.0   Microsoft.PowerShell.Management
   
   Created: 26 April, 2018
   Author : Herb Martin
#>


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
    [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')][string]$LiteralPath, 
    [switch]$PassThru,
    [Parameter(ParameterSetName='Stack', ValueFromPipelineByPropertyName=$true)]
      [string]$StackName
  )
  Begin {
    If ($PSBoundParameters.ContainsKey('LiteralPath') -and 
        (Test-Path $PSBoundParameters.LiteralPath -PathType Leaf -ea Ignore)) {
      $PSBoundParameters.LiteralPath = 
        Split-Path $PSBoundParameters.LiteralPath -ea ignore
      Write-Verbose "Begin LiteralPath: $($PSBoundParameters.LiteralPath)" 
    }
    If ($PSBoundParameters.ContainsKey('Path') -and 
        (Test-Path $PSBoundParameters.Path -PathType Leaf -ea Ignore)) {
      $PSBoundParameters.Path = Split-Path $PSBoundParameters.Path -ea ignore
      Write-Verbose "Begin Path: $($PSBoundParameters.Path)"  
    }
    Write-Verbose "[BEGIN  ] Starting $($MyInvocation.Mycommand)"
    Write-Verbose "[BEGIN  ] Using parameter set $($PSCmdlet.ParameterSetName)"
    Write-Verbose ($PSBoundParameters | Out-String)
    try {
      $outBuffer = $null
      if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
        $PSBoundParameters['OutBuffer'] = 1
      }
      $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Set-Location', [System.Management.Automation.CommandTypes]::Cmdlet)
      $scriptCmd = {& $wrappedCmd @PSBoundParameters }
      $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
      $steppablePipeline.Begin($PSCmdlet)
    } catch {
      throw
    }
  } #begin
  Process {
    try {
      If ($PSBoundParameters.ContainsKey('LiteralPath') -and 
          (Test-Path $PSBoundParameters.LiteralPath -PathType Leaf -ea Ignore)) {
        $PSBoundParameters.LiteralPath = 
          Split-Path $PSBoundParameters.LiteralPath -ea ignore
        Write-Verbose "Process LiteralPath: $($PSBoundParameters.LiteralPath)"  
      }
      If ($PSBoundParameters.ContainsKey('Path') -and 
          (Test-Path $PSBoundParameters.Path -PathType Leaf -ea Ignore)) {
        $PSBoundParameters.Path = Split-Path $PSBoundParameters.Path -ea ignore
        Write-Verbose "Process Path: $($PSBoundParameters.Path)"  
      }
      $steppablePipeline.Process($_)
    } catch {
      throw
    }
  } #process
  End {
    Write-Verbose "[END  ] Ending $($MyInvocation.Mycommand)"
    try {
      $steppablePipeline.End()
    } catch {
      throw
    }
  } #end
} #end function Set-Location