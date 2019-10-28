Set-StrictMode -Version Latest

  # $ForestContext = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::New('forest', $ForestName)
  # [System.DirectoryServices.ActiveDirectory.forest]::GetForest($ForestContext)

  Function Get-UserDomain     { [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()  }
  Function Get-UserForest     { [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()  }
  Function Get-ComputerDomain { [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain() }
  Function Get-ComputerForestContext {
    If (Get-Variable -ea Ignore ComputerForestContext) { return $ComputerForestContext }  
    $ForestName    = (Get-ComputerDomain).Forest
    [System.DirectoryServices.ActiveDirectory.DirectoryContext]::New('Forest', $ForestName)
  }
  Function Get-ComputerForest {
    If (Get-Variable -ea Ignore ComputerForest) { return $ComputerForest}  
    [System.DirectoryServices.ActiveDirectory.Forest]::GetForest((Get-ComputerForestContext)) 
  }
  
  $UserDomain            = Get-UserDomain
  $UserForest            = Get-UserForest
  $ComputerDomain        = Get-ComputerDomain
  $ComputerForestContext = Get-ComputerForestContext
  $ComputerForest        = Get-ComputerForest

  Function Get-CurrentForest {
    [Alias('Get-UserForest','GCF','GUF','Get-DefaultForest','GDF')] 
    [CmdletBinding()]Param(
      [PSCredential]$Credential = $Null,
      [Alias('ForestName')][string[]]$Name           = @(),
                           [switch]  $ComputerForest = $False,
                           [switch]  $BothForests    = $False
    )
    Begin { }
    Process {
      [System.DirectoryServices.ActiveDirectory.forest]::GetCurrentForest()
    } 
  }

  Function Get-Forest {
    #[OutputType('PSCustomOBject')]
    [CmdletBinding()]Param(
      [Alias('ForestName')][string[]]$Name           = @(),
                           [switch]  $ComputerForest = $False,
                           [switch]  $BothForests    = $False
    )
    Begin {
      $AlreadySeen = @{}
      If ($BothForests -or $ComputerForest) {
        $Name += (Get-ComputerDomain).Domain
      }
      If ($BothForests -or !$Name) { 
        $Name += $Env:UserDNSDomain
      }
    }
    Process {
      ForEach ($Domain in $Name.trim('.')) {
        nslookup -type=srv "_kerberos._tcp.$($Domain)." | 
          Select-String '^[a-z][^:]+[.\d]{7}$'          | 
          ForEach-Object {
            $a = $_ -split '\s+'
            If (!$AlreadySeen.ContainsKey($a[0])) {
              $AlreadySeen.$($a[0]) = 1  # just remember it
              [PSCustomObject]@{ 
                ComputerName = $a[0] -replace '\..*'
                DNSDomain    = $a[0] -replace '^\w+\.'
                IPAddress    = $a[-1] 
              }
            }
          } 
      }  
    } 
  }
  
  Function Get-DomainController {
    [OutputType('PSCustomOBject')]
    [CmdletBinding()]Param(
      [Alias('DomainName')]
      [string[]]$Name           = @(),
      [switch]  $ComputerDomain = $False,
      [switch]  $BothDomains    = $False
    )
    Begin {
      $AlreadySeen = @{}
      If ($BothDomains -or $ComputerDomain) {
        $Name += (Get-ComputerDomain).Domain
      }
      If ($BothDomains -or !$Name) { 
        $Name += $Env:UserDNSDomain
      }
    }
    Process {
      ForEach ($Domain in $Name.trim('.')) {
        nslookup -type=srv "_kerberos._tcp.$($Domain)." | 
          Select-String '^[a-z][^:]+[.\d]{7}$'          | 
          ForEach-Object {
            $a = $_ -split '\s+'
            If (!$AlreadySeen.ContainsKey($a[0])) {
              $AlreadySeen.$($a[0]) = 1  # just remember it
              [PSCustomObject]@{ 
                ComputerName = $a[0] -replace '\..*'
                DNSDomain    = $a[0] -replace '^\w+\.'
                IPAddress    = $a[-1] 
              }
            }
          } 
      }  
    } 
  }


<#
.Synopsis
Execute RepAdmin to force SyncAll Push & Pull of Domain Controllers
.Description
Execute RepAdmin to force Push/Pull of some or all Domain Controllers in a Domain
.Notes
RepAdmin docs
https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc835086%28v%3dws.11%29
.Link
https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc835086%28v%3dws.11%29
  
#>
Function Invoke-SyncAll { 
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Medium')]
  Param (
    [Alias('DCName','Server','Name')]
    [Object[]]$ComputerName = @(Get-DomainController -Computer),
    [Parameter(ValueFromRemainingArguments)][string[]]$Args,
    [switch]$NoDefaultOptions = $False,
    [switch]$PushOnly = $False,
    [switch]$PullOnly = $False
  )
  Begin {
    If (!$NoDefaultOptions) {
      $DefaultPush = @('/AdeP')
      $DefaultPull = @('/Ade' )
    }
    $Push = If ($PullOnly) { '' } Else { 'Push' }
    $Pull = If ($PushOnly) { '' } Else { 'Pull' }
    $SyncMesage = ($Push,$Pull -join ' & ').Trim(' &') + ' SyncAll:' 
    $WhatIf  = $PSBoundParameters.ContainsKey('WhatIf' )
    $Confirm = $PSBoundParameters.ContainsKey('Confirm')
    $Msg = If     ($WhatIf)  { 'WhatIf:'  }
           ElseIf ($Confirm) { 'Confirm:' }
           Else              { 'Invoke:'  }     
  } 
  Process {
    ForEach ($DC in $ComputerName) {
      If ($DC -isnot [string]) { $DC = $DC.ComputerName}  
      If ($Push) { Write-Verbose "$Msg RepAdmin /syncall $(($DefaultPush -join ' ') +       ($Args -Join ' ')) $DC" } 
      If ($Pull) { Write-Verbose "$Msg RepAdmin /syncall $(($DefaultPull -join ' ') + ' ' + ($Args -Join ' ')) $DC" }
      If ($PSCmdLet.ShouldProcess($DC, $SyncMesage )) {
        Write-Verbose "$('= * 20') $SyncMesage $($DC) $('= * 20')";
        If ($Push) { RepAdmin /syncall @DefaultPush @Args $DC } 
        If ($Pull) { RepAdmin /syncall @DefaultPull @Args $DC }
      } Else {
        If ($Confirm) { $Msg = 'Skipped:' }
      }   
    }    
  }  
}   

Export-ModuleMember -Function *

# From within the script? $PSBoundParameters
# from outside the script? (get-command $scriptPath).Parameters.Keys
