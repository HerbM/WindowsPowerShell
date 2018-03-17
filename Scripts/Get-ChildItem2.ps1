<#
.SYNOPSIS
    Gets the files and folders in a file system drive beyond the 256 character limitation
.DESCRIPTION
    Gets the files and folders in a file system drive beyond the 256 character limitation
.PARAMETER Path
    Path to a folder/file
.PARAMETER Filter
    Filter object by name. Accepts wildcard (*)
.PARAMETER Recurse
    Perform a recursive scan
.PARAMETER Depth
    Limit the depth of a recursive scan
.PARAMETER Directory
    Only show directories
.PARAMETER File
    Only show files
.PARAMETER SimpleOutput 
  Output a simple string LastAccessTime,Length,FullName
.PARAMETER OutFileName
  Output to file give by OutFileName parameter 
.PARAMETER CSVOutput 
  Output CSV format, to filename by require OutFileName parameter
.PARAMETER LongOnly 
  Output only long names: total length > 260 or directory length > 248
.PARAMETER GCCount
 Default 5000 items between calls to the .NET Garbage Collector (GC)
 Set this to 0 to disable explicit garbage collection.   
.NOTES
    Name: Get-ChildItem2
    Author: Boe Prox (original and primary author)
    Version History:
      1.42//Herb Martin <2018-03-05>
          - Add simple GC, option to only output long files/paths   
      1.41//Herb Martin <2018-02-22>
          - Simple changes for output control added to Boe's excellent function
      1.4 //Boe Prox <21 OCt 2015>
          - Bug fixes in output
          - Auto conversion of path to UNC for bypassing 260 character limit w/o user input
      1.2 //Boe Prox <20 Oct 2015>
          - Added additional parameters (File, Directory and Filter)
          - Made output mirror Get-ChildItem
          - Added Mode property
      1.0 //Boe Prox
          - Initial version
.OUTPUT
    System.Io.DirectoryInfo
    System.Io.FileInfo
    or 
    LastAccessTime,Length,FullName
      Simple PSCustomOBjects, when -SimpleOutput switch is specified then out only 
.EXAMPLE
  \Scripts\Get-ChildItem2.ps1 -path $Home -outf t2.csv -long -rec -simple
.EXAMPLE
    Get-ChildItem2 -Recurse -Depth 3 -Directory

    Description
    -----------
    Performs a scan from the current directory and recursively displays all
    directories down to 3 folder levels.
