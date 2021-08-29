[CmdletBinding()]param(
  [switch]$BraceMatching,
  [switch]$QuoteMatching,
  [switch]$ForcePSReadLine,
  [Alias('AllMatching','BothMatching')][switch]$Matching
)

try {
# using namespace System.Management.Automation
# using namespace System.Management.Automation.Language

$Private:ErrorCount = if ($Error) { $Error.Count } else { 0 }

If ($Matching) {$BraceMatching = $QuoteMatching = $True }
If ($QuoteMatching -and $BraceMatching) { $Matching = $True }

# [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
# $SaveHistory = $null
# [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory('"This is a test"')
# OEMKey https://msdn.microsoft.com/en-us/library/system.windows.forms.keys%28v=vs.110%29.aspx?f=255&MSPPError=-2147217396
# [System.ConsoleKey] | gm -static | more
# Alt-w current line to history
$SaveHistory = @((Get-History -count 3000) | ForEach-Object commandline)
If ($SaveHistory) {
  write-warning "History count $($SaveHistory.count)"
} else {
  write-warning "No history to load"
}

$PSVersionNumber = "$($psversiontable.psversion.major).$($psversiontable.psversion.minor)" -as [double]
if (!(Get-Module PSReadline -listavailable -ea Ignore)) {
  $parms = @{force = $true; Confirm = $False}
  if ($PSVersionNumber -ge 5.1) { $parms += @{ AllowClobber = $True } }
  If (Get-Command Install-Module -ea Ignore) {
    Install-Module PSReadline @Parms -ea Ignore 
  } Else {
    Write-Warning "$(FLINE) Install-Module not found"
  }
}
if (!(Get-Module PSReadline -ea ignore) -and (Get-Module PSReadline -listavailable -ea ignore)) {
  Import-Module PSReadLine
}
$PSHistoryFileName  = 'PSReadLine_history.txt'
$PSHistoryDirectory = "$Home\Documents\PSHistory"
$PSHistory          = "$PSHistoryDirectory\$PSHistoryFileName"

Try {
  If (($PSRL = Get-Module PSReadLine -ea 0) -and ($PSRL.version -ge [version]'2.0.0')) { 
    Remove-PSReadLineKeyHandler ' ' -ea Ignore 
  }
} Catch {
  Write-Warning "Error Remove KeyHandler [$($_.ToString())]"
}

######### Move Old History to new location
	if (!(Test-path $PSHistoryDirectory)) { mkdir $PSHistoryDirectory }
	try {
		$OldHistory  = @(if (($oh = (Get-PSReadLineOption).HistorySavePath) -and
													$oh -ne $PSHistoryDirectory                   -and
													$oh -ne $PSHistory) { $oh })
		$OldHistory += "$(Split-Path $Profile)\$PSHistoryFileName"
		$OldHistory  = Get-ChildItem $OldHistory -file -ea ignore | Sort-Object -uniq lastwritetime,fullname
		$null =  $OldHistory | ForEach-Object {
			Get-Content $_ -ea Stop | out-file -append $PSHistory -ea Stop
			Remove-Item $_ -ea Stop
		}
		Set-PSReadlineOption -HistorySavePath $PSHistory
	} catch {
		$_
		write-error "Cannot reset PSReadlineHistory:$PSHistoryFileName to $PSHistoryDirectory"
		"HistorySavePath : $((Get-PSReadLineOption).HistorySavePath)"
	} Finally {
		write-information "HistorySavePath : $((Get-PSReadLineOption).HistorySavePath)"
	}
###################

<#
Set-PSReadLineOption     -HistorySearchCursorMovesToEnd
#>
New-Alias kh   Get-PSReadlineKeyHandler    -force
New-Alias skh  Set-PSReadlineKeyHandler    -force
New-Alias rkh  Remove-PSReadlineKeyHandler -force
New-Alias rlo  Set-PSReadLineOption        -force
New-Alias srlo Set-PSReadLineOption        -force
New-Alias rlo  Get-PSReadLineOption        -force

Set-PSReadLineKeyHandler -Key 'Alt+F7','Alt+F8' `
                         -BriefDescription History `
                         -LongDescription 'Show command history' `
                         -ScriptBlock {
  $pattern = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
  if ($pattern) { $pattern = [regex]::Escape($pattern) }
  $history = [System.Collections.ArrayList]@(
    $last = $lines = ''
    foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
      if ($line.EndsWith('`')) {
        $line = $line.Substring(0, $line.Length - 1)
        $lines = if ($lines) { "$lines`n$line" } else { $line }
        continue
      }
      if ($lines) {
        $line = "$lines`n$line"
        $lines = ''
      }
      if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
        $last = $line
        $line
      }
    }
  )
  $history.Reverse()
  $command = $history | Out-GridView -Title History -PassThru
  if ($command) {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
  }
}

