If (!(Get-Variable PSGalleryPath -Scope Global -ea Ignore -value)) {
  $Global:PSGalleryPath = Join-Path '$Home' 'PSGallery.csv'
}

Function Receive-PSGallery {
  If (Test-Path $PSGalleryPath) {
    Write-Warning "$(LINE) Loading `$PSGallery from file: $PSGalleryPath"
    $Global:PSGallery = Import-CSV $PSGalleryPath   
  } Else {
    $VPN = Get-WMIObject Win32_NetworkAdapters | 
           Where-Object Caption -match 'Juniper.*Virtual'
    Start-Job -name PSGallery { 
      If ($VPN -or (ipconfig | sls IPv4).Length -ge 2) {
        Set-Proxy -e
      }
      $Global:PSGallery = Find-Module * 
      # $Global:PSGallery = Find-Module * -ea STOP 
    }
  }  
}

# Get PSGallery Modules
# Store in file if successful
# Store in variable if successful

# Check file date and run if out-of-date or forced

