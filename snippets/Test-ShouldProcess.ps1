<#
.Notes
  https://dille.name/blog/2017/08/27/how-to-use-shouldprocess-in-powershell-functions/
.Links 
  https://dille.name/blog/2017/08/27/how-to-use-shouldprocess-in-powershell-functions/
  https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.cmdlet.shouldprocess?redirectedfrom=MSDN&view=powershellsdk-1.1.0#overloads
  
#>
Function New-Something {}

Function Test-SP {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
  Param(
    [Parameter()][switch]$Force
  )
  [System.Management.Automation.ShouldProcessReason]$ShouldProcessReason = 'None'
  $PSCmdlet.ShouldProcess('verboseDescription goes here', 'verboseWarning Goes here as well',
    'CaptionHerb', [ref]$ShouldProcessReason) # ("ShouldProcess?")
  $ShouldProcessReason
  # ShouldProcess (verboseDescription, verboseWarning, caption, ShouldProcessReadon);
  # ShouldProcess (verboseDescription, verboseWarning, caption);
  # ShouldProcess('Target', 'Action')
  # ShouldProcess('Target')
}

Function Test-ShouldProcess {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
  Param(
    [Parameter()][switch]$Force
  )
  Begin {
    if (-not $PSBoundParameters.ContainsKey('Verbose')) {
      $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) {
      $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
    }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
      $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
    }
    Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f 
                  $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
  }
  Process {
    <# Pre-impact code #>
    # -Confirm --> $ConfirmPreference = 'Low'
    # ShouldProcess intercepts WhatIf* --> no need to pass it on
    if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
      Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
      # Variable scope ensures that parent session remains unchanged
      $ConfirmPreference = 'None'
      New-Something
    }
    <# Post-impact code #>
  }
  End {
    Write-Verbose (
      '[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f 
      $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference
    )
  }
}

Describe 'ShouldProcess' {
  Mock New-Something {}
  It 'Should process by default' {
    Test-ShouldProcess
    Assert-MockCalled New-Something -Scope It -Exactly -Times 1
  }
  It 'Should not process on explicit request for confirmation (-Confirm)' {
    { Test-ShouldProcess -Confirm }
    Assert-MockCalled New-Something -Scope It -Exactly -Times 0
  }
  It 'Should not process on implicit request for confirmation (ConfirmPreference)' {
    {
      $ConfirmPreference = 'Medium'
      Test-ShouldProcess
    }
    Assert-MockCalled New-Something -Scope It -Exactly -Times 0
  }
  It 'Should not process on explicit request for validation (-WhatIf)' {
    { Test-ShouldProcess -WhatIf }
    Assert-MockCalled New-Something -Scope It -Exactly -Times 0
  }
  It 'Should not process on implicit request for validation (WhatIfPreference)' {
    {
      $WhatIfPreference = $true
      Test-ShouldProcess
    }
    Assert-MockCalled New-Something -Scope It -Exactly -Times 0
  }
  It 'Should process on force' {
    $ConfirmPreference = 'Medium'
    Test-ShouldProcess -Force
    Assert-MockCalled New-Something -Scope It -Exactly -Times 1
  }
}