# This is an example of a macro that you might use to execute a command.
# This will add the command to history.
#Set-PSReadLineKeyHandler -Key Ctrl+B `
#                         -LongDescription "Build the current directory" `
#                         -BriefDescription BuildCurrentDirectory `
#                         -ScriptBlock {
#  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("msbuild")
#  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
#}

Set-PSReadLineKeyHandler -Key Shift+Ctrl+C   -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+V         -Function Paste
Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+S' -Function CaptureScreen

# The built-in word movement uses character delimiters, but token based word
# movement is also very useful - these are the bindings you'd use if you
# prefer the token based movements bound to the normal emacs word movement
# key bindings.
Set-PSReadLineKeyHandler -Key Alt+D           -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace   -Function ShellBackwardKillWord
Set-PSReadLineKeyHandler -Key Alt+B           -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F           -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Shift+Alt+B     -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Shift+Alt+F     -Function SelectShellForwardWord
Set-PSReadlineKeyHandler -Key Shift+BackSpace -Function BackwardDeleteChar

#region Smart Insert/Delete
if ($QuoteMatching) {
  # The next four key handlers are designed to make entering matched quotes
  # parens, and braces a nicer experience.  I'd like to include functions
  # in the module that do this, but this implementation still isn't as smart
  # as ReSharper, so I'm just providing it as a sample.
  Set-PSReadLineKeyHandler -Key '"',"'" `
                           -BriefDescription SmartInsertQuote `
                           -LongDescription "Insert paired quotes if not already on a quote" `
                           -ScriptBlock {
    param($key, $arg)
    $quote = $key.KeyChar
    $selectionStart = $selectionLength = $line = $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1) {    # text selected, sojust quote it without any smarts
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength,
        $quote + $line.SubString($selectionStart, $selectionLength) + $quote)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart +
        $selectionLength + 2)
      return
    }
    $ast = $tokens = $parseErrors = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast,
      [ref]$tokens, [ref]$parseErrors, [ref]$null)
    function FindToken {
      param($tokens, $cursor)
      foreach ($token in $tokens) {
        if ($cursor -lt $token.Extent.StartOffset) { continue }
        if ($cursor -lt $token.Extent.EndOffset) {
          $result = $token
          $token = $token -as [StringExpandableToken]
          if ($token) {
            $nested = FindToken $token.NestedTokens $cursor
            if ($nested) { $result = $nested }
          }
          return $result
        }
      }
      return $null
    }
    $token = FindToken $tokens $cursor
    # If we're on or inside a **quoted** string token (so not generic), we need to be smarter
    if ($token -is [StringToken] -and $token.Kind -ne [TokenKind]::Generic) {
      # If we're at the start of the string, assume we're inserting a new string
      if ($token.Extent.StartOffset -eq $cursor) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote ")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        return
      }
      # If we're at the end of the string, move over the closing quote if present.
      if ($token.Extent.EndOffset -eq ($cursor + 1) -and $line[$cursor] -eq $quote) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        return
      }
    }
    if ($null -eq $token) {
      if ($line[0..$cursor].Where{$_ -eq $quote}.Count % 2 -eq 1) {
        # Odd number of quotes before the cursor, insert a single quote
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote)
      } else  {  # Insert matching quotes, move cursor to be in between the quotes
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$quote$quote")
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
      }
      return
    }
    if ($token.Extent.StartOffset -eq $cursor) {
      if ($token.Kind -eq [TokenKind]::Generic -or $token.Kind -eq [TokenKind]::Identifier) {
        $end = $token.Extent.EndOffset
        $len = $end - $cursor
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($cursor, $len,
          $quote + $line.SubString($cursor, $len) + $quote)
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($end + 2)
      }
      return
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($quote) # just insert a single quote
  }
} # QuoteMatching

If ($BraceMatching) {
  Set-PSReadLineKeyHandler -Key '(','{','[' `
                           -BriefDescription InsertPairedBraces `
                           -LongDescription "Insert matching braces" `
                           -ScriptBlock {
    param($key, $arg)
    $retreat = 1
    $closeChar = switch ($key.KeyChar) {
      '('   {      [char]')'  ;               break }
      '{'   { "  $([char]'}')"; $retreat = 2; break }
      '['   {      [char]']'  ;               break }
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    $line = $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,[ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - $retreat)
  }

  Set-PSReadLineKeyHandler -Key ')',']','}' `
                           -BriefDescription SmartCloseBraces `
                           -LongDescription "Insert closing brace or skip" `
                           -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($line[$cursor] -eq $key.KeyChar) {
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    } else  {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
  }
} # BraceMatching

if ($Matching) {
  Set-PSReadLineKeyHandler -Key Backspace `
               -BriefDescription SmartBackspace `
               -LongDescription "Delete previous character or matching quotes/parens/braces" `
               -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -gt 0) {
      $toMatch = $null
      if ($cursor -lt $line.Length) {
        switch ($line[$cursor]) {
          <#case#> '"' { $toMatch = '"'; break }
          <#case#> "'" { $toMatch = "'"; break }
          <#case#> ')' { $toMatch = '('; break }
          <#case#> ']' { $toMatch = '['; break }
          <#case#> '}' { $toMatch = '{'; break }
        }
      }
      if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
      } else  {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
      }
    }
  }

} # Matching for BackSpace

