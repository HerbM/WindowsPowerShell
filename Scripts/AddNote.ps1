<#
.Synopsis
  New-Note added to a file as a CSV line
.Description
  Very simple start to adding notes to a text file but it's functional
.Example
  New-Note "Pickup milk on way home" ToDo
.Parameter Message
  Text note(s) to add to file
.Parameter Category
  Category for filing - note will be added with each category
.Parameter Path
  File to use -- add to Categoies.txt file to add new categories
.Parameter Configuration
  Look up and match partial category names from this file
.Notes
  Just a start but functional
  ToDo:  Add more fields
  ToDo:  ???

#>
Function New-Note {
  [CmdletBinding()]param(
    [Alias('Content')]        [string[]]$Message,
                              [string[]]$Category=@('Remember'),
    [Alias('File','FullName')][string[]]$Path=@("$Home\Notes.txt"),
                                [string]$Configuration="$Home\Categories.txt",
                                   [Int]$Count=0,
                                [switch]$Force  # force configuration creation
  )
  If (($Count -or ($Count = $Message[0] -as [Int])) -and (($Count -le 10) -or $Force)) {
    $Count = [Math]::Abs($Count)
    $Message = (Get-History -Count $Count).CommandLine
    If ($Category -eq @('Remember')) { $Category = @('PowerShell') }
  } 
  If (!(Test-Path $Configuration -ea 0 ) -and
       ($Force -or $Configuration -eq "$Home\Categories.txt")) {
    "DateTime","Category","Content" | Out-File $Configuration -ea 0
  }
  $Standard = @('Remember','ToDo','Fun','Learn','PowerShell','FP') +
               (Import-CSV $Configuration -ea 0 | % { $_.Category } | select -uniq )
  $Message  = $Message | % { $_ -split "`n" }
  $Date     = Get-Date -f 's'
  $Category = $Category | % {
    $Found  = $Standard -match $_
    If ($Found) { $Found } else { $_ }
  }
  $Show = @()
  ForEach ($File in $Path) {
    ForEach ($Cat in $Category) {
      ForEach ($Line in $Message) {
        $Out = [pscustomobject]@{
          DateTime = $Date -f 's'
          Category = $Cat
          Message  = $Line
        }
        $Out   | Export-Csv $File -append -notype
        $Show += $Out
      }
    }
  }
  $Show | Format-Table
}
New-Alias Add-Note New-Note -force -scope Global
New-Alias an       New-Note -force -scope Global
New-Alias nn       New-Note -force -scope Global

<#. 
.Notes
  ToDo: consider more/better Notes, Json captures, etc.  
        support csv, xml, json
#>
Function New-Mistake {
  [CmdletBinding()]Param(
    [Parameter(Mandatory)][string[]]$Mistake,
                          [string]  $Reason  = 'Unknown',
                          [string]  $Comment = '',
                          [string]  $Path    = "$((Get-UserFolder 'Personal').Folder)\MistakeLog*.txt",
                          [Switch]  $Force                      
  )
  $Mistake, $Extra = $Mistake
  If (!$Comment ) {
    If ($Reason) {
      Write-Verbose "$(FLINE) Reason: $Reason but no Comment, Extra: $Extra"
      $Comment       = $Reason
      $Reason, $Null = $Extra
    } Else {
      Write-Verbose "$(FLINE) No Reason & no Comment Extra: $Extra"
      $Reason, $Comment, $Null = $Extra
    }
  }
  $Date     = Get-Date -f 's'
  $FileName = Get-MistakeFileName $Path -Force
  Write-Verbose "$(FLINE) $Date,$Mistake,$Reason,$Comment,$Extra"
  [PSCustomObject]@{ 
    Date    = $Date     
    Mistake = $Mistake -join ' '
    Reason  = $Reason  -join ' '
    Comment = $Comment -join ' '
  } | Export-Csv -Encoding UTF8 -Append $FileName -NoTypeInformation
}
New-Alias Add-Mistake New-Mistake -scope Global -Force # Mistake object
New-Alias nm          New-Mistake -scope Global -Force
New-Alias am          New-Mistake -scope Global -Force

Function Get-MistakeFileName {
  [CmdletBinding()]Param(
    [string]$Path    = "$((Get-UserFolder 'Personal').Folder)\MistakeLog*.txt",
    [Switch]$Force                      
  )
  $FileName = If ($File = (Get-Item $Path -ea Ignore | Select-Object -First 1)) {
    $File.FullName
  } ElseIf ($Force) {
    Join-Path (Get-UserFolder 'Personal').Folder "MistakeLog$($Env:UserName).txt"
  }
  Write-Verbose "$(FLINE) Filename: $FileName"
  $FileName
}

<#
.Notes
  ToDo: support date range, filter/search, count
#>
Function Get-Mistake {
  [CmdletBinding()]Param(
    [string]$Path = "$((Get-UserFolder 'Personal').Folder)\MistakeLog*.txt"
  )
  $FileName = Get-MistakeFileName $Path
  If (Test-Path $FileName -ea 0) { 
    Write-Verbose "$(FLINE) Mistake file found: $FileName"
    Import-CSV $FileName    
  } else {
    Write-Warning "$(FLINE) No mistake file found"
  }
}


<#
DateTime,Mistake,Reason,Comment
2018-08-12T16:35:13,Forgot I downloaded OpenXML to c:\s,2018-05-13,2 months ago
2018-08-12T16:35:13,PropHashOmitted = after E,careless,
2018-08-12T16:38:13,Put Hash @ on Expresssion scriptblock,Took took long due to previous mistake,
2018-08-12T16:54:10,Command after last param,moved them around 1st->last,common problem
2018-08-12T17:03:21,"used Resolve-Path wrong" "Don't use it often",doesn't return fileinfo/something else
2018-08-12T17:09:33,Used ps1 extension for txt file,wasted time debugging,Resolve-Path->Get-Item->Get-ChildItem
2018-08-12T18:07:22,Missing paren,Copied code but missed close paren,$(
##############
ToDo:
Compile OpenXML
Fix ImportXML
Fix Notepad++:  Find dialog A/D, switch tabs, close (reopen) search window
Notepad++ macro for datetime or Mistake file
PowerShell function for datetime Mistake file

#>