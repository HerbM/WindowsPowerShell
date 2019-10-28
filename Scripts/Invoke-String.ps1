<#
.Notes

  $a99 = 'def'
  Function X99 {
    [CmdletBinding()]Param(
      $arg = 123
    )
    $arg + 2
  }
  # 1/0
  x99 $a99

Function ig {   # https://vexx32.github.io/2018/11/16/Invoke-Command-Global-Scope/
  $GlobalScope = [psmoduleinfo]::new($true)
  & $GlobalScope { $x = 27; } 
}
#>
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low',DefaultParameterSetName='Script')]
  Param(
    [Parameter(ParametersetName='Script')][string[]]$Script = '',
    [Alias('PowerShell','RunSpace','RS')]
    [System.Management.Automation.PowerShell]$PS,
    [string]$SourceIdentifier = 'ErrorStream.DataAdded'
  )
  Begin {
    $DataAdded               = [Ordered]@{}
    $RegisterEventParameters = [Ordered]@{}
    Set-StrictMode -version Latest 
        $ShouldDispose = $False   
    try {
      If ($PS -and $PS -is [System.Management.Automation.PowerShell]) {
        $ShouldDispose = $False   
        ForEach ($Command in $ps.Commands) { $Command.Clear() }
      } ElseIf ($Global:PowerShellGlobalRunSpace -and 
                $Global:PowerShellGlobalRunSpace -is 
                  [System.Management.Automation.PowerShell]) {
        $ShouldDispose = $False
        $Script:PS = $Global:PowerShellGlobalRunSpace
        Write-Warning "Using: PowerShellGlobalRunSpace"
      } Else {
        $ps = [System.Management.Automation.PowerShell]::Create(
          [System.Management.Automation.RunspaceMode]::CurrentRunspace
        ) 
        $ps = $PowerShellGlobalRunspace = 
               [System.Management.Automation.PowerShell]::Create(
               [System.Management.Automation]'CurrentRunSpace', $False)
#        $PS = $Host.RunSpace 
        $ShouldDispose = $False
      }    
      $StreamNames = @($PS.streams.psobject.get_properties().name)
      ForEach ($StreamName in $StreamNames) {
        $RegisterEventParameters.Stream = @{
          InputObject      = $PS.Streams.$StreamName 
          EventName        = "IS_$($StreamName)DataAdded" 
          SourceIdentifier = $SourceIdentifier 
          Action           = { 
            $Stream  = $StreamName
            If ($WriteStream = Get-Command "Write-$_" -ea Ignore) {
              & $WriteStream ($Event)
            }
          }  
        }  
          #If (!(Get-Job -Name $RegisterEventParameters.EventName -ea Ignore)) {
        $Params = $RegisterEventParameters.StreamName  
        $DataAdded.$StreamName = Register-ObjectEvent @Params
            # If ($DataAdded) { Start-Job -name $DataAdded.name -ea STOP }
          #}
      }
  } catch {
      Write-Error "Caught error"
      Write-Error ($_ | Format-List | Out-String)
    } Finally {
      ## If ($DataAdded) {
      ##   If ($SourceIdentifier) { 
      ##     UnRegister-Event -SourceIdentifier $SourceIdentifier 
      ##   }      
      ##   #Stop-Job    -name $DataAdded.name
      ##   #Receive-Job -name $DataAdded.name
      ##   #Remove-Job  -name $DataAdded.name
      ## }
      #If ($ShouldDispose) {
      #  $PS.dispose()
      #  $PS = $Null
      #  $ShouldDispose = $False
      #}
    }
  }
  Process {
    If (!$Script) { $Script = @(Get-Clipboard) }
    ForEach ($CommandScript in $Script) {
      Write-Warning "Invoke-Script: $Script"
      $Null = $ps.AddScript($CommandScript, $False)
      $ps.Invoke()
      ForEach ($Job in $DataAdded.Keys) {
        If ($DataAdded.$Job) { Receive-Job $DataAdded.$Job }
      }  
      ForEach ($Command in $ps.Commands) { $Command.Clear() }
    }
  }  
  End {
    ForEach ($StreamName in $DataAdded.Keys) {
      If ($EventParameters = $RegisterEventParameters.StreamName) { 
        UnRegister-Event -SourceIdentifier $EventParameters.SourceIdentifier 
      }      
      If ($DataAdded.StreamName) {
        Get-Job $DataAdded.StreamName -ea Ignore | ForEach-Object {
          Stop-Job $_; Receive-Job $_; Remove-Job $_ 
        }
      }
    }
    #If ($ShouldDispose -and $PS) {
    #  $PS.dispose()
    #  $PS = $Null
    #}
  }    
  
<#  
  # $ps.dispose();$ps = $null
  # UnRegister-Event $Stream DataAdded -SourceIdentifier Stream.DataAdded1
# $ps.ClearStreams()
# $ps.streams.error.DataAdded = { Write-Error($Event) }
$PriorErrorCount = $ps.streams.error.count
$ClipBoard = Get-Clipboard 
$Null = $ps.AddScript($ClipBoard, $False)
#write-warning "ps -eq ps2 = [$($ps2 -eq $ps)]"
$ps.Invoke()
#If (($ErrorCount = $ps.streams.error.count) -gt $PriorErrorCount) {
#  $ps.streams.error[0..($ErrorCount - $PriorErrorCount - 1)]
#}  
#ForEach ($stream in $ps2.streams.psobject.get_properties()) {
#  $stream.value
#}
# ForEach ($command in $ps.commands) { $command.clear() }
# $ps2.streams.ClearStreams()




# Empty collection for errors
$Errors = @()

# Define input script
$inputScript = 'Do-Something -Param 1,2,3,'

[void][System.Management.Automation.Language.Parser]::ParseInput($inputScript,[ref]$null,[ref]$Errors)

if($Errors.Count -gt 0){
  Write-Warning 'Errors found'
}


#This could easily be turned into a simple function:

Function Test-Syntax {
  [CmdletBinding(DefaultParameterSetName='File')]
  param(
    [Alias('PSPath')][Parameter(Mandatory=$true, ParameterSetName='File')]
    [string[]]$Path, 
    [Parameter(Mandatory=$true, ParameterSetName='String')]
    [string[]]$ScriptDefinition
  )
  Begin {}
  Process {
    $Defs = @(If ($PSCmdlet.ParameterSetName -eq 'String') { $Path } Else { $ScriptDefinition })
    ForEach ($Script in $Defs) {
      $ErrorCount = @()
      if ($PSCmdlet.ParameterSetName -eq 'String') {
        [void][System.Management.Automation.Language.Parser]::ParseInput(
          $Script,[ref]$null,[ref]$Errors
        )
      } else {
        [void][System.Management.Automation.Language.Parser]::ParseFile(
          $Script,[ref]$null,[ref]$Errors
        )
      }
      $Errors.Count -eq 0
    }
  }
  End {}
}
#>

