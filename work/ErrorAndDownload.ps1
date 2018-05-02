Function Get-ServiceVersion {    #  :TODO:  :HM:
  [CmdletBinding()]Param(
    $Name
  )
  # Get-Process
  # Get-WMIOBject Win32_Service -filter 'Name = "Everything"'
  # 'Name = "Everything"'
  $Filter = "Name = `"$Name`""
  $Path = (Get-WMIOBject Win32_Service -filter $Filter).PathName
  ($Path | % { 
    Write-Verbose "Path: $_" 
    $_ | Get-ChildItem 
  }).VersionInfo  
  # & ([scriptblock]::Create("EchoArgs $Path"))
}


Function Format-Error {
  [CmdletBinding()]Param(
    [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
      [Alias('Error')][ErrorRecord[]]$ErrorList
  )  
  Begin {}
  process {
    $ErrorList | Foreach-Object {
      $Line = $_.invocationinfo.ScriptLineNumber
      $Char = $_.invocationinfo.OffSetInLine
      $Name = If ($_.invocationinfo.PSCommandPath) {
        Split-Path -ea 0 $_.invocationinfo.PSCommandPath -Leaf 
      }
      $Msg  = "[$($_.tostring())]"
      $FQID = $_.FullyQualifiedErrorId -replace ',.*'
      $Cmd1 = $_.invocationinfo.InvocationName
      $Cmd2 = $_.invocationinfo.MyCommand.Name
      If ($Cmd1 -ne $Cmd2) { $Cmd1 += "/$Cmd2" } 
      ( "LINE: $Line","CHAR:$Char",$FQID,$Cmd1,$Name,$Msg |
        Where-Object { $_ }
      ) -join ' '
    }
    write-verbose ('-' * 72)
  }  
  End {}
}

<# 
format-error $error[0]
LINE: 1 CHAR:28 ParseException / ic.ps1 [Exception calling "Create" with "1" argument(s): "At line:14 char:64
+     Where-Object Href -match $FileRegex | select -first 1).href
+                                                                ~
Missing closing ')' in expression.

At line:15 char:3
+   $FileName = $File -replace '.*(7z.*\.exe).*', '$1'
+   ~~~~~~~~~
Unexpected token '$FileName' in expression or statement."]
WARNING: ------------------------------------------------------------------------


param (
  [Alias('Url','Link')] [string]$uri='https://git-scm.com/download/win', # Windows Git page 
  [Alias('Directory')][string[]]$Path="$Home\Downloads",                 # downloaded file to path 
  [Alias('bit32','b32','old')][switch]$Bits32
)
                               
  $VersionPattern = If ($bits32) { 'git-.*-32-bit.exe' } else { 'git-.*-64-bit.exe' }  
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"


  $page = Invoke-WebRequest -Uri $uri -UseBasicParsing -verbose:$false # get the web page 
  $dl   = ($page.links | where outerhtml -match $VersionPattern | 
    select -first 1 *).href                                 # download link latest 64-bit version
  write-verbose "Link: $dl"  
  $filename = split-path $dl -leaf                          # split out the filename
  write-verbose "Filename: $filename"    
  $out = Join-Path -Path $path -ChildPath $filename         # construct a filepath for the download 
  write-verbose "Download save path: $out"    
  if ($PSCmdlet.ShouldProcess("$dl", "Saving: $out`n")) {
    Invoke-WebRequest -uri $dl -OutFile $out -UseBasicParsing -verbose:$false # download file 
  }  
  Get-item $out | ForEach { "$($_.length) $($_.lastwritetime) $($_.fullname)" }

#>

Function Get-7ZipInstaller  {
  [CmdletBinding()]Param(
    [string]$Name         = '7Z',
    [string]$URL          = 'https://www.7-zip.org',
    [string]$Type         = '',
    [string]$Architecture = 'x64'
  )
  # ((Invoke-WebRequest https://www.7-zip.org).links | ? Href -match '7z.*x64.*exe' | select Innerhtml,href,outertext -first 1).href
  # 64-bit ->  a/7z1801-x64.exe
  # 32-bit ->  a/7z1801.exe
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  $FileRegex = ($Name, $Type, $Architecture, '\.exe' | ? { $_ }) -join '.*'
  Write-Verbose "$(LINE) File regex: $FileRegex"
  $File = ((Invoke-WebRequest $URL -UseBasicParsing).Links | 
    Where-Object Href -match $FileRegex | select -first 1).href
  $FileName = $File -replace '.*(7z.*\.exe).*', '$1'  
  Write-Verbose "$(LINE) Downloading: Invoke-WebRequest $Url/$File -UseBasicParsing -outfile $FileName"
  $Download = Invoke-WebRequest "$Url/$File" -outfile $FileName  
  Write-Verbose "$(LINE) Download: $($Download.StatusCode) $($Download.StatusDescription)"
}

