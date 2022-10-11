(gc .\0.vlc) -split '' | ? { $_ -and [uint][char]$_ -ge 128 } # find utf-8 non-regular ASCII

b64 ((gcb | ? length -gt 0) -replace '^[\r\n\s]|[\r\n\s]$+') | clip; gcb

Scripts\Add-AliasList.ps1