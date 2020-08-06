$Parsed = $event4771 |  % { $dt = $_.TimeGenerated -as [DateTime]; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:([.\d]{7,})','$1' }} 


get-date
get-date.adddays(-2)
(get-date).adddays(-2)
(get-time).adddays(-2)
get-now
get-time
hostname
dir
eventvwr
ipconfig
repadmin /replsummary
repadmin /showrepl
whoami /priv
dir
cd .\Documents
gc .\ParseReplacementStrings.ps1 | clip


repadmin /showrepl
cd $Home
dir
dir dc*
notepad .\dcdiag.txt
dir
dir *.csv
more .\counts2.csv
dir
more count.csv
dir
dir | sort lastwritetime
type count.txt
dir | sort lastwritetime
dir .\Documents
cd .\Documents
$el = import-csv '.\Event Log.csv'
$el[0]
$e4771 = $el | ? 'Event ID' -eq 4771
$e4771.count
$event4771 = Get-Eventlog -log Security -InstanceId 4771 -entrytype FailureAudit
$event4771.count
$event4771[0] | gm
$e = $event4771 | ? TImegenerated -gt (Get-Date).AddDays(1.25)
$e.count
$e = $event4771 | ? { (Get-Date $_.TImegenerated) -gt (Get-Date).AddDays(1.25)}
$e.count
$e = $event4771 | ? { (Get-Date $_.TimeGenerated) -gt (Get-Date).AddDays(1.25)}
$e.count
$event4771.TImeGenerated
$e = $event4771 | ? { (Get-Date (($_.TimeGenerated -split ', ' )[1])) -gt (Get-Date).AddDays(1.25)}
($e.TimeGenerated -split ', ' )[1]
($e.TimeGenerated -split ', ' )
($event4771.TimeGenerated -split ', ' )[1]
$event4771.count
$event4771 | % { $_.TimeGenerated -split ', ' )[1] }
$event4771 | % { ($_.TimeGenerated -split ', ' )[1] }
$event4771 | % { ($_.TimeGenerated }
$event4771 | % { ($_.TimeGenerated) }
$event4771 | % { ($_.TimeGenerated -split ', ' ) }
h -coun 40
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ')) -gt (Get-Date).AddDays(1.25)}
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ')) }
$e = $event4771 | ? { (($_.TimeGenerated -split ', ')) }
$e.count
$e[]0
$e[0]
$e = $event4771 | % { (($_.TimeGenerated -split ', ')) }
$e
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ')) }
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ').trim()) }
$e
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ').trim()).gettype() }
$e
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-28) }
$e.count
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-36) }
$e.count
$e = $event4771 | % { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-12) }
$e.count
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-36) }
$e.count
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-28) }
$e.count
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ').trim()) -gt (get-date).AddHOurs(-24) }
$e.count
$e = $event4771 | ? { (Get-Date ($_.TimeGenerated -split ', ').trim()) -lt (get-date).AddHOurs(-24) }
$e.count
$e[0]
$e[0] | fl * -force
$e[0].ReplacementStrings | fl * -force
$e[0] | % {$_.ReplacementStrings } | fl * -force
$e[0] | % {$_.ReplacementStrings.getType() } | fl * -force
$e[0] | % {$_.ReplacementStrings.getType() } 
$e[0].ReplacementStrings
$e.count
$event4771.count
$event4771[0]
$event4771[0].ReplacementStrings
$event4771[0] |  % { $Name, $SID,$Service,$x,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ User= =$Name; Sid=$Sid  }}
$host.PrivateData.ErrorBackgroundColor = 'White'
$host.PrivateData.ErrorForegroundColor = 'DarkRed'
$event4771[0] |  % { $Name, $SID,$Service,$x,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ User= =$Name; Sid=$Sid  }}
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid  }}
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;$Status;IPAddress = $ips -replace '^.*:' }}
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;$Status; IPAddress = $ips -replace '^.*:' }}
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress = $ips -replace '^.*:' }}
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress = $ips -replace '^.*:' }} | fl
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress = $ips -replace '^.*:' }} | ft
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress,$Null = $ips -replace '^.*:' }} | ft
$event4771[0] |  % { $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:' }} | ft
$event4771[0] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; Sid=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:' }} | ft
$event4771[0] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:' }} | ft
$event4771[0] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:' }} | ft -auto
$event4771[0..5] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:' }} | ft -auto
$event4771[0..5] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:([.\d])','$1' }} | ft -auto
$event4771[0..5] |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:([.\d]{7,})','$1' }} | ft -auto
(h -count 1).COmmandline > ParseReplacementStrings.ps1
more .\ParseReplacementStrings.ps1
$Parsed = $event4771 |  % { $dt = $_.TimeGenerated; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:([.\d]{7,})','$1' }} 
$Parsed
$Parsed | Export-CSV ParsedEvents.csv
more .\ParsedEvents.csv
$Parsed = $event4771 |  % { $dt = $_.TimeGenerated -as [DateTime]; $Name, $SID,$Service,$Null,$status,$null,$IPs,$Null = $_.ReplacementStrings;[PSCustomObject]@{ Time = $dt; Name = $Name; SID=$Sid;Service=$Service;Status = $Status; IPAddress= $ips -replace '^.*:([.\d]{7,})','$1' }} 
$Parsed | more
$Parsed | ft -auto
(h -count 1).COmmandline > ParseReplacementStrings.ps1
type .\ParseReplacementStrings.ps1
(h -count 5) #.COmmandline > ParseReplacementStrings.ps1
(h 104).COmmandline > ParseReplacementStrings.ps1
type .\ParseReplacementStrings.ps1
$Parsed | ft -auto
dsa
gcm Search-ADAccount
Search-ADAccount -LockedOut
gv e* 
$el.count
$el[0..2]
$el | ? "Event ID" -eq 4740
$LockOuts = $el | ? "Event ID" -eq 4740
$lockouts.count
$lockouts
$lockouts | fl * -force
$LockOuts = Get-EventLog -InstanceId 4740
$LockOuts = Get-EventLog -InstanceId 4740 -log Security
$Lockouts.count
$lockouts | fl * -force
$lockouts.timegenerated

