[CmdletBinding()]param()  
$Dashboard = New-UDDashboard -Title "Processes $(Get-Date -f 's')" -Content {
  New-UDChart -Title 'CPU% Usage' -Endpoint {
    Get-Process -ea Ignore | Sort-Object CPU -desc | Select -First 15 |
      Out-UDChartData -DataProperty 'CPU' -LabelProperty 'Name'
  }
}

Start-UDDashboard -dashboard $Dashboard -port 2000 -autoreload -cyclepages -cyclepagesinterval 
  
  
#  DCS4AVDevOps01  
#  DCS4SVDevOps02  