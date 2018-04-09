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
    [Alias('Content'][string[]]$Message,
    [string[]]$Category=@('Remember'),
    [Alias('File','FullName')][string[]]$Path=@("$Home\Notes.txt"),
    [string]  $Configuration = "$Home\Categories.txt",
    [switch]  $Force  # force configuration creation
  )
  If (!(Test-Path $Configuration -ea 0 ) -and 
       ($Force -or $Configuration -eq "$Home\Categories.txt")) {
    "DateTime","Category","Content" | Out-File $Configuration -ea 0 
  }
  $Standard  = @('Remember','ToDo','Fun','Learn','PowerShell','FP') + 
                 (Import-CSV $Configuration -ea 0 | % { $_.Category } | select -uniq )
  $Message = $Message | % { $_ -split "`n" }
  $Date = Get-Date -f 's'
  $Category = $Category | % { 
    $Found = $Standard -match $_ 
    If ($Found) { $Found } else { $_ }
  }
  ForEach ($File in $Path) {
    ForEach ($Cat in $Category) {
      ForEach ($Line in $Message) {
        $Out = [pscustomobject]@{
          DateTime = $Date -f 's'
          Category = $Cat
          Message  = $Line
        }
        $Out | Export-Csv $File -append -notype
        $Out | Format-Table -HideTableHeader
      }  
    }     
  }  
}
