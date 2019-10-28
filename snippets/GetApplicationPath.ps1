
Function Get-ApplicationPath {
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]Param(
    [string[]]$ApplicationNames,
    [string[]]$Defaults = @('.'),
    [String[]]$Roots    = (Get-WMIObject Win32_Volume | 
                            Where-Object { 
                            $_.DriveType -eq 3 -and $_.Name -match '^\w+:\\'} |
                            Sort-Object
                          ).Name
  )
  Begin {
    Function Get-RootPath {
      ForEach ($Name in $ApplicationNames) {
        $Path = @(Join-Path $Roots $Name -Resolve -ea Ignore)
        Write-Warning "Check path: $Path"
        If ($Path) { Write-Warning "Return path: $($Path[0])"; Return $Path[0] }
      }  
    }
    Function Get-EnvPath {
      ForEach ($Name in $ApplicationNames) {
        $N = "($Name)Path" 
        
        ##### WORK HERE 
        
        Write-Warning "Check path: $Path"
        If ($Path) { Write-Warning "Return path: $($Path[0])"; Return $Path[0] }
      }  
    }
    Function Resolve-FirstPath {

        ##### WORK HERE 

      ForEach ($Name in $ApplicationNames) {
        If ($Name -notmatch '\S') { Continue }
        Write-Warning "Check path: $Path"
        Resolve-FirstPath $Name -ea Ignore | Select-Object -First 1
      }  
    }
  }
  Process {

        ##### WORK HERE 

    $Env      = Get-EnvPath 
    $Root     = Get-RootPath
    $Default  = Resolve-FirstPath $Defaults
    $Variable = VariablePath 
        ##### WORK HERE 

    Write-Warning "GetRoot: $Root"
    $Path = Switch ($True) {
      { !!$Root     } { Write-Verbose "Root: $Root"; $Root }
      { !!$Defaults } { Write-Verbose "Defaults: $Defaults"; $Default }
      Default     { Write-Verbose "Switch Default: "; $PWD.Path } 
    }
    $Path
  }
  End {}
}

  $ApplicationName   = 'ESB'
  $PathVariableName  = $ApplicationName + 'Path'
  $ParentInvocation  = $MyInvocation          ## Mag-Master expects this
  $StubCommandLine   = $ParentInvocation.Line
  $ESBPath = [Environment]::GetEnvironmentVariable($PathVariableName, 'Process')
  If (!$ESBPath -or !(Test-Path $ESBPath)) {
    $ESBPath          = "C:\$ApplicationName"
  }
  If (!(Test-Path $ESBPath)) { $ESBPath = $PWD }
