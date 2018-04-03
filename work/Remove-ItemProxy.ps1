# Begin of ProxyCommand for command: remove-item
Function remove-item {
<#
.SYNOPSIS
	Deletes files and folders.
.EXAMPLE
	C:\PS>Get-Item C:\Test\Copy-Script.ps1 -Stream Zone.Identifier
	FileName: \\C:\Test\Copy-Script.ps1
	Stream           Length
	------           ------
	Zone.Identifier        26
	C:\PS>Remove-Item C:\Test\Copy-Script.ps1 -Stream Zone.Identifier
	C:\PS>Get-Item C:\Test\Copy-Script.ps1 -Stream Zone.Identifier
	get-item : Could not open alternate data stream 'Zone.Identifier' of file 'C:\Test\Copy-Script.ps1'.
	At line:1 char:1
	+ get-item 'C:\Test\Copy-Script.ps1' -Stream Zone.Identifier
	+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	+ CategoryInfo      : ObjectNotFound: (C:\Test\Copy-Script.ps1:String) [Get-Item], FileNotFoundE
	xception
	+ FullyQualifiedErrorId : AlternateDataStreamNotFound,Microsoft.PowerShell.Commands.GetItemCommand
	C:\PS>Get-Item C:\Test\Copy-Script.ps1
	Directory: C:\Test
	Mode        LastWriteTime   Length Name
	----        -------------   ------ ----
	-a---      8/4/2011  11:15 AM     9436 Copy-Script.ps1
	Description
	-----------
	This example shows how to use the Stream dynamic parameter of the Remove-Item cmdlet to delete an alternate data stream. The stream parameter is introduced in Windows PowerShell 3.0.
	The first command uses the Stream dynamic parameter of the Get-Item cmdlet to get the Zone.Identifier stream of the Copy-Script.ps1 file.
	The second command uses the Stream dynamic parameter of the Remove-Item cmdlet to remove the Zone.Identifier stream of the file.
	The third command uses the Stream dynamic parameter of the Get-Item cmdlet to verify that the Zone.Identifier stream is deleted.
	The fourth command Get-Item cmdlet without the Stream parameter to verify that the file is not deleted.
.EXAMPLE
	C:\PS>Remove-Item C:\Test\*.*
	Description
	-----------
	This command deletes all of the files with names that include a dot (.) from the C:\Test directory. Because the command specifies a dot, the command does not delete directories or files with no file name extension.
.EXAMPLE
	C:\PS>Remove-Item * -Include *.doc -Exclude *1*
	Description
	-----------
	This command deletes from the current directory all files with a .doc file name extension and a name that does not include "1". It uses the wildcard character (*) to specify the contents of the current directory. It uses the Include and Exclude parameters to specify the files to delete.
.EXAMPLE
	C:\PS>Remove-Item -Path C:\Test\hidden-RO-file.txt -Force
	Description
	-----------
	This command deletes a file that is both hidden and read-only. It uses the Path parameter to specify the file. It uses the Force parameter to give permission to delete it. Without Force, you cannot delete read-only or hidden files.
.EXAMPLE
	C:\PS>Get-ChildItem * -Include *.csv -Recurse | Remove-Item
	Description
	-----------
	This command deletes all of the CSV files in the current directory and all subdirectories recursively.
	Because the Recurse parameter in this cmdlet is faulty, the command uses the Get-Childitem cmdlet to get the desired files, and it uses the pipeline operator to pass them to the Remove-Item cmdlet.
	In the Get-ChildItem command, the Path parameter has a value of *, which represents the contents of the current directory. It uses the Include parameter to specify the CSV file type, and it uses the Recurse parameter to make the retrieval recursive.
	If you try to specify the file type in the path, such as "-path *.csv", the cmdlet interprets the subject of the search to be a file that has no child items, and Recurse fails.
.INPUTS
.OUTPUTS
.LINK
	http://technet.microsoft.com/library/jj628241(v=wps.630).aspx
.LINK
	Online version:
.LINK
	Remove-Item (generic); http://go.microsoft.com/fwlink/?LinkID=113373
.LINK
	FileSystem Provider
.LINK
	Clear-Content
.LINK
	Get-Content
.LINK
	Get-ChildItem
.LINK
	Get-Content
.LINK
	Get-Item
.LINK
	Remove-Item
.LINK
	Set-Content
.LINK
	Test-Path
#>
	[CmdletBinding(DefaultParameterSetName='Path', SupportsShouldProcess=$true, ConfirmImpact='Medium', SupportsTransactions=$true)]
 	param(
 	  [Parameter(ParameterSetName='Path', Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
 	  [string[]]${Path},
 	  [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, 
       ValueFromPipelineByPropertyName=$true)]
       [Alias('PSPath')][string[]]${LiteralPath},
 	  [string]${Filter},
 	  [string[]]${Include},
 	  [string[]]${Exclude},
 	  [switch]${Recurse},
 	  [switch]${Force},
 	  [Parameter(ValueFromPipelineByPropertyName=$true)]
    [pscredential][System.Management.Automation.CredentialAttribute()]${Credential}
  )
 	dynamicparam {
 	  try {
 	    $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Remove-Item', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
 	    $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
 	    if ($dynamicParams.Length -gt 0) {
 	      $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
 	      foreach ($param in $dynamicParams) {
 	        $param = $param.Value
 	        if(-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name)) {
 	          $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, 
              $param.ParameterType, $param.Attributes)
 	          $paramDictionary.Add($param.Name, $dynParam)
 	        }
 	      }
 	      return $paramDictionary
 	    }
 	  } catch {
 	    throw
 	  }
 	}
 	begin {
 	  try {
 	    $outBuffer = $null
 	    if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
 	    {
 	      $PSBoundParameters['OutBuffer'] = 1
 	    }
 	    $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Remove-Item', [System.Management.Automation.CommandTypes]::Cmdlet)
 	    $scriptCmd = {& $wrappedCmd @PSBoundParameters }
 	    $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
 	    $steppablePipeline.Begin($PSCmdlet)
 	  } catch {
 	    throw
 	  }
 	}
 	process {
 	  try {
 	    $steppablePipeline.Process($_)
 	  } catch {
 	    throw
 	  }
 	}
 	end {
 	  try {
 	    $steppablePipeline.End()
 	  } catch {
 	    throw
 	  }
 	}
} # End ProxyFunction for command: remove-item