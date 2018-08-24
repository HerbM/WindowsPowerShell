Function Get-ArithmeticMean {
  [CmdletBinding()]Param(
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Object[]]$InputObject,
    [string[]]$Property=@(),
    [switch]$IgnoreInvalid,
    [switch]$IgnoreEmpty
    
  )
  Begin { 
    $NonEmpty = $Count = $Accumulator = 0 
    If ($InputObject       -is [array]  -and
        $InputObject.count -eq 1        -and
        $InputObject[0]    -is [string] -and 
        $InputObject[0]    -match '^\s*([-\d]*\d[.]{2}\d[\d]*)\s*$') { 
      Write-Verbose "Match 1: $($Matches[1])"
      $InputObject = @(Invoke-Command ([ScriptBlock]::Create($Matches[1])))   
    } ElseIf ($Null -ne $InputObject) {
      Write-Verbose "InputObject Type: $($InputObject.GetType())"
    }
  }
  Process {
    ForEach ($Value in $InputObject) {
      Write-Verbose "[$($Value)] Type: $($Value.GetType())"
      $Count++; 
      If (!$IgnoreEmpty -or $Value -or (0.0 -eq $Value)) { $NonEmpty++ }
    }
  }
  End { 
    Write-Verbose "Count: $Count NonEmpty: $NonEmpty"
  }
}