#endregion Smart Insert/Delete


# Sometimes you enter a command but realize you forgot to do something else first.
# This binding will let you save that command in the history so you can recall it,
# but it doesn't actually execute.  It also clears the line with RevertLine so the
# undo stack is reset - though redo will still reconstruct the command line.
Set-PSReadLineKeyHandler -Key Alt+w,Shift+Escape `
             -BriefDescription SaveInHistory `
             -LongDescription "Save current line in history but do not execute" `
             -ScriptBlock {
  param($key, $arg)
  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}
Set-PSReadLineKeyHandler -key escape -function RevertLine 

<#
Set-PSReadLineKeyHandler -Chord Escape `
                         -BriefDescription RevertLineWithSave `
                         -LongDescription "Save Curent line then revert" `
                         -ScriptBlock {
  param($key, $arg)
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)                         
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}
#>

# Insert text from the clipboard as a here string
Set-PSReadLineKeyHandler -Key Ctrl+Shift+v `
             -BriefDescription PasteAsHereString `
             -LongDescription "Paste the clipboard text as a here string" `
             -ScriptBlock {
  param($key, $arg)
  Add-Type -Assembly PresentationCore
  if ([System.Windows.Clipboard]::ContainsText()) {
    # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
    $text = ([System.Windows.Clipboard]::GetText() -replace "\p{Zs}*`r?`n","`n").TrimEnd()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
  } else  {
    [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
  }
}

## Stub to add new handler
## Set-PSReadLineKeyHandler -Key "+Alt+'" `
##                          -BriefDescription InsertQuotePair `
##                          -LongDescription "Insert pair of quotes" `
##                          -ScriptBlock {
##   param($key, $arg)
## }

# Each time you press Alt+', this key handler will change the token
# under or before the cursor.  It will cycle through single quotes, double quotes, or
# no quotes each time it is invoked.

Set-PSReadLineKeyHandler -Key "Ctrl+Alt+'" `
             -BriefDescription ToggleQuoteArgument `
             -LongDescription "Toggle quotes on the argument under the cursor" `
             -ScriptBlock {
  param($key, $arg)

  $ast = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

  $tokenToChange = $null
  foreach ($token in $tokens) {
    $extent = $token.Extent
    if ($extent.StartOffset -le $cursor -and $extent.EndOffset -ge $cursor) {
      $tokenToChange = $token
      # If the cursor is at the end (it's really 1 past the end) of the previous token,
      # we only want to change the previous token if there is no token under the cursor
      if ($extent.EndOffset -eq $cursor -and $foreach.MoveNext()) {
        $nextToken = $foreach.Current
        if ($nextToken.Extent.StartOffset -eq $cursor) {
          $tokenToChange = $nextToken
        }
      }
      break
    }
  }

  if ($tokenToChange -ne $null) {
    $extent = $tokenToChange.Extent
    $tokenText = $extent.Text
    if ($tokenText[0] -eq '"' -and $tokenText[-1] -eq '"') {
      # Switch to no quotes
      $replacement = $tokenText.Substring(1, $tokenText.Length - 2)
    } elseif ($tokenText[0] -eq "'" -and $tokenText[-1] -eq "'") {
      # Switch to double quotes
      $replacement = '"' + $tokenText.Substring(1, $tokenText.Length - 2) + '"'
    } else  {
      # Add single quotes
      $replacement = "'" + $tokenText + "'"
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
      $extent.StartOffset,
      $tokenText.Length,
      $replacement)
  }
}

# This example will replace any aliases on the command line with the resolved commands.
Set-PSReadLineKeyHandler -Key "Alt+%" `
                         -BriefDescription ExpandAliases `
                         -LongDescription "Replace all aliases with the full command" `
                         -ScriptBlock {
  param($key, $arg)
  $ast    = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
  $startAdjustment = 0
  foreach ($token in $tokens) {
    if ($token.TokenFlags -band [TokenFlags]::CommandName) {
      $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
      if ($alias -ne $null) {
        $resolvedCommand = $alias.ResolvedCommandName
        if ($resolvedCommand -ne $null) {
          $extent = $token.Extent
          $length = $extent.EndOffset - $extent.StartOffset
          [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $extent.StartOffset + $startAdjustment,
            $length, $resolvedCommand)
          # Our copy of the tokens won't have been updated, so we need to
          # adjust by the difference in length
          $startAdjustment += ($resolvedCommand.Length - $length)
        }
      }
    }
  }
}

