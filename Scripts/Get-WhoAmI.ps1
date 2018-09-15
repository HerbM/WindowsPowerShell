Function Get-WhoAmI {
  [CmdletBinding()]param(
    [ValidatePattern('^(P|G|U|F|L|C|P|A)')]$Show = 'Privileges'
  )
  $Switches = 'UPN', 'FQDN', 'USER', 'LOGONID', 'GROUPS', 'PRIV', 'ALL'
  If ($Show -match '^(P|G|U|F|L|C|P|A)') {
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

<#

WhoAmI has three ways of working: 

Syntax 1:    WHOAMI [/UPN | /FQDN | /LOGONID]

Syntax 2:    WHOAMI { [/USER] [/GROUPS] [/CLAIMS] [/PRIV] } [/FO format] [/NH]

Syntax 3:    WHOAMI /ALL [/FO format] [/NH]


Parameter List:
    /UPN      Displays the user name in User Principal               Name (UPN) format.

    /FQDN     Displays the user name in Fully Qualified               Distinguished Name (FQDN) format.
    /USER     Displays information on the current user along with the security identifier (SID).
    /GROUPS   Displays group membership for current user, type of account, security identifiers (SID) and attributes.
    /CLAIMS   Displays claims for current user,               including claim name, flags, type and values. 
    /PRIV     Displays security privileges of the current               user. 
    /LOGONID  Displays the logon ID of the current user.

    /ALL                    Displays the current user name, groups 
                            belonged to along with the security 
                            identifiers (SID), claims and privileges for 
                            the current user access token.

    /FO       format        Specifies the output format to be displayed.
                            Valid values are TABLE, LIST, CSV.
                            Column headings are not displayed with CSV
                            format. Default format is TABLE.

    /NH                     Specifies that the column header should not
                            be displayed in the output. This is
                            valid only for TABLE and CSV formats.

#>