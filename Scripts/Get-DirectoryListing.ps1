<#
You are responsible for implementing the logic for added parameters.  These 
parameters are bound to $PSBoundParameters so if you pass them on the the 
command you are proxying, it will almost certainly cause an error.  This logic
should be added to your BEGIN statement to remove any specified parameters 
from $PSBoundParameters.

In general, the way you are going to implement additional parameters is by
modifying the way you generate the $scriptCmd variable.  Here is an example
of how you would add a -SORTBY parameter to a cmdlet:

    if ($SortBy)
    {
      [Void]$PSBoundParameters.Remove("SortBy")
      $scriptCmd = {& $wrappedCmd @PSBoundParameters |Sort-Object -Property $SortBy}
    }else
    {
      $scriptCmd = {& $wrappedCmd @PSBoundParameters }
    }
    
################################################################################    
New ATTRIBUTES
    if ($SortName)
    {
      [Void]$PSBoundParameters.Remove("SortName")
    }
    if ($SortDate)
    {
      [Void]$PSBoundParameters.Remove("SortDate")
    }
    if ($SortLength)
    {
      [Void]$PSBoundParameters.Remove("SortLength")
    }
    if ($SortExt)
    {
      [Void]$PSBoundParameters.Remove("SortExt")
    }
    if ($SortType)
    {
      [Void]$PSBoundParameters.Remove("SortType")
    }
    if ($SortGroupDirectories)
    {
      [Void]$PSBoundParameters.Remove("SortGroupDirectories")
    }
    if ($LastWriteTime)
    {
      [Void]$PSBoundParameters.Remove("LastWriteTime")
    }
    if ($LastAccessTime)
    {
      [Void]$PSBoundParameters.Remove("LastAccessTime")
    }
    if ($CreationTime)
    {
      [Void]$PSBoundParameters.Remove("CreationTime")
    }
    if ($VersionInfo)
    {
      [Void]$PSBoundParameters.Remove("VersionInfo")
    }
    if ($FileVersionInfo)
    {
      [Void]$PSBoundParameters.Remove("FileVersionInfo")
    }
    if ($ProductVersionInfo)
    {
      [Void]$PSBoundParameters.Remove("ProductVersionInfo")
    }

################################################################################
#>

[CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true, HelpUri='http://go.microsoft.com/fwlink/?LinkID=113308')]
param(
  [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, 
  ValueFromPipelineByPropertyName=$true)]
  [string[]]${Path},
  [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
  [Alias('PSPath')][string[]]${LiteralPath},
  [Parameter(Position=1)][string]${Filter},
  [string[]]${Include},
  [string[]]${Exclude},
  [Alias('sort')][string[]]$Order,
  [Alias('s')][switch]${Recurse},
  [uint32]${Depth},
  [switch]${Force},[switch]${Name},
  [Alias('sn')]    [switch]$SortName,  
  [Alias('sd')]    [switch]$SortDate,
  [Alias('sl')]    [switch]$SortLength,
  [Alias('se')]    [switch]$SortExt,
  [Alias('st')]    [switch]$SortType,
  [Alias('sg')]    [switch]$SortGroupDirectories,
  [Alias('sw')]    [switch]$LastWriteTime,
  [Alias('sa')]    [switch]$LastAccessTime,
  [Alias('sc')]    [switch]$CreationTime,
  [Alias('sv')]    [switch]$VersionInfo,
  [Alias('sfv')]   [switch]$FileVersionInfo,
  [Alias('spv')]   [switch]$ProductVersionInfo
)

dynamicparam {
  try {
    $Script:ProxyParamNames = @(
      'SortName',  
      'SortDate',
      'SortLength',
      'SortExt',
      'SortType',
      'SortGroupDirectories',
      'LastWriteTime',
      'LastAccessTime',
      'CreationTime',
      'VersionInfo',
      'FileVersionInfo',
      'ProductVersionInfo'
    )
    $Script:ProxyBoundParams = [ordered]@{}
    ForEach ($ProxyParam in $ProxyParamNames) {
      $Script:ProxyBoundParams.$ProxyParam = $PSBoundParameters.ContainsKey($ProxyParam)    
      $Null = $PSBoundParameters.Remove($ProxyParam) 
    }        
    
    $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
    $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
    if ($dynamicParams.Length -gt 0) {
      $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
      foreach ($param in $dynamicParams) {
        $param = $param.Value
        if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name)) {
          $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
          $paramDictionary.Add($param.Name, $dynParam)
        }
      }
      return $paramDictionary
    }
  } catch {
    Write-Error "$LINE What's happening here?"
    #throw
  }
}