# F1 for help on the command line - naturally
Set-PSReadLineKeyHandler -Key F1,Alt+h `
                         -BriefDescription CommandHelp `
                         -LongDescription "Open the help window for the current command" `
                         -ScriptBlock {
  param($key, $arg)
  $ast    = $null
  $tokens = $null
  $errors = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
  $commandAst = $ast.FindAll( {
    $node = $args[0]
    $node -is [CommandAst] -and
      $node.Extent.StartOffset -le $cursor -and
      $node.Extent.EndOffset -ge $cursor
    }, $true) | Select-Object -Last 1
  if ($commandAst) {
    $commandName = $commandAst.GetCommandName()
    if ($commandName) {
      $command = $ExecutionContext.InvokeCommand.GetCommand($commandName, 'All')
      if ($command -is [AliasInfo]) {
        $commandName = $command.ResolvedCommandName
      }
      if ($commandName -ne $null) { Get-Help $commandName -ShowWindow }
    }
  }
}

# Ctrl+Shift+j then type a key to mark the current directory.
# Ctrj+j then the same key will change back to that directory without
# needing to type Set-Location and won't change the command line.
$global:PSReadLineMarks = @{}
Set-PSReadLineKeyHandler -Key Ctrl+Shift+j `
                         -BriefDescription MarkDirectory `
                         -LongDescription "Mark the current directory" `
                         -ScriptBlock {
  param($key, $arg)

  $key = [Console]::ReadKey($true)
  $global:PSReadLineMarks[$key.KeyChar] = $pwd
}

Set-PSReadLineKeyHandler -Key Ctrl+j `
                         -BriefDescription JumpDirectory `
                         -LongDescription "Goto the marked directory" `
                         -ScriptBlock {
  param($key, $arg)

  $key = [Console]::ReadKey()
  $dir = $global:PSReadLineMarks[$key.KeyChar]
  if ($dir) {
    Set-Location $dir
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
}

Set-PSReadLineKeyHandler -Key Alt+j `
                         -BriefDescription ShowDirectoryMarks `
                         -LongDescription "Show the currently marked directories" `
                         -ScriptBlock {
  param($key, $arg)
  $global:PSReadLineMarks.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{Key = $_.Key; Dir = $_.Value}
  } | Format-Table -AutoSize | Out-Host
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}

<#
Set-PSReadLineKeyHandler -Key Ctrl+Z -Function Redo 
Set-PSReadLineKeyHandler -Key Ctrl+Z `
                         -BriefDescription Redo `
                         -LongDescription "Redo most recent Undo" `
                         -ScriptBlock {
  param($key, $arg)
  $global:PSReadLineMarks.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{Key = $_.Key; Dir = $_.Value}
  } | Format-Table -AutoSize | Out-Host
  [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
#>

Set-PSReadLineOption -CommandValidationHandler {
  param([CommandAst]$CommandAst)
  switch ($CommandAst.GetCommandName()) {
    'git' {
      $gitCmd = $CommandAst.CommandElements[1].Extent
      switch ($gitCmd.Text) {
        'cmt' {
          [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $gitCmd.StartOffset, $gitCmd.EndOffset - $gitCmd.StartOffset, 'commit')
        }
      }
    }
  }
}

Set-PSReadLineKeyHandler -Key Alt+'(',Alt+'{',Alt+'[',Alt+'<' `
                         -BriefDescription WrapEOLWithBraces `
                         -LongDescription "Wrap EOL With matching braces" `
                         -ScriptBlock {
  param($key, $arg)
  # $retreat = 1
  # $closeChar = switch ($key.KeyChar) {
  #   '(' {      [char]')'  ;               break }
  #   '{' { "  $([char]'}')"; $retreat = 2; break }
  #   '[' {      [char]']'  ;               break }
  # }
  Switch ($char) {
    '[' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; break }
    ']' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; break }
    '(' { $Open, $Close  = '('  ,  ')' ; $retreat = 1; break }
    ')' { $Open, $Close  = '('  ,  ')' ; $retreat = 1; break }
    '{' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; break }
    '}' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; break }
    '<' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; break }
    '>' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; break }
  }

  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$Close")
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,[ref]$cursor)
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - $retreat)
}

