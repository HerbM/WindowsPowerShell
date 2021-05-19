$DockingStateChange = @"
   Select * from RegistryValueChangeEvent WITHIN 1
     WHERE Hive='HKEY_LOCAL_MACHINE' AND
       KeyPath='SYSTEM\\CurrentControlSet\\Control\\IDConfigDB\\CurrentDockInfo' AND
       ValueName='DockingState'
"@
$DockingEventAction = { Write-Warning "Dock event fired" }
Register-CimIndicationEvent -SourceIdentifier HerbEvent -Action $DockingEventAction -Query $DockingStateChange

# https://www.scriptrunner.com/en/blog/events-powershell-wmi/
# https://docs.microsoft.com/en-us/windows/win32/wmisdk/determining-the-type-of-event-to-receive
# https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-auditing-faq

# 4738: A user account was changed
# The following are some of the events related to user account management:
#     Event ID 4720 shows a user account was created.
#     Event ID 4722 shows a user account was enabled.
#     Event ID 4740 shows a user account was locked out.
#     Event ID 4725 shows a user account was disabled.
#     Event ID 4726 shows a user account was deleted.
#     Event ID 4738 shows a user account was changed.
#     Event ID 4781 shows the name of an account was changed.

# Select is SENSITIVE, must not have leading spaces, all backslashes must be DOUBLED \\
$RunKeyValue = @"
Select * from RegistryValueChangeEvent WITHIN 1
    WHERE Hive='HKEY_LOCAL_MACHINE' AND
      KeyPath='SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run' AND
      ValueName='Nitro System Tray'
"@
$RunKeyValue
$RunKeyAction = { Write-Warning "Nitro Run Key changed" }
$RunKeyAction
<#
# __EventFilter
# LogFileEventConsumer: Writes to a log file.
# __FilterToConsumerBinding class and supply it with values for Filter and Consumer objects.
$WQLQuery =
'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "Win32_USBControllerDevice"'

gwmi -Query ("SELECT * FROM Win32_NTLogEvent WHERE Logfile = 'Application' AND SourceName = 'Group Policy Services' AND EventCode = '4098'")

$WQLQuery = @"
SELECT * FROM Win32_NTLogEvent WHERE Logfile = 'Security' AND EventCode = '4098'"
@"

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "Win32_NTLogEvent"'

Get-CIMInstance -Query $WQLQuery

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "Win32_NTLogEvent"'
$WMIFilterInstance = New-CimInstance -ClassName __EventFilter -Namespace "root\subscription" -Property @{
  Name="NTLogEvent"
  EventNameSpace="rootcimv2";
  QueryLanguage="WQL";
  Query=$WQLQuery
}
# Get-CimInstance -ClassName __EventFilter -namespace root\subscription -filter "name='NTLogEvent'" #| Remove-CimInstance
# Get-CimInstance -ClassName __EventFilter -namespace root\subscription -filter "name='NTLogEvent'" #| Remove-CimInstance
# $WQLQuery = @"
##  SELECT * FROM Win32_NTLogEvent Where Logfile = 'Security' AND EventCode = '4722' and SourceName = 'Microsoft-Windows-Security-Auditing'
##  "@
##  Get-CIMInstance -Query $WQLQuery | FT TimeGenerate,EventIdentifier,CategoryString,SourceName,Message

$WMIEventConsumer =
  New-CimInstance -ClassName NTEventLogEventConsumer -Namespace "root\subscription" -Property  @{
    Name="AccountEnabled";
    EventId = [uint32] 4722; # shows a user account was enabled
    LogFile = 'Security';
    SourceName="Microsoft-Windows-Security-Auditing";
    # EventType = [uint32]8;
    # Category= [uint16] 1000
}
# EventType can have following values; Error 1, FailureAudit 16, Information 4, SuccesAudit 8, Warning 2
# Category is never really used but can have any value and basically
# meant to provide more information about the event
# "Microsoft Windows security"

$WMIWventBinding = New-CimInstance -ClassName __FilterToConsumerBinding -Namespace "rootsubscription" -Property @{
  Filter   = [Ref] $WMIFilterInstance;
  Consumer = [Ref] $WMIEventConsumer
}

$ConsumerArgs = @{name='TestWithNotepad-event4722';
                CommandLineTemplate="$($Env:SystemRoot)\System32\notepad.exe";}
$Consumer=New-CimInstance -Namespace root/subscription -ClassName CommandLineEventConsumer -Property $ConsumerArgs

$WMIWventBinding = New-CimInstance -ClassName __FilterToConsumerBinding -Namespace "root\subscription" -Property @{
  Filter   = [Ref] $WMIFilterInstance;
  Consumer = [Ref] $Consumer
}


# Application     Internet Explorer       PDW Component Failures  Security  Windows Azure
# HardwareEvents  Key Management Service  ResScan                 System    Windows PowerShell


Get-CimInstance -ClassName __EventFilter -namespace rootsubscription -filter "name='myFilter'" | Remove-CimInstance
Get-CimInstance -ClassName NTEventLogEventConsumer -Namespace rootsubscription -filter "name='FolderWriteLogging'" | Remove-CimInstance
Get-CimInstance -ClassName __FilterToConsumerBinding -Namespace rootsubscription -Filter "Filter = ""__eventfilter.name='myFilter'""" | Remove-CimInstance
#>


<#
Register-CimIndicationEvent -SourceIdentifier RunKeyChange -Action $RunKeyAction -Query $RunKeyValue
Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'Nitro System Tray'

Event consumer
Once our event filter matches the criteria we would like to take certain action like we did in our example for temporary event subscription. For permanent event subscription we have five action types provided by five different consumer classes to choose from.

Event Log Consumers:
  LogFileEventConsumer: Writes to a log file.
  ActiveScriptEventConsumer: Execute a Script.
  NTEventLogEventConsumer: Write to Windows event log.
  SMTPEventConsumer: Send an email.
  CommandLineEventConsumer: Command line execution.

__FilterToConsumerBinding class and supply it with values for Filter and Consumer objects.

Example: setting up permanent WMI event subscription
Let’s take an example, suppose we want to generate Event log when a user plugs in a USB device. We can easily do this using WMI eventing.

It’s a three-step process:

We first define the Filter for an Event representing “user plugging in USB stick”
We then define a Consumer to generate Event log when this Filter matches the Event
Finally, Filter-to-Consumer binding joins the Event Filter with the rightful Consumer

#>

$WQLQuery = 'SELECT * FROM __InstanceCreationEvent WITHIN 10 WHERE TargetInstance ISA "Win32_USBControllerDevice"'
$WQLQuery