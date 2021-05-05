[CmdletBinding()]Param(
  [Switch]$Force=$False
)

If (!$Force) {
  Write-Warning "Run this script only if you completely understand the issues...  returning without executing..."
  return
}

Set-StrictMode -off
# $jpp = @{ ErrorAction = 'Ignore'} #; resolve = $True }
If (($UserName       -or (      $UserName = $Env:UserName))               -and
    ($SharedLocation -or ($SharedLocation = 'D:'))                        -and
    ($UserFolderRoot -or ($UserFolderRoot = "$SharedLocation\$UserName")) -and
    ($UserDocuments  -or ($UserDocuments  = "$UserFolderRoot\Documents"))) {
  Write-Host "Directories variables set"
} else {
  Write-Host "Unable to set Directories variables, exiting!!!"
  return
}

Function Set-PersonalFolder {
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact=’HIGH’)]param(
    [String]$FolderRoot = 'C:\Users\%UserName%',
    [string[]]$FoldersToMove  = @('Personal','Desktop','Programs','Startup',
                                  '{374DE290-123F-4565-9164-39C4925E467B}',
                                  'AppData','Local AppData','Start Menu',
                                  'NetHood')
  )
  Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -name *
  # $FolderRoot = 'C:\Users\%UserName%'   # default
  # $FolderRoot = 'D:\%UserName%'          # share from RDP servers
  $UserFolders = @{
    AppData                                  = "$FolderRoot\AppData\Roaming"
    Cache                                    = "$FolderRoot\AppData\Local\Microsoft\Windows\Temporary Internet Files"
    Cookies                                  = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Cookies"
    Desktop                                  = "$FolderRoot\Desktop"
    Favorites                                = "$FolderRoot\Favorites"
    History                                  = "$FolderRoot\AppData\Local\Microsoft\Windows\History"
    'Local AppData'                          = "$FolderRoot\AppData\Local"
    'My Music'                               = "$FolderRoot\Music"
    'My Pictures'                            = "$FolderRoot\Pictures"
    'My Video'                               = "$FolderRoot\Videos"
    NetHood                                  = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Network Shortcuts"
    Personal                                 = "$FolderRoot\Documents"
    Programs                                 = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
    Recent                                   = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Recent"
    SendTo                                   = "$FolderRoot\AppData\Roaming\Microsoft\Windows\SendTo"
    Startup                                  = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    'Start Menu'                             = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Start Menu"
    Templates                                = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Templates"
    '{374DE290-123F-4565-9164-39C4925E467B}' = "$FolderRoot\Downloads"
    PrintHood                                = "$FolderRoot\AppData\Roaming\Microsoft\Windows\Printer Shortcuts"
    'CD Burning'                             = "$FolderRoot\AppData\Local\Microsoft\Windows\Burn\Burn2"
  }
  $UserFoldersKey = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
  Get-ItemProperty $UserFoldersKey  -name *
  # $FolderRoot = 'C:\Users\%UserName%'   # default
  # $FolderRoot = 'D:\%UserName%'          # share from RDP servers
  $FoldersToMove  = 'Personal','Desktop','Programs','Startup','AppData','Local AppData','Start Menu','NetHood','{374DE290-123F-4565-9164-39C4925E467B}'
  ForEach ($Folder in $FoldersToMove) {
    $Existing = Get-ItemProperty $UserFoldersKey -name $Folder -ea ignore
    If (!$Existing -or $UserFolders.$Folder -ne $Existing.$Folder) {
      Set-ItemProperty $UserFoldersKey -name $Folder -Value $UserFolders.$Folder -Type ExpandString -Force
      (Get-ItemProperty $UserFoldersKey -name $Folder -ea ignore).$Folder
    } Else {
      Write-Warning "Already set: $Folder = [$($Existing.$Folder)]"
    }
  }
  foreach ($F in $FoldersToMove) {
    "$F $($F)";
    if (!(Test-Path $UserFolders.$f -ea ignore)) { mkdir $UserFolders.$f }
    Get-ItemProperty $UserFoldersKey -name *
  }
}
# set-personalfolder
Function Get-UserFolder {
  [CmdletBinding()][Alias('guf','gf')]param(
    [Alias('Folder', 'FolderName', 'Directory', 'DirectoryName','Path','PSPath')]
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [string[]]$Name='*',
    [switch]$Regex
  )
  Begin {
    $Key = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    $Folders = @()
    $RegistryFolders = (Get-ItemProperty $Key -name * -ea Ignore).psobject.get_properties() |
      Where-Object Name -notlike 'PS*' | ForEach-Object {  # Skip PS* ItemProperty 'pseudo-properties'
        $_ = [PSCustomObject]@{ $_.Name = $_.Value }       # Ignore other (registry) properties
        If ($_.Name -eq '{374DE290-123F-4565-9164-39C4925E467B}') {  # Downloads uses a GUID name
          $Alias = $_.Clone
          $Alias.Name =  'Downloads'
          $Alias
        }
      }
  }
  Process {
    $Folders += ForEach ($Folder in $Name) {
      $Folder = $Folder -replace '^Downloads', '{374DE290-123F-4565-9164-39C4925E467B}'
      $Folder = $Folder -replace '^Documents',  'Personal'
      $Folder = $Folder -replace '^(Pictures|Video|Music)', 'My $1'
      # $Folder = $Folder -replace '^(AppData)$', 'Local $1'
      Write-Verbose "Folder: Folder pattern: [$Folder]"
      If ($Regex -and ($F = $RegistryFolders | Where-Object Name -match $Folder)) {
        Write-Verbose "Regex: User folders: [$($F.Name)]"
        $F
      } ElseIf ($F = Get-ItemProperty $Key -name $Folder -ea Ignore) {
        $F.psobject.get_properties() | Where-Object Name -notlike 'PS*'
      } Else {
        Write-Warning "User folder: [$Folder] not found"
      }
    }
  }
  End {
    $Folders | Select-Object -unique Name,@{N='Folder';E={$_.Value}}
  }
}
get-userfolder

