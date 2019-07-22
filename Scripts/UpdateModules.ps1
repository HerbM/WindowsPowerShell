[CmdLetBinding()]Param(
  [switch]$Reload
)
# Get gallery modules
If (!$PSGallery -and !$Reload) {
  Write-Warning "$(FLINE) Loading module list from PSGallery"
  $Global:PSGallery = Find-Module
}
Write-Warning "$(FLINE) PSGallery module count: $($PSGallery.Count)"

Function Select-Version {  #TRASH Needs lots of work
  [CmdLetBinding()]Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)][string[]]$Name = $Null,
    [switch]$Oldest
  )
  If (!$Name) { $Name = Get-Module -ListAvailable }
  $Name | Group-Object Name | ForEach-Object { $_.Group | Sort Version -desc | Select -first 1}
}
Function Select-Version {  
  [CmdLetBinding()]Param(
    [Parameter(ValueFromPipeline)][Object[]]$InputObject = @(Get-Module -ListAvailable),
    [switch]$Oldest = $False
  )
  Begin { 
    $Descending = !$Oldest
  }
  Process {
    $InputObject | Group-Object Name | ForEach-Object { 
      $_.Group | Sort-Object Version -Descending:$Descending | Select-Object -first 1
    }
  }
  End {}
}

# (gcb | Select -skip 1 | ConvertFrom-CSV -Header Agency,Domain,Groups -delim "`t") 

Function Select-OutOfDate {  
  [CmdLetBinding()]Param(
    [Parameter(ValueFromPipeline)][Object[]]$InputObject,# = @(Get-Module -ListAvailable),
    [Object[]]$Available = @(Get-Variable PSGallery -ea Ignore -Value),
    [switch]$ShowInstalledVersion = $False
  )
  Begin {   
    Write-Warning "Begin $($MyInvocation.MyCommand)"
    $Local:AvailableLookup = If (@($Available)[0] -is 'hashtable') {
      $Available
    } Else {
      Write-Warning "Making hashtable"
      $Available | Group-Object Name -AsHashTable
    }   
    Set-Strictmode -Off
    Write-Warning "Begin completed $($MyInvocation.MyCommand)"
  }
  Process {
    ForEach ($Item in $InputObject) { 
      $Name = $Item.Name
      # Write-Verbose "$Name found: $([Boolean]$AvailableLookup.$Name)"
      If ($Gallery = $AvailableLookup.$Name) {
        Write-Verbose "Installed/Gallery versions $($Name): $($Item.Version) $($Gallery.Version)"
        If ($Gallery.Version -gt $Item.Version) { 
          If ($ShowInstalledVersion) { $Item } Else { $Gallery } 
        } 
      } 
    }  
  }
}


# Uninstall older versions of modules with multiple versions
$Installed = Get-Module -ListAvailable 
$OlderVersions  = $Installed | Group Name | Where-Object count -gt 1 | ForEach-Object { 
  $_.Group | Sort-Object Version -Desc | Select-Object -skip 1 
} 
$OlderVersions | ForEach-Object { uninstall-module $_.name -RequiredVersion $_.version -ea 4 -force } 

# Get installed module most recent version
$Current = get-module -list | group name | % { $_.Group | Sort version -desc | select -first 1  }
# Get installed from gallery
$FromGallery = $Current | ? Name -in ($Gallery.Name)
# Join modules
# Join-Object $FromGallery $Gallery Name Name -LeftProperties name,author,version -RightProperties version,name,author -Prefix GAL_ | ft name,version,gal_version,author
# Join-Object [-Left] <Object> [-Right] <Object> [-LeftJoinProperty] <string[]> 
# [-RightJoinProperty] <string[]> [[-RightJoinScript] <scriptblock>] [[-LeftJoinScript] 
# <scriptblock>] [[-LeftProperties] <Object>] [[-RightProperties] <Object>] 
# [[-ExcludeLeftProperties] <string[]>] [[-ExcludeRightProperties] <string[]>] [[-Type] <string>] 
# [[-Prefix] <string>] [[-Suffix] <string>] [-PassThru] [-DataTable] [<CommonParameters>]
$JoinParameters = @{
  Left              = $FromGallery
  Right             = $Gallery 
  LeftJoinProperty  = 'Name' 
  RightJoinProperty = 'Name' 
  LeftProperties    = 'name',    'author', 'version' 
  RightProperties   = 'version', 'name',   'author'
  Prefix            = 'GAL_'
}
$Joined = Join-Object -type AllInBoth @JoinParameters

