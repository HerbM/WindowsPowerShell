Function Get-Path {
  [CmdletBinding()]Param(
    [switch]$Split   = $Null,
    [switch]$User    = $Null,
    [switch]$Process = $Null,
    [switch]$System  = $Null,
    [switch]$Unique  = $Null,
    [switch]$Length  = $Null,
    [switch]$Measure = $Null,
    [switch]$Dummy   = $Null
  )
  If ($Measure) { $Length = $True }
  $Path = $Env:Path
  $Stats = [Ordered]@{}
  $SplitPath         = $Path.Split(';')
  $Stats.Characters  = $Path.Length
  $Stats.Excess      = 4095 - $Path.Length
  $Stats.Directories = $SplitPath.Count
  $Path = Switch ($True) {
    {  $Unique    } { $Split.Path = $SplitPath | Select-Object -Unique } 
    {  $SplitPath } { $SplitPath }
    { !$SplitPath } { $SplitPath -join ';' } 
    Default         { $Path }
  }
  $Path
  If ($Measure) {
    $Stats = [PSCustomObject]$Stats
    Write-Host "$($Stats | Format-Table | Out-String)" -fore Yellow -back DarkCyan
  }
}


#	[System.Environment]::SetEnvironmentVariable('Pathx','Value', 'user')  # 'process' 'machine' 
#	[System.Environment]::GetEnvironmentVariable('pathx','user')  # 'process' 'machine' 