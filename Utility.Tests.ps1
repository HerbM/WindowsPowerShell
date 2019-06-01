[CmdletBinding()]Param(
  [switch]$NoMocks
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut  = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Write-Warning "`$MyInvocation.MyCommand.Path $($MyInvocation.MyCommand.Path)"
Write-Warning "Get-CurrentFileName $(Get-CurrentFileName)"
Write-Warning "Get-CurrentFileLine $(Get-CurrentFileLine)"

Describe 'Test Function Get-CurrentLineNumber' {
  Context "CurrentLineNumber" {
    It 'Returns greater than 0' {
      Get-CurrentLineNumber | Should -BeGreaterThan 0
    }
  }
}

Describe 'Test Function Get-FormattedDate, Get-SortableDate' {
  Context "Correctly formatted dates" {
    $Now                  = Get-Date -Format 's'
    $SortableDate         = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    $FormattedDate        = Get-Date -Format "yyyy-MM-ddTHH:mm:ss-ddd"
    $SortableDatePattern  = '^(\d{4})(-\d{2}){2}T(\d{2}(?::\d{2}){2})$'
    $FormattedDatePattern = $SortableDatePattern -replace '\$$','-([a-z]{3})$'
    It 'Get-SortableDate -> "yyyy-MM-ddTHH:mm:ss"'  {
       $Result  = Get-SortableDate $Now
       $Matched = $Result -match $SortableDatePattern
       Write-Verbose "[$Result] $Matched"
       $Result | Should Match $SortableDatePattern
    }
    It 'Get-FormattedDate -> "yyyy-MM-ddTHH:mm:ss-ddd"'  {
       $Result  = Get-FormattedDate $Now
       $Matched = $Result -match $FormattedDatePattern
       Write-Verbose "[$Result] $Matched"
       $Result | Should Match $FormattedDatePattern
    }    
    It 'Random DatePattern -> "$DatePattern"'  {
       $Count   = 20
       $Dates   = 1..$Count | ForEach { (Get-Date).AddHours([uint32](Get-Random -Maximum 100 -Minimum 0)) }
       $Matched = @($Dates | Where { (Get-SortableDate $_) -match $SortableDatePattern })
       Write-Verbose "[Result $($Matched.Count)] $($Dates.Count)"
       $Matched.Count | Should Be $Dates.count
    }
  }
}

<#

Utility.ps1:106:function Get-CurrentLineNumber {
Utility.ps1:111:function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   
Utility.ps1:112:function Get-CurrentFileLine   {
Utility.ps1:117:function Get-CurrentFileName1  {
Utility.ps1:135:function Get-SortableDate {
Utility.ps1:140:function Get-FormattedDate ([DateTime]$Date = (Get-Date)) {
Utility.ps1:147:function Write-Log {
Utility.ps1:180:Function Test-Variable {  # Remove when new version is tested
Utility.ps1:186:Function Test-Variable {
Utility.ps1:212:Function Write-LogSeparator {
Utility.ps1:228:function Log-ComputerInfo {
Utility.ps1:252:function ExitWithCode($exitcode) {
Utility.ps1:257:function GetVerbose {   # return a --verbose switch string for calling other programs or ''
Utility.ps1:262:function Make-Credential([string]$username, [string]$password) {
Utility.ps1:276:function Get-ErrorDetail {
Utility.ps1:288:function MyPSHost {
Utility.ps1:310:function Convert-HashToString1($ht) {
Utility.ps1:318:function Convert-HashToString($Hash, [string]$prefix='-',
Utility.ps1:328:function Get-AdminRole() {
Utility.ps1:332:function PSBoundParameter([string]$Parm) {
Utility.ps1:336:  function Remove-MappedDrive([string]$name) {
Utility.ps1:342:  function Get-MappedDrive([string]$name, [string]$share, [string]$username="", [string]$password="") {
Utility.ps1:357:function Get-AESKey([uint16]$length=256) {
Utility.ps1:369:function Decrypt-SecureString ($secureString) {
Utility.ps1:373:function Get-PlainText ([string]$string, [byte[]]$key=$(Get-Temporary)) {
Utility.ps1:379:function Set-EncryptedString([string]$content, [byte[]]$Key) {
Utility.ps1:387:function Get-Temporary {
Utility.ps1:403:function Get-EncryptedString($Secret, [byte[]]$key) {
Utility.ps1:407:function Set-EncryptedContent([string]$Path, [string]$content, [switch]$Append) {
Utility.ps1:417:function Get-EncryptedContent([string]$Path, [byte[]]$key, [switch]$Delete) {
Utility.ps1:424:function Get-StandardWindowsAdministrator { @('Administrator') }
Utility.ps1:426:function Get-CredentialContent ([string]$ZipFile, [string]$CredFile, $pwd = "NOTHING") {
Utility.ps1:443:function Import-SecureZip {
Utility.ps1:474:  function New-Zipfile ([string]$ZipFile, [string]$contents, $pwd = "NOTHING") {
Utility.ps1:486:  function Get-LocalCredential {
Utility.ps1:514:  function Fix-Encoding([string]$xmlstring, [string]$enc=$encoding) {
Utility.ps1:521:  Function Start-ProcessWithWait ([string]$cmd, [string[]]$arg, $wait = (10 * 1000)) {
Utility.ps1:534:  function Run-CmdBatch ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000)) { # wait up to 2 
minutes by default
Utility.ps1:541:  Function Start-ProcessWithWait2 ([string]$cmd, [string[]]$arg, $wait = (10 * 1000), $cred=$null) {
Utility.ps1:554:  function Run-CmdBatch2 ($Batch='APPConfig.cmd', $arguments=@(), $wait=(2*60*1000), $cred=$null) { # 
wait up to 2 minutes by default
Utility.ps1:561:  function Add-ADDMAccount {
Utility.ps1:574:  function Reboot-Computer($delay=15) {
Utility.ps1:598:  function Get-LocalAdministrator {
Utility.ps1:602:  function Set-Password([string]$UserName, [string]$Password, [byte[]]$key) {
Utility.ps1:620:  function New-LocalUser {
Utility.ps1:637:  function Get-Cleartext {
Utility.ps1:650:  function Rename-LocalAdmin($NewName='Admin999', $Password, [byte[]]$key, 
[switch]$force,[switch]$HardForce) {
Utility.ps1:651:    function Get-LocalAdminName {(Get-LocalAdministrator).Name}
Utility.ps1:686:function Get-DomainRoleName ([int32]$Role) {
Utility.ps1:698:function Get-Drive {
Utility.ps1:708:function Get-DomainInformation {
Utility.ps1:713:function Delete-AppDirectoryAtNextBoot {
Utility.ps1:737:function Get-SystemBootTime  {
Utility.ps1:742:function Get-ComputerDomain {
Utility.ps1:746:function Get-ComputerNetBiosDomain {
Utility.ps1:750:function Get-LocalUserList() {
Utility.ps1:757:function LocalUserExists([string]$user, [string []]$userlist = @()) {
Utility.ps1:762:function Delete-LocalUser([string []]$users) {
Utility.ps1:770:function Add-UserToGroup ([string]$user, [string]$group='Administrators') {
Utility.ps1:776:function Add-GroupMember {
Utility.ps1:796:function Add-LocalUser([string]$user, [string]$password, [string]$comment="") {
Utility.ps1:812:Function Get-TempPassword() {
Utility.ps1:826:Function Get-TempName([UINT16]$Length=8, [switch]$Alphabetic, [switch]$Numeric) {
Utility.ps1:837:function Get-RegValue([String] $KeyPath, [String] $ValueName) {
Utility.ps1:841:function Get-AdminRole() {
Utility.ps1:848:function Copy-DirectoryTree([string]$sourcepath, [string]$destpath) {
Utility.ps1:854:function Remove-Parameters {
Utility.ps1:870:function Get-PresentSwitchName([string[]]$switch) {
Utility.ps1:882:function Get-SerialNumber {
Utility.ps1:886:function Get-MACAddress {
Utility.ps1:891:function Get-UUID {
Utility.ps1:895:function New-UniqueName() { [System.IO.Path]::GetRandomFileName() }
Utility.ps1:897:function New-TemporaryDirectory ([string]$Path = '.\temp', [switch]$Create) {
Utility.ps1:914:function testlog () {
Utility.ps1:919:function testfl () {
Utility.ps1:924:function Set-ExecutionPolicyRemotely([string]$Computername, [string]$ExecutionPolicy, $cred) {
Utility.ps1:943:function Set-FirewallOff {
Utility.ps1:965:function Get-OS {(Get-WmiObject -class Win32_OperatingSystem -ea 0).caption}
Utility.ps1:966:function Is-Windows2008? {return ((Get-OS) -match '2008')}
Utility.ps1:968:function Get-EnvironmentVariable([string] $Name, [System.EnvironmentVariableTarget] $Scope) {
Utility.ps1:972:function Get-EnvironmentVariableNames([System.EnvironmentVariableTarget] $Scope) {
Utility.ps1:981:function Update-Environment {
Utility.ps1:1007:function Is-RebootPending? {
Utility.ps1:1028:function Clear-All-Event-Logs ($ComputerName="localhost") {
Utility.ps1:1039:function WaitFor-WSMan {
Utility.ps1:1073:function Test-Json {
Utility.ps1:1102:function Get-CharSet ([string]$start='D', [string]$end='Q') {
Utility.ps1:1106:function Get-UnusedDriveLetter($LetterSet) {
Utility.ps1:1119:function Get-ServiceStatus ($Name) {
Utility.ps1:1125:Function Write-ImageInfoLog([string]$CorrelationID, [string]$IPAddress,
Utility.ps1:1144:function Get-HostsContent ($path="$Env:SystemRoot\System32\drivers\etc\hosts") { gc $path -ea 0 }
Utility.ps1:1146:function Replace-HostRecord ([string[]]$hosts, [string]$IP, [string[]]$Name, [string]$comment) {
Utility.ps1:1164:function Add-HostRecord ([string]$IP, [string[]]$Name, [string]$comment='') {
Utility.ps1:1175:function Sort-ConnectionSpeed {
Utility.ps1:1198:Function ConvertTo-QuotedElementString {

#>
