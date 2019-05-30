#Set-StrictMode -Version 1.0
#Set-StrictMode -Version 2.0
#Set-StrictMode -Version Latest
#Set-StrictMode -Off

Function Test-StrictMode {
  [CmdletBinding(DefaultParameterSetName='Mixed')]Param(
    [Parameter(ParameterSetName='Boolean')][Alias('AsBoolean')][switch]$Boolean = $False,
    [Parameter(ParameterSetName='Version')][Alias('AsVersion')][switch]$Version = $False,
    [Parameter(ParameterSetName='String' )][Alias('AsString' )][switch]$String  = $False,
    [Parameter(ParameterSetName='Mixed'  )][Alias('AsBString')][switch]$Mixed   = $False
  )
  $Mixed = $String -and $Boolean -or $PSCmdlet.ParameterSetName -eq 'Mixed'
  $Level = Switch ($True) {
    { $Boolean } { $False         }
    { $String  } { 'Off'          }
    { $Version } { [Version]'0.0' }
    { $Mixed   } { ''             }
    Default    { ''             }
  }  
  try { [void]   $local:a   } catch { $Level = '1.0' }
  try { [void]"$($local:a)" } catch { $Level = '2.0' }
  If ($Boolean) { $Level = [boolean]$Level }
  $Level
}

If ($MyInvocation.InvocationName -ne '.') { Test-StrictMode @args }

<#
get-eventlog system -Newest 100 -EntryType Error | Group Source,EventID
#>