Function Get-NotePadPlusPlus {
  [CmdletBinding()]Param(
    [string]$Name         = 'NotePad++',
    [string]$URL          = 'https://notepad-plus-plus.org/download/',
    [string]$Type         = '',
    [string]$Architecture = 'x64'
  )
   
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  # https://notepad-plus-plus.org/download/
  # https://notepad-plus-plus.org/download/v7.5.6.html
  # ((Invoke-WebRequest https://notepad-plus-plus.org/download/v7.5.6.html).links | 
  #    Where-Object Href -match 'npp.*bin(\.x64)?\.7z' | select innertext,href,outertext)
  #  'npp.*bin(\.x64)?\.7z'
  # innerText                       href                                       outerText
  # ---------                       ----                                       ---------
  # Notepad++ 7z package 32-bit x86 /repository/7.x/7.5.6/npp.7.5.6.bin.7z     Notepad++ 7z package 32-bit x86
  # Notepad++ 7z package 64-bit x64 /repository/7.x/7.5.6/npp.7.5.6.bin.x64.7z Notepad++ 7z package 64-bit x64  
  # https://notepad-plus-plus.org/download/v7.5.6.html
  <#
  
    ((Invoke-WebRequest https://notepad-plus-plus.org).links |? href -match 'download/v').href
    download/v7.5.6.html
    
    ((Invoke-WebRequest https://notepad-plus-plus.org).links |? href -match 'download')
    innerHTML : Download
    innerText : Download
    outerHTML : <A title=Download href="download/">Download</A>
    outerText : Download
    tagName   : A
    title     : Download
    href      : download/

    innerHTML : Download
    innerText : Download
    outerHTML : <A href="download/v7.5.6.html">Download</A>
    outerText : Download
    tagName   : A
    href      : download/v7.5.6.html
  #>
  $FileRegex = 'npp.*bin(\.x64)?\.7z' # ($Name, $Type, $Architecture, '\.exe' | ? { $_ }) -join '.*'
  Write-Verbose "$(LINE) File regex: $FileRegex"
  $File = ((Invoke-WebRequest $URL).Links | 
    Where-Object Href -match $FileRegex | select -first 1).href
  $FileName = $File -replace '.*(7z.*\.exe).*', '$1'  
  Write-Verbose "$(LINE) Downloading: Invoke-WebRequest $Url/$File -outfile $FileName"
  $Download = Invoke-WebRequest "$Url/$File" -outfile $FileName  
  Write-Verbose "$(LINE) Download: $($Download.StatusCode) $($Download.StatusDescription)"
}

Function Get-EverythingInstaller  {
  [CmdletBinding()]Param(
    [string]$Name         = 'Everything',
    [string]$URL          = 'http://www.voidtools.com',
    [string]$Type         = 'Portable',
    [string]$Architecture = '64'
  )
  
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    
  # http://www.voidtools.com/downloads/
  # Target: http://www.voidtools.com/Everything-1.4.1.895.x64.zip
  $FileRegex = ('Download', $Type, $Architecture | ? { $_ }) -join '.*'
  Write-Verbose "$(LINE) File regex: $FileRegex"
  $File = (((Invoke-WebRequest $URL).Links | 
    Where-Object InnerHtml -match $FileRegex).href) -replace '^($Url)?/' 
  Write-Verbose "$(LINE) Downloading: Invoke-WebRequest $Url/$File -outfile $File"
  $Download = Invoke-WebRequest "$Url/$File" -outfile $File  
  Write-Verbose "$(LINE) Download: $($Download.StatusCode) $($Download.StatusDescription)"
  $Url += '/downloads'
  $File = (((Invoke-WebRequest -Uri $url )).links | ? {$_.href -match '^.?ES.*\.(z)' } | 
    select innerhtml,href).href -replace '^($Url)?/?'
  Write-Verbose "$(LINE) Downloading: Invoke-WebRequest $Url/$File -outfile $File"
  $Download = Invoke-WebRequest $Url/$File -outfile $File  
  Write-Verbose "$(LINE) Download: $($Download.StatusCode) $($Download.StatusDescription)"
  # http://www.voidtools.com/ES-1.1.0.9.zip
  # http://www.voidtools.com/Everything-SDK.zip
  # http://www.voidtools.com/Everything.chm.zip
}

# Alias with switches -- create easy simple functions 
# Requests, BeautifulSoup Scrapy
# Python objects <-> PowerShell
# ((Invoke-WebRequest -Uri $uri )).links | ? {$_.href -match '\.(z|x|msi)' } | select innerhtml,href
# ((Invoke-WebRequest -Uri $uri )).links | ? {$_.href -match '64.*\.(z|ex|msi)' } | select innerhtml,href
# https://powershell.org/2014/01/13/getting-your-script-module-functions-to-inherit-preference-variables-from-the-caller/
# https://gallery.technet.microsoft.com/scriptcenter/Inherit-Preference-82343b9d

function Rename-MyFile {
  [CmdletBinding(SupportsShouldProcess=$true)]
  [OutputType([System.Void])]
  param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [Alias('FullName')]
    [String[]]
    $Path
  )
  begin {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
  }
  process {
    foreach ($item in $Path) {
      if ($PSCmdlet.ShouldProcess($item)) {
        Rename-Item -LiteralPath $item -NewName "$($item | Split-Path -Leaf).MyFile" -WhatIf
      }
    }
  }
}

<#
# $Path = (Get-WMIOBject Win32_Service -filter 'Name = "Everything"').PathName ; & ([scriptblock]::Create("EchoArgs $Path"))

# ((get-command Invoke-WebRequest | Select -expand Parametersets)) | select Parameters | select -first 1 -expand Parameters | ft



class ErrorRecord
{
  Exception = 
    class ItemNotFoundException
    {
      ErrorRecord = 
        class ErrorRecord
        {
          Exception = 
            class ParentContainsErrorRecordException
            {
              Message = Cannot find a variable with the name 'MaxPromptLength'.
              Data = 
                [
                ]
                
              InnerException = 
              TargetSite = 
              StackTrace = 
              HelpLink = 
              Source = 
              HResult = -2146233087
            }
          TargetObject = MaxPromptLength
          CategoryInfo = 
            class ErrorCategoryInfo
            {
              Category = ObjectNotFound
              Activity = 
              Reason = ParentContainsErrorRecordException
              TargetName = MaxPromptLength
              TargetType = String
            }
          FullyQualifiedErrorId = VariableNotFound
          ErrorDetails = 
          InvocationInfo = 
          ScriptStackTrace = 
          PipelineIterationInfo = 
            [
            ]
            
          PSMessageDetails = 
        }
      ItemName = MaxPromptLength
      SessionStateCategory = Drive
      WasThrownFromThrowStatement = False
      Message = Cannot find a variable with the name 'MaxPromptLength'.
      Data = 
        [
        ]
        
      InnerException = 
      TargetSite = 
      StackTrace = 
      HelpLink = 
      Source = 
      HResult = -2146233087
    }
  TargetObject = MaxPromptLength
  CategoryInfo = 
    class ErrorCategoryInfo
    {
      Category = ObjectNotFound
      Activity = Get-Variable
      Reason = ItemNotFoundException
      TargetName = MaxPromptLength
      TargetType = String
    }
  FullyQualifiedErrorId = VariableNotFound,Microsoft.PowerShell.Commands.GetVariableCommand
  ErrorDetails = 
  InvocationInfo = 
    class InvocationInfo
    {
      MyCommand = 
        class CmdletInfo
        {
          Verb = Get
          Noun = Variable
          HelpFile = Microsoft.PowerShell.Commands.Utility.dll-Help.xml
          PSSnapIn = 
          Version = 
            class Version
            {
              Major = 3
              Minor = 1
              Build = 0
              Revision = 0
              MajorRevision = 0
              MinorRevision = 0
            }
          ImplementingType = 
            class RuntimeType
            {
              Module = Microsoft.PowerShell.Commands.Utility.dll
              Assembly = Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, 
              PublicKeyToken=31bf3856ad364e35
              TypeHandle = System.RuntimeTypeHandle
              DeclaringMethod = 
              BaseType = Microsoft.PowerShell.Commands.VariableCommandBase
              UnderlyingSystemType = Microsoft.PowerShell.Commands.GetVariableCommand
              FullName = Microsoft.PowerShell.Commands.GetVariableCommand
              AssemblyQualifiedName = Microsoft.PowerShell.Commands.GetVariableCommand, 
              Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
              Namespace = Microsoft.PowerShell.Commands
              GUID = d3e484a2-f842-3705-8e1b-4fb8241908dd
              IsEnum = False
              GenericParameterAttributes = 
              IsSecurityCritical = True
              IsSecuritySafeCritical = False
              IsSecurityTransparent = False
              IsGenericTypeDefinition = False
              IsGenericParameter = False
              GenericParameterPosition = 
              IsGenericType = False
              IsConstructedGenericType = False
              ContainsGenericParameters = False
              StructLayoutAttribute = System.Runtime.InteropServices.StructLayoutAttribute
              Name = GetVariableCommand
              MemberType = TypeInfo
              DeclaringType = 
              ReflectedType = 
              MetadataToken = 33554537
              GenericTypeParameters = 
                [
                ]
                
              DeclaredConstructors = 
                [
                  Void .ctor()
                ]
                
              DeclaredEvents = 
                [
                ]
                
              DeclaredFields = 
                [
                  System.String[] name
                  Boolean valueOnly
                ]
                
              DeclaredMembers = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredMethods = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredNestedTypes = 
                [
                  Microsoft.PowerShell.Commands.GetVariableCommand+<>c
                ]
                
              DeclaredProperties = 
                [
                  System.String[] Name
                  System.Management.Automation.SwitchParameter ValueOnly
                  System.String[] Include
                  System.String[] Exclude
                ]
                
              ImplementedInterfaces = 
                [
                ]
                
              TypeInitializer = 
              IsNested = False
              Attributes = AutoLayout, AnsiClass, Class, Public, BeforeFieldInit
              IsVisible = True
              IsNotPublic = False
              IsPublic = True
              IsNestedPublic = False
              IsNestedPrivate = False
              IsNestedFamily = False
              IsNestedAssembly = False
              IsNestedFamANDAssem = False
              IsNestedFamORAssem = False
              IsAutoLayout = True
              IsLayoutSequential = False
              IsExplicitLayout = False
              IsClass = True
              IsInterface = False
              IsValueType = False
              IsAbstract = False
              IsSealed = False
              IsSpecialName = False
              IsImport = False
              IsSerializable = False
              IsAnsiClass = True
              IsUnicodeClass = False
              IsAutoClass = False
              IsArray = False
              IsByRef = False
              IsPointer = False
              IsPrimitive = False
              IsCOMObject = False
              HasElementType = False
              IsContextful = False
              IsMarshalByRef = False
              GenericTypeArguments = 
                [
                ]
                
              CustomAttributes = 
                [
                  [System.Management.Automation.CmdletAttribute("Get", "Variable", HelpUri = 
                  "http://go.microsoft.com/fwlink/?LinkID=113336")]
                  [System.Management.Automation.OutputTypeAttribute(typeof(System.Management.Automation.PSVariable))]
                ]
                
            }
          Definition = 
          Get-Variable [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
          [<CommonParameters>]
          
          DefaultParameterSet = 
          OutputType = 
            [
              System.Management.Automation.PSVariable
            ]
            
          Options = ReadOnly
          Name = Get-Variable
          CommandType = Cmdlet
          Source = Microsoft.PowerShell.Utility
          Visibility = Public
          ModuleName = Microsoft.PowerShell.Utility
          Module = 
            class PSModuleInfo
            {
              Name = Microsoft.PowerShell.Utility
              Path = C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShe
              ll.Utility.psd1
              Description = 
              Guid = 1da87e53-152b-403e-98dc-74d7b4d63d59
              Version = 3.1.0.0
              ModuleBase = C:\Windows\System32\WindowsPowerShell\v1.0
              ModuleType = Manifest
              PrivateData = 
              AccessMode = ReadWrite
              ExportedAliases = 
                [
                  [CFS, CFS]
                  [fhx, fhx]
                ]
                
              ExportedCmdlets = 
                [
                  [Add-Member, Add-Member]
                  [Add-Type, Add-Type]
                  [Clear-Variable, Clear-Variable]
                  [Compare-Object, Compare-Object]
                  ...
                ]
                
              ExportedFunctions = 
                [
                  [ConvertFrom-SddlString, ConvertFrom-SddlString]
                  [Format-Hex, Format-Hex]
                  [Get-FileHash, Get-FileHash]
                  [Import-PowerShellDataFile, Import-PowerShellDataFile]
                  ...
                ]
                
              ExportedVariables = 
                [
                ]
                
              NestedModules = 
                [
                  Microsoft.PowerShell.Commands.Utility.dll
                  Microsoft.PowerShell.Utility
                ]
                
            }
          RemotingCapability = PowerShell
          Parameters = 
            [
              [Name, System.Management.Automation.ParameterMetadata]
              [ValueOnly, System.Management.Automation.ParameterMetadata]
              [Include, System.Management.Automation.ParameterMetadata]
              [Exclude, System.Management.Automation.ParameterMetadata]
              ...
            ]
            
          ParameterSets = 
            [
              [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
              [<CommonParameters>]
            ]
            
          HelpUri = http://go.microsoft.com/fwlink/?LinkID=113336
          DLL = C:\windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856
          ad364e35\Microsoft.PowerShell.Commands.Utility.dll
        }
      BoundParameters = 
        [
        ]
        
      UnboundArguments = 
        [
        ]
        
      ScriptLineNumber = 1374
      OffsetInLine = 9
      HistoryId = 574
      ScriptName = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      Line =   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLength = 45 }
      
      PositionMessage = At C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:1374 char:9
      +   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLeng ...
      +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      PSScriptRoot = C:\Users\A469526\Documents\WindowsPowerShell
      PSCommandPath = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      InvocationName = Get-Variable
      PipelineLength = 0
      PipelinePosition = 0
      ExpectingInput = False
      CommandOrigin = Internal
      DisplayScriptPosition = 
    }
  ScriptStackTrace = at Global:prompt, C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1: 
  line 1374
  at <ScriptBlock>, <No file>: line 1
  PipelineIterationInfo = 
    [
      0
      1
    ]
    
  PSMessageDetails = 
}

class ErrorRecord
{
  Exception = 
    class ItemNotFoundException
    {
      ErrorRecord = 
        class ErrorRecord
        {
          Exception = 
            class ParentContainsErrorRecordException
            {
              Message = Cannot find a variable with the name 'MaxPromptLength'.
              Data = 
                [
                ]
                
              InnerException = 
              TargetSite = 
              StackTrace = 
              HelpLink = 
              Source = 
              HResult = -2146233087
            }
          TargetObject = MaxPromptLength
          CategoryInfo = 
            class ErrorCategoryInfo
            {
              Category = ObjectNotFound
              Activity = 
              Reason = ParentContainsErrorRecordException
              TargetName = MaxPromptLength
              TargetType = String
            }
          FullyQualifiedErrorId = VariableNotFound
          ErrorDetails = 
          InvocationInfo = 
          ScriptStackTrace = 
          PipelineIterationInfo = 
            [
            ]
            
          PSMessageDetails = 
        }
      ItemName = MaxPromptLength
      SessionStateCategory = Drive
      WasThrownFromThrowStatement = False
      Message = Cannot find a variable with the name 'MaxPromptLength'.
      Data = 
        [
        ]
        
      InnerException = 
      TargetSite = 
      StackTrace = 
      HelpLink = 
      Source = 
      HResult = -2146233087
    }
  TargetObject = MaxPromptLength
  CategoryInfo = 
    class ErrorCategoryInfo
    {
      Category = ObjectNotFound
      Activity = Get-Variable
      Reason = ItemNotFoundException
      TargetName = MaxPromptLength
      TargetType = String
    }
  FullyQualifiedErrorId = VariableNotFound,Microsoft.PowerShell.Commands.GetVariableCommand
  ErrorDetails = 
  InvocationInfo = 
    class InvocationInfo
    {
      MyCommand = 
        class CmdletInfo
        {
          Verb = Get
          Noun = Variable
          HelpFile = Microsoft.PowerShell.Commands.Utility.dll-Help.xml
          PSSnapIn = 
          Version = 
            class Version
            {
              Major = 3
              Minor = 1
              Build = 0
              Revision = 0
              MajorRevision = 0
              MinorRevision = 0
            }
          ImplementingType = 
            class RuntimeType
            {
              Module = Microsoft.PowerShell.Commands.Utility.dll
              Assembly = Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, 
              PublicKeyToken=31bf3856ad364e35
              TypeHandle = System.RuntimeTypeHandle
              DeclaringMethod = 
              BaseType = Microsoft.PowerShell.Commands.VariableCommandBase
              UnderlyingSystemType = Microsoft.PowerShell.Commands.GetVariableCommand
              FullName = Microsoft.PowerShell.Commands.GetVariableCommand
              AssemblyQualifiedName = Microsoft.PowerShell.Commands.GetVariableCommand, 
              Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
              Namespace = Microsoft.PowerShell.Commands
              GUID = d3e484a2-f842-3705-8e1b-4fb8241908dd
              IsEnum = False
              GenericParameterAttributes = 
              IsSecurityCritical = True
              IsSecuritySafeCritical = False
              IsSecurityTransparent = False
              IsGenericTypeDefinition = False
              IsGenericParameter = False
              GenericParameterPosition = 
              IsGenericType = False
              IsConstructedGenericType = False
              ContainsGenericParameters = False
              StructLayoutAttribute = System.Runtime.InteropServices.StructLayoutAttribute
              Name = GetVariableCommand
              MemberType = TypeInfo
              DeclaringType = 
              ReflectedType = 
              MetadataToken = 33554537
              GenericTypeParameters = 
                [
                ]
                
              DeclaredConstructors = 
                [
                  Void .ctor()
                ]
                
              DeclaredEvents = 
                [
                ]
                
              DeclaredFields = 
                [
                  System.String[] name
                  Boolean valueOnly
                ]
                
              DeclaredMembers = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredMethods = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredNestedTypes = 
                [
                  Microsoft.PowerShell.Commands.GetVariableCommand+<>c
                ]
                
              DeclaredProperties = 
                [
                  System.String[] Name
                  System.Management.Automation.SwitchParameter ValueOnly
                  System.String[] Include
                  System.String[] Exclude
                ]
                
              ImplementedInterfaces = 
                [
                ]
                
              TypeInitializer = 
              IsNested = False
              Attributes = AutoLayout, AnsiClass, Class, Public, BeforeFieldInit
              IsVisible = True
              IsNotPublic = False
              IsPublic = True
              IsNestedPublic = False
              IsNestedPrivate = False
              IsNestedFamily = False
              IsNestedAssembly = False
              IsNestedFamANDAssem = False
              IsNestedFamORAssem = False
              IsAutoLayout = True
              IsLayoutSequential = False
              IsExplicitLayout = False
              IsClass = True
              IsInterface = False
              IsValueType = False
              IsAbstract = False
              IsSealed = False
              IsSpecialName = False
              IsImport = False
              IsSerializable = False
              IsAnsiClass = True
              IsUnicodeClass = False
              IsAutoClass = False
              IsArray = False
              IsByRef = False
              IsPointer = False
              IsPrimitive = False
              IsCOMObject = False
              HasElementType = False
              IsContextful = False
              IsMarshalByRef = False
              GenericTypeArguments = 
                [
                ]
                
              CustomAttributes = 
                [
                  [System.Management.Automation.CmdletAttribute("Get", "Variable", HelpUri = 
                  "http://go.microsoft.com/fwlink/?LinkID=113336")]
                  [System.Management.Automation.OutputTypeAttribute(typeof(System.Management.Automation.PSVariable))]
                ]
                
            }
          Definition = 
          Get-Variable [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
          [<CommonParameters>]
          
          DefaultParameterSet = 
          OutputType = 
            [
              System.Management.Automation.PSVariable
            ]
            
          Options = ReadOnly
          Name = Get-Variable
          CommandType = Cmdlet
          Source = Microsoft.PowerShell.Utility
          Visibility = Public
          ModuleName = Microsoft.PowerShell.Utility
          Module = 
            class PSModuleInfo
            {
              Name = Microsoft.PowerShell.Utility
              Path = C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShe
              ll.Utility.psd1
              Description = 
              Guid = 1da87e53-152b-403e-98dc-74d7b4d63d59
              Version = 3.1.0.0
              ModuleBase = C:\Windows\System32\WindowsPowerShell\v1.0
              ModuleType = Manifest
              PrivateData = 
              AccessMode = ReadWrite
              ExportedAliases = 
                [
                  [CFS, CFS]
                  [fhx, fhx]
                ]
                
              ExportedCmdlets = 
                [
                  [Add-Member, Add-Member]
                  [Add-Type, Add-Type]
                  [Clear-Variable, Clear-Variable]
                  [Compare-Object, Compare-Object]
                  ...
                ]
                
              ExportedFunctions = 
                [
                  [ConvertFrom-SddlString, ConvertFrom-SddlString]
                  [Format-Hex, Format-Hex]
                  [Get-FileHash, Get-FileHash]
                  [Import-PowerShellDataFile, Import-PowerShellDataFile]
                  ...
                ]
                
              ExportedVariables = 
                [
                ]
                
              NestedModules = 
                [
                  Microsoft.PowerShell.Commands.Utility.dll
                  Microsoft.PowerShell.Utility
                ]
                
            }
          RemotingCapability = PowerShell
          Parameters = 
            [
              [Name, System.Management.Automation.ParameterMetadata]
              [ValueOnly, System.Management.Automation.ParameterMetadata]
              [Include, System.Management.Automation.ParameterMetadata]
              [Exclude, System.Management.Automation.ParameterMetadata]
              ...
            ]
            
          ParameterSets = 
            [
              [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
              [<CommonParameters>]
            ]
            
          HelpUri = http://go.microsoft.com/fwlink/?LinkID=113336
          DLL = C:\windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856
          ad364e35\Microsoft.PowerShell.Commands.Utility.dll
        }
      BoundParameters = 
        [
        ]
        
      UnboundArguments = 
        [
        ]
        
      ScriptLineNumber = 1374
      OffsetInLine = 9
      HistoryId = 573
      ScriptName = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      Line =   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLength = 45 }
      
      PositionMessage = At C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:1374 char:9
      +   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLeng ...
      +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      PSScriptRoot = C:\Users\A469526\Documents\WindowsPowerShell
      PSCommandPath = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      InvocationName = Get-Variable
      PipelineLength = 0
      PipelinePosition = 0
      ExpectingInput = False
      CommandOrigin = Internal
      DisplayScriptPosition = 
    }
  ScriptStackTrace = at Global:prompt, C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1: 
  line 1374
  at <ScriptBlock>, <No file>: line 1
  PipelineIterationInfo = 
    [
      0
      1
    ]
    
  PSMessageDetails = 
}

class ErrorRecord
{
  Exception = 
    class ItemNotFoundException
    {
      ErrorRecord = 
        class ErrorRecord
        {
          Exception = 
            class ParentContainsErrorRecordException
            {
              Message = Cannot find a variable with the name 'MaxPromptLength'.
              Data = 
                [
                ]
                
              InnerException = 
              TargetSite = 
              StackTrace = 
              HelpLink = 
              Source = 
              HResult = -2146233087
            }
          TargetObject = MaxPromptLength
          CategoryInfo = 
            class ErrorCategoryInfo
            {
              Category = ObjectNotFound
              Activity = 
              Reason = ParentContainsErrorRecordException
              TargetName = MaxPromptLength
              TargetType = String
            }
          FullyQualifiedErrorId = VariableNotFound
          ErrorDetails = 
          InvocationInfo = 
          ScriptStackTrace = 
          PipelineIterationInfo = 
            [
            ]
            
          PSMessageDetails = 
        }
      ItemName = MaxPromptLength
      SessionStateCategory = Drive
      WasThrownFromThrowStatement = False
      Message = Cannot find a variable with the name 'MaxPromptLength'.
      Data = 
        [
        ]
        
      InnerException = 
      TargetSite = 
      StackTrace = 
      HelpLink = 
      Source = 
      HResult = -2146233087
    }
  TargetObject = MaxPromptLength
  CategoryInfo = 
    class ErrorCategoryInfo
    {
      Category = ObjectNotFound
      Activity = Get-Variable
      Reason = ItemNotFoundException
      TargetName = MaxPromptLength
      TargetType = String
    }
  FullyQualifiedErrorId = VariableNotFound,Microsoft.PowerShell.Commands.GetVariableCommand
  ErrorDetails = 
  InvocationInfo = 
    class InvocationInfo
    {
      MyCommand = 
        class CmdletInfo
        {
          Verb = Get
          Noun = Variable
          HelpFile = Microsoft.PowerShell.Commands.Utility.dll-Help.xml
          PSSnapIn = 
          Version = 
            class Version
            {
              Major = 3
              Minor = 1
              Build = 0
              Revision = 0
              MajorRevision = 0
              MinorRevision = 0
            }
          ImplementingType = 
            class RuntimeType
            {
              Module = Microsoft.PowerShell.Commands.Utility.dll
              Assembly = Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, 
              PublicKeyToken=31bf3856ad364e35
              TypeHandle = System.RuntimeTypeHandle
              DeclaringMethod = 
              BaseType = Microsoft.PowerShell.Commands.VariableCommandBase
              UnderlyingSystemType = Microsoft.PowerShell.Commands.GetVariableCommand
              FullName = Microsoft.PowerShell.Commands.GetVariableCommand
              AssemblyQualifiedName = Microsoft.PowerShell.Commands.GetVariableCommand, 
              Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
              Namespace = Microsoft.PowerShell.Commands
              GUID = d3e484a2-f842-3705-8e1b-4fb8241908dd
              IsEnum = False
              GenericParameterAttributes = 
              IsSecurityCritical = True
              IsSecuritySafeCritical = False
              IsSecurityTransparent = False
              IsGenericTypeDefinition = False
              IsGenericParameter = False
              GenericParameterPosition = 
              IsGenericType = False
              IsConstructedGenericType = False
              ContainsGenericParameters = False
              StructLayoutAttribute = System.Runtime.InteropServices.StructLayoutAttribute
              Name = GetVariableCommand
              MemberType = TypeInfo
              DeclaringType = 
              ReflectedType = 
              MetadataToken = 33554537
              GenericTypeParameters = 
                [
                ]
                
              DeclaredConstructors = 
                [
                  Void .ctor()
                ]
                
              DeclaredEvents = 
                [
                ]
                
              DeclaredFields = 
                [
                  System.String[] name
                  Boolean valueOnly
                ]
                
              DeclaredMembers = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredMethods = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredNestedTypes = 
                [
                  Microsoft.PowerShell.Commands.GetVariableCommand+<>c
                ]
                
              DeclaredProperties = 
                [
                  System.String[] Name
                  System.Management.Automation.SwitchParameter ValueOnly
                  System.String[] Include
                  System.String[] Exclude
                ]
                
              ImplementedInterfaces = 
                [
                ]
                
              TypeInitializer = 
              IsNested = False
              Attributes = AutoLayout, AnsiClass, Class, Public, BeforeFieldInit
              IsVisible = True
              IsNotPublic = False
              IsPublic = True
              IsNestedPublic = False
              IsNestedPrivate = False
              IsNestedFamily = False
              IsNestedAssembly = False
              IsNestedFamANDAssem = False
              IsNestedFamORAssem = False
              IsAutoLayout = True
              IsLayoutSequential = False
              IsExplicitLayout = False
              IsClass = True
              IsInterface = False
              IsValueType = False
              IsAbstract = False
              IsSealed = False
              IsSpecialName = False
              IsImport = False
              IsSerializable = False
              IsAnsiClass = True
              IsUnicodeClass = False
              IsAutoClass = False
              IsArray = False
              IsByRef = False
              IsPointer = False
              IsPrimitive = False
              IsCOMObject = False
              HasElementType = False
              IsContextful = False
              IsMarshalByRef = False
              GenericTypeArguments = 
                [
                ]
                
              CustomAttributes = 
                [
                  [System.Management.Automation.CmdletAttribute("Get", "Variable", HelpUri = 
                  "http://go.microsoft.com/fwlink/?LinkID=113336")]
                  [System.Management.Automation.OutputTypeAttribute(typeof(System.Management.Automation.PSVariable))]
                ]
                
            }
          Definition = 
          Get-Variable [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
          [<CommonParameters>]
          
          DefaultParameterSet = 
          OutputType = 
            [
              System.Management.Automation.PSVariable
            ]
            
          Options = ReadOnly
          Name = Get-Variable
          CommandType = Cmdlet
          Source = Microsoft.PowerShell.Utility
          Visibility = Public
          ModuleName = Microsoft.PowerShell.Utility
          Module = 
            class PSModuleInfo
            {
              Name = Microsoft.PowerShell.Utility
              Path = C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShe
              ll.Utility.psd1
              Description = 
              Guid = 1da87e53-152b-403e-98dc-74d7b4d63d59
              Version = 3.1.0.0
              ModuleBase = C:\Windows\System32\WindowsPowerShell\v1.0
              ModuleType = Manifest
              PrivateData = 
              AccessMode = ReadWrite
              ExportedAliases = 
                [
                  [CFS, CFS]
                  [fhx, fhx]
                ]
                
              ExportedCmdlets = 
                [
                  [Add-Member, Add-Member]
                  [Add-Type, Add-Type]
                  [Clear-Variable, Clear-Variable]
                  [Compare-Object, Compare-Object]
                  ...
                ]
                
              ExportedFunctions = 
                [
                  [ConvertFrom-SddlString, ConvertFrom-SddlString]
                  [Format-Hex, Format-Hex]
                  [Get-FileHash, Get-FileHash]
                  [Import-PowerShellDataFile, Import-PowerShellDataFile]
                  ...
                ]
                
              ExportedVariables = 
                [
                ]
                
              NestedModules = 
                [
                  Microsoft.PowerShell.Commands.Utility.dll
                  Microsoft.PowerShell.Utility
                ]
                
            }
          RemotingCapability = PowerShell
          Parameters = 
            [
              [Name, System.Management.Automation.ParameterMetadata]
              [ValueOnly, System.Management.Automation.ParameterMetadata]
              [Include, System.Management.Automation.ParameterMetadata]
              [Exclude, System.Management.Automation.ParameterMetadata]
              ...
            ]
            
          ParameterSets = 
            [
              [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
              [<CommonParameters>]
            ]
            
          HelpUri = http://go.microsoft.com/fwlink/?LinkID=113336
          DLL = C:\windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856
          ad364e35\Microsoft.PowerShell.Commands.Utility.dll
        }
      BoundParameters = 
        [
        ]
        
      UnboundArguments = 
        [
        ]
        
      ScriptLineNumber = 1374
      OffsetInLine = 9
      HistoryId = 572
      ScriptName = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      Line =   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLength = 45 }
      
      PositionMessage = At C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:1374 char:9
      +   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLeng ...
      +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      PSScriptRoot = C:\Users\A469526\Documents\WindowsPowerShell
      PSCommandPath = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      InvocationName = Get-Variable
      PipelineLength = 0
      PipelinePosition = 0
      ExpectingInput = False
      CommandOrigin = Internal
      DisplayScriptPosition = 
    }
  ScriptStackTrace = at Global:prompt, C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1: 
  line 1374
  at <ScriptBlock>, <No file>: line 1
  PipelineIterationInfo = 
    [
      0
      1
    ]
    
  PSMessageDetails = 
}

class ErrorRecord
{
  Exception = 
    class ItemNotFoundException
    {
      ErrorRecord = 
        class ErrorRecord
        {
          Exception = 
            class ParentContainsErrorRecordException
            {
              Message = Cannot find a variable with the name 'MaxPromptLength'.
              Data = 
                [
                ]
                
              InnerException = 
              TargetSite = 
              StackTrace = 
              HelpLink = 
              Source = 
              HResult = -2146233087
            }
          TargetObject = MaxPromptLength
          CategoryInfo = 
            class ErrorCategoryInfo
            {
              Category = ObjectNotFound
              Activity = 
              Reason = ParentContainsErrorRecordException
              TargetName = MaxPromptLength
              TargetType = String
            }
          FullyQualifiedErrorId = VariableNotFound
          ErrorDetails = 
          InvocationInfo = 
          ScriptStackTrace = 
          PipelineIterationInfo = 
            [
            ]
            
          PSMessageDetails = 
        }
      ItemName = MaxPromptLength
      SessionStateCategory = Drive
      WasThrownFromThrowStatement = False
      Message = Cannot find a variable with the name 'MaxPromptLength'.
      Data = 
        [
        ]
        
      InnerException = 
      TargetSite = 
      StackTrace = 
      HelpLink = 
      Source = 
      HResult = -2146233087
    }
  TargetObject = MaxPromptLength
  CategoryInfo = 
    class ErrorCategoryInfo
    {
      Category = ObjectNotFound
      Activity = Get-Variable
      Reason = ItemNotFoundException
      TargetName = MaxPromptLength
      TargetType = String
    }
  FullyQualifiedErrorId = VariableNotFound,Microsoft.PowerShell.Commands.GetVariableCommand
  ErrorDetails = 
  InvocationInfo = 
    class InvocationInfo
    {
      MyCommand = 
        class CmdletInfo
        {
          Verb = Get
          Noun = Variable
          HelpFile = Microsoft.PowerShell.Commands.Utility.dll-Help.xml
          PSSnapIn = 
          Version = 
            class Version
            {
              Major = 3
              Minor = 1
              Build = 0
              Revision = 0
              MajorRevision = 0
              MinorRevision = 0
            }
          ImplementingType = 
            class RuntimeType
            {
              Module = Microsoft.PowerShell.Commands.Utility.dll
              Assembly = Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, 
              PublicKeyToken=31bf3856ad364e35
              TypeHandle = System.RuntimeTypeHandle
              DeclaringMethod = 
              BaseType = Microsoft.PowerShell.Commands.VariableCommandBase
              UnderlyingSystemType = Microsoft.PowerShell.Commands.GetVariableCommand
              FullName = Microsoft.PowerShell.Commands.GetVariableCommand
              AssemblyQualifiedName = Microsoft.PowerShell.Commands.GetVariableCommand, 
              Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
              Namespace = Microsoft.PowerShell.Commands
              GUID = d3e484a2-f842-3705-8e1b-4fb8241908dd
              IsEnum = False
              GenericParameterAttributes = 
              IsSecurityCritical = True
              IsSecuritySafeCritical = False
              IsSecurityTransparent = False
              IsGenericTypeDefinition = False
              IsGenericParameter = False
              GenericParameterPosition = 
              IsGenericType = False
              IsConstructedGenericType = False
              ContainsGenericParameters = False
              StructLayoutAttribute = System.Runtime.InteropServices.StructLayoutAttribute
              Name = GetVariableCommand
              MemberType = TypeInfo
              DeclaringType = 
              ReflectedType = 
              MetadataToken = 33554537
              GenericTypeParameters = 
                [
                ]
                
              DeclaredConstructors = 
                [
                  Void .ctor()
                ]
                
              DeclaredEvents = 
                [
                ]
                
              DeclaredFields = 
                [
                  System.String[] name
                  Boolean valueOnly
                ]
                
              DeclaredMembers = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredMethods = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredNestedTypes = 
                [
                  Microsoft.PowerShell.Commands.GetVariableCommand+<>c
                ]
                
              DeclaredProperties = 
                [
                  System.String[] Name
                  System.Management.Automation.SwitchParameter ValueOnly
                  System.String[] Include
                  System.String[] Exclude
                ]
                
              ImplementedInterfaces = 
                [
                ]
                
              TypeInitializer = 
              IsNested = False
              Attributes = AutoLayout, AnsiClass, Class, Public, BeforeFieldInit
              IsVisible = True
              IsNotPublic = False
              IsPublic = True
              IsNestedPublic = False
              IsNestedPrivate = False
              IsNestedFamily = False
              IsNestedAssembly = False
              IsNestedFamANDAssem = False
              IsNestedFamORAssem = False
              IsAutoLayout = True
              IsLayoutSequential = False
              IsExplicitLayout = False
              IsClass = True
              IsInterface = False
              IsValueType = False
              IsAbstract = False
              IsSealed = False
              IsSpecialName = False
              IsImport = False
              IsSerializable = False
              IsAnsiClass = True
              IsUnicodeClass = False
              IsAutoClass = False
              IsArray = False
              IsByRef = False
              IsPointer = False
              IsPrimitive = False
              IsCOMObject = False
              HasElementType = False
              IsContextful = False
              IsMarshalByRef = False
              GenericTypeArguments = 
                [
                ]
                
              CustomAttributes = 
                [
                  [System.Management.Automation.CmdletAttribute("Get", "Variable", HelpUri = 
                  "http://go.microsoft.com/fwlink/?LinkID=113336")]
                  [System.Management.Automation.OutputTypeAttribute(typeof(System.Management.Automation.PSVariable))]
                ]
                
            }
          Definition = 
          Get-Variable [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
          [<CommonParameters>]
          
          DefaultParameterSet = 
          OutputType = 
            [
              System.Management.Automation.PSVariable
            ]
            
          Options = ReadOnly
          Name = Get-Variable
          CommandType = Cmdlet
          Source = Microsoft.PowerShell.Utility
          Visibility = Public
          ModuleName = Microsoft.PowerShell.Utility
          Module = 
            class PSModuleInfo
            {
              Name = Microsoft.PowerShell.Utility
              Path = C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShe
              ll.Utility.psd1
              Description = 
              Guid = 1da87e53-152b-403e-98dc-74d7b4d63d59
              Version = 3.1.0.0
              ModuleBase = C:\Windows\System32\WindowsPowerShell\v1.0
              ModuleType = Manifest
              PrivateData = 
              AccessMode = ReadWrite
              ExportedAliases = 
                [
                  [CFS, CFS]
                  [fhx, fhx]
                ]
                
              ExportedCmdlets = 
                [
                  [Add-Member, Add-Member]
                  [Add-Type, Add-Type]
                  [Clear-Variable, Clear-Variable]
                  [Compare-Object, Compare-Object]
                  ...
                ]
                
              ExportedFunctions = 
                [
                  [ConvertFrom-SddlString, ConvertFrom-SddlString]
                  [Format-Hex, Format-Hex]
                  [Get-FileHash, Get-FileHash]
                  [Import-PowerShellDataFile, Import-PowerShellDataFile]
                  ...
                ]
                
              ExportedVariables = 
                [
                ]
                
              NestedModules = 
                [
                  Microsoft.PowerShell.Commands.Utility.dll
                  Microsoft.PowerShell.Utility
                ]
                
            }
          RemotingCapability = PowerShell
          Parameters = 
            [
              [Name, System.Management.Automation.ParameterMetadata]
              [ValueOnly, System.Management.Automation.ParameterMetadata]
              [Include, System.Management.Automation.ParameterMetadata]
              [Exclude, System.Management.Automation.ParameterMetadata]
              ...
            ]
            
          ParameterSets = 
            [
              [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
              [<CommonParameters>]
            ]
            
          HelpUri = http://go.microsoft.com/fwlink/?LinkID=113336
          DLL = C:\windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856
          ad364e35\Microsoft.PowerShell.Commands.Utility.dll
        }
      BoundParameters = 
        [
        ]
        
      UnboundArguments = 
        [
        ]
        
      ScriptLineNumber = 1374
      OffsetInLine = 9
      HistoryId = 571
      ScriptName = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      Line =   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLength = 45 }
      
      PositionMessage = At C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:1374 char:9
      +   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLeng ...
      +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      PSScriptRoot = C:\Users\A469526\Documents\WindowsPowerShell
      PSCommandPath = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      InvocationName = Get-Variable
      PipelineLength = 0
      PipelinePosition = 0
      ExpectingInput = False
      CommandOrigin = Internal
      DisplayScriptPosition = 
    }
  ScriptStackTrace = at Global:prompt, C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1: 
  line 1374
  at <ScriptBlock>, <No file>: line 1
  PipelineIterationInfo = 
    [
      0
      1
    ]
    
  PSMessageDetails = 
}

class ErrorRecord
{
  Exception = 
    class ItemNotFoundException
    {
      ErrorRecord = 
        class ErrorRecord
        {
          Exception = 
            class ParentContainsErrorRecordException
            {
              Message = Cannot find a variable with the name 'MaxPromptLength'.
              Data = 
                [
                ]
                
              InnerException = 
              TargetSite = 
              StackTrace = 
              HelpLink = 
              Source = 
              HResult = -2146233087
            }
          TargetObject = MaxPromptLength
          CategoryInfo = 
            class ErrorCategoryInfo
            {
              Category = ObjectNotFound
              Activity = 
              Reason = ParentContainsErrorRecordException
              TargetName = MaxPromptLength
              TargetType = String
            }
          FullyQualifiedErrorId = VariableNotFound
          ErrorDetails = 
          InvocationInfo = 
          ScriptStackTrace = 
          PipelineIterationInfo = 
            [
            ]
            
          PSMessageDetails = 
        }
      ItemName = MaxPromptLength
      SessionStateCategory = Drive
      WasThrownFromThrowStatement = False
      Message = Cannot find a variable with the name 'MaxPromptLength'.
      Data = 
        [
        ]
        
      InnerException = 
      TargetSite = 
      StackTrace = 
      HelpLink = 
      Source = 
      HResult = -2146233087
    }
  TargetObject = MaxPromptLength
  CategoryInfo = 
    class ErrorCategoryInfo
    {
      Category = ObjectNotFound
      Activity = Get-Variable
      Reason = ItemNotFoundException
      TargetName = MaxPromptLength
      TargetType = String
    }
  FullyQualifiedErrorId = VariableNotFound,Microsoft.PowerShell.Commands.GetVariableCommand
  ErrorDetails = 
  InvocationInfo = 
    class InvocationInfo
    {
      MyCommand = 
        class CmdletInfo
        {
          Verb = Get
          Noun = Variable
          HelpFile = Microsoft.PowerShell.Commands.Utility.dll-Help.xml
          PSSnapIn = 
          Version = 
            class Version
            {
              Major = 3
              Minor = 1
              Build = 0
              Revision = 0
              MajorRevision = 0
              MinorRevision = 0
            }
          ImplementingType = 
            class RuntimeType
            {
              Module = Microsoft.PowerShell.Commands.Utility.dll
              Assembly = Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, 
              PublicKeyToken=31bf3856ad364e35
              TypeHandle = System.RuntimeTypeHandle
              DeclaringMethod = 
              BaseType = Microsoft.PowerShell.Commands.VariableCommandBase
              UnderlyingSystemType = Microsoft.PowerShell.Commands.GetVariableCommand
              FullName = Microsoft.PowerShell.Commands.GetVariableCommand
              AssemblyQualifiedName = Microsoft.PowerShell.Commands.GetVariableCommand, 
              Microsoft.PowerShell.Commands.Utility, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
              Namespace = Microsoft.PowerShell.Commands
              GUID = d3e484a2-f842-3705-8e1b-4fb8241908dd
              IsEnum = False
              GenericParameterAttributes = 
              IsSecurityCritical = True
              IsSecuritySafeCritical = False
              IsSecurityTransparent = False
              IsGenericTypeDefinition = False
              IsGenericParameter = False
              GenericParameterPosition = 
              IsGenericType = False
              IsConstructedGenericType = False
              ContainsGenericParameters = False
              StructLayoutAttribute = System.Runtime.InteropServices.StructLayoutAttribute
              Name = GetVariableCommand
              MemberType = TypeInfo
              DeclaringType = 
              ReflectedType = 
              MetadataToken = 33554537
              GenericTypeParameters = 
                [
                ]
                
              DeclaredConstructors = 
                [
                  Void .ctor()
                ]
                
              DeclaredEvents = 
                [
                ]
                
              DeclaredFields = 
                [
                  System.String[] name
                  Boolean valueOnly
                ]
                
              DeclaredMembers = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredMethods = 
                [
                  Void set_Name(System.String[])
                  System.String[] get_Name()
                  System.Management.Automation.SwitchParameter get_ValueOnly()
                  Void set_ValueOnly(System.Management.Automation.SwitchParameter)
                  ...
                ]
                
              DeclaredNestedTypes = 
                [
                  Microsoft.PowerShell.Commands.GetVariableCommand+<>c
                ]
                
              DeclaredProperties = 
                [
                  System.String[] Name
                  System.Management.Automation.SwitchParameter ValueOnly
                  System.String[] Include
                  System.String[] Exclude
                ]
                
              ImplementedInterfaces = 
                [
                ]
                
              TypeInitializer = 
              IsNested = False
              Attributes = AutoLayout, AnsiClass, Class, Public, BeforeFieldInit
              IsVisible = True
              IsNotPublic = False
              IsPublic = True
              IsNestedPublic = False
              IsNestedPrivate = False
              IsNestedFamily = False
              IsNestedAssembly = False
              IsNestedFamANDAssem = False
              IsNestedFamORAssem = False
              IsAutoLayout = True
              IsLayoutSequential = False
              IsExplicitLayout = False
              IsClass = True
              IsInterface = False
              IsValueType = False
              IsAbstract = False
              IsSealed = False
              IsSpecialName = False
              IsImport = False
              IsSerializable = False
              IsAnsiClass = True
              IsUnicodeClass = False
              IsAutoClass = False
              IsArray = False
              IsByRef = False
              IsPointer = False
              IsPrimitive = False
              IsCOMObject = False
              HasElementType = False
              IsContextful = False
              IsMarshalByRef = False
              GenericTypeArguments = 
                [
                ]
                
              CustomAttributes = 
                [
                  [System.Management.Automation.CmdletAttribute("Get", "Variable", HelpUri = 
                  "http://go.microsoft.com/fwlink/?LinkID=113336")]
                  [System.Management.Automation.OutputTypeAttribute(typeof(System.Management.Automation.PSVariable))]
                ]
                
            }
          Definition = 
          Get-Variable [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
          [<CommonParameters>]
          
          DefaultParameterSet = 
          OutputType = 
            [
              System.Management.Automation.PSVariable
            ]
            
          Options = ReadOnly
          Name = Get-Variable
          CommandType = Cmdlet
          Source = Microsoft.PowerShell.Utility
          Visibility = Public
          ModuleName = Microsoft.PowerShell.Utility
          Module = 
            class PSModuleInfo
            {
              Name = Microsoft.PowerShell.Utility
              Path = C:\windows\system32\WindowsPowerShell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShe
              ll.Utility.psd1
              Description = 
              Guid = 1da87e53-152b-403e-98dc-74d7b4d63d59
              Version = 3.1.0.0
              ModuleBase = C:\Windows\System32\WindowsPowerShell\v1.0
              ModuleType = Manifest
              PrivateData = 
              AccessMode = ReadWrite
              ExportedAliases = 
                [
                  [CFS, CFS]
                  [fhx, fhx]
                ]
                
              ExportedCmdlets = 
                [
                  [Add-Member, Add-Member]
                  [Add-Type, Add-Type]
                  [Clear-Variable, Clear-Variable]
                  [Compare-Object, Compare-Object]
                  ...
                ]
                
              ExportedFunctions = 
                [
                  [ConvertFrom-SddlString, ConvertFrom-SddlString]
                  [Format-Hex, Format-Hex]
                  [Get-FileHash, Get-FileHash]
                  [Import-PowerShellDataFile, Import-PowerShellDataFile]
                  ...
                ]
                
              ExportedVariables = 
                [
                ]
                
              NestedModules = 
                [
                  Microsoft.PowerShell.Commands.Utility.dll
                  Microsoft.PowerShell.Utility
                ]
                
            }
          RemotingCapability = PowerShell
          Parameters = 
            [
              [Name, System.Management.Automation.ParameterMetadata]
              [ValueOnly, System.Management.Automation.ParameterMetadata]
              [Include, System.Management.Automation.ParameterMetadata]
              [Exclude, System.Management.Automation.ParameterMetadata]
              ...
            ]
            
          ParameterSets = 
            [
              [[-Name] <string[]>] [-ValueOnly] [-Include <string[]>] [-Exclude <string[]>] [-Scope <string>] 
              [<CommonParameters>]
            ]
            
          HelpUri = http://go.microsoft.com/fwlink/?LinkID=113336
          DLL = C:\windows\Microsoft.Net\assembly\GAC_MSIL\Microsoft.PowerShell.Commands.Utility\v4.0_3.0.0.0__31bf3856
          ad364e35\Microsoft.PowerShell.Commands.Utility.dll
        }
      BoundParameters = 
        [
        ]
        
      UnboundArguments = 
        [
        ]
        
      ScriptLineNumber = 1374
      OffsetInLine = 9
      HistoryId = 570
      ScriptName = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      Line =   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLength = 45 }
      
      PositionMessage = At C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1:1374 char:9
      +   If (!(Get-Variable MaxPromptLength -ea 0 2>$Null)) { $MaxPromptLeng ...
      +         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      PSScriptRoot = C:\Users\A469526\Documents\WindowsPowerShell
      PSCommandPath = C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
      InvocationName = Get-Variable
      PipelineLength = 0
      PipelinePosition = 0
      ExpectingInput = False
      CommandOrigin = Internal
      DisplayScriptPosition = 
    }
  ScriptStackTrace = at Global:prompt, C:\Users\A469526\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1: 
  line 1374
  at <ScriptBlock>, <No file>: line 1
  PipelineIterationInfo = 
    [
      0
      1
    ]
    
  PSMessageDetails = 
}




#>
