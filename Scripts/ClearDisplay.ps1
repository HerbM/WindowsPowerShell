Function clx {
    Param($SaveRows=0)
    If ($SaveRows) {
        [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop-($SaveRows+1))
    } Else {
        [System.Console]::SetWindowPosition(0,[System.Console]::CursorTop)
   }
}
