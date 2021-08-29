:~*:^^wl::Write-Log "$`(FLINE) "
:~*:^^ww::Write-Warning "$`(FLINE) "
:~*:^^wi::Write-Information "$`(FLINE) "
:~*:^^wh::Write-Host "$`(FLINE) "
:~*:^^wd::Write-Debug "$`(FLINE) "
:~*:^^sm::Set-StrictMode -Version Latest

:~*:@@fun::
(
def F(x) -> int:
  pass
)
Return

:~*:@@Fn2::
(
Function Fn2 {
  `[CmdletBinding`()]Param`()

}
)
return