# WORKING HERE
Set-PSReadLineKeyHandler -Key Alt+'(',Alt+'{',Alt+'[',Alt+'<' `
                         -BriefDescription WrapEOLWithBraces `
                         -LongDescription "Wrap EOL With matching braces" `
                         -ScriptBlock {
  param($key, $arg)
  $char  = $key.KeyChar
  Switch ($char) {
    '[' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; break }
    ']' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; break }
    '(' { $Open, $Close  = '('  ,  ')' ; $retreat = 1; break }
    ')' { $Open, $Close  = '('  ,  ')' ; $retreat = 1; break }
    '{' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; break }
    '}' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; break }
    '<' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; break }
    '>' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; break }
  }
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $LeftLine  = $line.SubString(0, [Math]::Max(0,$Cursor))
  $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, 
      $Open + $line.SubString($selectionStart, $selectionLength) + $Close)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + $retreat)
  } elseif ($line.Length -le $cursor) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "$Open$line$Close")
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  } else {
    $Wrapped = "$LeftLine$Open$RightLine$Close"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $Wrapped)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor)
  }
}

Set-PSReadLineKeyHandler -Key Alt+')',Alt+'}',Alt+']',Alt+'>',Alt+'.',Alt+'#' `
                         -BriefDescription WrapEOLWithBraces `
                         -LongDescription "Wrap EOL With matching braces" `
                         -ScriptBlock {
  param($key, $arg)
  $char  = $key.KeyChar
  Switch ($char) {
    '.' { $Open, $Close  = '('  ,  ').'; $retreat = 3; $IsClose = $True;  break }
    '[' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; $IsClose = $False; break }
    ']' { $Open, $Close  = '['  ,  ']' ; $retreat = 1; $IsClose = $True;  break }
    '(' { $Open, $Close  = '('  ,  ')' ; $retreat = 2; $IsClose = $False; break }
    ')' { $Open, $Close  = '('  ,  ')' ; $retreat = 2; $IsClose = $True;  break }
    '{' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; $IsClose = $False; break }
    '}' { $Open, $Close  = '{ ' , ' }' ; $retreat = 2; $IsClose = $True;  break }
    '<' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; $IsClose = $False; break }
    '>' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; $IsClose = $True;  break }
    '#' { $Open, $Close  = '<# ', ' #>'; $retreat = 3; $IsClose = $True;  break }
  }
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, 
                                                              [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $LeftLine  = $line.SubString(0, [Math]::Max(0, $Cursor))
  $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, 
      $Open + $line.SubString($selectionStart, $selectionLength) + $Close)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart  + 
                                                                $selectionLength + 2)
  } elseif ($line.Length -le $cursor) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "$Open$Line$Close")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor+$Retreat)
  } elseif (!$cursor) {
    $Wrapped = "$Open$Line$Close"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $Wrapped)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Wrapped.Length)  
  } else {
    $Wrapped = If ($IsClose) { "$Open$LeftLine$Close$RightLine" } 
    else                     { "LeftLine$Open$$RightLine$Close" }  
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $Wrapped)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor+$Retreat)
  }
}

#################
<#
# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
Set-PSReadLineKeyHandler -Key 'Alt+(' `
                         -BriefDescription ParenthesizeSelectionRight `
                         -LongDescription "Parenthesize selection, line right, or entire line, and move the cursor to after the closing parenthesis" `
                         -ScriptBlock {
  param($key, $arg)
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $LeftLine  = $line.SubString(0, [Math]::Max(0,$Cursor))
  $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  } elseif ($line.Length -le $cursor) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "($line)")
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
  } else {
    $Wrapped = "$LeftLine($RightLine)"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $Wrapped)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor)
  }
}

Set-PSReadLineKeyHandler -Key 'Alt+)' `
                         -BriefDescription ParenthesizeSelectionLeft `
                         -LongDescription "Parenthesize selection, line left, or entire line, and move the cursor to after the closing parenthesis" `
                         -ScriptBlock {
  param($key, $arg)
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $LeftLine  = $line.SubString(0, [Math]::Max(0, $Cursor))
  $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  } elseif ($line.Length -le $cursor) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, "($line)")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor+2)
  } else {
    $Wrapped = "($LeftLine)$RightLine"
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, $Wrapped)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($Cursor+2)
  }
}
#>

