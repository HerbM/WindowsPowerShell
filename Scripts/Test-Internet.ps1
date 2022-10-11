$Count = 1
$DNSInterfaces = Get-DnsClientServerAddress -Family IPv4 | Where { $_.ServerAddresses.Count -and $_.InterfaceAlias -notmatch 'LoopBack' } | Sort InterfaceIndex
$DNSServers = $DNSInterfaces.ServerAddresses | Select -unique
$GoogleIP = "142.251.32.228", "74.125.21.147", "74.125.21.104", "74.125.21.103",
            "74.125.21.105", "74.125.21.106", "74.125.21.99"
$IPs = $DNSServers + $GoogleIP
rc $IPs 53 80 443 -P
