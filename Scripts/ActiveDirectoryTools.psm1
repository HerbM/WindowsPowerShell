Set-StrictMode -Version Latest

# $ForestContext = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::New('forest', $ForestName)

# [System.DirectoryServices.ActiveDirectory.forest]::GetForest($ForestContext)

$UserDomain            = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$UserForest            = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$ComputerDomain        = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
$ComputerForestContext = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::New(
                           'Forest', $ComputerDomain.Forest)
$ComputerForest        = [System.DirectoryServices.ActiveDirectory.Forest]::GetForest($ComputerForestContext)
  


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

Export-ModuleMember -Function *


From within the script? $PSBoundParameters
from outside the script? (get-command $scriptPath).Parameters.Keys