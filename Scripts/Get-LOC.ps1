dir S:\dev\Herb\loc\*cred.xml | ForEach-Object {
  New-Variable "$($_.BaseName)" -Value (Import-Clixml $_) -force
}

