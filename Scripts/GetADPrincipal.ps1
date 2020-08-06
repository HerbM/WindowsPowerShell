Function Get-ADPrincipal { 
  [CmdletBinding()]Param(
    [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)][string[]]$Name,
    [parameter(DontShow)][string]$ParentGroup = '',
    [switch]$NoRecursion = $False
  )
  Begin {
    If (!$ParentGroup) { $GroupsSeen = @($ParentGroup) }
    $CommonProperties = 'DistinguishedName', 'Enabled', 'Name', 
      'ObjectClass', 'SamAccountName', 'SID', 'UserPrincipalName' 
  }
  Process {
    ForEach ($N in $Name) {
      $Members = @()
      $Properties = 'Name', 'SamAccountName', 'DistinguishedName', 'ObjectSID', 
                    'DisplayName', 'ObjectGUID'
      $Filter = @(ForEach ($P in $Properties) { "$P -eq '$N'" }) -join ' -or '
      Write-Verbose "Filter: $Filter"
      $Members = @()
      If       ($Principal = Get-ADUser     -Filter $Filter -ea IGNORE) {
        If (!$ParentGroup) { Write-Warning "User: [$($Principal.Name)] [SamAccountName]" }
        Write-Verbose "ADUser: $($Principal.Name)"
      } ElseIf ($Principal = Get-ADGroup    -Filter $Filter -ea IGNORE -properties Members) {
        $Seen = Get-Variable GroupsSeen -Scope 1 -value -ea Ignore
        ForEach ($Group in $Principal) {
          If          
          Write-Verbose "ADUser: $($Group.Name)" 
          # If (!$NoRecursion) { $Members = Get-ADPrincipal $Group.Members $Group.Name }
          If (!$NoRecursion) { $Members = $Group.Members }
          $Seen += $Group 
        }
      } ElseIf ($Principal = Get-ADComputer -Filter $Filter -ea IGNORE -wa IGNORE) {
        If ($Principal) { 
          Write-Verbose "ADComputer: $($Principal.Name)" 
          If (! $Principal.UserPrincipalName) {
            $Principal.UserPrincipalName = $Principal.DNSHostName
          }
        }
      } Else {
        Write-Warning "AD Principal not found: [$N]"
      }
      ForEach ($SP in $Principal) {
        $P = [PSCustomObject]@{
          Name              = $SP.Name
          SamAccountName    = $SP.SamAccountName
          ObjectClass       = $SP.ObjectClass
          Enabled           = $SP.Enabled
          ParentGroup       = $ParentGroup
          DistinguishedName = $SP.DistinguishedName
          SID               = $SP.SID
          UserPrincipalName = $SP.UserPrincipalName
        }
        If (Get-Command Set-DefaultPropertySet -ea Ignore) {
          Set-DefaultPropertySet $P @('Name','SamAccountName','ObjectClass','ParentGroup')
        }
      }
      ForEach ($Member in $Members) {
        Get-ADPrincipal $Member $Principal.Name
      }
    }  
  }
}

Function Set-DefaultPropertySet { param([Object]$Object,
  [Alias('Properties','Property','Members')][string[]]$DefaultProperties)
  If (!$Object) { return $Null }
  $defaultDisplayPropertySet =
    New-Object System.Management.Automation.PSPropertySet(
      'DefaultDisplayPropertySet',[string[]]$defaultProperties)
  $PSStandardMembers =
    [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
  $OBject | Add-Member MemberSet PSStandardMembers $PSStandardMembers -PassThru
}

<#
DistinguishedName
Enabled
Name
ObjectClass
SamAccountName
SID
UserPrincipalName
GivenName
Surname
ObjectGUID

DistinguishedName
Enabled
Name
ObjectClass
SamAccountName
SID
UserPrincipalName
ObjectGUID
DNSHostName
Function Get-GroupMembership {
  [CmdletBinding()]Param(
    [string[]]$GroupName,
    [string]$ParentGroup = ''
  )
  Begin {}
  Process {
    # dsget group "CN=Administrators,CN=Builtin,DC=txdcs,DC=teamibm,DC=com" -members -expand
    ForEach ($Name in $GroupName ) { 
      $Name = $Name.tostring().trim()
      Write-Verbose "Group $Name"
      Try {
        # $Filter = switch -regex $Name {
        #   '^CN='  { "DistinguishedName -eq '$Name'"}
        #   Default { }
        # }
        $ADID = @(Get-ADGroup $Name -ea ignore -properties members)
        If ($ADID) {
          $ADGroup = $ADID.Clone()
        } Else {
          $ADGroup = @()        
          Write-Verbose "Get-ADUser $Name"
          $ADID = Get-ADUser $Name -ea STOP
          Write-Verbose "Found User: [$($ADID.Name)]"
        }  
        [PSCustomObject]@{
          Name           = $ADID.Name
          SamAccountName = $ADID.samaccountname
          ObjectClass    = $ADID.objectclass
          ParentGroup    = $ParentGroup
        }
        If ($ADGroup) {
          Write-Warning "Recurse GroupMembership: $($ADGroup.Members)`nParent: $Name"        
          Get-GroupMembership -GroupName $ADGroup.members -ParentGroup $Name
          Write-Warning "Returning from recursion Parent: $Name"          
        }
      } Catch { 
        Write-Verbose "Missing name: [$Name]"
        Write-Verbose "##$($_ | format-list * -force | Out-String )"
        Write-Debug   "Missing name: [$Name]"
        Write-Debug   "##$($_ | format-list * -force | Out-String )"
      }  
    }
  }
  End {}
}


#>