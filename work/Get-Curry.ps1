<#
.Synopsis 
Curry a PowerShell function or cmdlet
.Description
Return a curried PowerShell function supplied with default paraters provided by caller
.Notes
Build a function or scriptblock closure with PSDefaultParameterValues closed inside

#>
[Get-CmdletBinding()]Param(
  [Parameter(Mandatory)]$Name,
  [Parameter(Mandatory)]$NewName,
  [Hashtable]$Parameters = @{},       
  [Switch]$Test                  # Dummy for development simplicity   
)


New-Module -Name $Name$NewName {
  $PSDefaultParameterValues = Get-Variable PSDefaultParameterValues -Scope 1
  ForEach ($Key in $Parameters.Keys) {
     $PSDefaultParameterValues."$($Name):$Key" = $Parameters.$Key  ## Need to convert to Name:Parameter
  }

}

txcloud\_svcAutomation         Aut0m@t10n
txdcs\_svcAutomation           +4$8*Hyx2@Yeal
txdtools\_svcAutomation        Wrt234@#$