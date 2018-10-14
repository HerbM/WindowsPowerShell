<##############################################################################
.Name Invoke-CmdScript.ps1
.Description
Invoke the specified batch file (and parameters), but also propagate any
environment variable changes back to the PowerShell environment that
called it.

i.e., for an already existing 'foo-that-sets-the-FOO-env-variable.cmd': 

.Example
PS > type foo-that-sets-the-FOO-env-variable.cmd
@set FOO=%*
echo FOO set to %FOO%.

PS > $env:FOO

PS > Invoke-CmdScript "foo-that-sets-the-FOO-env-variable.cmd" Test 

C:\Temp>echo FOO set to Test. 
FOO set to Test.

PS > $env:FOO 
Test 
.Notes
  Windows PowerShell Cookbook by Lee Holmes
.Links
  https://www.oreilly.com/library/view/windows-powershell-cookbook/9780596528492/ch01s09.html
  
##############################################################################>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
Param(
  [string]$Script, 
  [string]$Parameters
)

try {
  $tempFile = [IO.Path]::GetTempFileName()
  ## Store the output of cmd.exe. We also ask cmd.exe to output
  ## the environment table after the batch file completes 
  cmd /c " `"$script`" $parameters && set >`"$tempFile`" "
  ## Go through the environment variables in the temp file.
  ## For each of them, set the variable in our local environment.
  Get-Content $tempFile | Foreach-Object {
    if($_ -match '^(.*?)=(.+)$' ) {
      If ($ShouldProcess = $PSCmdlet.ShouldProcess($Item, $NewMessage)) {
        Set-Content "env:\$($matches[1])" $matches[2]
      }  
    }
  }
} finally {
  If (Test-Path $tempFile -ea ignore){ Remove-Item $tempFile -ea Ignore -force }
}
