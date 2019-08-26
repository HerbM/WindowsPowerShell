

FSMO Roles
ntdsutilroles Connections "Connect to server %logonserver%" Quit "selectOperation Target" "List roles for conn server" Quit Quit Quit
[JDH: This is really a series of steps, not a single command
expression]

Domain Controllers
Nltest /dclist:%userdnsdomain%

Domain Controller IP Configuration
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do psexec \\%i ipconfig /all

Stale computer accounts
dsquery computer domainroot -stalepwd 180 -limit 0

Stale user accounts
dsquery user domainroot -stalepwd 180 -limit 0

Disabled user accounts
dsquery user domainroot -disabled -limit 0

AD Database disk usage
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do dir \\%i\admin$\ntds

Global Catalog Servers from DNS
dnscmd %logonserver% /enumrecords %userdnsdomain% _tcp | find /i "3268"

Global Catalog Servers from AD
dsquery * "CN=Configuration,DC=forestRootDomain" -filter "(&(objectCategory=nTDSDSA)(options:1.2.840.113556.1.4.803:=1))"

Users with no logon script
dsquery * domainroot -filter"(&(objectCategory=Person)(objectClass=User)(!scriptPath=*))"-limit 0 -attr sAMAccountName sn givenName pwdLastSet distinguishedName

User accounts with no pwd required
dsquery * domainroot -filter "(&(objectCategory=Person)(objectClass=User)(userAccountControl:1.2.840.113556.1.4.803:=32))"

User accounts with no pwd expiry
dsquery * domainroot -filter"(&(objectCategory=Person)(objectClass=User)(userAccountControl:1.2.840.113556.1.4.803:=65536))"

User accounts that are disabled
dsquery * domainroot -filter "(&(objectCategory=Person)(objectClass=User)(userAccountControl:1.2.840.113556.1.4.803:=2))"

DNS Information
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do dnscmd %i /info

DNS Zone Detailed information
dnscmd /zoneinfo %userdnsdomain%

Garbage Collection and tombstone
dsquery * "cn=Directory Service,cn=WindowsNT,cn=Services,cn=Configuration,DC=forestRootDomain" -attrgarbageCollPeriod tombstoneLifetime

Netsh authorised DHCP Servers
netsh dhcp show server

DSQuery authorised DHCP Servers
Dsquery * "cn=NetServices,cn=Services,cn=Configuration, DC=forestRootDomain" -attr dhcpServers

DHCP server information
netsh dhcp server \\DHCP_SERVER show all

DHCP server dump
netsh dhcp server \\DHCP_SERVER dump

WINS serer information
Netsh wins server \\WINS_SERVER dump

Group Policy Verification Tool
gpotool.exe /checkacl /verbose

AD OU membership
dsquery computer -limit 0

AD OU membership
dsquery user -limit 0

List Service Principal Names
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do setspn -L %i

Compare DC Replica Object Count
dsastat ?s:DC1;DC2;… ?b:Domain ?gcattrs:objectclass ?p:999

Check AD ACLs
acldiag dc=domainTree

NTFRS Replica Sets
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do ntfrsutl sets %i

NTFRS DS View
for /f %i in (‘dsquery server -domain %userdnsdomain% -o rdn’) do ntfrsutl ds %i

Domain Controllers per site
Dsquery * "CN=Sites,CN=Configuration,DC=forestRootDomain" -filter (objectCategory=Server)

DNS Zones in AD
for /f %i in (‘dsquery server -o rdn’) do Dsquery * -s %i domainroot -filter (objectCategory=dnsZone)

Enumerate DNS Server Zones
for /f %i in (‘dsquery server -o rdn’) do dnscmd %i /enumzones

Subnet information
Dsquery subnet ?limit 0

List Organisational Units
Dsquery OU

ACL on all OUs
For /f "delims=|" %i in (‘dsquery OU’) do acldiag %i

Domain Trusts
nltest /domain_trusts /v

Print DNS Zones
dnscmd DNSServer /zoneprint DNSZone

Active DHCP leases
For /f %i in (DHCPServers.txt) do for /f "delims=- " %j in (‘"netshdhcp server \\%i show scope | find /i "active""’) do netsh dhcp server\\%i scope %j show clientsv5

DHCP Server Active Scope Info
For /f %i in (DHCPServers.txt) do netsh dhcp server \\%i show scope | find /i "active"

