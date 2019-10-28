<#
  Function Test-PipeLine 
  Function Test-RegistryValue 
#>

Function Test-RegistryValue {
  param(
    [Alias("PSPath")]
    [Parameter(Position=0,Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [String]$Path,
    [Parameter(Position = 1, Mandatory = $true)][String]$Name,
    [Switch]$PassThru
  ) 
  Process {
    Switch ($True) {
      { !(Test-Path $Path) }                                   { return $False }
      { ![Boolean]($Key = Get-Item -LiteralPath $Path -ea 4) } { return $False }
      { (($Value = $Key.GetValue($Name, $null)) -eq $null)}    { return $False }
      { $PassThru }                                            { return $Value } 
      Default                                                  { return $True  }
    }
    if (Test-Path $Path) {
      $Key = Get-Item -LiteralPath $Path -ea 4
      If (($Value = $Key.GetValue($Name, $null)) -ne $null) {
        If ($PassThru) { $Value } 
        Else { $True  }
      } Else { $False }
    } Else { $False }
  }
}

Function Test-PipeLine {
  [CmdletBinding()][Alias('guf','gf')]param(
    [Alias('Path','PSPath')]
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Name='*',
    #[Alias('String','AsString','AsPathOnly')]
    [switch]$Begin,
    [switch]$Break,
    [switch]$Return
  )
  Begin {
    Write-Warning "Begin"
    $First = $True
    If ($Begin) {
      Write-Warning "Begin Break:$Break Return:$Return"
      If ($Break) {
        Write-Warning "Begin Break"
        Break
      } ElseIf ($Return) {
        Write-Warning "Begin Return"
        $PSCmdLet.EndProcessing()
        Return
      }
    }
  }
  Process {
    If ($First) {
      Write-Warning "First"
      $First = $False
    }
    If ($Input) {
      Write-Warning "Input -- $($Input) $($Input[0].GetType())"
      $First = $False
    }
    If (!$Begin) {
      Write-Warning "Process Break:$Break Return:$Return"
      If ($Break) {
        Write-Warning "Process Break"
        Break
      } ElseIf ($Return) {
        Write-Warning "Process Return"
        $PSCmdLet.EndProcessing()
        Return
      }
    }
    Write-Warning "Name: [$Name]"
  }
  End {
    Write-Warning "End"
    Write-Warning "Input -- $(@($Input).Count)"
  }
}
