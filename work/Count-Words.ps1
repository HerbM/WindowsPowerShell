<#
  Example from: "Thinking Functionally with Haskell" Byrd p. 7
    concat . map showRun . take n .
      sortRuns . countRuns . sortWords .
      words . map toLower

  PowerShell version follows, which with functions 'words' & 'countruns' becomes:

  Get-Content $Path | lowercase | words | sort | countruns | sort length -desc | select -first $n      
  
#>

[CmdletBinding()]Param(
  [Int]$n           = 10, 
  [Alias('Filename','Name','Book','Textbook')][string]$Path     = '',
  [string]$Url      = '',
  [switch]$Download = $False
) # parameters to this script file Get-Words.ps1

$DefaultFile = 'C:\dev\WarAndPeaceStart.txt'
$DefaultUrl  = 'http://www.gutenberg.org/files/2600/2600-0.txt'

Function CountRuns {
  Param([Parameter(ValueFromPipeline)][string[]]$Words) 
  Begin {
    Function New-RunCount {
      Param([string]$Word, [Int]$Count)     
      [PSCustomObject]@{ Count = $Count; Word = $Word } 
    }
    
    $Count, $LastWord = 0, ''      # Start with no word, count 0 
  }   
  Process {
    If (!$PSBoundParameters.ContainsKey('Words')) { $Words = $_ }
    ForEach ($Word in $Words) {
      If ($Count++) {
        If ($Word -cne $LastWord) {
          [PSCustomObject]@{
            Count = $Count
            Word  = $LastWord
          }          
          $Count, $LastWord = 0, $Word      # reset for new word 
          Continue
        } 
      } ElseIf (!$Word) {
        $LastWord = $Word
      }
    }
  }    
  end { if ($Count) { New-WordCount $Count $LastWord }}  # Flush final word                      
}

filter ToLower { $_.toLower() }
filter words   { $_ -split '\W+' | ? Length -gt 0 }
  


$Text = If ($Url -or $Download) {
  If (!$Url) { $Url = $DefaultUrl }
  (Invoke-WebRequest $Url).Content
} Else {
  If (!$Path) { $Path = $DefaultFile }
  Get-Content $Path  
}  
Write-Verbose "$(LINE) [$Path] [$Url]"
$Text | toLower | words | group | sort Count -Descending | select -first $n


<# Output of "War and Peace" from Project Gutenberg http://www.gutenberg.org/files/2600/2600-0.txt

    word length
    ---- ------
    the   34258
    and   21396
    to    16500
    of    14904
    -     14555
    a     10388
    he     9298
    in     8733
    his    7930
    that   7412
      
# The following line is the older 'program'  
# Get-Content $Path | % ToLower | % Split | sort | countruns | sort count -desc | select -first $n
#>
