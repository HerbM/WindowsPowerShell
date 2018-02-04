# [System.Enum]::getvalues([System.ConsoleColor]) | % {Write-Host "Happy New Year!!" -ForegroundColor $_}
# http://mikefrobbins.com/2017/02/02/video-powershell-101-the-no-nonsense-beginners-guide-to-powershell/

############################ PSReadLine Begin ########################
#write-information "$(LINE) Import-Module PSReadLine https://github.com/lzybkr/PSReadLine"

if (!(Get-Module PSReadline -ea 0 -list)) {
  write-information "$(LINE) PSReadline module not found."
  return
}

write-information "$(LINE) Import-Module PSReadLine -force -scope AllUsers"
write-information "$(LINE) Customize:  PSReadLine examples:" 
write-information "$(LINE) https://github.com/lzybkr/PSReadLine/blob/master/PSReadLine/SamplePSReadlineProfile.ps1"

write-warning "PSReadline Profile"
try {

  # Import-Module PSReadLine
  write-information "$(LINE) Get-PSReadlineKeyHandler to see key bindings"
  write-information ("$(LINE) " + 'Get-PSReadlineKeyHandler | % {"{0,-24} {1,-25} {2}" -f $_.key, $_.function, $_.description} > .\PSReadLineKeys.txt')
  #write-information "$(LINE) Set-PSReadlineKeyHandler -Function HistorySearchBackward -Key UpArrow  "
  #write-information "$(LINE) Set-PSReadlineKeyHandler -Function HistorySearchForward  -Key DownArrow"
  set-PSReadlineOption -dingduration 2
  set-PSReadlineOption -dingtone 75
  # Need to explicitly import PSReadLine in a number of cases: Windows versions < 10 and
  # x86 consoles that aren't loading PSReadLine.
  # Source: https://gist.github.com/rkeithhill/3103994447fd307b68be#file-psreadline_config-ps1
  # Other hosts (ISE, ConEmu) don't always work as well with PSReadline.
  ############# 
  ####if (!(Get-Module PSReadline -ErrorAction SilentlyContinue)) {
  ####  if (([IntPtr]::Size -eq 4) -and !(Get-Module -ListAvailable PSReadline)) {
  ####    $origPSModulePath = $env:PSModulePath
  ####    $env:PSModulePath += ';C:\Program Files\WindowsPowerShell\Modules'
  ####    Import-Module PSReadline
  ####    $env:PSModulePath = $origPSModulePath
  ####  } else {
  ####    Import-Module PSReadline
  ####  }
  ####}
  
  $HistorySet = (get-psreadlineoption).HistorySavePath -eq "$($PSScriptRoot)\PSReadLine_history.txt"
  if (!$HistorySet -and                            # -and ($host.Name -eq 'ConsoleHost' -or 
      ($PSR = gcm Get-PSReadlineKeyHandler -module PSReadline -type Cmdlet -ea 0)) {  # PSReadline hasn't been auto-imported, try to manually import it
    Set-PSReadlineOption -HistorySavePath $PSScriptRoot\PSReadLine_history.txt
  }    
  Set-PSReadlineOption -MaximumHistoryCount 10000 -HistorySearchCursorMovesToEnd -HistoryNoDuplicates 
  Set-PSReadlineOption -AddToHistoryHandler {
    param([string]$line)
    return $line.Length -gt 3
  }
  # [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState 
  # [Microsoft.PowerShell.PSConsoleReadLine]::Insert
  # [Microsoft.PowerShell.PSConsoleReadLine]::Replace
  # [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition  
  ### Set-PSReadlineKeyHandler -Chord UpArrow     -Function HistorySearchBackward
  ### Set-PSReadlineKeyHandler -Chord DownArrow   -Function HistorySearchForward
  Set-PSReadlineKeyHandler -Chord 'Ctrl+Alt+S'    -Function CaptureScreen
  Set-PSReadlineKeyHandler -Chord 'Ctrl+c'        -Function Copy
  
  # Insert paired quotes if not already on a quote
  Set-PSReadlineKeyHandler -Chord "Ctrl+'","Ctrl+Shift+'" `
                           -BriefDescription SmartInsertQuote `
                           -Description "Insert paired quotes if not already on a quote" `
                           -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $keyChar = $key.KeyChar
    if ($key.Key -eq 'Oem7') {
      if ($key.Modifiers -eq 'Control') {
        $keyChar = "`'"
      } elseif ($key.Modifiers -eq 'Shift','Control') {
        $keyChar = '"'
      }
    }  
    if ($line[$cursor] -eq $key.KeyChar) {
      # Just move the cursor
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    } else { # Insert matching quotes, move cursor to be in between the quotes
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$keyChar" * 2)
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    }
  }
  # Copy the current path to the clipboard
  Set-PSReadlineKeyHandler -Key Alt+c `
                           -BriefDescription CopyCurrentPathToClipboard `
                           -LongDescription "Copy the current path to the clipboard" `
                           -ScriptBlock {
    param($key, $arg)
    Add-Type -Assembly System.Windows.Forms
    [System.Windows.Forms.Clipboard]::SetText($pwd.Path, 'Text')
  }

  Set-PSReadLineKeyHandler -Key F7 `
                           -BriefDescription History `
                           -LongDescription 'Show command history' `
                           -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
      $pattern = [regex]::Escape($pattern)
    }
    $history = [System.Collections.ArrayList]@(
      $last = ''
      $lines = ''
      foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
        if ($line.EndsWith('`')) {
          $line = $line.Substring(0, $line.Length - 1)
          $lines = if ($lines) {
            "$lines`n$line"
          } else  {
            $line
          }
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
  Set-PSReadLineKeyHandler -Key Ctrl+B `
                           -LongDescription "Build the current directory" `
                           -BriefDescription BuildCurrentDirectory `
                           -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("msbuild")
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
  }

  
  # Paste the clipboard text as a here string
  Set-PSReadlineKeyHandler -Key Ctrl+Shift+v `
                           -BriefDescription PasteAsHereString `
                           -LongDescription "Paste the clipboard text as a here string" `
                           -ScriptBlock {
    param($key, $arg)
    Add-Type -Assembly System.Windows.Forms
    if ([System.Windows.Forms.Clipboard]::ContainsText()) {
      # Get clipboard text - remove trailing spaces, convert \r\n to \n, and remove the final \n.
      $text = ([System.Windows.Forms.Clipboard]::GetText() -replace "\p{Zs}*`r?`n","`n").TrimEnd()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("@'`n$text`n'@")
    } else {
      [Microsoft.PowerShell.PSConsoleReadLine]::Ding()
    }
  }
  # Insert matching braces
  Set-PSReadlineKeyHandler -Key '(','{','[' `
                           -BriefDescription InsertPairedBraces `
                           -LongDescription "Insert matching braces" `
                           -ScriptBlock {
    param($key, $arg)
    $closeChar = switch ($key.KeyChar) {
      <#case#> '(' { [char]')'; break }
      <#case#> '{' { [char]'}'; break }
      <#case#> '[' { [char]']'; break }
    }
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($cursor -eq $line.Length -or $line[$cursor] -match '\)|}|\]|\s') {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($key.KeyChar)
    }      
  }
  # Insert closing brace or skip
  Set-PSReadlineKeyHandler -Key ')',']','}' `
                           -BriefDescription SmartCloseBraces `
                           -LongDescription "Insert closing brace or skip" `
                           -ScriptBlock {
    param($key, $arg)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($line[$cursor] -eq $key.KeyChar) {
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    } else {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
  }
  # Put parentheses around the selection or entire line and move the cursor to after the closing paren
  Set-PSReadlineKeyHandler -Key 'Ctrl+(' `
                           -BriefDescription ParenthesizeSelection `
                           -LongDescription "Put parentheses around the selection or entire line and move the cursor to after the closing parenthesis" `
                           -ScriptBlock {
    param($key, $arg)
    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1) {
      $replacement = '(' + $line.SubString($selectionStart, $selectionLength) + ')'
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, $replacement)
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    } else {
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
      [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
  }
  # Replace all aliases with the full command
  Set-PSReadlineKeyHandler -Key Alt+r `
                           -BriefDescription ResolveAliases `
                           -LongDescription "Replace all aliases with the full command" `
                           -ScriptBlock {
    param($key, $arg)
    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)
    $startAdjustment = 0
    foreach ($token in $tokens)	{
      if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName) {
        $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
        if ($alias -ne $null)	{
          $resolvedCommand = $alias.ResolvedCommandName 
          if ($resolvedCommand -ne $null) {
            $extent = $token.Extent
            $length = $extent.EndOffset - $extent.StartOffset
            [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                $extent.StartOffset + $startAdjustment,
                $length,
                $resolvedCommand)
            # Our copy of the tokens won't have been updated, so we need to
            # adjust by the difference in length
            $startAdjustment += ($resolvedCommand.Length - $length)
          }
        }
      }
    }
  }
  # Save current line in history but do not execute
  Set-PSReadlineKeyHandler -Key Alt+w `
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
  # This key handler shows the entire or filtered history using Out-GridView. The
  # typed text is used as the substring pattern for filtering. A selected command
  # is inserted to the command line without invoking. Multiple command selection
  # is supported, e.g. selected by Ctrl + Click.
  Set-PSReadlineKeyHandler -Key F7 `
                           -BriefDescription History `
                           -LongDescription 'Show command history' `
                           -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern) {
      $pattern = [regex]::Escape($pattern)
    }
    $history = [System.Collections.ArrayList]@(
      $last = ''
      $lines = ''
      foreach ($line in [System.IO.File]::ReadLines((Get-PSReadlineOption).HistorySavePath)) {
        if ($line.EndsWith('`')) {
          $line = $line.Substring(0, $line.Length - 1)
          $lines = if ($lines) {
            "$lines`n$line"
          } else {
            $line
          }
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
 
  Set-PSReadLineKeyHandler -Key 'Alt+(' `
               -BriefDescription ParenthesizeSelection `
               -LongDescription "Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis" `
               -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$selectionStart, [ref]$selectionLength)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    if ($selectionStart -ne -1) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace($selectionStart, $selectionLength, '(' + $line.SubString($selectionStart, $selectionLength) + ')')
      [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($selectionStart + $selectionLength + 2)
    } else  {
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, '(' + $line + ')')
      [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
  }
 
  Set-PSReadlineOption -token Operator  -fore cyan
  Set-PSReadlineOption -token Comment   -fore green
  Set-PSReadlineOption -token Parameter -fore green
  Set-PSReadlineOption -token Comment   -fore Yellow -back DarkBlue

	Set-PSReadlineOption -ForegroundColor Yellow -TokenKind None
	Set-PSReadlineOption -ForegroundColor White  -TokenKind String
	Set-PSReadlineOption -ForegroundColor White  -TokenKind Keyword
	Set-PSReadlineOption -ForegroundColor Green  -TokenKind Comment
	Set-PSReadlineOption -ForegroundColor Green  -TokenKind Parameter
	Set-PSReadlineOption -ForegroundColor Yellow -TokenKind Operator
	Set-PSReadlineOption -ForegroundColor Green  -TokenKind Type

  # Doesn't work	
  #  $Colors = [ConsoleColor]::('Black'),[ConsoleColor]::('Cyan'),[ConsoleColor]::('DarkCyan'),[ConsoleColor]::('DarkGreen'),[ConsoleColor]::('DarkRed'),[ConsoleColor]::('Gray'),[ConsoleColor]::('Magenta'),[ConsoleColor]::('White'),[ConsoleColor]::('Blue'),[ConsoleColor]::('DarkBlue'),[ConsoleColor]::('DarkGray'),[ConsoleColor]::('DarkMagenta'),[ConsoleColor]::('DarkYellow'),[ConsoleColor]::('Green'),[ConsoleColor]::('Red'),[ConsoleColor]::('Yellow')
  #	$Colors | % {$Fore = $_; $Colors | % { write-host "$fore on $_ abcdefg" -fore $fore -back $back}}
	
  Set-PSReadLineKeyHandler -Key 'Alt+S,w','Alt+S,Alt+w' `
                           -LongDescription "Sort LastWriteTime" `
                           -BriefDescription SortLastWriteTime `
                           -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" | sort lastwritetime")
  }
  Set-PSReadLineKeyHandler -Key 'Alt+S,s','Alt+S,Alt+s' `
                           -LongDescription "Sort Length" `
                           -BriefDescription SortLength `
                           -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" | sort length")
  }
  write-information "$(LINE) PSReadLine configuration completed"
} catch {
  write-error       "$(LINE) Error during import or configuration of PSReadLine"
  write-information "$(LINE) Error during import or configuration of PSReadLine"
}  



############################ END PSReadline #################################
  <#
      ExtraPromptLineCount                   : 0
      AddToHistoryHandler                    :
      CommandValidationHandler               :
      CommandsToValidateScriptBlockArguments : {ForEach-Object, %, Invoke-Command, icm...}
      HistoryNoDuplicates                    : False
      MaximumHistoryCount                    : 4096
      MaximumKillRingCount                   : 10
      HistorySearchCursorMovesToEnd          : False
      ShowToolTips                           : False
      DingTone                               : 1221
      CompletionQueryItems                   : 100
      WordDelimiters                         : ;:,.[]{}()/\|^&*-=+--?
      DingDuration                           : 50
      BellStyle                              : Audible
      HistorySearchCaseSensitive             : False
      HistorySavePath                        :
      C:\Users\TestUser\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_histor
      HistorySaveStyle                       : SaveIncrementally
      ContinuationPromptForegroundColor      : DarkYellow
      ContinuationPromptBackgroundColor      : DarkMagenta
      DefaultTokenForegroundColor            : DarkYellow
      CommentForegroundColor                 : DarkGreen
      KeywordForegroundColor                 : Green
      StringForegroundColor                  : DarkCyan
      OperatorForegroundColor                : DarkGray
      VariableForegroundColor                : Green
      CommandForegroundColor                 : Yellow
      ParameterForegroundColor               : DarkGray
      TypeForegroundColor                    : Gray
      NumberForegroundColor                  : White
      MemberForegroundColor                  : White
      DefaultTokenBackgroundColor            : DarkMagenta
      CommentBackgroundColor                 : DarkMagenta
      KeywordBackgroundColor                 : DarkMagenta
      StringBackgroundColor                  : DarkMagenta
      OperatorBackgroundColor                : DarkMagenta
      VariableBackgroundColor                : DarkMagenta
      CommandBackgroundColor                 : DarkMagenta
      ParameterBackgroundColor               : DarkMagenta
      TypeBackgroundColor                    : DarkMagenta
      NumberBackgroundColor                  : DarkMagenta
      MemberBackgroundColor                  : DarkMagenta
      EmphasisForegroundColor                : Cyan
      EmphasisBackgroundColor                : DarkMagenta
      ErrorForegroundColor                   : Red
      ErrorBackgroundColor                   : DarkMagenta
  #>  