Resolve DHCP clients hostnames
for /f "tokens=1,2,3 delims=," %i in (Output from ‘Find Subnets fromDHCP clients’) do @for /f "tokens=2 delims=: " %m in (‘"nslookup %j |find /i "Name:""’) do echo %m,%j,%k,%i

Find two online PCs per subnet
Echo. > TwoClientsPerSubnet.txt & for /f "tokens=1,2,3,4delims=, " %i in (‘"find /i "pc" ‘Output from Resolve DHCP clientshostnames’"’) do for /f "tokens=3 skip=1 delims=: " %m in (‘"Find /i /c"%l" TwoClientsPerSubnet.txt"’) do If %m LEQ 1 for /f %p in (‘"ping -n1 %i | find /i /c "(0% loss""’) do If %p==1 Echo %i,%j,%k,%l

AD Subnet and Site Information
dsquery * "CN=Subnets,CN=Sites,CN=Configuration,DC=forestRootDomain" -attr cn siteObject description location

AD Site Information
dsquery * "CN=Sites,CN=Configuration,DC=forestRootDomain" -attr cn description location -filter (objectClass=site)

Printer Queue Objects in AD
dsquery * domainroot -filter "(objectCategory=printQueue)" -limit 0

Group Membership with user details
dsget group "groupDN" -members | dsget user -samid -fn -mi -ln -display -empid -desc -office -tel -email -title -dept -mgr

Total DHCP Scopes
find /i "subnet" "Output from DHCP server information" | find /i "subnet"

Site Links and Cost
dsquery * "CN=Sites,CN=Configuration,DC=forestRootDomain" -attr cn costdescription replInterval siteList -filter (objectClass=siteLink)

Time gpresult
timethis gpresult /v

Check time against Domain
w32tm /monitor /computers:ForestRootPDC

Domain Controller Diagnostics
dcdiag /s:%logonserver% /v /e /c

Domain Replication Bridgeheads
repadmin /bridgeheads

Replication Failures from KCC
repadmin /failcache

Inter-site Topology servers per site
Repadmin /istg * /verbose

Replication latency
repadmin /latency /verbose

Queued replication requests
repadmin /queue *

Show connections for a DC
repadmin /showconn *

Replication summary
Repadmin /replsummary

Show replication partners
repadmin /showrepl * /all

All DCs in the forest
repadmin /viewlist *

ISTG from AD attributes
dsquery * "CN=NTDS Site Settings,CN=siteName,CN=Sites,CN=Configuration,DC=forestRootDomain" -attr interSiteTopologyGenerator

Return the object if KCC Intra/Inter site is disabled for each site
Dsquery site | dsquery * -attr * -filter "(|(Options:1.2.840.113556.1.4.803:=1)(Options:1.2.840.113556.1.4.803:=16))"

Find all connection objects
dsquery * forestRoot -filter (objectCategory=nTDSConnection) ?attr distinguishedName fromServer whenCreated displayName

Find all connection schedules
adfind -b "cn=Configuration,dc=qraps,dc=com,dc=au" -f "objectcategory=ntdsConnection" cn Schedule -csv

Software Information for each server
for /f %i in (Output from ‘Domain Controllers’) do psinfo \\%i &filever \\%i\admin$\explorer.exe \\%i\admin$\system32\vbscript.dll\\%i\admin$\system32\kernel32.dll \\%i\admin$\system32\wbem\winmgmt.exe\\%i\admin$\system32\oleaut32.dll

Check Terminal Services Delete Temp on Exit flag
For /f %i in (Output from ‘Domain Controllers’) do Reg query"\\%i\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TerminalServer" /v DeleteTempDirsOnExit
F
or each XP workstation, query the current site and what Group Policy info
@dsquery * domainroot -filter"(&(objectCategory=Computer)(operatingSystem=Windows XPProfessional))" -limit 0 -attr cn > Workstations.txt & @For /f%i in (Workstations.txt) do @ping %i -n 1 >NUL & @if ErrorLevel0 If NOT ErrorLevel 1 @Echo %i & for /f "tokens=3" %k in (‘"regquery "\\%i\hklm\software\microsoft\windows\currentversion\grouppolicy\history" /v DCName | Find /i "DCName""’) do @for /f %m in(‘"nltest /server:%i /dsgetsite | find /i /v "completedsuccessfully""’) do @echo %i,%k,%m

Information on existing GPOs
dsquery * "CN=Policies,CN=System,domainRoot" -filter"(objectCategory=groupPolicyContainer)" -attr displayName cnwhenCreated gPCFileSysPath

Copy all Group Policy .pol files
for /f "tokens=1-8 delims=\" %i in (‘dir /b /s\\%userdnsdomain%\sysvol\%userdnsdomain%\policies\*.pol’) do @echo copy\\%i\%j\%k\%l\%m\%n\%o %m_%n.pol

Domain Controller Netlogon entries
for /f %i in (‘dsquery server /o rdn’) do echo %i & reg query\\%i\hklm\system\currentcontrolset\services\netlogon\parameters

WINS Statistics
for /f "tokens=1,2 delims=," %i in (WINSServers.txt) do netsh wins server \\%i show statistics

WINS Record counts per server
for /f "tokens=1,2 delims=," %i in (WINSServers.txt) do netsh wins server \\%i show reccount %i

WINS Server Information
for /f "tokens=2 delims=," %i in (WINSServers.txt) do netsh wins server \\%i show info

WINS Server Dump
for /f "tokens=2 delims=," %i in (WINSServers.txt) do netsh wins server \\%i dump

WINS Static Records per Server
netsh wins server \\LocalWINSServer show database servers={} rectype=1

Find policy display name given the GUID
dsquery * "CN=Policies,CN=System,DC=domainRoot" -filter (objectCategory=groupPolicyContainer) -attr Name displayName

Find empty groups
dsquery * -filter "&(objectCategory=group)(!member=*)" -limit 0-attr whenCreated whenChanged groupType sAMAccountNamedistinguishedName memberOf

Find remote NIC bandwidth
wmic /node:%server% path Win32_PerfRawData_Tcpip_NetworkInterface GET Name,CurrentBandwidth

Find remote free physical memory
wmic /node:%Computer% path Win32_OperatingSystem GET FreePhysicalMemory

Find remote system information
SystemInfo /s %Computer%

Disk statistics, including the number of files on the filesystem
chkdsk /i /c

Query IIS web sites
iisweb /s %Server% /query "Default Web Site"

Check port state and connectivity
portqry -n %server% -e %endpoint% -v

Forest/Domain Functional Levels
ldifde -d cn=partitions,cn=configuration,dc=%domain% -r"(|(systemFlags=3)(systemFlags=-2147483648))" -lmsds-behavior-version,dnsroot,ntmixeddomain,NetBIOSName -p subtree -fcon

Forest/Domain Functional Levels
dsquery * cn=partitions,cn=configuration,dc=%domain% -filter"(|(systemFlags=3)(systemFlags=-2147483648))" -attrmsDS-Behavior-Version
Name dnsroot ntmixeddomain NetBIOSName

Find the parent of a process
wmic path Win32_Process WHERE Name=’notepad.exe’ GET Name,ParentProcessId

Lookup SRV records from DNS
nslookup -type=srv _ldap._tcp.dc._msdcs.{domainRoot}

Find when the AD was installed
dsquery * cn=configuration,DC=forestRootDomain -attr whencreated -scope base

Enumerate the trusts from the specified domain
dsquery * "CN=System,DC=domainRoot" -filter "(objectClass=trustedDomain)" -attr trustPartner flatName

Find a DC for each trusted domain
for /f "skip=1" %i in (‘"dsquery * CN=System,DC=domainRoot -filter(objectClass=trustedDomain) -attr trustPartner"’) do nltest /dsgetdc:%i

Check the notification packages installed on all DCs
for /f %i in (‘dsquery server /o rdn’) do @for /f "tokens=4" %m in(‘"reg query\\%i\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa /v"Notification Packages" | find /i "Notification""’) do @echo %i,%m

List ACLs in SDDL format
setacl -on %filepath% -ot file -actn list -lst f:sddl

Find out if a user account is currently enabled or disabled
dsquery user DC=%userdnsdomain:.=,DC=% -name %username% | dsget user -disabled -dn

Find servers in the domain
dsquery * domainroot -filter "(&(objectCategory=Computer)(objectClass=Computer)(operatingSystem=*Server*))" -limit 0

Open DS query window
rundll32 dsquery,OpenQueryWindow

