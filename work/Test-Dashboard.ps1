$Dashboard = New-UDDashboard -Title 'Processes' -Content {
  New-UDChart -Title 'ProcessMemory' -Endpoint {
    Get-Process -ea Ignore | Sort-Object WorkingSet -desc | Select -First 5 |
      Out-UDChartData -DataProperty 'WorkingSet' -LabelProperty 'Name' 
  }
}

Start-UDDashboard -dashboard $Dashboard -port 8999 -autoreload
  