Set-PSReadLineKeyHandler -Key '"',"'" `
                         -BriefDescription InsertQuoteSelected `
                         -LongDescription "Insert paired quotes for selections" `
                         -ScriptBlock {
  param($key, $arg)
  $quote = $key.KeyChar
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  # $LeftLine  = $line.SubString(0, [Math]::Max(0,$Cursor - 1))
  # $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $Quote + $line.SubString($selectionStart, $selectionLength) + $Quote)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
  } else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Quote)
  }
}

Set-PSReadLineKeyHandler -Key '[',']','(',')','{','}','<','>' `
                         -BriefDescription InsertQuoteSelected `
                         -LongDescription "Insert paired quotes for selections" `
                         -ScriptBlock {
  param($key, $arg)
  $char  = $key.KeyChar
  #write-verbose "[$char]"; sleep 2
  Switch ($char) {
    '[' { $Open, $Close  = '['  ,  ']' ; break }
    ']' { $Open, $Close  = '['  ,  ']' ; break }
    '(' { $Open, $Close  = '('  ,  ')' ; break }
    ')' { $Open, $Close  = '('  ,  ')' ; break }
    '{' { $Open, $Close  = '{ ' , ' }' ; break }
    '}' { $Open, $Close  = '{ ' , ' }' ; break }
    '<' { $Open, $Close  = '<# ', ' #>'; break }
    '>' { $Open, $Close  = '<# ', ' #>'; break }
  }
  $Width = $Open.length
  $Extra = $Width * 2
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  # $LeftLine  = $line.SubString(0, [Math]::Max(0,$Cursor - 1))
  # $RightLine = $Line.SubString($Cursor, $Line.Length - $Cursor)
  if ($selectionStart -ne -1) {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $Open + $line.SubString($selectionStart, $selectionLength) + $Close)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + $Extra)
  } else {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($char)
  }
}

Set-PSReadLineKeyHandler -Chord 'Alt+|','Alt+%','Alt+\' `
                         -BriefDescription InsertWhereObject `
                         -LongDescription "Insert Where-Object with scriptblock " `
                         -ScriptBlock {
  param($key, $arg)
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $Selection = if ($selectionStart -ne -1) {
    $line.SubString($selectionStart, $selectionLength)
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '')
  } else { '' }
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("| ForEach-Object { $Selection }")
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 19 )
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $Length = $Line.Length
  $Regex2Pipes = '\|\s*\|'                     # Pipe maybe-Spaces Pipe
  If ($line -match $Regex2Pipes) {             # adjacent Pipes are present 
    $line = $line -replace $Regex2Pipes, '|'   # replace empty pipe
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $Length, $Line)
    
  }
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Min($cursor, $Line.Length - 3 ))
}

If ($PSVersionTable.PSVersion -ge [Version]'7.1.9999')  {
  Write-Warning "Set-PSReadLineOption -PredictionSource History -ea Ignore"
  Set-PSReadLineOption -PredictionSource History -ea Ignore
}

$HandlerParams = @{ 
  Chord = 'Alt+&','Ctrl+Alt+&','Ctrl+&','Alt+&','Ctrl+7','Alt+7'
  BriefDescription = 'AddExecuteWithWrap'
  LongDescription  = "Prefix with & and wrap line to cursor with Parens"
}
Set-PSReadLineKeyHandler @HandlerParams -ScriptBlock {
  Param($Key, $Arg)
  $Line = $Cursor = $Null                      # Initialize variables
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line, [ref]$Cursor)
  If (!$Cursor) { $Cursor = $Line.Length }     # Wrap entire line
  $Line = "& ($($Line.SubString(0,$Cursor)))"  # Wrap to cursor
  [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $Cursor, $Line)
}
Remove-PSReadLineKeyHandler -Chord 7,'&'  # Avoid bug???

Write-Warning "$(FLINE) Before Ctrl+Alt+|"

