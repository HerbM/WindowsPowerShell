[CmdletBinding()]param()  
$Dashboard = New-UDDashboard -Title 'Processes' -Content {
  New-UDChart -Title 'CPU%' -Endpoint {
    Get-Process -ea Ignore | Sort-Object CPU -desc | Select -First 5 |
      Out-UDChartData -DataProperty 'CPU' -LabelProperty 'Name'
  }
}

Start-UDDashboard -dashboard $Dashboard -port 1000 -autoreload
  
  
#  DCS4AVDevOps01  
#  DCS4SVDevOps02  