Function Get-WhoAmI {
  [CmdletBinding()]param(
    [ValidatePattern('^(P|G|U|F|L|G|P|A)')]$Show = 'Privileges'
  )
  $Switches = 'UPN', 'FQDN', 'USER', 'LOGONID', 'GROUPS', 'PRIV', 'ALL'
  If ($Show -match '^(P|G|U|F|L|G|P|A)') {
    $SwitchKey = $Matches[1]
  }
  Write-Verbose "Show: $Show Switchkey: $Switchkey"
  # $Args = "/$Switch"   
  $Switch = $Switches -match "^$SwitchKey"
  If ($Switch -in 'GROUPS', 'PRIV', 'ALL') { 
    Write-Verbose "WhoAmI `"/$Switch`" /fo csv | convertfrom-csv"
    WhoAmI "/$Switch" /fo csv | convertfrom-csv
  } {
    Write-Verbose "WhoAmI /$Switch | % { [PSCustomObject]@{ $Switch = $_ } }"
    WhoAmI "/$Switch" | ForEach-Object { [PSCustomObject]@{ $Switch = $_ } }
  }  
}
