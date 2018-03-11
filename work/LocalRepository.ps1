$RepositoryName = 'ECSTeam1'
$path = '\\server1\myrepository'
$exists = Test-Path "filesystem::$path"             # check that target location exists
if (!$exists) { throw "Repository $path is offline" }
$existing = Get-PSRepository -Name $RepositoryName -ea 0 # check if location is registered 
if ($existing -eq $null) {  # if not, register it
  Register-PSRepository -Name $RepositoryName -SourceLocation $path -ScriptSourceLocation $path -InstallationPolicy Trusted 
}

Get-PSRepository # list all registered repositories
