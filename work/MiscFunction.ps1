
Begin {
  $Buffer = @()
}
Process {
  If ($InputObject -match $EndPattern) {
    $Buffer
    $Buffer = @()    
  } else {
    $Buffer += $_
  }
}
End {
  If ($Buffer) {
    $Buffer  
  }
}