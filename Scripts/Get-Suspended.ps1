Function Get-SuspendedProcess {
<#
.SYNOPSIS
	Gets suspended processes running on the local computer or a remote computer.	
.DESCRIPTION
	Get-SuspendedProcess gets the processes on a local or remote computer.
	
	Without parameters, this cmdlet lists suspended processes on the local computer. 
  You can also specify a process name or process ID (PID) or pass a process object through the pipeline to this cmdlet.
	
	By default, this cmdlet returns process objects with detailed information and supports methods that let you start and stop the process. You can also use the parameters of the Get-SuspendedProcess cmdlet to get file version information for the program that runs in the process and to get the modules that the process loaded.
	
.PARAMETER ComputerName
	Specifies the computers for which this cmdlet gets active processes. The default is the local computer.
	
	Type the NetBIOS name, an IP address, or a fully qualified domain name (FQDN) of one or more computers. To specify the local computer, type the computer name, a dot (.), or localhost.
	
	This parameter does not rely on Windows PowerShell remoting. You can use the ComputerName parameter of this cmdlet even if your computer is not configured to run remote commands.
	
.PARAMETER FileVersionInfo
	Indicates that this cmdlet gets the file version information for the program that runs in the process.
	
	On Windows Vista and later versions of Windows, you must open Windows PowerShell with the Run as administrator option to use this parameter on processes that you do not own.
	
	You cannot use the FileVersionInfo and ComputerName parameters of the Get-SuspendedProcess cmdlet in the same command. To get file version information for a process on a remote computer, use the Invoke-Command cmdlet.
	
	Using this parameter is equivalent to getting the MainModule.FileVersionInfo property of each process object. When you use this parameter, Get-SuspendedProcess returns a FileVersionInfo object (System.Diagnostics.FileVersionInfo), not a process object. So, you cannot pipe the output of the command to a cmdlet that expects a process object, such as Stop-Process.
	
.PARAMETER Id
	Specifies one or more processes by process ID (PID). To specify multiple IDs, use commas to separate the IDs. To find the PID of a process, type `Get-SuspendedProcess`.
	
.PARAMETER IncludeUserName
	Indicates that the UserName value of the Process object is returned with results of the command.
	
.PARAMETER InputObject
	Specifies one or more process objects. Enter a variable that contains the objects, or type a command or expression that gets the objects.
	
.PARAMETER Module
	Indicates that this cmdlet gets the modules that have been loaded by the processes.
	
	On Windows Vista and later versions of Windows, you must open Windows PowerShell with the Run as administrator option to use this parameter on processes that you do not own.
	
	You cannot use the Module and ComputerName parameters of the Get-SuspendedProcess cmdlet in the same command. To get the modules that have been loaded by a process on a remote computer, use the Invoke-Command cmdlet.
	
	This parameter is equivalent to getting the Modules property of each process object. When you use this parameter, this cmdlet returns a ProcessModule object (System.Diagnostics.ProcessModule), not a process object. So, you cannot pipe the output of the command to a cmdlet that expects a process object, such as Stop-Process.
	
	When you use both the Module and FileVersionInfo parameters in the same command, this cmdlet returns a FileVersionInfo object with information about the file version of all modules.
	
.PARAMETER Name
	Specifies one or more processes by process name. You can type multiple process names (separated by commas) and use wildcard characters. The parameter name ("Name") is optional.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess
	This command gets a list of all active processes running on the local computer. For a definition of each column, see the "Additional Notes" section of the Help topic for Get-Help.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess winword, explorer | Format-List *
	This command gets all available data about the Winword and Explorer processes on the computer. It uses the Name parameter to specify the processes, but it omits the optional parameter name. The pipeline operator (|) passes the data to the Format-List cmdlet, which displays all available properties (*) of the Winword and Explorer process objects.
	You can also identify the processes by their process IDs. For instance, `Get-SuspendedProcess -Id 664, 2060`.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess | Where-Object {$_.WorkingSet -gt 20000000}
	This command gets all processes that have a working set greater than 20 MB. It uses the Get-SuspendedProcess cmdlet to get all running processes. The pipeline operator (|) passes the process objects to the Where-Object cmdlet, which selects only the object with a value greater than 20,000,000 bytes for the WorkingSet property. WorkingSet is one of many properties of process objects. To see all of the properties, type `Get-SuspendedProcess | Get-Member`. By default, the values of all amount properties are in bytes, even though the default display lists them in kilobytes and megabytes.
	
.EXAMPLE
	PS C:\>$A = Get-SuspendedProcess PS C:\>Get-SuspendedProcess -InputObject $A | Format-Table -View priority
	These commands list the processes on the computer in groups based on their priority class. The first command gets all the processes on the computer and then stores them in the $A variable.
	The second command uses the InputObject parameter to pass the process objects that are stored in the $A variable to the Get-SuspendedProcess cmdlet. The pipeline operator passes the objects to the Format-Table cmdlet, which formats the processes by using the Priority view. The Priority view, and other views, are defined in the PS1XML format files in the Windows PowerShell home directory ($pshome).
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess Powershell -ComputerName S1, localhost | ft @{Label="NPM(K)";Expression={[int]($_.NPM/1024)}}, @{Label="PM(K)";Expression={[int]($_.PM/1024)}},@{Label="WS(K)";Expression={[int]($_.WS/1024)}},@{Label="VM(M)";Expression={[int]($_.VM/1MB)}}, @{Label="CPU(s)";Expression={if ($_.CPU -ne $()) { $_.CPU.ToString("N")}}}, Id, MachineName, ProcessName -Auto
	
	NPM(K) PM(K) WS(K) VM(M) CPU(s)   Id MachineName ProcessName
	------ ----- ----- ----- ------   -- ----------- -----------
	6      23500 31340   142        1980 S1          powershell
	6      23500 31348   142        4016 S1          powershell
	27     54572 54520   576        4428 localhost   powershell
	This example provides a Format-Table (alias = ft) command that adds the MachineName property to the standard Get-SuspendedProcess output display.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess powershell -FileVersionInfo
	
	ProductVersion   FileVersion      FileName
	--------------   -----------      --------
	6.1.6713.1       6.1.6713.1 (f... C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe
	This command uses the FileVersionInfo parameter to get the version information for the PowerShell.exe file that is the main module for the PowerShell process.
	To run this command with processes that you do not own on Windows Vista and later versions of Windows, you must open Windows PowerShell with the Run as administrator option.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess SQL* -Module
	This command uses the Module parameter to get the modules that have been loaded by the process. This command gets the modules for the processes that have names that begin with SQL.
	To run this command on Windows Vista and later versions of Windows with processes that you do not own, you must start Windows PowerShell with the Run as administrator option.
	
.EXAMPLE
	PS C:\>$P = Get-WmiObject win32_process -Filter "name='powershell.exe'"
	PS C:\>$P.getowner()
	
	__GENUS          : 2
	__CLASS          : __PARAMETERS
	__SUPERCLASS     :
	__DYNASTY        : __PARAMETERS
	__RELPATH        :
	__PROPERTY_COUNT : 3
	__DERIVATION     : {}
	__SERVER         :
	__NAMESPACE      :
	__PATH           :
	Domain           : DOMAIN01
	ReturnValue      : 0
	User             : user01
	This command shows how to find the owner of a process. Because the System.Diagnostics.Process object that Get-SuspendedProcess returns does not have a property or method that returns the process owner, the command uses the Get-WmiObject cmdlet to get a Win32_Process object that represents the same process.
	The first command uses Get-WmiObject to get the PowerShell process. It saves it in the $P variable.
	The second command uses the GetOwner method to get the owner of the process in $P. The command reveals that the owner is Domain01\user01.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess powershell
	
	Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
	-------  ------    -----      ----- -----   ------     -- -----------
	308      26        52308      61780   567     3.18   5632 powershell
	377      26        62676      63384   575     3.88   5888 powershell PS C:\>Get-SuspendedProcess -Id $pid
	
	Handles  NPM(K)    PM(K)      WS(K) VM(M)   CPU(s)     Id ProcessName
	-------  ------    -----      ----- -----   ------     -- -----------
	396      26        56488      57236   575     3.90   5888 powershell
	These commands show how to use the $pid automatic variable to identify the process that is hosting the current Windows PowerShell session. You can use this method to distinguish the host process from other Windows PowerShell processes that you might want to stop or close. The first command gets all of the Windows PowerShell processes in the current session.
	The second command gets the Windows PowerShell process that is hosting the current session.
	
.EXAMPLE
	PS C:\>Get-SuspendedProcess | where {$_.mainWindowTitle} | Format-Table id, name, mainwindowtitle -autosize
	This command gets all the processes that have a main window title, and it displays them in a table with the process ID and the process name.
	The mainWindowTitle property is just one of many useful properties of the Process object that Get-SuspendedProcess returns. To view all of the properties, pipe the results of a Get-SuspendedProcess command to the Get-Member cmdlet (Get-SuspendedProcess | get-member).
	
.NOTES
	* You can also refer to this cmdlet by its built-in aliases, ps and gps. For more information, see about_Aliases.
	
	* On computers that are running a 64-bit version of Windows, the 64-bit version of Windows PowerShell gets only 64-bit process modules and the 32-bit version of Windows PowerShell gets only 32-bit process modules.
	
	* You can use the properties and methods of the Windows Management Instrumentation (WMI) Win32_Process object in Windows PowerShell. For information, see Get-WmiObject and the WMI SDK.
	
	* The default display of a process is a table that includes the following columns. For a description of all of the properties of process objects, see Process Propertieshttp://go.microsoft.com/fwlink/?LinkId=204482 at http://go.microsoft.com/fwlink/?LinkId=204482.
	
	- Handles: The number of handles that the process has opened.
	
	- NPM(K): The amount of non-paged memory that the process is using, in kilobytes.
	
	- PM(K): The amount of pageable memory that the process is using, in kilobytes.
	
	- WS(K): The size of the working set of the process, in kilobytes. The working set consists of the pages of memory that were recently referenced by the process.
	
	- VM(M): The amount of virtual memory that the process is using, in megabytes. Virtual memory includes storage in the paging files on disk.
	
	- CPU(s): The amount of processor time that the process has used on all processors, in seconds.
	
	- ID: The process ID (PID) of the process.
	
	- ProcessName: The name of the process.
	
	For explanations of the concepts related to processes, see the Glossary in Help and Support Center and the Help for Task Manager.
	* You can also use the built-in alternate views of the processes available with Format-Table, such as StartTime and Priority, and you can design your own views.
	
.INPUTS
	System.Diagnostics.Process
	
.OUTPUTS
	System.Diagnostics.Process, System.Diagnotics.FileVersionInfo, System.Diagnostics.ProcessModule
	
.LINK
	http://go.microsoft.com/fwlink/?linkid=821590
	
.LINK
	Online Version:
	
.LINK
	Debug-Process
	
.LINK
	Get-SuspendedProcess
	
.LINK
	Start-Process
	
.LINK
	Stop-Process
	
.LINK
	Wait-Process
#>

  [CmdletBinding(DefaultParameterSetName='Name', 
    RemotingCapability='SupportedByCommand')]
  param(
    [Parameter(ParameterSetName='NameWithUserName', Position=0, ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='Name', Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('ProcessName')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    ${Name},
   
    [Parameter(ParameterSetName='Id', Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='IdWithUserName', Mandatory=$true, 
      ValueFromPipelineByPropertyName=$true)]
    [Alias('PID')][int[]]${Id},
   
    [Parameter(ParameterSetName='InputObject', Mandatory=$true, ValueFromPipeline=$true)]
    [Parameter(ParameterSetName='InputObjectWithUserName', Mandatory=$true, ValueFromPipeline=$true)]
    [System.Diagnostics.Process[]]
    ${InputObject},
   
    [Parameter(ParameterSetName='IdWithUserName', Mandatory=$true)]
    [Parameter(ParameterSetName='NameWithUserName', Mandatory=$true)]
    [Parameter(ParameterSetName='InputObjectWithUserName', Mandatory=$true)]
    [switch]${IncludeUserName},
   
    [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='Name', ValueFromPipelineByPropertyName=$true)]
    [Parameter(ParameterSetName='InputObject', ValueFromPipelineByPropertyName=$true)]
    [Alias('Cn')][ValidateNotNullOrEmpty()][string[]]${ComputerName},    
    [Parameter(ParameterSetName='Name')]
    [Parameter(ParameterSetName='Id')]
    [Parameter(ParameterSetName='InputObject')]
    [ValidateNotNull()][switch]${Module},
    [Parameter(ParameterSetName='Name')][Parameter(ParameterSetName='Id')]
    [Parameter(ParameterSetName='InputObject')]
    [Alias('FV','FVI')][ValidateNotNull()][switch]${FileVersionInfo}
  )
   
   Begin {
     Try {
       $OutBuffer = $null
       if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
           $PSBoundParameters['OutBuffer'] = 1
       }
       $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-SuspendedProcess', [System.Management.Automation.CommandTypes]::Cmdlet)
       $scriptCmd = {& $wrappedCmd @PSBoundParameters }
       $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
       $steppablePipeline.Begin($PSCmdlet)
     } catch {
       throw
     }
   }
   Process {
    try {
      $steppablePipeline.Process($_)
    } catch {
      throw
    }
  } End {
    try {
      $SteppablePipeline.End()
    } catch {
      Throw
    }
  }
} # End of function: Get-SuspendedProcess


$processes = Get-Process *
$processHt = @{}                                 # empty hash table
foreach ($process in $processes) {
  foreach ($thread in $process.Threads) {   
    if($thread.ThreadState -eq "Wait") {
      if ( $processHt.Containskey($Process.Name ) ) {
        if ($ProcessHt[$Process.Name] -match $($Thread.WaitReason.ToString()) ) {
        
        } else {
          $ProcessHt[$Process.Name] += ",$($Thread.WaitReason.ToString())"
        }
      } else {
        $ProcessHt.Add( $Process.Name , $Thread.WaitReason.ToString() )
      }
    }
  }
}

# "`n=== all threads suspended ==="
# $processHt.Keys | Where-Object { $processHt[$_] -eq 'Suspended' }
# "`n=== some thread suspended ==="
# $processHt.Keys | Where-Object { $processHt[$_] -match 'Suspended' } | 
#   ForEach-Object { @{ $_ = $processHt[$_] } } |
#   Format-Table -AutoSize -HideTableHeaders       # merely for simple output look
  
If ($MyInvocation.InvocationName -eq '.' -and !$Args[0]) { 
  Write-Warning 'New-ProxyCommand -Name ''Get-ChildItem'' -CommandType Cmdlet -NewName Get-Popel'
} Else {
  New-ProxyCommand @args 
}
  