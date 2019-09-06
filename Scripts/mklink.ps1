<#
.Synopsis
  Create a file or directory link
.Description
  Create a file or directory link to anther (existing) file or directory
.Example 
  mklink C:\Util\dnGrep.exe "$($Env:ProgramW6432)\dnGREP\dnGREP.exe"
  Add linked 'file' in utility that references Program Files installed path
.Example 
  mklink C:\NewName $Home\Documents /D
  Add C:\NewName as a link to the current users Documents directory
  
.Notes 
  MKLINK [[/D] | [/H] | [/J]] Link Target

    /D      Create a directory symbolic link 
            Default is a file symbolic link
    /H      Create a hard link instead of symbolic link
    /J      Create a Directory Junction
    Link    specifies the new symbolic link name
    Target  Path new link references - (relative or absolute)
#>
[CmdletBinding(
  DefaultParameterSetName='File',
  PositionalBinding,
  SupportsShouldProcess,
  ConfirmImpact='Low'
)]
Param(
  [string[]]$LinkPath,
  [string[]]$Path,
  [Parameter(ValueFromRemainingArguments)]$Args = @(),
  [switch]$Directory = $False,
  [switch]$Junction  = $False,
  [switch]$HardLink  = $False,
  [switch]$Test      = $False
)
Begin {
  $Arguments = @(
    Switch ($True) {
      {[boolean]$LinkPath  } { $LinkPath                  }
      {[boolean]$Path      } { $Path                      }
      {[boolean]$Args      } { ForEach ($A in $Args) {$A} }
      {[boolean]$Directory } { '/D'                       }
      {[boolean]$Junction  } { '/J'                       }
      {[boolean]$Hardlink  } { '/H'                       }
      {[boolean]$Test      } { ''                         }
      Default                { @()                        }    
    }
  )
  $Arguments = $Arguments | Select -unique
}
Process {
  If ($PSCmdlet.ShouldProcess($Path, "MkLink: Make new link [$LinkPath]")) {
    Write-Warning "cmd /c mklink $($Arguments -join ' ')"
  } Else {  
    Write-Warning "Echo Arguments:"
    echoargs @arguments
  }
}
End {}
