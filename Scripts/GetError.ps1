Function Get-InvocationInfo {

  #################################################
  ######      Needs Convert-HashToString     ######
  #################################################

  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('ErrorRecord','ParseException')]
    [Object[]]$InvocationInfo = $Null,

    [String]$AsString = $False,
    [Alias('MaximumDepth')][Int32]$MaxDepth = 3,
    [Parameter(DontShow)]  [Int32]$Depth = 0
  )
  Begin {
    $ReturnFromRecursion = $False
    If ($Depth++ -gt $MaxDepth) {
      $ReturnFromRecursion = $True  # Safety from unlikely infinite recursion
      RETURN
    }
    Function Clean {
      [CmdletBinding()]Param([Object]$O)
      $O
    }
  }
  Process {
    Try {
      If ($ReturnFromRecursion) { RETURN }
      ForEach ($Invocation in $InvocationInfo) {
        $Type =
        $Inv = If ($Invocation.GetType().Name -eq 'InvocationInfo') {
                 $Invocation
               } Else {
                 Get-ErrorInvocationInfo $Invocation -Depth $Depth
               }
        If ($Inv) {
          $PositionMessage = $Inv.PositionMessage + "`t\`"<>&'"
          # $PositionMessage = [System.Security.SecurityElement.Escape]::($PositionMessage);
          $PositionMessage =
            $PositionMessage -replace
                   '\\','/'  -replace
                   '"', '''' -replace
                   '\t','\t' -split
                   '[\r\n]+' -join
                   ';;'
          $I = [PSCustomObject]@{
            MyCommand             = ($Inv.MyCommand            )  #
            BoundParameters       = ($Inv.BoundParameters      )  # {}
            UnboundArguments      = ($Inv.UnboundArguments     )  # {}
            ScriptLineNumber      = ($Inv.ScriptLineNumber     )  # 1
            OffsetInLine          = ($Inv.OffsetInLine         )  # 5
            HistoryId             = ($Inv.HistoryId            )  # -1
            ScriptName            = ($Inv.ScriptName           )  #
            Line                  = ($Inv.Line                 )  # $TXD-DCs = $TXD | ? DomainController -eq $True
            PositionMessage       = ($PositionMessage          )  # At line:1 char:5
            PSScriptRoot          = ($Inv.PSScriptRoot         )  #
            PSCommandPath         = ($Inv.PSCommandPath        )  #
            InvocationName        = ($Inv.InvocationName       )  #
            PipelineLength        = ($Inv.PipelineLength       )  # 0
            PipelinePosition      = ($Inv.PipelinePosition     )  # 0
            ExpectingInput        = ($Inv.ExpectingInput       )  # False
            CommandOrigin         = ($Inv.CommandOrigin        )  # Internal
          }
          Set-DefaultPropertySet $I @(
            'ScriptName','PositionMessage','Line' 
          )
          $I
        }
      }
    } Catch {
      If ($AsString) { 'Invocation record not found' }
    }
  }
  End {}
}

# Just get the Error then read the "message":
# (($error | ? GetType -match 'Exception' ).ErrorRecord.Exception.Message) -split '[\r\n]+' -join ';;'
# Don't need to select first:
# @(((($error | ? GetType -match 'Exception').ErrorRecord.Exception.Message) | ForEach { $_ -split '[\r\n]+' -join ';;' })).count
# cls;($error | Get-InvocationInfo) | ConvertTo-Json -depth 1
# NEWTONSOFT????

Function Get-Error {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline)]
    [Alias('ErrorRecord','Exception','ParseException')]
    [Object[]]$ErrorObject = $Null
  )
  Begin {}
  Process {
    ForEach ($E in $ErrorObject) {
      Try {
        $Type = $E.GetType().Name
        If ($Type -match 'ErrorRecord') {
          $E
        } ElseIf ($Type -match 'Exception') {
          $E.ErrorRecord
        }
      } Catch { Write-Warning "New Error"; $Null = 'DoNothing' }
    }
  }  
}

Function Get-ErrorInvocationInfo {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline)]
    [Alias('ErrorRecord','Exception','ParseException','InvocationInfo')]
                        [Object[]]$ErrorObject = $Null,
    [Alias('MaximumDepth')][Int32]$MaxDepth    = 2,
    [Parameter(DontShow)]  [Int32]$Depth       = 0
  )
  Begin {
    $ReturnFromRecursion = $False
    If ($Depth++ -gt $MaxDepth) {
      $ReturnFromRecursion = $True  # Safety from unlikely infinite recursion
      RETURN
    }
  }
  Process {
    Try {
      If ($ReturnFromRecursion) { RETURN }
      ForEach ($E in $ErrorObject) {
        Try {
          :SwitchError Switch -Regex ($E.GetType().Name) {
            'ErrorRecord'    { $E.InvocationInfo; break  }
            'Exception'      {
              Get-ErrorInvocationInfo $E.ErrorRecord -Depth $Depth;
              break SwitchError
            }
            # 'InvocationInfo' { $ErrorObject; break  } # Never???
            Default          {                            } # Possible???
          }
        } Catch { Write-Warning "New Error" $Null = 'DoNothing' }
      }
    } Catch { $Null = 'DoNothing' }
  }
  End {}
}

Function Get-InvocationInfo {
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline)]
    [Alias('ErrorRecord','Exception','ParseException')]
                        [Object[]]$ErrorObject = $Null
  )
  Process {
    ForEach ($E in $ErrorObject) {
      Try {
        (Get-Error $E).InvocationInfo
      } Catch { Write-Warning "New Error" $Null = 'DoNothing' }
    }
  }
}

return
Function Get-About {
  Param([String[]]$Name='.*')
  Begin {
    $Topics = Import-CSV "$Home\Documents\WindowsPowerShell\Reference\About_HelpTopics.csv"
  }
  Process {
    ForEach ($N in $Name) {
      $Topics | ? Name -match $N | Select-Object Name,Synopsis
    }
  }
}

<#
Select-Object 'ScriptLineNumber','OffsetInLine','ScriptName',
              'MyCommand',:'Line','PSScriptRoot','PSCommandPath',
              'InvocationName','PipelineLength','PipelinePosition'

$Err1.InvocationInfo.PositionMessage -split '[\r\n]+' -join ';; ' -split ';; '

$exc1.Message
($exc1.Message).count
($exc1.Message).gettype()
$err | Get-Member -MemberType Property -Name InvocationInfo,Message,*exception*
$err | Get-Member -MemberType Property -Name InvocationInfo,Message,*exception* | FL * -FORCE


MyCommand             :
BoundParameters       : {}
UnboundArguments      : {}
ScriptLineNumber      : 1
OffsetInLine          : 5
HistoryId             : -1
ScriptName            :
Line                  : $TXD-DCs = $TXD | ? DomainController -eq $True
PositionMessage       : At line:1 char:5
                        + $TXD-DCs = $TXD | ? DomainController -eq $True
                        +     ~~~~
PSScriptRoot          :
PSCommandPath         :
InvocationName        :
PipelineLength        : 0
PipelinePosition      : 0
ExpectingInput        : False
CommandOrigin         : Internal
DisplayScriptPosition :


$Error | % -begin {$X = 0} {
  try {
    $e = $_;
    "****$X**** $($e.gettype())";
    $X++;
    If ($e -is [System.Management.Automation.ErrorRecord]) {
      $null=$_.InvocationInfo.ScriptLineNumber
    } Else {
      "#######$($e.gettype())#######"
    }
  } catch {
    "=======$($e.errors.count)==$($e.gettype())========"
    $e.ErrorRecord | Format-List -Force *
  }
}


$Error | % -begin {$X = 0} {
  try {
    "Type: $($e.gettype())"
    $Invocation = If ($e -is [System.Management.Automation.ErrorRecord]) {
      $_.InvocationInfo
    } Else {
      $e.errorrecord.InvocationInfo
    }
    $Invocation.ScriptLineNumber
    $e | gm -membertype Property
  } catch {
    try {
      Write-Warning "#######$($e.gettype())#######"
      "Unknown Error/Exception: "
      $e | Format-List -Force *
      "Catch complete"
    } catch {
      Write-Warning "2nd CATCH ++++++++$($e.gettype())+++++++"
    } finally {
      Write-Warning "FINALLY: ++++++++$($e.gettype())+++++++"
    }
  }
}
$error | ? { try { $_.InvocationInfo } catch {} } | % InvocationInfo | export-csv t.csv

$ErrorCopy = $Error.Clone()
$ErrorCopy | % -begin {$X = 0} {
  try {
    If ($_ -is [System.Management.Automation.ErrorRecord]) {
      $Invocation = $_.InvocationInfo
      $Category = $_.Category
    } Else {
      $Invocation = $_ | Get-Member -MemberType Property -Name InvocationInfo -ea Ignore
      If (!$Invocation) {
        $ErrorRecord = $_ | Get-Member -MemberType Property -Name ErrorRecord -ea Ignore
        If ($ErrorRecord) {
          $InvocationInfo = $ErrorRecord.InvocationInfo
          $Category   = $ErrorRecord.Category
        }
      }
    }
    $Message = If ($Invocation) {
      $CategoryReason = If ($Category) {
        "$($Category.Category)/$($Category.Reason)"
      } Else { "_UnknownCause_"}
      $Name = If ($Invocation.ScriptName) { $Invocation.ScriptName }
              Else                        { '_NoScriptName_' }
      "$($Name):$($Invocation.ScriptLineNumber):: [$CategoryReason] $($Invocation.Line)"
    } Else {
      "Unknown exception type: [$CategoryReason] $($_.GetType())"
    }
    $Message
  } catch {
    try {
      Write-Warning "#######$($e.gettype())#######"
      "Unknown Error/Exception: "
      $e | Format-List -Force *
      "Catch complete"
    } catch {
    "Type: $($e.gettype())"
      Write-Warning "2nd CATCH ++++++++$($e.gettype())+++++++"
    } finally {
      Write-Warning "FINALLY: ++++++++$($e.gettype())+++++++"
    }
  }
}
#>

