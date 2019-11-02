# S-1-12-1-1628084675-1095761744-3240085893-319057096,A469526,WW930,     0x11f080,Microsoft Software Key Storage Provider,UNKNOWN,TB_1_outlook.com,%%2500,%%2480,0x80090016
# S-1-5-18,                                  DESKTOP-73BET4G$,AtosC2-DWP,0x3e7,   S-1-0-0,0x8009030e,                     %%2304,0x0,3,Authz,Kerberos,DESKTOP-73BET4G,0,0x406c,C:\Windows\System32\SearchProtocolHost.exe


# https://gpsearch.azurewebsites.net/

$FailAudit = Get-EventLog -Log Security -EntryType FailureAudit
Write-Warning "Total FailAudit: $FailAudit.count of $(IDCounts.count) IDs"
$IDCounts     = $FailAudit | Group EventId | Sort Count
Write-Warning "$($IDCounts | ft Count, Name| Out-String)”

$Now = Get-Date -f 'HHmmss’
$FailAuditFile = "FailAuditFile$($Now).csv”
$IDCounts      = $FailAudit | Group EventId | Sort Count
Write-Warning "$($IDCounts | ft Count, Name| Out-String)”
Write-Warning "$($IDCounts | % {(($_.Group[0]) | % { ($_.ReplacementStrings | ? { $_ -match '\w'}).trim()  -join ',' }) })"
$IDCounts | % {
  (($_.Group   ) | % { ($_.ReplacementStrings | ? { $_ -match '\w'}).trim()  -join ',' }) } | Out-File $FailAuditFile
