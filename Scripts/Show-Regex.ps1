#  Technically this is a PowerShell script
[CmdLetBinding()]param(
  [parameter(ValueFromRemainingArguments=$true)][string[]]$Args
)

$Params = ForEach ($a in $Args) {
  $a | ForEach-Object  { $_ }  
}

Function Main {
  [CmdLetBinding()]param(
    [parameter(ValueFromRemainingArguments=$true)][string[]]$Args
  )
  $Info =  $RegexInfo.Keys | ForEach-Object { "$_`n$($RegexInfo.$_)`n" }
  If (!($Args | Where-Object { $_ } )) {
    $Info
  } else {
    $Patterns = @()
    ForEach ($Parm in $Params) {
      If ($Parm -and $RegexInfo.Contains($Parm)) { "$_`n$($RegexInfo.$_)`n" }
      Else { $Patterns += $Parm }
    }  
    $Info | Select-String $Patterns
  }
}

$RegexInfo = [Ordered]@{
  Title = @'
  .Net Framework Regular Expressions'
'@
SINGLE_CHARACTERS = @'
  Use      To match any character
  [set]    In that set
  [^set]   Not in that set
  [a-z]    In the a-z range
  [^a-z]   Not in the a-z range
  .        Any except \n (new line)
  \char    Escaped special character
'@
CONTROL_CHARACTERS = @'
  Use           To match         Unicode
  \t            Horizontal tab   \u0009
  \v            Vertical tab     \u000B
  \b            Backspace        \u0008
  \e            Escape           \u001B
  \r            Carriage return  \u000D
  \f            Form feed        \u000C
  \n            New line         \u000A
  \a            Bell (alarm)     \u0007
  \c char       ASCII control character
'@
'NON-ASCII_CODES' = @'
  Use           To match Character with
  \octal        2-3 digit octal character code
  \x hex        2-digit   hex   character code
  \u hex        4-digit   hex   character code
'@
CHARACTER_CLASSES = @'
  Use             To match Character
  \p{ctgry}       In that Unicode category or block
  \P{ctgry}       Not in that Unicode category or block
  \w              Word character
  \W              Non-word character
  \d              Decimal digit
  \D              Not a decimal digit
  \s              White-space character
  \S              Non-white-space char
'@
QUANTIFIERS = @'
  Greedy  Lazy    Matches
  *       *?      0 or more times
  +       +?      1 or more times
  ?       ??      0 or 1 time
  {n}     {n}?    Exactly n times
  {n,}    {n,}?   At least n times
  {n,m}   {n,m}?  From n to m times
'@
ANCHORS = @'
  Use     To specify position
  ^       At start of string or line
  \A      At start of string
  \z      At end of string
  \Z      At end (or before \n at end) of string
  $       At end (or before \n at end) of string or line
  \G      Where previous match ended
  \b      On word boundary
  \B      Not on word boundary
'@
GROUPS = @'
  Use                  To define
  (exp)                Indexed group
  (?<name>exp)         Named group
  (?<name1-name2>exp)  Balancing group
  (?:exp)              Noncapturing group
  (?=exp)              Zero-width positive lookahead
  (?!exp)              Zero-width negative lookahead
  (?<=exp)             Zero-width positive lookbehind
  (?<!exp)             Zero-width negative lookbehind
  (?>exp)              Non-backtracking (greedy)
'@
INLINE_OPTIONS = @'
  Option               Effect on match
  i                    Case-insensitive
  m                    Multiline mode
  n                    Explicit (named)
  s                    Single-line mode
  x                    Ignore white space
  Use                  To
  (?imnsx-imnsx)       Set or disable specified options
  (?imnsx-imnsx:exp)   Set or disable specified options within expression
'@
BACKREFERENCES = @'
  Use             To match
  \n              Indexed group
  \k<name>        Named group
'@
ALTERNATION = @'
  Use             To match
  a|b             Either a or b
  (?(exp)yes|no)  yes if exp  is matched, no if exp isn't matched
  (?(name)yes|no) yes if name is matched, no if name isn't matched
'@
SUBSTITUTION = @'
  Use             To substitute
  $n              Substring matched by group number n
  ${name}         Substring matched by group name
  $$              Literal $ character
  $&              Copy of whole match
  $`              Text before the match
  $'              Text after the match
  $+              Last captured group
  $_              Entire input string
'@
COMMENTS = @'
  Use             To
  (?# comment)    Add inline comment
  #               Add x-mode comment
'@
SUPPORTED_UNICODE_CATEGORIES = @'
  Category        Description
  Lu              Letter, uppercase
  LI              Letter, lowercase
  Lt              Letter, title case
  Lm              Letter, modifier
  Lo              Letter, other
  L               Letter, all
  Mn              Mark, nonspacing combining
  Mc              Mark, spacing combining
  Me              Mark, enclosing combining
  M               Mark, all diacritic
  Nd              Number, decimal digit
  Nl              Number, letterlike
  No              Number, other
  N               Number, all
  Pc              Punctuation, connector
  Pd              Punctuation, dash
  Ps              Punctuation, opening mark
  Pe              Punctuation, closing mark
  Pi              Punctuation, initial quote mark
  Pf              Puntuation, final quote mark
  Po              Punctuation, other
  P               Punctuation, all
  Sm              Symbol, math
  Sc              Symbol, currency
  Sk              Symbol, modifier
  So              Symbol, other
  S               Symbol, all
  Zs              Separator, space
  Zl              Separator, line
  Zp              Separator, paragraph
  Z               Separator, all
  Cc              Control code
  Cf              Format control character
  Cs              Surrogate code point
  Co              Private-use character
  Cn              Unassigned
  C               Control characters, all
  For named character set blocks (e.g., Cyrillic), search for
  "supported named blocks" in the MSDN  Library.
'@
REGULAR_EXPRESSION_OPERATIONS = @'
  Class:                  System.Text.RegularExpressions.Regex
  Pattern matching with   Regex objects
  To initialize with      Use constructor
  Regular exp             Regex(String)
  + options               Regex(String, RegexOptions)
  + time-out              Regex(String, RegexOptions, TimeSpan)
'@
Pattern_matching_with_static_methods = @'
  Use an overload of a method below to supply
  the regular expression & the text you want to search.
  Finding and replacing matched patterns
  To                      Use method
  Validate match          Regex.IsMatch
  Retrieve single match   Regex.Match     (first)
                          Match.NextMatch (next)
  Retrieve all matches    Regex.Matches
  Replace match           Regex.Replace
  Divide text             Regex.Split
  Handle char escapes     Regex.Escape
                          Regex.Unescape
'@
Getting_info_about_regular_expression_patterns = @'
  To get              Use Regex API
  Group names         GetGroupNames
                      GetGroupNameFromNumber
  Group numbers       GetGroupNumbers
                      GetGroupNumberFromName
  Expression          ToString
  Options             Options
  Time-out            MatchTimeOut
  Cache size          CacheSize
  Direction           RightToLeft
'@
Reference = @'
  For detailed information & examples: http://aka.ms/regex
  To test your regular expressions:    http://regexlib.com/RETester.aspx
'@
}

Main @PSBoundParameters