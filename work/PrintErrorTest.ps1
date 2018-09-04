[CmdletBinding()]
Param(
  [string]$ScriptBlock = ''
)

function Get-ErrorDetail {
  [CmdletBinding()]param(
    $ErrorRecord = $Error[0],
    $Exception=$Null,
    $count = 0
  )
  If ($Exception) {
  } Else {
    Write-Warning "$(LINE) Error is a: $($ErrorRecord.gettype())"
    $ErrorRecord | Format-List * -Force
    $ErrorRecord.InvocationInfo | Format-List *
    $Exception = $ErrorRecord.Exception
  }
  for ($depth = 0; $Exception -ne $null; $depth++) {
    "$depth" * 80
    $Exception | Format-List -Force *
    If (Get-Property $Exception | ? Name -eq InnerException) {
      $count++
      Write-Warning "$(LINE) Process InnerException $count"
      # Get-ErrorDetail -Exception $Exception.InnerException -count $i
      $Exception = $Exception.InnerException
    } else {
      Write-Warning "No inner exception depth $depth"
      $Exception = $Null
    }
  }
}

try {
  If ($ScriptBlock) {
    Write-Warning "$(LINE) ScriptBlock: $ScriptBlock"
    & ([scriptblock]::Create($ScriptBlock))
  } else {
    1/0
  } 
} catch {
  write-warning "$(LINE) `$_: Type: $($_.gettype()) $((Get-Property $_).Name -join ' ')"
  $_                | fl * -force
  Write-Warning "$(LINE) ----------------"
  $_.CategoryInfo   | fl * -force
  $catinfo = (get-property ($_.CategoryInfo)).value -join ' '
  write-warning "$(LINE) $catinfo"  
  # $error.Exception.Message
  $InvInfo = ($_.InvocationInfo).positionmessage -split '[\r\n]+' -join ''
  write-warning "$(LINE) $invinfo"  
  Write-Warning "$(LINE) ----------------"
  $_.InvocationInfo | fl * -force
  Write-Warning "$(LINE) -----------------------------------"
  write-warning "$(LINE) Exception: Type: $($_.Exception.gettype()) $((Get-Property $_.Exception).Name -join ' ')"
  $_.Exception | fl * -force
  Write-Warning "$(LINE) -----------------------------------"
  $file = $_.InvocationInfo.ScriptName
  $line = $_.InvocationInfo.ScriptLineNumber
  $ec = ('{0:x}' -f $_.Exception.HResult); 
  $em = $_.Exception.Message; 
  $in = $_.Exception.ItemName
  $description = "$(LINE) $file $line Catch: $ec, $in, $em"
  write-warning  "$description"
  Write-Warning "$(LINE) -----------------------------------"
  Get-ErrorDetail -Exception $_
}

