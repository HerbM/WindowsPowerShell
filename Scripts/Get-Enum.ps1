Param (
  [Alias('Name','EnumerationrName')][type]$Type = $Null
)

  <#
.Synopsis Get names and values for .NET enumerations
.Example
  Get-Enum System.ConsoleColor
    Name        Value
    ----        -----
    Black           0
    DarkBlue        1
    DarkGreen       2
    ...
.Example
  Get-Enum System.DayOfWeek
    Name      Value
    ----      -----
    Sunday        0
    Monday        1
    Tuesday       2
    Wednesday     3
    Thursday      4
    Friday        5
    Saturday      6
.Example
  Get-Enum System.Management.Automation.Host.ReadKeyOptions
      Name           Value Binary
      ----           ----- ------
      AllowCtrlC         1        1
      NoEcho             2       10
      IncludeKeyDown     4      100
      IncludeKeyUp       8     1000
.Notes
  Adapted from:
  PowerShell Tip: Getting enum values as names, int and bit
.Links
  https://blogs.technet.microsoft.com/fieldcoding/2017/05/18/powershell-tip-getting-enum-values-as-names-int-and-bit/
#>

Function Get-Enum { 
  [CmdletBinding()]Param (
    [Alias('Name','EnumerationrName')][type]$Type = $Null
  )
  If (!$Type) { 
    Throw "Type '$Type' is not an enum"; 
    return 
  } ElseIf ($Type.BaseType.FullName -ne 'System.Enum') {
    # Write-Error "Type '$Type' is not an enum"; return
    Throw "Type '$Type' is not an enum"
    Return
  } Else {
    If ('FlagsAttribute' -in $Type.CustomAttributes.AttributeType.Name) {
      Write-Warning "Type '$Type' is a Flags enum"
      $FlagEnum = $true
    }
    $Properties = @(
      @{ Name = 'Name';  Expression={ "$_" }}
      @{ Name = 'Value'; Expression={ 
        [uint32](Invoke-Expression "[$($Type.FullName)]'$_'") }
        # [uint32](Invoke-Expression "[$($type.FullName)]'$_'") }
      }
    )
    if ($FlagEnum) {
      $Properties += @{ 
        Name = 'Binary'; 
        Expression= {'{0,8}' -f [Convert]::ToString([uint32](Invoke-Expression "[$($type.FullName)]'$_'"), 2)}
      }
    }
    [enum]::GetNames($Type) | Select-Object -Property $Properties
  }
}


If ($MyInvocation.InvocationName -eq '.') {
  Write-Warning "Function loaded by dot sourcing."
} ElseIf (!$Type) {
  Write-Warning "$($MyInvocation.MyCommand): Load by dot sourcing or call with .NET type name argument"
}
If ($Type) {
  Get-Enum @PSBoundParameters
} 
