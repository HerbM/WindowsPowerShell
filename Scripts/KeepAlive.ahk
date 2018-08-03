
; If the user has been idle for a certain time this script moves
; the mouse pointer left and right by distance_x_px in regular intervals
movement_x        := 10
check_interval_ms := 10  * 1000
minimum_idle_ms   := 180 * 1000
oldX              := 0
oldY              := 0
Loop {
  Sleep, %check_interval_ms%
  if (A_TimeIdle > minimum_idle_ms) {
    MouseGetPos, oldX, oldY, , ,
    move_x := oldX + movement_x
    MouseMove, %move_x%, %oldY%, 0
    MouseMove, %oldX%,   %oldY%, 0
  }
}