join-object -type AllInBoth @JoinParameters | ? { $_.version -lt $_.gal_version } | select name,version,gal_version,author
  
$JoinParameters = @{
  Left              = $Current
  Right             = $Gallery 
  LeftJoinProperty  = 'Name' 
  RightJoinProperty = 'Name' 
  LeftProperties    = 'name',    'author', 'version' 
  RightProperties   = 'version', 'name',   'author'
  Prefix            = 'GAL_'
}  
  
# Get InstalledFromGallery that are outdated
$OutDated = $FromGallery | % { $Gallery.Name -eq $_.name }
# Update/Install those

$modules = find-modules 
$modules = find-module
$modules.count
$current = get-module -list
$current.count
$currentGallery = $Current | ? Name -in ($Modules.Name)
$currentGallery.count
$currentGallery
$currentGallery | group name | sort count
$currentGallery | group name | sort count | ? count -gt 1
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1  }
$currentGallery | group name | ? count -gt 2 | % { $_.Group | Sort version -desc | select -first 1  }
$currentGallery | group name | ? count -gt 2 | % { $_.Group | Sort version -desc | select -first 5  }
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1 } | ? { $gal = $modules -match $_.name; $_.version -lt $gal.version  }
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1 } | ? { $gal = $modules -match $_.name; (!$gal) -or ($gal.version) -or $_.version -lt $gal.version  }
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1 } | ? { $gal = $modules -match $_.name; $gal -and $gal.version -and $_.version -lt $gal.version  }
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1 } | % { $gal = $modules -match $_.name; <# $gal -and $gal.version -and $_.version -lt $gal.version#>; "c[$($_.version)] g:[$($gal.Version])"  }
$currentGallery | group name | % { $_.Group | Sort version -desc | select -first 1 } | % { $gal = $modules -match $_.name; <# $gal -and $gal.version -and $_.version -lt $gal.version#>; "c[$($_.version)] g:[$($gal.Version)]"  }
$current | ? version -eq [version]
$current | ? version -eq [version]'0.6.8'
$current[1]
$current | ? version -eq [version]'1.4.2'
$current | ? version -eq '1.4.2'
$current | ? version -eq '0.6.8'
$current | ? name =eq AzureRM.AnalysisServices
$current | ? name =eq 'AzureRM.AnalysisServices'
$current | ? name -eq 'AzureRM.AnalysisServices'
$currentGallery | ? name -eq 'AzureRM.AnalysisServices'
$current | ? name -eq 'AzureRM.AnalysisServices' | ? version -lt '0.6.8' 
$current | ? name -eq 'AzureRM.AnalysisServices' | ? version -lt '0.6.0' 
$current | ? name -eq 'AzureRM.AnalysisServices' | ? version -lt '0.59.0' 
$current | ? name -eq 'AzureRM.AnalysisServices' | ? version -lt '0.5' 
$current | ? name -eq 'AzureRM.AnalysisServices' | ? version -lt '0.7' 
$notcurrent = $Current | ? { $mods = $_.Name -in ($Modules.Name; $mods -and ($mods.version -gt $_.version) )}
$notcurrent = $Current | ? { $mods = $_.Name -in $Modules.Name; $mods -and ($mods.version -gt $_.version) )}
$notcurrent = $Current | ? { $mods = $_.Name -in $Modules.Name; $mods -and ($mods.version -gt $_.version) }
$notcurrent = $Current | ? { $mods =$Modules.Name -eq $_.name ; $mods -and ($mods.version -gt $_.version) }
$notcurrent = $Current | ? { ($mods =$Modules.Name -eq $_.name) -and ($mods.version -gt $_.version) }
h -count 200 | clip
