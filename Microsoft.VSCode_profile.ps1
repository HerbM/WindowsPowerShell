If ($Host.PrivateData -and $host.PrivateData.ErrorBackGroundcolor -ne 'Black') {
    $host.PrivateData.errorbackgroundcolor = 'Red'
    $host.PrivateData.errorForeGroundColor = 'White'
    # $host.PrivateData.verbosebackgroundcolor = 'black'
    $host.PrivateData.debugbackgroundcolor = 'black'
}

$ProfileDirectory = Split-Path $Profile
$ParentPath = Split-Path $ProfileDirectory
$OldProfile = Join-Path  $ParentPath 'WindowsPowershell\Microsoft.PowerShell_profile.ps1' 
write-warning "Profile: $Profile Parent: $ParentPath OldProfile: $OldProfile"
if (Test-Path $OldProfile) {
    .  $OldProfile
}
else {
    Set-PSReadlineOption -token string    -fore white 
    Set-PSReadlineOption -token None      -fore yellow
    Set-PSReadlineOption -token Operator  -fore cyan
    Set-PSReadlineOption -token Comment   -fore green
    Set-PSReadlineOption -token Parameter -fore green
    Set-PSReadlineOption -token Comment   -fore Yellow -back DarkBlue
}
