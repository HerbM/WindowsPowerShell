Function Get-StrictMode {
  [CmdletBinding()]param(
    $Version       = [Version]'0.0.0.0',
    [Switch]$All   = $Null,
    [switch]$IsOn  = $Null,
    [switch]$IsOff = $Null
  )
  $Boolean = $IsOn -or $IsOff
  If ($Version -as [Double]) { $Version = [Version]"$($Version).0"}
  If (!($Version -as [Version])) { 
    Write-Error "'$Version' is not a valid version" 
  }
  [Reflection.BindingFlags]$flags = 'Instance, NonPublic'
  try {
  $engineSessionState =             # SessionStateInternal
    [System.Management.Automation.SessionState].GetField('sessionState', 
    $flags).GetValue($executioncontext.SessionState)
  $sessionStateScope =              # CurrentScope property of SessionStateInternal
    $engineSessionState.GetType().GetProperty('CurrentScope', 
                                              $flags).GetValue($engineSessionState)
  $enumerator = 
    [PowerShell].Assembly.GetType('System.Management.Automation.SessionStateScopeEnumerator').
            GetConstructor($flags, $null, $sessionStateScope.GetType(), $null).
            Invoke($sessionStateScope)
    :FOREACH foreach ($sessionStateScope in $enumerator) {
      # StrictModeVersion of SessionStateScope
      $Found = $sessionStateScope.GetType().GetProperty('StrictModeVersion', $flags).
                GetValue($sessionStateScope)
      if ($Found) {
        switch ($True) {
          { $IsOn  } { return $Found -gt $Version }
          { $IsOff } { return $Found -le $Version } 
          { $True  } {        $Found              }
          { $All   } { continue :FOREACH          }
        }  
      }
    }
  } catch {
    throw
  } 
}
If ($MyInvocation.InvocationName -ne '.') { Get-StrictMode @args }