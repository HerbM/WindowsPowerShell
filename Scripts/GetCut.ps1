# 
Function Get-Cut   { 
  [CmdletBinding(DefaultParameterSetName='Character')]param(
    [Parameter(ParameterSetName='Character',Position=0)][string[]]$Characters = '1-80', 
    [Parameter(ParameterSetName='Byte',     Position=0)][string[]]$Bytes      = '1-80',
    [Parameter(ParameterSetName='Field',    Position=0)][string[]]$Fields     = '1-254',     
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=1)]
    [Alias('Strings','Text')]
      [string[]]$Lines='',
    [Alias('Separator','FSeparator')]                 [string]$Delimeter='\s+',
    [Alias('LineSeparator','LSeparator','RSeparator')][string]$RecordSeparator=[Environment]::NewLine,
    [Uint32]$Skip     = 0,
    [Uint32]$SkipLast = 0,
    [string]$MatchPattern = '',
    [string]$IgnorePattern = '',
    [switch]$AtLeastCount,
    [switch]$ExactCount,
    [switch]$OmitBlankLines,
    [switch]$Dummy
  )
  Begin {
    $MaxLine = [uint16]::MaxValue
    $FirstPosition = 1
    $Spans,$SpanType = Switch ($PSCmdLet.ParameterSetName) {
      'Character' { $Characters, 'Char' ; break }
      'Byte'      { $Bytes     , 'Byte' ; break }
      'Field'     { $Fields    , 'Field'; break }
      DEFAULT     { $Characters, 'Char' ; break }
    }
    $Debug = $PSBoundParameters.ContainsKey('Debug') -and $Debug      
    $Spans = @(
      ForEach ($Span in $Spans) {
        $Span = $Span.Trim()
        If ($Difference = $Span -match '\+') {
          # $Debug -and (Write-Verbose "$(LINE) Replacing...$Span")
          $Span = $Span -replace '\++', '-'
        }
        Write-Verbose "$(LINE) Span: [$Span]"
        If ($Span -match '-$')   { $Span = $Span + $MaxLine       }
        If ($Span -match '^-')   { $Span = "$FirstPosition$Span"; }
        If ($Span -notmatch '-') { $Span = "$Span-$Span"; }
        $Span = $Span -split '-'
        Write-Verbose "$(LINE) Span: [$Span]"
        If ($Difference) { $Span[1] = [Int]$Span[0] + [Int]$Span[1] - 1 }
        Write-Verbose "$(LINE) Span: [$Span]"
        ,$Span  # Return 2 element array
      }
    )
    $LineCount = 0
    $Buffer = New-Object System.Collections.Arraylist
    Write-Verbose "$(LINE) Count: $($Spans.Count) Spans: [$(($Spans | Out-String) -split '[\r\n]+' -join ', ')]"
  }  
  Process {
    ForEach ($Line in $Lines) {
      :NEXTLINE ForEach ($L in ($Line -split $RecordSeparator)) {
        If ($Skip -gt $LineCount++)                          { continue :NEXTLINE }
        If ($MatchPattern  -and $L -notmatch $MatchPattern ) { continue :NEXTLINE }
        If ($IgnorePattern -and $L -match    $IgnorePattern) { continue :NEXTLINE }
        If ($SpanType -eq 'Field') { 
          $L = $L -split $Delimeter
          $LastIndex = $L.Count - 1 
        }
        $LastIndex = $L.Length - 1
        Write-Verbose ("$(LINE) LastIndex: {0,3}  Line: [{1}]" -f $LastIndex, $L)
        $Collection = @(
          ForEach ($Span in $Spans) {
            $Low  = [Math]::Max([Int]$Span[0] - 1, 0)
            If ($Low -ge $LastIndex) {
              Write-Verbose "$(LINE) SKIP: $Low $LastIndex L: $($L -join '; ') "
            } Else {
              Write-Verbose "$(LINE) Span:[$Span] LineLen: $($L.Length)"
              $Count = [Math]::Min($Span[1], $LastIndex) - $Low + 1
              $Hi    = [Math]::Min($Count + $Low, $LastIndex)
              Write-Verbose "$(LINE) Type: $SpanType Span: [$Span] Range: $Low for $Count"
              Switch ($SpanType) {
                'Char'  { $L.SubString($Low,$Count); break }
                'Byte'  { $L.SubString($Low,$Count); break }
                'Field' { $L[($Low+1)..$Hi]        ; break }
              }
            }  
          }
        )
        Write-Verbose "$(LINE) CollectionCount: $($Collection.Count)"
        If (($AtLeastCount -and ($Collection.Count -ge $Spans.Count)) -or 
            ($ExactCount   -and ($Collection.Count -eq $Spans.Count)) -or
            (!($AtLeastCount -or $ExactCount)                      )) {
          If ($SkipLast) {
           $Null = $Buffer.Add($Collection -join ',')
          } Else {
            $Collection -join ','
          }           
        }  
      }
    }
  }
  End {
    If ($Buffer -and ($OutCount = $Buffer.Count - $SkipLast) -gt 0) {
      $Buffer[0..$OutCount]
    }
  }  
}

# route print | get-cut 3-17,20-33 #20 ( gc license)
# . getcut;cls; route print | get-cut 3+14,20-33 # -verbose #20 ( gc license)'
# . getcut;cls; route print | get-cut -field 1-3 # -verbose #,20-33 # -verbose #20 ( gc license)'
# . getcut;cls; route print | get-cut -field 1-3 -match '^\s*\d' -atleast -ignore '\.\.\.\.'

Function Get-Slice { 
  param($Character, $Line='') $N 
}
# cut --help
<#
Usage: c:\unx\cut.exe [OPTION]... [FILE]...

Print selected parts of lines from each FILE to standard output.

Mandatory arguments to long options are mandatory for short options too.
  -b, --bytes=LIST        select only these bytes
  -c, --characters=LIST   select only these characters
  -d, --delimiter=DELIM   use DELIM instead of TAB for field delimiter
  -f, --fields=LIST       select only these fields;  also print any line
                            that contains no delimiter character, unless
                            the -s option is specified
  -n                      (ignored)
      --complement        complement the set of selected bytes, characters
                            or fields.
  -s, --only-delimited    do not print lines not containing delimiters
      --output-delimiter=STRING  use STRING as the output delimiter
                            the default is to use the input delimiter
      --help     display this help and exit
      --version  output version information and exit

Use one, and only one of -b, -c or -f.  Each LIST is made up of one
range, or many ranges separated by commas.  Selected input is written
in the same order that it is read, and is written exactly once.
Each range is one of:

  N     N'th byte, character or field, counted from 1
  N-    from N'th byte, character or field, to end of line
  N-M   from N'th to M'th (included) byte, character or field
  -M    from first to M'th (included) byte, character or field

With no FILE, or when FILE is -, read standard input.

Report bugs to <bug-coreutils@gnu.org>.
#>