begin {
  try {   # Separate out for proxy to clarify source of errors
    #Write-Verbose "$LINE ProxyBoundParams contains: [$($Script:ProxyBoundParams | Out-String)]"
    #Write-Verbose "$LINE Params: $($ProxyParamNames)"
    ForEach ($ProxyParam in $Script:ProxyParamNames) {
      Write-Verbose ( "$LINE ProxyBoundParams has parm {0,-20} with value [{1}]" -f 
                      $ProxyParam, 
  ##                    "[$([boolean]$ProxyBoundParams.Contains($ProxyParam))]"   ####,
                      $ProxyBoundParams.$ProxyParam     
      )              
    }      
    $ProxyOutput         = @()
    $ProxySortProperties = @()  
    switch ($True) {
      { $ProxyBoundParams.SortName            } { $ProxySortProperties += 'Name'               }  
      { $ProxyBoundParams.SortDate            } { $ProxySortProperties += 'LastWriteTime'      }
      { $ProxyBoundParams.SortLength          } { $ProxySortProperties += 'Length'             }
      { $ProxyBoundParams.SortExt             } { $ProxySortProperties += 'Extension'          }
      { $ProxyBoundParams.SortType            } { $ProxySortProperties += 'Type'               }
      { $ProxyBoundParams.SortGroupDirectories} { $ProxySortProperties += 'Group'              }
      { $ProxyBoundParams.LastWriteTime       } { $ProxySortProperties += 'LastWriteTime'      }
      { $ProxyBoundParams.LastAccessTime      } { $ProxySortProperties += 'LastAccessTime'     }
      { $ProxyBoundParams.CreationTime        } { $ProxySortProperties += 'CreationTime'       }
      { $ProxyBoundParams.VersionInfo         } { $ProxySortProperties += 'VersionInfo'        }
      { $ProxyBoundParams.FileVersionInfo     } { $ProxySortProperties += 'FileVersionInfo'    }
      { $ProxyBoundParams.ProductVersionInfo  } { $ProxySortProperties += 'ProductVersionInfo' }
    } 
    Write-Verbose ("$LINE ProxySortProperties1a $($ProxySortProperties)")
    Write-Verbose ("$LINE ProxySortProperties1b $($Script:ProxySortProperties)")
    $Script:ProxySortProperties = $ProxySortProperties | Select-Object -unique
    $Script:ShouldSortObject    = [boolean]$Script:ProxySortProperties
    Write-Verbose ("$LINE ShouldSortObject2 $($Script:ShouldSortObject) on properties:")
    Write-Verbose ("$LINE ProxySortProperties2 $($Script:ProxySortProperties)")
  } catch {
    Write-Error "$LINE Proxy made an error in begin block"
  }
  try {
    Write-Verbose "$LINE ProxyBoundParams contains: [$($Script:ProxyBoundParams | Out-String)]"
    Write-Verbose "$LINE Params: $($ProxyParamNames)"
    ForEach ($ProxyParam in $Script:ProxyParamNames) {
      Write-Verbose ( "$LINE ProxyBoundParams has parm {0,-20}:{1,7} with value [{2}]" -f 
                      $ProxyParam, 
                      "[$($ProxyBoundParams.Contains($ProxyParam))]",
                      $ProxyBoundParams.$ProxyParam     
      )                
    }  
    $outBuffer = $null
    if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
      $PSBoundParameters['OutBuffer'] = 1
    }
    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
    $scriptCmd = {& $wrappedCmd @PSBoundParameters }
    $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
    $steppablePipeline.Begin($PSCmdlet)
  } catch {
    Write-Error "$LINE $($MyInvocation.MyCommand): Caught Error "
    #throw
  }
}
process {
  try {
    if ($Script:ShouldSortObject) {
      $ProxyOutput += $_
      #$steppablePipeline.Process($_) | Sort-Object -Property $Script:ProxySortProperties
    } else {
      $steppablePipeline.Process($_)
    }  
  } catch {
    Write-Warning "$LINE $($MyInvocation.MyCommand): 2nd Catch Process block: $_"
    Write-Error   "$LINE $($MyInvocation.MyCommand): 2nd Catch Process block: "
    #throw
  }
}
end {
  try {
    $steppablePipeline.End()
    If ($ShouldSortObject) {
      write-warning "Sorting.....$($ProxyOutput.Count)"    
      $ProxyOutput | Sort-Object -Property $Script:ProxySortProperties 
    } else {
      write-warning "NOT sorting, no sort requested"    
    }
  } catch [ItemNotFoundException] {
    Write-Warning "$LINE $($MyInvocation.MyCommand): Caught Error $($_.Exception)"
    Write-Error   "$LINE $($MyInvocation.MyCommand): Caught Error "
  } catch {
      #Write-Warning "$LINE $($MyInvocation.MyCommand): END 2nd Catch: $_"
      #Write-Error   "$LINE $($MyInvocation.MyCommand): END 2nd Catch: "
    #throw
  }
}

<#
.ForwardHelpTargetName Microsoft.PowerShell.Management\Get-ChildItem
.ForwardHelpCategory Cmdlet
#>

