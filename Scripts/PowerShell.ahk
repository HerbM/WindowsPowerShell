:~*:##wl::Write-Log "$`(FLINE) "
:~*:##ww::Write-Warning "$`(FLINE) "
:~*:##wi::Write-Information "$`(FLINE) "
:~*:##wh::Write-Host "$`(FLINE) "
:~*:##wd::Write-Debug "$`(FLINE) "
:~*:##sm::Set-StrictMode -Version Latest

:~*:##cb::
(
`[CmdletBinding`()]Param`(
    `[Parameter`(ValueFromPipeline)]`[Object`[]]$InputObject,
    `[switch]$LoadOnly
  `)
return
)

:~*:##Fn::
(
Function Since {
  `[CmdletBinding`()]Param`(
    `[Parameter`(ValueFromPipeline)]`[Object`[]]$InputObject,
    `[switch]$LoadOnly
  `)
  Begin   {
    $Local:ObjectCount = 0
  }
  Process {
    $Property = Switch `($True) {
      { $InputObject`[0] -is 'System.IO.DirectoryInfo' } { 'LastwriteTime' }
      default { 
        `(Get-Property $InputObject`[0]).name | 
        Select-String 'time|date' | Select-Object -first 1
      }  
`   }
    Write-Warning "Property: $Property"
    ForEach `($Object in $InputObject) {
      $Object.GetType`(), $Object.ToString`() -join ' '
      $ObjectCount++
    }
  }
  End     {
    Write-Warning "Object count: $`($ObjectCount)"
  }
}
)
return

:~*:##Fn2::
(
Function Fn2 {
  `[CmdletBinding`()]Param`()
  
} 
)
return