$RDCCert = "Cert:\currentuser\my\826412376C99DAEBA25FE2CEA1F51D66964BFF3D"
If (Test-Path $RDCCert -ea Ignore) {
  Write-Warning "Certificate found:  $RDCCert"
} Else {
  Write-Host "Certificate NOT found:  $RDCCert" -back 'Black' -fore 'Yellow'
  # set-location (Get-UserFolder 'Documents').Folder
  Set-Location D:\A469526\Documents
  If (Test-Path RDCManCertificate.pfx -ea Ignore) {
    .\Import-RDPCertificate.ps1 .\RDCManCertificate.pfx
  }
  If (Test-Path $RDCCert -ea Ignore) {
    Write-Warning "Certificate installed:  $RDCCert"
  } else {
    Write-Error "Certificate NOT found:  $RDCCert" -back 'DarkRed' -fore 'White'
  }
}

If (!(Test-Path O:\ -ea ignore )) {
  net use O: /d /y 2>&1 1>$Null
  net use O: \\tsclient\C /persistent:yes
}
$Drive,$Null = $SharedLocation -split  '(?<=:)'
$EscapeUserFolderRoot   = [Regex]::Escape($UserFolderRoot)
$UserPSProfileDirectory = "$UserDocuments\WindowsPowerShell"
$NetworkModules         = "$UserPSProfileDirectory\Modules"
If ($Env:PSModulePath -NotMatch "$EscapeUserFolderRoot" ) {
  $Env:PSModulePath    += ";$NetworkModules"
}
$PSProfileName          = 'Microsoft.PowerShell_profile.ps1'  # different for 6.x
$Global:Profile         = "$UserPSProfileDirectory\$PSProfileName"

# $SessionID = ( ((qwinsta) -match '>') -split '\s+')[2]

# dir -dir task* -ea ignore -rec
$StartUpSubPath  = "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$TaskBarSubPath  = "AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
$OriginalStartUp = "$Home\$StartUpSubPath\"
$OriginalTaskbar = "$Home\$TaskBarSubPath\"
$NetworkStartUp  = "$UserFolderRoot\$StartUpSubPath\"
$NetworkTaskbar  = "$UserFolderRoot\$TaskBarSubPath\"
copy-item  "$UserFolderRoot\Task"  $OriginalTaskbar -force -ea Ignore
copy-item  "$UserFolderRoot\Start" $OriginalStartUp -force -ea Ignore
copy-item  "$UserFolderRoot\Task"  $NetworkStartUp  -force -ea Ignore
copy-item  "$UserFolderRoot\Start" $NetworkTaskbar  -force -ea Ignore

Set-Location $UserPSProfileDirectory
. $Global:Profile
