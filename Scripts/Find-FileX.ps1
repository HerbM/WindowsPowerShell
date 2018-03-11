function Find-File {
  [CmdletBinding()]param(
    [Parameter(Mandatory=$true)][string[]]$File,
    [string[]]$Location=@(($env:path -split ';') | select -uniq | ? { $_ -notmatch '^\s*$' }),
    [string[]]$Environment,
    [switch]$Recurse,
    [switch]$Details
  )
  
  Begin { 
    $e = @{}
    function Extend-File { 
      param([string]$name, [string]$ext="$($env:pathext);.PS1")
      If ($name -match '(\.[a-z0-9]{0,5})|\*$') {
        return @($name)
      } elseIf (!$e[$name]) { 
        $e[$name] = @($ext -split ';' | select -uniq | 
                  ? { $_ -notmatch '^\s*$' } | % { "$($Name)$_" })
      }
      $e[$name]
    }
    
    $Location += $Environment | % { $Location += ";$((dir -ea 0 Env:$_).value)" }
    If ($EPath) {$Location += ";$($Env:Path)"}
    $Location = $Location | % { $_ -split ';' } | select -uniq | ? { $_ -notmatch '^\s*$' } 
    write-verbose ("$($Location.Count)`n" + ($Location -join "`n"))  
    write-verbose ('-' * 72)
    write-verbose "Recurse: $Recurse"    
  }

  Process {
    $File | % { $F=$_; ($Location | % { 
      $L = $_; Extend-File $F | 
      % { dir -file -ea 0 -recurse:$recurse (Join-Path $L $_) } 
    })} | % {
      if ($Details) { $_ | select length,lastwritetime,fullname }
      else { $_.fullname }
    }
  }

  End { write-verbose ('-' * 72) }  
}