#	[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
#	[Microsoft.PowerShell.PSConsoleReadLine]::Insert($Line)
Set-PSReadLineOption -HistorySearchCursorMovesToEnd 
# ::HM::Todo:: Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+|','Ctrl+Alt+?','Ctrl+\','Ctrl+Alt+\' `
Remove-PSReadLineKeyHandler -chord '?','|','\','/'

Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+|','Ctrl+\','Ctrl+Alt+\','Ctrl+?' `
                         -BriefDescription InsertForEachObject `
                         -LongDescription "Insert ForEach-Object with scriptblock " `
                         -ScriptBlock {
  param($key, $arg)
  # Write-Information "key: [$Key] arg: [$arg]"
  $selectionStart = $selectionLength = $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $Selection = if ($selectionStart -ne -1) {
    $line.SubString($selectionStart, $selectionLength)
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '')
  } else { '' }
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert("| Where-Object { $Selection } ")
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 17 )
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $Length = $Line.Length
  $Regex2Pipes = '\|\s*\|'                     # Pipe maybe-Spaces Pipe
  If ($line -match $Regex2Pipes) {             # adjacent Pipes are present 
    $line = $line -replace $Regex2Pipes, '|'   # replace empty pipe
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $Length, $Line)
    
  }
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Min($cursor, $Line.Length - 3 ))
}
Remove-PSReadLineKeyHandler -chord '?','|','\','/'

