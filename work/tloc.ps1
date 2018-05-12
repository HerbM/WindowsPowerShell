Function Test-Location {
  [CmdletBinding(DefaultParameterSetName='Path', SupportsTransactions=$true)]
  Param(
    [Parameter(ParameterSetName='Path', Position=0, ValueFromPipeline=$true, 
      ValueFromPipelineByPropertyName=$true)][string]$Path,
    [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')][string]$LiteralPath, 
    [switch]$PassThru,
    [Parameter(ParameterSetName='Stack', ValueFromPipelineByPropertyName=$true)]
      [string]$StackName
  )
  Begin { 
    write-warning "Begin"
    $PSBoundParameters
  }
  Process {
    write-warning "Begin"
    $PSBoundParameters
  }
  End {
    write-warning "Begin"
    $PSBoundParameters
  }
}