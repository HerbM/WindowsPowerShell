# Import the Active Directory module for the Get-ADComputer CmdLet 
# Import-Module ActiveDirectory 
 
# Get today's date for the report 
$today = Get-Date 
 
# Setup email parameters 
$subject = "ACTIVE SERVER SESSIONS REPORT - " + $today 
$priority = "Normal" 
$smtpServer = "YourMailServer" 
$emailFrom = "email@yourdomain.com" 
$emailTo = "email@yourdomain.com" 
 
# Create a fresh variable to collect the results. You can use this to output as desired 
$SessionList = "ACTIVE SERVER SESSIONS REPORT - " + $today + "`n`n" 

function Get-WinStaSession {
  [CmdletBinding()]param($UserName, [Alias('Me','Mine')][switch]$Current)
  $WinSta = qwinsta | select -skip 1
  write-verbose "Winsta count: $($WinSta.count)"
  $WinSta | % {
    write-verbose "WinStaLine: $_"
    # SESSIONNAME       USERNAME                 ID  STATE   TYPE        DEV
    # rdp-tcp#89        jramirez                 10  Active
    ForEach ($COL in @(2,19,56,68)) {
      $_ = $_ -replace "^(.{$($COL)})\s{3}", '$1###'
    }
    write-verbose "WinStaLine: $_"
    $S=[ordered]@{};
    $O=[ordered]@{};
    [boolean]$O.Current =  $_ -match '^>'
    # $S.Type,$S.Device,
    $null,$S.Name,$S.UserName,$S.ID,$S.State,$Null,$Null,$null = $_ -split '[>\s]+'
    ForEach ($Key in $S.Keys) { $O.$Key = $S.$Key -replace '^###$' }    
    $SelectUser = [boolean]$UserName
    #switch ($True) {
    #  { $True       } { $SessionList = [PSCustomObject]$O          }
    #  { $Current    } { $SessionList | ? Current  -eq    $True     }
    #  { $SelectUser } { $SessionList | ? UserName -match $UserName }
    #  default         { $SessionList                               }
    #}
    $SessionList = [PSCustomObject]$O
    if ($Current)    { $SessionList | ? Current  -eq    $True     }
    if ($SelectUser) { $SessionList | ? UserName -match $UserName }
    $SessionList                              
  }
}

 
# Query Active Directory for computers running a Server operating system 
# $Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} 
$Servers = ,$Env:Computername 
# Loop through the list to query each server for login sessions 
ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
 
    # When running interactively, uncomment the Write-Host line below to show which server is being queried 
    # Write-Host "Querying $ServerName" 
 
    # Run the qwinsta.exe and parse the output 
    $queryResults = (qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)  
     
    # Pull the session information from each instance 
    ForEach ($queryResult in $queryResults) { 
        $RDPUser = $queryResult.USERNAME 
        $sessionType = $queryResult.SESSIONNAME 
         
        # We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number 
        If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL)) {  
            # When running interactively, uncomment the Write-Host line below to show the output to screen 
            # Write-Host $ServerName logged in by $RDPUser on $sessionType 
            $SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType 
        } 
    } 
} 
 
# Send the report email 
Send-MailMessage -To $emailTo -Subject $subject -Body $SessionList -SmtpServer $smtpServer -From $emailFrom -Priority $priority 
 
# When running interactively, uncomment the Write-Host line below to see the full list on screen 
$SessionList 