###   WORKING HERE
Set-PSReadLineKeyHandler -Chord 'Ctrl+|,s','Ctrl+|,f','Ctrl+|,o','Ctrl+|,w', 
                                'Ctrl+|,a','Ctrl+|,l','Ctrl+|,t','Ctrl+|,g', 
                                'Ctrl+|,c','Ctrl+|,d','Ctrl+|,v','Ctrl+|,p',
                                'Ctrl+|,n','Ctrl+|,z'                       `                               `
                         -BriefDescription InsertPipes                       `
                         -LongDescription 'Insert Pipe | Select Sort Format' `
                         -ScriptBlock {
  param($key, $arg)
  $Insertion = Switch ($key.KeyChar) {
    's' { '| Select-Object '              }
    'f' { '| Select-Object -First 1 '     }
    'z' { '| Select-Object -Last 1 '      }
    'o' { '| Sort-Object '                }
    'n' { '| Sort-Object name '           }
    'e' { '| Sort-Object extension '      }
    'w' { '| Sort-Object LastWriteTime '  }
    'a' { '| Sort-Object LastAccessTime ' }
    'l' { '| Sort-Object Length '         }
    't' { '| Format-Table '               }
    'd' { 'Get-ChildItem  | Sort-Object -LastWriteTime ' }
    'g' { '| Select-String '''''          }  # g for Grep
    'c' { '| Sort-Object CreationTime '   }  
    default { '{NO MATCH}' }
  }
  ####    ##########   If es es($Insertion -match '\bLength\b' -and 
  ####    ##########       ((Get-Variable Length -value -ea Ignore) -and
  ####    ##########       ## #:HM: 
  ####    ##########   )
  #[Microsoft.PowerShell.PSConsoleReadLine]::Insert("Key: [$($key.Keychar)] arg: [$arg] Ins: [$Insertion]")
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Insertion)
  If ($False) {
    $selectionStart = $selectionLength = $line = $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $Selection = if ($selectionStart -ne -1) {
      $line.SubString($selectionStart, $selectionLength)
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '')
    } else { '' }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("| Where-Object { $Selection } ")
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 17 )
  }
  $line = $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  $Length = $Line.Length
  $Regex2Pipes = '\|\s*\|'                     # Pipe maybe-Spaces Pipe
  If ($line -match $Regex2Pipes) {             # adjacent Pipes are present 
    $line = $line -replace $Regex2Pipes, '|'   # replace empty pipe
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $Length, $Line)
  }
  [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Min($cursor, $Line.Length))
}

# if ($ForcePSReadline -or $host.Name -match 'ConsoleHost|((ISE|Code) Host)') {
if (Get-Module PSReadline -ea Ignore) {
    #Import-Module PSReadline
    Set-PSReadlineKeyHandler -Key Ctrl+Delete     -Function KillWord
    Set-PSReadlineKeyHandler -Key Ctrl+Backspace  -Function BackwardKillWord
    Set-PSReadlineKeyHandler -Key Shift+Backspace -Function BackwardDeleteChar  ### Kill word EVIL ####
    Set-PSReadlineKeyHandler -Key UpArrow         -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow       -Function HistorySearchForward
    set-psreadlineoption -WordDelimiters ' !"%&''()*+,-/<=>?@[\]^`~'
    If ($Host.PrivateData -and $Host.PrivateData.ErrorBackgroundColor) {
      $Host.PrivateData.ErrorBackgroundColor   = $Host.UI.RawUI.BackgroundColor
      $Host.PrivateData.WarningBackgroundColor = $Host.UI.RawUI.BackgroundColor
      $Host.PrivateData.VerboseBackgroundColor = $Host.UI.RawUI.BackgroundColor

      $Host.PrivateData.ErrorBackgroundColor   = 'Black'
      $Host.PrivateData.WarningBackgroundColor = 'Black'
      $Host.PrivateData.VerboseBackgroundColor = 'Black'

      $Host.PrivateData.ErrorBackgroundColor   = 'DarkRed'
      $Host.PrivateData.ErrorForegroundColor   = 'White'
      $Host.PrivateData.VerboseBackgroundColor = 'Black'
      $Host.PrivateData.VerboseForegroundColor = 'Yellow'
      $Host.PrivateData.WarningBackgroundColor = 'Black'
      $Host.PrivateData.WarningForegroundColor = 'White'
    }
}

  <#

    WordDelimiters                         : ;:,.[]{}()/\|^&*-=+'"–—―
    CommandColor                           : ←[93m"$([char]0x1b)[93m"←[0m
    CommentColor                           : ←[92m"$([char]0x1b)[92m"←[0m
    ContinuationPromptColor                : ←[95m"$([char]0x1b)[95m"←[0m
    DefaultTokenColor                      : ←[93m"$([char]0x1b)[93m"←[0m
    EmphasisColor                          : ←[95m"$([char]0x1b)[95m"←[0m
    ErrorColor                             : ←[95m"$([char]0x1b)[95m"←[0m
    KeywordColor                           : ←[93m"$([char]0x1b)[93m"←[0m
    MemberColor                            : ←[97m"$([char]0x1b)[97m"←[0m
    NumberColor                            : ←[97m"$([char]0x1b)[97m"←[0m
    OperatorColor                          : ←[96m"$([char]0x1b)[96m"←[0m
    ParameterColor                         : ←[92m"$([char]0x1b)[92m"←[0m
    SelectionColor                         : ←[95m"$([char]0x1b)[95m"←[0m
    StringColor                            : ←[97m"$([char]0x1b)[97m"←[0m
    TypeColor                              : ←[97m"$([char]0x1b)[97m"←[0m
    VariableColor                          : ←[92m"$([char]0x1b)[92m"←[0m
  #>
  
if ($PSRL = Get-Module PSReadline -ea Ignore) {
  Set-PSReadlineKeyHandler 'Tab'                      -Function TabCompleteNext
  Set-PSReadlineKeyHandler 'Shift+Tab'                -Function TabCompletePrevious
  Set-PSReadLineKeyHandler -Key UpArrow               -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow             -Function HistorySearchForward
  Set-PSReadLineKeyHandler -Key 'F7','F9'             -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key 'Shift+F7','Shift+F9' -Function HistorySearchForward
  Try {
    Set-PSReadLineKeyHandler -Key 'Ctrl+b'              -Function GotoBrace 
    Set-PSReadLineKeyHandler -Key 'Ctrl+Alt-B'          -Function ViDeleteBrace
    Set-PSReadLineKeyHandler -Key 'Ctrl+B'              -Function ViYankPercent
    Set-PSReadLineKeyHandler -Key 'Ctrl+5'              -Function ViYankPercent
    Set-PSReadLineKeyHandler -Key 'Ctrl+%'              -Function ViYankPercent
  } Catch {
    Write-Verbose "$(FLINE) 'Set-PSReadLine -Key ? -Function ?'`n$_ | Format-List * -force | Out-String"
  }

  if ($SaveHistory -and !@(Get-History).count) { Add-History $SaveHistory };
  try {
    if ($SaveHistory) {
      $SaveHistory | ForEach-Object { [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($_) }
      $SaveHistory = $null
    }
  } catch { } # just ignore this for VSCode
  set-psreadlinekeyhandler -key Spacebar -Function SelfInsert
  If ($PSRL.version -ge [version]'2.0.0') { 
    Remove-PSReadLineKeyHandler SpaceBar -ea Ignore 
  }
}

Write-Warning "$(FLINE) New Errors: $($Error.Count - $Private:ErrorCount)"

<#
    $c = [ConsoleColor]::Cyan
    $l = [ConsoleColor]::DarkCyan
    $b = [ConsoleColor]::Gray
    $h = [ConsoleColor]::DarkGray

#>
} Catch {
  $_ | Format-List -Force * | Out-String
}