Function Get-TrainingAssignment {
  [CmdletBinding()]param(
    [string]$Name      = 'Herb\s+Martin',
    [string]$Path      = '.\Training Matrix Distribution ListServiceNow.xlsx',
    [string[]]$Headers = @(
      'ProcessArea',
      'Module',
      'Content',
      'Hours',
      'Owner'
      'Teams',
      'RolesRequiring',
      'Name',
      'Email'
    )
  ) 
  Import-Excel -path $Path -sheet 'Atos_Build' -HeaderName $Headers |
    Where-Object Name -match $Name
}

$Training = Get-TrainingAssignment
$Training | Format-Table Hours,Module
$Training | Measure Hours -sum | Format-Table Sum