#>
[CmdletBinding()]
param(
  [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
      [Alias('FullName','PSPath')]         [string]$Path = $PWD.ToString(),
  [parameter()]                            [string]$Filter='*',  
  [parameter()]                            [switch]$Recurse,
  [parameter()]                               [int]$Depth,
  [parameter()]                            [switch]$Directory,
  [parameter()]                            [switch]$File,
  [Alias('OutputFileName')]                [string]$OutFileName = '',
                                            [Int32]$MaxLeafPath  = 260,
                                            [Int32]$MaxParentPath= 248,
  [Alias('StringOutput')]                  [switch]$SimpleOutput, 
                                           [switch]$CSVOutput, 
  [Alias('OutputOnlyLong','OnlyLongNames')][switch]$LongOnly, 
                                            [Int32]$GCCount=5000                                
)


Function Get-ChildItem2 {
<#
  .SYNOPSIS
      Gets the files and folders in a file system drive beyond the 256 character limitation
  .DESCRIPTION
      Gets the files and folders in a file system drive beyond the 256 character limitation
  .PARAMETER Path
      Path to a folder/file
  .PARAMETER Filter
      Filter object by name. Accepts wildcard (*)
  .PARAMETER Recurse
      Perform a recursive scan
  .PARAMETER Depth
      Limit the depth of a recursive scan
  .PARAMETER Directory
      Only show directories
  .PARAMETER File
      Only show files
  .PARAMETER SimpleOutput 
    Output a simple string LastAccessTime,Length,FullName
  .PARAMETER OutFileName
    Output to file give by OutFileName parameter 
  .PARAMETER CSVOutput 
    Output CSV format, to filename by require OutFileName parameter
  .PARAMETER LongOnly 
    Output only long names: total length > 260 or directory length > 248
  .PARAMETER GCCount
   Default 5000 items between calls to the .NET Garbage Collector (GC)
   Set this to 0 to disable explicit garbage collection.   
  .NOTES
      Name: Get-ChildItem2
      Author: Boe Prox (original and primary author)
      Version History:
        1.42//Herb Martin <2018-03-05>
            - Add simple GC, option to only output long files/paths   
        1.41//Herb Martin <2018-02-22>
            - Simple changes for output control added to Boe's excellent function
        1.4 //Boe Prox <21 OCt 2015>
            - Bug fixes in output
            - Auto conversion of path to UNC for bypassing 260 character limit w/o user input
        1.2 //Boe Prox <20 Oct 2015>
            - Added additional parameters (File, Directory and Filter)
            - Made output mirror Get-ChildItem
            - Added Mode property
        1.0 //Boe Prox
            - Initial version
  .OUTPUT
      System.Io.DirectoryInfo
      System.Io.FileInfo
      or 
      LastAccessTime,Length,FullName
        Simple PSCustomOBjects, when -SimpleOutput switch is specified then out only 

  .EXAMPLE
    \Scripts\Get-ChildItem2.ps1 -path $Home -outf t2.csv -long -rec -simple
  .EXAMPLE
      Get-ChildItem2 -Recurse -Depth 3 -Directory

      Description
      -----------
      Performs a scan from the current directory and recursively displays all
      directories down to 3 folder levels.
  #>
  [OutputType('System.Io.DirectoryInfo','System.Io.FileInfo','PSCustomOBject')]
  [cmdletbinding(DefaultParameterSetName = '__DefaultParameterSet')]
  Param(
    [parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
      [Alias('FullName','PSPath')]         [string]$Path = $PWD.ToString(),
    [parameter()]                          [string]$Filter,
    [parameter()]                          [switch]$Recurse,
    [parameter()]                             [int]$Depth,
    [parameter()]                          [switch]$Directory,
    [parameter()]                          [switch]$File,
    [Alias('OutputFileName')]              [string]$OutFileName  =  '',
                                            [Int32]$MaxLeafPath  = 260,
                                            [Int32]$MaxParentPath= 248,
  [Alias('StringOutput')]                  [switch]$SimpleOutput, 
                                           [switch]$CSVOutput, 
  [Alias('OutputOnlyLong','OnlyLongNames')][switch]$LongOnly, 
                                            [Int32]$GCCount=5000                                
  )
  Begin {
    Try{
      if ($OutFileName) { 
      if (!($OutParent = Split-Path $OutFileName)) { 
        $OutFileName = Join-Path . $OutFileName
      }
      $OutParent = Resolve-Path (Split-Path $OutFileName) -ea 0
      if ($OutFile = Test-Path $OutParent) {
        $OutChild  = (Split-Path $OutFileName -leaf)
        $OutFileName = Join-Path $OutFileParent $OutFileName
        $OutFileName = (Resolve-Path $OutFileName -ea 0).ToString()
        write-verbose "OutFileName: $OutFileName"
      } else {
        write-error "OutFileName parent directory NOT_FOUND: $OutParent"
        $OutFileName = ''
        $OutFile = $CSVOutput = $False
      }
      } 
      If (!$OutFileName) { $OutFile = $CSVOutput = $False }
      write-verbose "ToFile: $OutFile Simple: $SimpleOutput CSV: $CSVOutput Path: $OutFileName"
      [void][PoshFile]
    } Catch {
      #region Module Builder
      $Domain = [AppDomain]::CurrentDomain
      $DynAssembly = New-Object System.Reflection.AssemblyName('SomeAssembly')
      $AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [System.Reflection.Emit.AssemblyBuilderAccess]::Run) # Only run in memory
      $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('SomeModule', $False)
      #endregion Module Builder
 
      #region Structs      
      $Attributes = 'AutoLayout,AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
      #region WIN32_FIND_DATA STRUCT
      $UNICODEAttributes = 'AutoLayout,AnsiClass, UnicodeClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
      $STRUCT_TypeBuilder = $ModuleBuilder.DefineType('WIN32_FIND_DATA', $UNICODEAttributes, [System.ValueType], [System.Reflection.Emit.PackingSize]::Size4)
      [void]$STRUCT_TypeBuilder.DefineField('dwFileAttributes', [int32], 'Public')
      [void]$STRUCT_TypeBuilder.DefineField('ftCreationTime',   [long],  'Public')
      [void]$STRUCT_TypeBuilder.DefineField('ftLastAccessTime', [long],  'Public')
      [void]$STRUCT_TypeBuilder.DefineField('ftLastWriteTime',  [long],  'Public')
      [void]$STRUCT_TypeBuilder.DefineField('nFileSizeHigh',    [int32], 'Public')
      [void]$STRUCT_TypeBuilder.DefineField('nFileSizeLow',     [int32], 'Public')
      [void]$STRUCT_TypeBuilder.DefineField('dwReserved0',      [int32], 'Public')
      [void]$STRUCT_TypeBuilder.DefineField('dwReserved1',      [int32], 'Public')
  
      $ctor = [System.Runtime.InteropServices.MarshalAsAttribute].GetConstructor(@([System.Runtime.InteropServices.UnmanagedType]))
      $CustomAttribute = [System.Runtime.InteropServices.UnmanagedType]::ByValTStr
      $SizeConstField = [System.Runtime.InteropServices.MarshalAsAttribute].GetField('SizeConst')
      $CustomAttributeBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder -ArgumentList $ctor, $CustomAttribute, $SizeConstField, @(260)
      $cFileNameField = $STRUCT_TypeBuilder.DefineField('cFileName', [string], 'Public')
      $cFileNameField.SetCustomAttribute($CustomAttributeBuilder)
 
      $CustomAttributeBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder -ArgumentList $ctor, $CustomAttribute, $SizeConstField, @(14)
      $cAlternateFileName = $STRUCT_TypeBuilder.DefineField('cAlternateFileName', [string], 'Public')
      $cAlternateFileName.SetCustomAttribute($CustomAttributeBuilder)
      [void]$STRUCT_TypeBuilder.CreateType()
      #endregion WIN32_FIND_DATA STRUCT
      #endregion Structs
 
      #region Initialize Type Builder
      $TypeBuilder = $ModuleBuilder.DefineType('PoshFile', 'Public, Class')
      #endregion Initialize Type Builder
 
      #region Methods
      #region FindFirstFile METHOD
      $PInvokeMethod = $TypeBuilder.DefineMethod(
        'FindFirstFile', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [IntPtr],  #Method Return Type
        [Type[]] @(
          [string],
          [WIN32_FIND_DATA].MakeByRefType()
        ) #Method Parameters
      )
      $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
      $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
        [Runtime.InteropServices.DllImportAttribute].GetField('CharSet')
      )
 
      $FieldValueArray = [Object[]] @(
        'FindFirstFile', #CASE SENSITIVE!!
        $True,
        $False,
        [System.Runtime.InteropServices.CharSet]::Unicode
      )
 
      $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
      )
 
      $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
      #endregion FindFirstFile METHOD
 
      #region FindNextFile METHOD
      $PInvokeMethod = $TypeBuilder.DefineMethod(
        'FindNextFile', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool], #Method Return Type
        [Type[]] @(
          [IntPtr],
          [WIN32_FIND_DATA].MakeByRefType()
        ) #Method Parameters
      )
      $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
      $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
        [Runtime.InteropServices.DllImportAttribute].GetField('CharSet')
      )
 
      $FieldValueArray = [Object[]] @(
        'FindNextFile', #CASE SENSITIVE!!
        $True,
        $False,
        [System.Runtime.InteropServices.CharSet]::Unicode
      )
 
      $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
      )
 
      $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
      #endregion FindNextFile METHOD

      #region FindClose METHOD
      $PInvokeMethod = $TypeBuilder.DefineMethod(
        'FindClose', #Method Name
        [Reflection.MethodAttributes] 'PrivateScope, Public, Static, HideBySig, PinvokeImpl', #Method Attributes
        [bool], #Method Return Type
        [Type[]] @(
          [IntPtr]
        ) #Method Parameters
      )
      $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
      $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField('EntryPoint'),
        [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        [Runtime.InteropServices.DllImportAttribute].GetField('ExactSpelling')
      )
 
      $FieldValueArray = [Object[]] @(
        'FindClose', #CASE SENSITIVE!!
        $True,
        $True
      )
 
      $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
        $DllImportConstructor,
        @('kernel32.dll'),
        $FieldArray,
        $FieldValueArray
      )
 
      $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
      #endregion FindClose METHOD
      #endregion Methods
 
      #region Create Type
      [void]$TypeBuilder.CreateType()
      #endregion Create Type  
    }

    #region Inititalize Data
    $Found = $True  
    $findData = New-Object WIN32_FIND_DATA 
    #endregion Inititalize Data
  }
  Process {
    If ($Path -notmatch '^[a-z]:|^\\\\') {
      $Path = Convert-Path $Path
    }
    If ($Path.Endswith('\')) {
      $SearchPath = "$($Path)*"
    } ElseIf ($Path.EndsWith(':')) {
      $SearchPath = "$($Path)\*"
      $Path = "$($Path)\"
    } ElseIf ($Path.Endswith('*')) {
      $SearchPath = $Path
    } Else {
      $SearchPath = "$($Path)\*"
      $path = "$($Path)\"
    }
    If (-NOT $Path.StartsWith('\\')) {
      $Path = "\\?\$($Path)"
      $SearchPath = "\\?\$($SearchPath)"
    }
    If ($PSBoundParameters.ContainsKey('Recurse') -AND (-NOT $PSBoundParameters.ContainsKey('Depth'))) {
      $PSBoundParameters.Depth = [int]::MaxValue
      $Depth = [int]::MaxValue
    }
    If (-NOT $PSBoundParameters.ContainsKey('Recurse') -AND ($PSBoundParameters.ContainsKey('Depth'))) {
      Throw "Cannot set Depth without Recurse parameter!"    #### :HM: Fix this to figure it out
    }
    Write-Verbose "Depth: $($Script:Count) Search: $($SearchPath)"
    $Handle = [poshfile]::FindFirstFile("$SearchPath",[ref]$findData)
    If ($Handle -ne -1) {
      While ($Found) {
        If ($findData.cFileName -notmatch '^(\.){1,2}$') {
          $IsDirectory =  [bool]($findData.dwFileAttributes -BAND 16)  
          $FullName = "$($Path)$($findData.cFileName)"
          $Mode = New-Object System.Text.StringBuilder          
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::Directory) {
                   [void]$Mode.Append('d')
          } Else { [void]$Mode.Append('-') }
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::Archive) {
                   [void]$Mode.Append('a')
          } Else { [void]$Mode.Append('-') }
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::ReadOnly) {
                   [void]$Mode.Append('r')
          } Else { [void]$Mode.Append('-') }
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::Hidden) {
                   [void]$Mode.Append('h')
          } Else { [void]$Mode.Append('-') }
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::System) {
                   [void]$Mode.Append('s')
          } Else { [void]$Mode.Append('-') }
          If ($findData.dwFileAttributes -BAND [System.IO.FileAttributes]::ReparsePoint) {
                   [void]$Mode.Append('l') 
          } Else { [void]$Mode.Append('-') }
          $Fullname = ([string]$FullName).replace('\\?\','')
          $Object = New-Object PSObject -Property @{
            Name           = [string]$findData.cFileName
            FullName       = $Fullname
            Length         = $Null             
            Attributes     = [System.IO.FileAttributes]$findData.dwFileAttributes
            LastWriteTime  = [datetime]::FromFileTime($findData.ftLastWriteTime)
            LastAccessTime = [datetime]::FromFileTime($findData.ftLastAccessTime)
            CreationTime   = [datetime]::FromFileTime($findData.ftCreationTime)
            PSIsContainer  = [bool]$IsDirectory
            Mode           = $Mode.ToString()
          }  
          If ($Object.PSIsContainer) {
            $Object.pstypenames.insert(0,'System.Io.DirectoryInfo')
          } Else {
            $Object.Length = [int64]("0x{0:x}" -f $findData.nFileSizeLow)
            $Object.pstypenames.insert(0,'System.Io.FileInfo')
          }
          If ($PSBoundParameters.ContainsKey('Directory') -AND $Object.PSIsContainer) {              
            $ToOutPut = $Object
          } ElseIf ($PSBoundParameters.ContainsKey('File') -AND (-NOT $Object.PSIsContainer)) {
            $ToOutPut = $Object
          }
          If (-Not ($PSBoundParameters.ContainsKey('Directory') -OR $PSBoundParameters.ContainsKey('File'))) {
            $ToOutPut = $Object
          } 
          If ($PSBoundParameters.ContainsKey('Filter')) {
            If (-NOT ($ToOutPut.Name -like $Filter)) {
              $ToOutPut = $Null
            }
          }
          
# Hey, I found a problem in the PS, the SimpleOutput formatting referenced the wrong object.
# The line had 
# $ToOutPut = "$($ ToOutPut.LastAccessTime -f 's'),$($ ToOutPut.Length),$($ ToOutPut.FullName)"
# And I changed to
# $ToOutPut = "$($Object.LastAccessTime -f 's'),$($Object.Length),$($Object.FullName)"
# 
# I like the –SimpleOutput because the date has the mm and dd padded with leading zeros.  
# I would like to also format the file size to a fixed number of characters to make it easier for BF relevance to parse.  
# I am researching and learning a bit.
          
          
          If ($ToOutPut -and $LongOnly) {
            $fullLength = $Object.Fullname.Length
            $nameLength = $Object.Name.Length
            $dirLength  = $fullLength - $nameLength
            #write-verbose "Total length: $FullLength DirLength: $dirLength $($Object.Name)"
            If ($fullLength -le $MaxLeafPath -or $dirLength -le $MaxParentPath) {
              $ToOutPut = $Null
            }
          }
          If ($ToOutPut) {
            [void]$Script:OutputCount++
            if ($SimpleOutput) {
              $ToOutPut = "$($ToOutPut.LastAccessTime -f 's'),$($ToOutPut.Length),$($ToOutPut.FullName)"
            } elseif ( $CSVOutput ) {
              $ToOutPut =  $ToOutPut | ConvertTo-CSV -notypeInformation              
            }
            if ($OutFile) { 
              $ToOutPut | out-file $OutFileName -append
            } else {
              $ToOutPut
            }
            $ToOutPut = $Null
          }
          If ($Recurse -AND $IsDirectory -AND ($PSBoundParameters.ContainsKey('Depth')) -AND ([int]$Script:Count -lt $Depth)) {             
            [void]$Script:Count++
            Write-Verbose "Recurse to $($Script:Count): $($Script:OutputCount) of $($Script:IOInfoCount)"
            $PSBoundParameters.Path = $FullName
            Get-ChildItem2 @PSBoundParameters                          #Dive deeper
            [void]$Script:Count--
          }
        }
        $Output = $Null
        if ($GCCount -and !(++$Script:IOInfoCount % $GCCount)) { 
          Write-Warning "$(get-date -f 't') GC: $($Script:OutputCount) Total items: $($Script:IOInfoCount)"
          [GC]::Collect() 
        }
        $Found = [poshfile]::FindNextFile($Handle,[ref]$findData)
      }
      [void][PoshFile]::FindClose($Handle)
    }
  }
  End { }
} 

