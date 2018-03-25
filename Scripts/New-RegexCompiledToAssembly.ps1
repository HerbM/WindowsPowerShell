<#
.EXAMPLE
  ./New-RegExCompiledToAssembly '\s+' 'Spaces' 'CodeAssassin.RegEx' -ignoreCase
.NOTES
  Jason Stangroome https://blog.stangroome.com/2007/09/12/powershell-regular-expression-compiler/
#>
[CmdletBinding()]param (
  [Parameter(Mandatory=$True)][string]$pattern,
  [string]$typeName      = $('PSCompiledRegex' + (get-date -f 'mmddhhss')),
  [string]$fullNamespace = "PS$($Env:UserName).Regex",
  [System.Reflection.AssemblyName]$assemblyName,
  [switch]$CaseSensitive,
  [switch]$multiLine
)

if (!$assemblyName) {
  $assemblyName         = New-Object System.Reflection.AssemblyName($fullNamespace + 
                          '.' + $typeName);
  $assemblyName.Version = New-Object System.Version (1, 0);
}

$sysRx = [ordered]@{
  Namespace    = 'System.Text.RegularExpressions'
  RegEx        = [System.Text.RegularExpressions.RegEx]
  RegExOptions = [System.Text.RegularExpressions.RegExOptions]::None
}
$IgnoreCase = !$CaseSensitive
if ($ignoreCase) { $options = $options -bor $sysRx.RegExOptions::IgnoreCase }
if ($multiLine)  { $options = $options -bor $sysRx.RegExOptions::Multiline  }

$info = New-Object ($sysRx.Namespace+'.RegexCompilationInfo') (
  $pattern, $options, $typeName, $fullNamespace, $true
)

Push-Location
write-warning $PWD
$sysRx.RegEx::CompileToAssembly($info, $assemblyName)
write-warning $PWD
Pop-Location


<#
$sysRx = @{};
$sysRx.Namespace    = 'System.Text.RegularExpressions';
$sysRx.RegEx        = [System.Text.RegularExpressions.RegEx];
$sysRx.RegExOptions = [System.Text.RegularExpressions.RegExOptions];

$options = $sysRx.RegExOptions::None

$info = New-Object ($sysRx.Namespace+'.RegexCompilationInfo') (
          $pattern, $options, $typeName, $fullNamespace, $true);

$sysRx.RegEx::CompileToAssembly($info, $assemblyName);
#>