#requires -Version 5
# this enum works in PowerShell 5 only
# in earlier versions, simply remove the enum,
# and use the numbers for the desired window state
# directly

Enum ShowStates
{
  Hide = 0
  Normal = 1
  Minimized = 2
  Maximized = 3
  ShowNoActivateRecentPosition = 4
  Show = 5
  MinimizeActivateNext = 6
  MinimizeNoActivate = 7
  ShowNoActivate = 8
  Restore = 9
  ShowDefault = 10
  ForceMinimize = 11
}


# the C#-style signature of an API function (see also www.pinvoke.net)
$code = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'

# add signature as new type to PowerShell (for this session)
$type = Add-Type -MemberDefinition $code -Name myAPI -PassThru

<#
# access a process
# (in this example, we are accessing the current PowerShell host
#  with its process ID being present in $pid, but you can use
#  any process ID instead)
$process = Get-Process -Id $PID
#>

$processes = $Args | % { $_ | % { Get-Process $_ }}
ForEach ($Process in $Processes) {
  # get the process window handle
  $hwnd = $process.MainWindowHandle
  # apply a new window size to the handle, i.e. hide the window completely
 # $type::ShowWindowAsync($hwnd, [ShowStates]::Hide)
 # Start-Sleep -Seconds 2
  # restore the window handle again
  $type::ShowWindowAsync($hwnd, [ShowStates]::Show)
}
