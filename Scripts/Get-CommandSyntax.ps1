#requires -version 5.0
<#
This is a copy of:

CommandType Name        Version Source                   
----------- ----        ------- ------                   
Cmdlet      Get-Command 3.0.0.0 Microsoft.PowerShell.Core

Created: 10 March 2018
Author : Herb

#>
[CmdletBinding()]param(
  [Parameter(ValueFromRemainingArguments=$true)]$args,
  [switch]$LoadOnly
)

Function Get-CommandSyntax {
<#

.SYNOPSIS

Gets all commands.


.DESCRIPTION

The  cmdlet gets all commands that are installed on the computer, including cmdlets, aliases, functions, workflows, filters, scripts, and applications.  gets the commands from Windows PowerShell modules and snap-ins and commands that were imported from other sessions. To get only commands that have been imported into the current session, use the ListImported parameter.

Without parameters, a  command gets all of the cmdlets, functions, workflows and aliases installed on the computer. A ` *` command gets all types of commands, including all of the non-Windows PowerShell files in the Path environment variable ($env:path), which it lists in the Application command type.

A  command that uses the exact name of the command, without wildcard characters, automatically imports the module that contains the command so that you can use the command immediately. To enable, disable, and configure automatic importing of modules, use the $PSModuleAutoLoadingPreference preference variable. For more information, see about_Preference_Variables (http://go.microsoft.com/fwlink/?LinkID=113248) in the Microsoft TechNet library.  gets its data directly from the command code, unlike Get-Help, which gets its information from help topics.

In Windows PowerShell 2.0,  gets only commands in current session. It does not get commands from modules that are installed, but not imported. To limit  in Windows PowerShell 3.0 and later versions to commands in the current session, use the ListImported parameter.

Starting in Windows PowerShell 5.0, results of the  cmdlet display a Version column by default. A new Version property has been added to the CommandInfo class.


.PARAMETER All

Indicates that this cmdlet gets all commands, including commands of the same type that have the same name. By default,  gets only the commands that run when you type the command name.

For more information about the method that Windows PowerShell uses to select the command to run when multiple commands have the same name, see about_Command_Precedence (http://go.microsoft.com/fwlink/?LinkID=113214) in the TechNet library. For information about module-qualified command names and running commands that do not run by default because of a name conflict, see about_Modules (http://go.microsoft.com/fwlink/?LinkID=144311).

This parameter was introduced in Windows PowerShell 3.0.

In Windows PowerShell 2.0,  gets all commands by default.

.PARAMETER ArgumentList

Specifies an array of arguments. This cmdlet gets information about a cmdlet or function when it is used with the specified parameters ("arguments"). The alias for ArgumentList is Args .

To detect dynamic parameters that are available only when certain other parameters are used, set the value of ArgumentList to the parameters that trigger the dynamic parameters.

To detect the dynamic parameters that a provider adds to a cmdlet, set the value of the ArgumentList parameter to a path in the provider drive, such as WSMan:, HKLM:, or Cert:. When the command is a Windows PowerShell provider cmdlet, enter only one path in each command. The provider cmdlets return only the dynamic parameters for the first path the value of ArgumentList . For information about the provider cmdlets, see about_Providers (http://go.microsoft.com/fwlink/?LinkID=113250) in the TechNet library.

.PARAMETER CommandType

Specifies the  types of commands that this cmdlet gets. Enter one or more command types. Use CommandType or its alias, Type . By default,  gets all cmdlets, functions, and workflows, and aliases.

The acceptable values for this parameter are:

- Alias. Gets the aliases of all Windows PowerShell commands. For more information, see about_Aliases.

- All. Gets all command types. This parameter value is the equivalent of ` *`.

- Application. Gets non-Windows-PowerShell files in paths listed in the Path environment variable ($env:path), including .txt, .exe, and .dll files. For more information about the Path environment variable, see about_Environment_Variables. - Cmdlet. Gets all cmdlets.

- ExternalScript. Gets all .ps1 files in the paths listed in the Path environment variable ($env:path). - Filter and Function. Gets all Windows PowerShell advanced and simple functions and filters.

- Script. Gets all script blocks. To get Windows PowerShell scripts (.ps1 files), use the ExternalScript value.

- Workflow. Gets all workflows. For more information about workflows, see Introducing Windows PowerShell Workflow.

.PARAMETER FullyQualifiedModule

Specifies modules with names that are specified in the form of ModuleSpecification objects, described by the Remarks section of Module Specification Constructor (Hashtable)http://msdn.microsoft.com/library/windows/desktop/jj136290(v=vs.85).aspx on the Microsoft Developer Network (MSDN). For example, the FullyQualifiedModule parameter accepts a module name that is specified in the format @{ModuleName = "modulename"; ModuleVersion = "version_number"} or @{ModuleName = "modulename"; ModuleVersion = "version_number"; Guid = "GUID"}. ModuleName and ModuleVersion are required, but Guid is optional.

You cannot specify the FullyQualifiedModule parameter in the same command as a Module parameter. The two parameters are mutually exclusive.

.PARAMETER ListImported

Indicates that this cmdlet gets only commands in the current session.

Starting in Windows PowerShell 3.0, by default,  gets all installed commands, including, but not limited to, the commands in the current session. In Windows PowerShell 2.0, it gets only commands in the current session.

This parameter was introduced in Windows PowerShell 3.0.

.PARAMETER Module

Specifies an array of modules. This cmdlet gets the commands that came from the specified modules or snap-ins. Enter the names of modules or snap-ins, or enter snap-in or module objects.

This parameter takes string values, but the value of this parameter can also be a PSModuleInfo or PSSnapinInfo object, such as the objects that the Get-Module, Get-PSSnapin, and Import-PSSession cmdlets return.

You can refer to this parameter by its name, Module , or by its alias, PSSnapin . The parameter name that you choose has no effect on the command output.

.PARAMETER Name

Specifies an array of names. This cmdlet gets only commands that have the specified name. Enter a name or name pattern. Wildcard characters are permitted.

To get commands that have the same name, use the All parameter. When two commands have the same name, by default,  gets the command that runs when you type the command name.

.PARAMETER Noun

Specifies an array of command nouns. This cmdlet gets commands, which include cmdlets, functions, workflows, and aliases, that have names that include the specified noun. Enter one or more nouns or noun patterns. Wildcard characters are permitted.

.PARAMETER ParameterName

Specifies an array of parameter names. This cmdlet gets commands in the session that have the specified parameters. Enter parameter names or parameter aliases. Wildcard characters are supported.

The ParameterName and ParameterType parameters search only commands in the current session.

This parameter was introduced in Windows PowerShell 3.0.

.PARAMETER ParameterType

Specifies an array of parameter names. This cmdlet gets commands in the session that have parameters of the specified type. Enter the full name or partial name of a parameter type. Wildcard characters are supported.

The ParameterName and ParameterType parameters search only commands in the current session.

This parameter was introduced in Windows PowerShell 3.0.

.PARAMETER ShowCommandInfo

Indicates that this cmdlet displays command information.

For more information about the method that Windows PowerShell uses to select the command to run when multiple commands have the same name, see about_Command_Precedence. For information about module-qualified command names and running commands that do not run by default because of a name conflict, see about_Modules.

This parameter was introduced in Windows PowerShell 3.0.

In Windows PowerShell 2.0,  gets all commands by default.

.PARAMETER Syntax

Indicates that this cmdlet gets only the following specified data about the command:

- Aliases. Gets the standard name.

- Cmdlets. Gets the syntax.

- Functions and filters. Gets the function definition.

- Scripts and applications or files. Gets the path and filename.

.PARAMETER TotalCount

Specifies the number of commands to get. You can use this parameter to limit the output of a command.

.PARAMETER Verb

Specifies an array of command verbs. This cmdlet gets commands, which include cmdlets, functions, workflows, and aliases, that have names that include the specified verb. Enter one or more verbs or verb patterns. Wildcard characters are permitted.


.EXAMPLE

PS C:\>
This command gets the Windows PowerShell cmdlets, functions, and aliases that are installed on the computer.

.EXAMPLE

PS C:\> -ListImported
This command uses the ListImported parameter to get only the commands in the current session.

.EXAMPLE

PS C:\> -Type Cmdlet | Sort-Object -Property Noun | Format-Table -GroupBy Noun
This command gets all of the cmdlets, sorts them alphabetically by the noun in the cmdlet name, and then displays them in noun-based groups. This display can help you find the cmdlets for a task.

.EXAMPLE

PS C:\> -Module Microsoft.PowerShell.Security, PSScheduledJob
This command uses the Module parameter to get the commands in the Microsoft.PowerShell.Security and PSScheduledJob modules.

.EXAMPLE

PS C:\> Get-AppLockerPolicy
This command gets information about the Get-AppLockerPolicy cmdlet. It also imports the AppLocker module, which adds all of the commands in the AppLocker module to the current session.
When a module is imported automatically, the effect is the same as using the Import-Module cmdlet. The module can add commands, types and formatting files, and run scripts in the session. To enable, disable, and configuration automatic importing of modules, use the $PSModuleAutoLoadingPreference preference variable. For more information, see about_Preference_Variables.

.EXAMPLE

PS C:\> Get-Childitem -Args Cert: -Syntax
This command uses the ArgumentList and Syntax parameters to get the syntax of the Get-ChildItem cmdlet when it is used in the Cert: drive. The Cert: drive is a Windows PowerShell drive that the Certificate Provider adds to the session.
When you compare the syntax displayed in the output with the syntax that is displayed when you omit the Args ( ArgumentList ) parameter, you'll see that the Certificate provider adds a dynamic parameter, CodeSigningCert , to the Get-ChildItem cmdlet.
For more information about the Certificate provider, see Certificate Provider.

.EXAMPLE

PS C:\>function Get-DynamicParameters
{
    param ($Cmdlet, $PSDrive)
    ( $Cmdlet -ArgumentList $PSDrive).ParameterSets | ForEach-Object {$_.Parameters} | Where-Object { $_.IsDynamic } | Select-Object -Property Name -Unique
}
PS C:\> Get-DynamicParameters -Cmdlet Get-ChildItem -PSDrive Cert:

Name
----
CodeSigningCert
The Get-DynamicParameters function in this example gets the dynamic parameters of a cmdlet. This is an alternative to the method used in the previous example. Dynamic parameter can be added to a cmdlet by another cmdlet or a provider.
The command in the example uses the Get-DynamicParameters function to get the dynamic parameters that the Certificate provider adds to the Get-ChildItem cmdlet when it is used in the Cert: drive.

.EXAMPLE

PS C:\> *
This command gets all commands of all types on the local computer, including executable files in the paths of the Path environment variable ($env:path). It returns an ApplicationInfo object (System.Management.Automation.ApplicationInfo) for each file, not a FileInfo object (System.IO.FileInfo).

.EXAMPLE

PS C:\> -ParameterName *Auth* -ParameterType AuthenticationMechanism
This command gets cmdlets that have a parameter whose name includes Auth and whose type is AuthenticationMechanism . You can use a command like this one to find cmdlets that let you specify the method that is used to authenticate the user.
The ParameterType parameter distinguishes parameters that take an AuthenticationMechanism value from those that take an AuthenticationLevel parameter, even when they have similar names.

.EXAMPLE

PS C:\> dir
CommandType     Name                                               ModuleName
-----------     ----                                               ----------
Alias           dir -> Get-ChildItem
This example shows how to use the  cmdlet with an alias. Although it is typically used on cmdlets and functions,  also gets scripts, functions, aliases, workflows, and executable files.
The output of the command shows the special view of the Name property value for aliases. The view shows the alias and the full command name.

.EXAMPLE

PS C:\> Notepad -All | Format-Table CommandType, Name, Definition

CommandType     Name           Definition
-----------     ----           ----------
Application     notepad.exe    C:\WINDOWS\system32\notepad.exe
Application     NOTEPAD.EXE    C:\WINDOWS\NOTEPAD.EXE
This example uses the All parameter of the  cmdlet to show all instances of the "Notepad" command on the local computer. The All parameter is useful when there is more than one command with the same name in the session.
Beginning in Windows PowerShell 3.0, by default, when the session includes multiple commands with the same name,  gets only the command that runs when you type the command name. With the All parameter,  gets all commands with the specified name and returns them in execution precedence order. To run a command other than the first one in the list, type the fully qualified path to the command.
For more information about command precedence, see about_Command_Precedence (http://go.microsoft.com/fwlink/?LinkID=113214).

.EXAMPLE

PS C:\>( Get-Date).ModuleName
Microsoft.PowerShell.Utility
This command gets the name of the snap-in or module in which the Get-Date cmdlet originated. The command uses the ModuleName property of all commands.
This command format works on commands in Windows PowerShell modules and snap-ins, even if they are not imported into the session.

.EXAMPLE

PS C:\> -Type Cmdlet | Where-Object OutputType | Format-List -Property Name, OutputType
This command gets the cmdlets and functions that have an output type and the type of objects that they return.
The first part of the command gets all cmdlets. A pipeline operator (|) sends the cmdlets to the Where-Object cmdlet, which selects only the ones in which the OutputType property is populated. Another pipeline operator sends the selected cmdlet objects to the Format-List cmdlet, which displays the name and output type of each cmdlet in a list.
The OutputType property of a CommandInfo object has a non-null value only when the cmdlet code defines the OutputType attribute for the cmdlet.

.EXAMPLE

PS C:\> -ParameterType (((Get-NetAdapter)[0]).PSTypeNames)
CommandType     Name                                               ModuleName
-----------     ----                                               ----------
Function        Disable-NetAdapter                                 NetAdapter
Function        Enable-NetAdapter                                  NetAdapter
Function        Rename-NetAdapter                                  NetAdapter
Function        Restart-NetAdapter                                 NetAdapter
Function        Set-NetAdapter                                     NetAdapter
This command finds cmdlets that take net adapter objects as input. You can use this command format to find the cmdlets that accept the type of objects that any command returns.
The command uses the PSTypeNames intrinsic property of all objects, which gets the types that describe the object. To get the PSTypeNames property of a net adapter, and not the PSTypeNames property of a collection of net adapters, the command uses array notation to get the first net adapter that the cmdlet returns.

.NOTES

When more than one command that has the same name is available to the session,  returns the command that runs when you type the command name. To get commands that have the same name, listed in run order, use the All* parameter. For more information, see about_Command_Precedence. * When a module is imported automatically, the effect is the same as using the Import-Module cmdlet. The module can add commands, types and formatting files, and run scripts in the session. To enable, disable, and configuration automatic importing of modules, use the $PSModuleAutoLoadingPreference preference variable. For more information, see about_Preference_Variables.



.INPUTS

System.String

.LINK

http://go.microsoft.com/fwlink/?LinkId=821482

.LINK

Online Version:

.LINK

Get-Help

#>
[CmdletBinding(DefaultParameterSetName='CmdletSet')]
Param(
    [Parameter(ParameterSetName='AllCommandSet', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$Name,
    [Parameter(ParameterSetName='CmdletSet', ValueFromPipelineByPropertyName=$true)]
    [string[]]$Verb,
    [Parameter(ParameterSetName='CmdletSet', ValueFromPipelineByPropertyName=$true)]
    [string[]]$Noun,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('PSSnapin')]
    [string[]]$Module,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Microsoft.PowerShell.Commands.ModuleSpecification[]]$FullyQualifiedModule,
    [Parameter(ParameterSetName='AllCommandSet', ValueFromPipelineByPropertyName=$true)]
    [Alias('Type')]
    [System.Management.Automation.CommandTypes]$CommandType,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [int]$TotalCount,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]$Syntax,
    [switch]$ShowCommandInfo,
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [Alias('Args')]
    [AllowEmptyCollection()]
    [AllowNull()]
    [System.Object[]]$ArgumentList,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]$All,
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [switch]$ListImported,
    [ValidateNotNullOrEmpty()]
    [string[]]$ParameterName,
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSTypeName[]]$ParameterType
)

Begin {
    If ($PSBoundParameters.ContainsKey('Syntax')) {
      $Syntax = $PSBoundParameters.Syntax
      Write-Verbose "Syntax: $($PSBoundParameters.Syntax)"
    }
    # Write-Verbose "[BEGIN] Starting $($MyInvocation.Mycommand) Syntax: $Syntax"
    # Write-Verbose "[BEGIN] Using parameter set $($PSCmdlet.ParameterSetName)"
    # Write-Verbose ($PSBoundParameters | Out-String)
} #begin

Process {
    If ($Syntax -and $PSBoundParameters.ContainsKey('Name')) { 
      $PSBoundParameters.Name = $PSBoundParameters.Name | ForEach-Object { 
        #if ($cmd = Get-Alias $_ -ea 0) {
        #  $cmd # $cmd.Definition
        #} else {
        #  $_
        #}
      }
    }
    Get-Command @PSBoundParameters | ForEach-Object {
      $_
      if ($_ -is [string] -and $_ -notmatch '(\[-)|(>])') {
        $parms = $PSBoundParameters.Clone()
        write-verbose "Returned string: [$_]"
        $parms.Name = $_
        Get-Command @Parms 
      }
    }
} #process

End {
   # Write-Verbose "[END  ] Ending $($MyInvocation.Mycommand)"
} #end

} #end function Get-Command

Function Test-DotSourced {
  [CmdletBinding()]
  param([object]$MyInvocation=$Script:MyInvocation)
  $MyInvocation.InvocationName -eq '.' -or $MyInvocation.Line -eq ''
  #$Line,$Squiggles = $MyInvocation.PositionMessage -split "`n" | ? { $_ -match '^\+(?:(\s+[^\s]+)|(\s+~))' }
  #$Command = $line.substring($squiggles.IndexOf('~')).trim()
  #Write-Verbose "$($MyInvocation.MyCommand) Command: [$Command]"
  #$Command -match '^\.[^/\\.\w]'
}

# $MyInvocation

If ($PSBoundParameters.ContainsKey('LoadOnly')) {
  write-warning "LoadOnly: Load functions and halt"
} elseif (Test-DotSourced) {
  write-warning "DotSourced: Load functions and halt"
} else {
  #write-host "Run some code"
  Get-CommandSyntax @args
}
<#
# $members = ($MyInvocation | gm -memb prop* ).name  |  ? { $_ -match 'script '}
$mi = $MyInvocation  # | select $members
#write-output ("-" * 72) #-foreground $host.ui.RawUI.backgroundcolor -back $host.ui.RawUI.foregroundcolor
# $members = ($MyInvocation.MyCommand | gm -memb prop* ).name  |  ? { $_ -match 'script '}
$mic = $MyInvocation.MyCommand  # | select $members

 #((. .\Get-CommandSyntax.ps1)).PositionMessage -split "`n" | sls '^\+'
 
# if ($mi.Line -match 'a') {}
#>