Set-Alias GCI2 Get-ChildItem2
if ($LoadOnly) {
  write-warning "Function loaded, no action taken."
} else {
  $Script:OutputCount = $Script:IOInfoCount = 0
  Get-ChildItem2 @PSBoundParameters 
  Write-Warning "Output: $($Script:OutputCount) Total items: $($Script:IOInfoCount)"
}   


<#
63 vscode paths are too long.
11 vscode and 52 vscode\insiders

(gc .\LongNames.csv) |  %   { $n= $_.length; ($_ -split ',')[2] } | ? { $_ -match '^((.+?\\){1,4})'} | % { "$n $($Matches[1])" }  

Junk Notes from testing:

  #$Folder="z:"
  #$dirs=Get-ChildItem2 $folder -Recurse -directory  
  #$dirs | Foreach-object {
  #    $_.FullName

  #gc .\dirstest.csv |
  # ForEach-Object { 
   #   Get-ChildItem2 $_ -Recurse |where {!$_.PsIsContainer} | Select-Object -Property LastAccessTime, Length, FullName } | Export-CSV Test.csv -NoTypeInformation
      Get-ChildItem2 @PSBoundParameters 
      #| where {!$_.PsIsContainer} | # Select-Object -Property LastAccessTime, Length, FullName } | 
      #  ForEach-Object {"$($_.LastAccessTime),$($_.Length),$($_.FullName)"} | Export-csv c:\users\brittonv\Documents\test222.csv -Append -NoTypeInformation
   #  }
      # Format-Table -Property @{n='Last Access Time';e={$_.LastAccessTime}}, @{n='Length';e={$_.Length}}, FullName -AutoSize } 
      #| Out-String -width 4096 | Out-file -append working.txt
      #| export-csv Userfiles.csv -NoTypeInformation 

#>
