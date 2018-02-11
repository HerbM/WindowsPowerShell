Set-PSReadLineOption -ForeGround Yellow  -Token None      
Set-PSReadLineOption -ForeGround Green   -Token Comment   
Set-PSReadLineOption -ForeGround Green   -Token Keyword   
Set-PSReadLineOption -ForeGround Cyan    -Token String    
Set-PSReadLineOption -ForeGround Gray    -Token Operator  
Set-PSReadLineOption -ForeGround Green   -Token Variable  
Set-PSReadLineOption -ForeGround Yellow  -Token Command   
Set-PSReadLineOption -ForeGround Gray    -Token Parameter 
Set-PSReadLineOption -ForeGround Gray    -Token Type      
Set-PSReadLineOption -ForeGround White   -Token Number    
Set-PSReadLineOption -ForeGround White   -Token Member    

$Host.PrivateData.ErrorBackgroundColor   = 'DarkRed'
$Host.PrivateData.ErrorForegroundColor   = 'White'
$Host.PrivateData.VerboseBackgroundColor = 'Black'
$Host.PrivateData.VerboseForegroundColor = 'Yellow'
$Host.PrivateData.WarningBackgroundColor = 'Black'
$Host.PrivateData.WarningForegroundColor = 'White'

# set-psreadlineoption -EmphasisForegroundColor Blue -EmphasisBackgroundColor Black

<#
DefaultTokenForegroundColor            : Yellow
CommentForegroundColor                 : Green
KeywordForegroundColor                 : White
StringForegroundColor                  : White
OperatorForegroundColor                : Yellow
VariableForegroundColor                : Green
CommandForegroundColor                 : Yellow
ParameterForegroundColor               : Green
TypeForegroundColor                    : Green
NumberForegroundColor                  : White
MemberForegroundColor                  : White
DefaultTokenBackgroundColor            : DarkCyan
CommentBackgroundColor                 : DarkBlue
KeywordBackgroundColor                 : DarkCyan
StringBackgroundColor                  : DarkCyan
OperatorBackgroundColor                : DarkCyan
VariableBackgroundColor                : DarkCyan
CommandBackgroundColor                 : DarkCyan
ParameterBackgroundColor               : DarkCyan
TypeBackgroundColor                    : DarkCyan
NumberBackgroundColor                  : DarkCyan
MemberBackgroundColor                  : DarkCyan
EmphasisForegroundColor                : Cyan
EmphasisBackgroundColor                : DarkCyan
ErrorForegroundColor                   : Red
ErrorBackgroundColor                   : DarkCyan 
#>