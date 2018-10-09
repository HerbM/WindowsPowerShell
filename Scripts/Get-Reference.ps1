[CmdletBinding()]param(
  [string[]]$Path = "$(Split-Path $Profile)\Reference",
  [switch]$Invocation
)

Function Get-Reference {
  [CmdletBinding()]param(
    [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
    [Alias('Filter','Reference')]
    [string[]]$Name = '.*',
    [string[]]$Path = "$(Split-Path $Profile)\Reference", 
    [switch]$All,
    [switch]$Invocation
  )
  Begin { $List = @() }
  Process {
    $Name = '(' + ($Name -join ')|(') + ')'
    ForEach ($P in $Path) {
      Write-Verbose "$(FLINE)P"
      Write-Verbose "Get-ChildItem $P | Where-Object Name -match '$Name'"
      $List += Get-ChildItem $P -File | Where-Object Name -match $Name
    }
  }
  End {
    If ($All -or $List.count -eq 1) {
      $List | ForEach-Object {
        [PSCustomObject]@{
          LastWriteTime = (get-date $_.LastWriteTime -f 's')
          Length        = $_.Length
          Type          = $_.Extension
          Name          = $_.BaseName
        }  
      }
    }     
  }
}

If ($Invocation) {  
  Get-Property ($MyInvocation) | Format-Table Name,Value | 
    Out-String | Write-Warning
} else {
  Write-Warning "InvocationName: $($MyInvocation.InvocationName)"
  Write-Warning "Line          : $($MyInvocation.Line)"
}
If ($MyInvocation.InvocationName -ne '.') {
  Get-Reference @PSBoundParameters
} else {
  Write-Warning "Function loaded"
}

# $env:path -split ';' | Split-Path | Sort -uniq

<#
MyCommand             : Get-Reference.ps1
BoundParameters       : {}
UnboundArguments      : {}
ScriptLineNumber      : 1
OffsetInLine          : 1
HistoryId             : 876
ScriptName            :
Line                  : get-reference
PositionMessage       : At line:1 char:1
                        + get-reference
                        + ~~~~~~~~~~~~~
PSScriptRoot          :
PSCommandPath         :
InvocationName        : get-reference
PipelineLength        : 1
PipelinePosition      : 1
ExpectingInput        : False
CommandOrigin         : Runspace
DisplayScriptPosition :

#>