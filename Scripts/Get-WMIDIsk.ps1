# Get-WMIObject -List | Where{$_.name -match ^Win32_} # List all Win32 classes
$diskdrive = gwmi win32_diskdrive
foreach($drive in $diskdrive) {
  out-host -InputObject "`nDrive: deviceid-$($drive.deviceid.substring(4)) Model - $($drive.model)"
  ##partition 
  $partitions = gwmi -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($drive.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
  foreach($part in $partitions) {
    Out-Host -InputObject "`tPartition: $($part.name)"
    $Query = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($part.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
    $vols = gwmi -Query $Query
    foreach($vol in $vols) {
      out-host -InputObject "`t`t$($vol.name)"
    }
  } 
}
