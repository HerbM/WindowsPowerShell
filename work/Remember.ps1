#|| ========================================================================
#|| SecurityLogAnalysis
165911535616/1gb
86511733/1mb
ForEach ($i in 1..36) { sleep -min 10; get-eventlog Security -After $Since | Export-CSV -NoTypeInformation "Security$(get-date -f 'yyyyMMdd-HHmmss').csv" } 
ForEach ($i in 1..36) { sleep -s (10 * 60); get-eventlog Security -After $Since | Export-CSV -NoTypeInformation "Security$(get-date -f 'yyyyMMdd-HHmmss').csv" } 
$events[-1]
$events[-1].Group
$events[-1].Group | fl
$events[-1].Group.ReplacementStrings | fl
$events[-1].Group.ReplacementStrings[3] | fl
$events[-1].Group.ReplacementStrings[4] | fl
$events[-1].Group.ReplacementStrings[2] | fl
$events[-1].Group.ReplacementStrings | fl
$events[-1].Group.ReplacementStrings[10] | fl
$events.Group.ReplacementStrings[10] | group 
$events.Group.ReplacementStrings[10] 
$events | % { $_.Group.ReplacementStrings[10] }
($events | % { $_.Group.ReplacementStrings } ) -match '^[\\.\w]+$'
($events | % { $_.Group.ReplacementStrings } ) -match '^[\\.\w]+[a-z\\.][\\.\w]+$'
($events | % { $_.Group.ReplacementStrings } ) -match '^[\\.\w]+[a-z\\.][\\.\w]+$' | group
($events | % { $_.Group.ReplacementStrings } ) -match '^[\\.\w]+[a-z\\.][\\.\w]+$' | %{[pscustomobject]@{String = $_ } } | group string
($events | % { $_.Group.ReplacementStrings } ) -match '^[^0][\\.\w]+[a-z\\.][\\.\w]+$' | %{[pscustomobject]@{String = $_ } } | group string | sort count
out-remember SecurityLogAnalysis 
. addnote
out-remember SecurityLogAnalysis 
. ic
#|| ========================================================================
#|| SecurityLogAnalysis
dir go
dir D:\WinTools\_gsdata_\_file_state_v4._gs
cd D:\WinTools\_gsdata_\_file_state_v4._gs
dir
dir | measure -sum length
234234852/1gb
dir \iso
dir 'D:\iso\Server 2019 Preview\'
cd ..\tools
dir
es windows insider iso
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source
dir junk
import-csv junk\Security20180818-170919.csv | select -fir 40 | gm
import-csv junk\Security20180818-170919.csv | ? username -match '\w' | group username
import-csv junk\Security20180818-170919.csv | select *user* | ft | more
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source | FL
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | fl # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source | FL
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | Select -expand replacementstrings # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source | FL
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | Select -expand replacementstrings -first 1 # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source | FL
get-eventlog Security | Group EventID | sort count | % { $Count = $_.Count; $_.Group | Sort TimeWritten -desc | Select -first 1 } | Select -expand replacementstrings -last 1 # | ft @{N='Count';E={$Count}},@{N='TimeWritten';E={(($_.TimeWritten -f 'HH:mm:ss') -split '\s')[1]}},EventName,EventID,Site,UserName,Category,Source | FL
. ic
