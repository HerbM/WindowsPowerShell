[CmdletBinding()] param(
  [Alias('InternetProxy','InetProxy')]
                 [string]$Proxy = 'proxy-us.glb.my-it-solutions.net:84',
  [Net.NetworkCredential]$Credential,
               [string[]]$BypassList,   # Array of regexes
  [Alias('UseLocal')]     [switch]$UseProxyOnLocal            = $Null,
  [Alias('NDC','NoCred')] [switch]$NoDefaultCredential        = $Null,
  [Alias('On','Set','Add','Default')]     [switch]$Enable     = $Null,
  [Alias('Off','Reset','Clear','Disable','D')][switch]$Remove = $Null
)

If (!(Get-Command FLINE -ea 4)) {
  function Get-CurrentLineNumber { 
    $Invocation = Get-Variable MyInvocation -value -ea 0 2>$Null
    If (!$Invocation) { $Invocation = $MyInvocation } 
    $Invocation.ScriptLineNumber 
  }
  function Get-CurrentFileName   { split-path -leaf $MyInvocation.PSCommandPath   }   #$MyInvocation.ScriptName
  function Get-CurrentFileLine   { 
    if ($MyInvocation.PSCommandPath) {
      "$(split-path -leaf $MyInvocation.PSCommandPath):$($MyInvocation.ScriptLineNumber)" 
    } else {"GLOBAL:$(LINE)"} 
  }
  function Get-CurrentFileName1  { 
    if ($var = get-variable MyInvocation -scope 1 -value) {
      if ($var.PSCommandPath) { split-path -leaf $var.PSCommandPath } 
      else {'GLOBAL'} 
    } else {"GLOBAL"}    
  }   #$MyInvocation.ScriptName

  try {
  #    if (![boolean](get-alias line -ea 0)) {
        New-Alias -Name   LINE   -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -ea Ignore
        New-Alias -Name __LINE__ -Value Get-CurrentLineNumber -Description 'Returns the current (caller''s) line number in a script.' -force -ea Ignore
        New-Alias -Name   FILE   -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -ea Ignore
        New-Alias -Name   FLINE  -Value Get-CurrentFileLine   -Description 'Returns the name of the current script file.' -force             -ea Ignore
        New-Alias -Name   FILE1  -Value Get-CurrentFileName1  -Description 'Returns the name of the current script file.' -force             -ea Ignore
        New-Alias -Name __FILE__ -Value Get-CurrentFileName   -Description 'Returns the name of the current script file.' -force             -ea Ignore
  #    } 
  } catch {}
}
If (!(Get-Command Set-EnvironmentVariable -ea 4)) {
  Function Set-EnvironmentVariable {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]
    [Alias('Set-Environment','Set-Env','sev','setenv')]Param(
      [string[]]$Variable                          = $Null,
      [string[]]$Value                             = @(),
      [string[]]$Scope                             = 'Local',
      [switch]  $Local                             = $False,
      [switch]  $Process                           = $False,
      [switch]  $User                              = $False,
      [Alias('Computer','System')][switch]$Machine = $False
    )
    Begin {
      $Scope = Switch ($True) {
        { $Local   } { 'Local'   }
        { $Process } { 'Process' }
        { $User    } { 'User'    }
        { $Machine } { 'Machine' }
        Default      { $Scope    }
      }
    }
    Process {
      ForEach ($Var in $Variable) {
        If ($Var -is 'System.Collections.DictionaryEntry') {
          $Var, $Val = $Var.Name, $Var.Value
        } Else {
          If ($Value) { $Val, $Value = $Value }
          If ($Scope) { $Env, $Scope = $Scope }
        }
        If ($Env -in 'Computer','System') { $Env = 'Machine'}
        If ($Var -as [String]) {
          $Val = If ($Val = Get-Variable Val -ea 4 -value) { $Val -as 'string' } Else { '' }
          Write-Verbose "Set environment [$Var=$Val] in [$Env] scope"
          If ($PSCmdlet.ShouldProcess("$Env scope", "Set [$Var=$Val]")) {
            If ($Env -eq 'Local') { Set-Item -Path "Env:$Var" -Value $Val }
            Else { [Environment]::SetEnvironmentVariable($Var,$Val,$Env) }
          }
        }
      }
    }
    End {}
  }
}
If (!(Get-Command Get-EnvironmentVariable -ea 4)) {
  Function Get-EnvironmentVariable {
    [CmdletBinding()][Alias('Get-Environment','Get-Env','gev','env')]
    [OutputType([String],[String[]],
      [System.Collections.DictionaryEntry],[System.Collections.DictionaryEntry[]])]
    Param(
      [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName)]
      [Alias('Key','Name','Path')][string[]]$Variable = $Null,
      [string[]]$Scope                                = 'Local',
      [switch]  $Local                                = $False,
      [switch]  $Process                              = $False,
      [switch]  $User                                 = $False,
      [switch]  $Value                                = $False,
      [Alias('Computer','System')][switch]$Machine    = $False
    )
    Begin {
      $Scope = Switch ($True) {
        { $Local   } { 'Local'   }
        { $Process } { 'Process' }
        { $User    } { 'User'    }
        { $Machine } { 'Machine' }
        DEFAULT      { $Scope    }
      }
    }
    Process {
      ForEach ($Var in $Variable) {
        If ($Var -is 'System.Collections.DictionaryEntry') {
          $Var, $Val = $Var.Name
        } Else {
          If ($Scope) { $Env, $Scope = $Scope }
        }
        If ($Env -in 'Computer','System') { $Env = 'Machine'}
        If ($Var -as [String]) {
          If ($Env -eq 'Local') {
            $Item = Get-Item -Path "Env:$Var"
            If ($Value) { $Item.Value } Else { $Item }
          } Else {
            If ($Null -ne ($Val = [Environment]::GetEnvironmentVariable($Var,$Env))) {
              If ($Value) { $Val }
              Else        { [System.Collections.DictionaryEntry]::New($Var, $Val) }
            }
          }
        }
      }
    }
    End {}
  }
}

Function Set-DefaultProxy {
  [CmdletBinding()] param(
    [Alias('InternetProxy','InetProxy')]
                            [string]$Proxy = 'proxy-us.glb.my-it-solutions.net:84',
             [Net.NetworkCredential]$Credential,
                          [string[]]$BypassList,  # Array of regexes
    [Alias('UseLocal')]     [switch]$UseProxyOnLocal=$Null,
    [Alias('NDC','NoCred')] [switch]$NoDefaultCredential=$Null,
    [Alias('Disable','Reset','Clear')][switch]$Remove=$Null
  )
  #https://msdn.microsoft.com/en-us/library/system.net.webrequest.defaultcachepolicy(v=vs.100).aspx
  #https://msdn.microsoft.com/en-us/library/system.net.networkcredential(v=vs.100).aspx
  # BypassProxyOnLocal    : False
  # BypassList            : {}
  # Credentials           : System.Net.SystemNetworkCredential
  # UseDefaultCredentials : True
  # BypassArrayList       : {}  ### CANNOT be set, get only
<#
# Use a proxy that isn't already configured in Internet Options
[net.webrequest]::defaultwebproxy = new-object net.webproxy "http://proxy.example.org:8080"
# Use the Windows credentials of the logged-in user to authenticate with proxy
[net.webrequest]::defaultwebproxy.credentials = [net.credentialcache]::defaultcredentials
# If you want to use other credentials (replace 'username' and 'password')
[net.webrequest]::defaultwebproxy.credentials = new-object net.networkcredential 'username', 'password'
These commands will affect any web requests using net.webclient until the end of your powershell session.
Configuring Scoop to use your proxy
Once Scoop is installed, you can use scoop config to configure your proxy. Here's an excerpt from scoop help config:
  scoop config proxy [username:password@]host:port
By default, Scoop uses proxy from Internet Options with anonymous authentication.
Use the credentials for the current logged-in user, use currentuser in place of username:password
System proxy settings configured in Internet Options: use default in place of host:port
Empty/unset proxy equivalent to default (with no username or password)
bypass system proxy: use none (with no username or password)
# Use your Windows credentials with the default proxy configured in Internet Options
scoop config proxy currentuser@default
#>
  If ($Remove) {
    Write-Verbose "Remove current default proxy settings" 
    [system.net.webrequest]::DefaultWebProxy = $Null
    return
  }
  [system.net.webrequest]::DefaultWebProxy = new-object system.net.webproxy($Proxy)
  If ($Credential -or $NoDefaultCredential) {
    Write-Verbose 'Set UseDefaultCredentials:$False' 
    [system.net.webrequest]::DefaultWebProxy.Credentials = Credential
  } else {
    Write-Verbose 'Set UseDefaultCredentials:$True' 
    [system.net.webrequest]::DefaultWebProxy.UseDefaultCredentials = $True
  }
  If ($BypassList) {
    Write-Verbose "SetByPassList: $BypassList" 
    [system.net.webrequest]::DefaultWebProxy.BypassList = $BypassList
  }
  Write-Verbose "Set ByPassProxyOnLocal: $(![Boolean]$UseProxyOnLocal)" 
  [system.net.webrequest]::DefaultWebProxy.BypassProxyOnLocal = ![Boolean]$UseProxyOnLocal
}

Function Get-DefaultProxy { [system.net.webrequest]::DefaultWebProxy }
Function Remove-DefaultProxy { Set-DefaultProxy -Remove }
# DefaultProxy mainly PowerShell git? InternetProxy IE, but no notify
# setproxy.exe does notify -- need to unify, add netsh + apps, env:
# GIT_credential_helper          wincred 
# setproxy /disable
# setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac
# https://www.makeuseof.com/tag/3-scripts-modify-proxy-setting-internet-explorer/
# setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac
Function Get-InternetProxy {
  [CmdletBinding()][Alias('Show-InternetProxy')]param()
  $InternetSettingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $UrlEnvironment      = $Env:AutoConfigUrl
  $UrlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  $ProxyValues         = 'AutoConfig*', 'ProxyEnable', 'Autodetect'
  Write-Verbose "`$Env:AutoConfigUrl  : $($Env:AutoConfigUrl)"
  Write-Verbose "Default proxy       : $urlDefault"
  Write-Verbose "Checked values      : $ProxyValues"
  get-itemproperty $InternetSettingsKey -ea ignore | Select $ProxyValues
}

Function Set-InternetProxy {
  [CmdletBinding()]
  param(
    #[Parameter(ValidateSet='Enable','On','Disable','Off')][string]$State,
    [string]$State,
    [string]$Url,
    [Alias('On' )][switch]$Enable=$Null,
    [Alias('Off','Reset','Clear','Remove')][switch]$Disable=$Null
  )
  $Verbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose
  If ($State -match '^(On|Ena)') { $Enable = $True  }
  If ($State -match '^(Of|Dis)') { $Disable = $True }
  If (!$Disable) { $Enable = $True }
  $InternetSettingsKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
  $AutoConfigURL       = 'AutoConfigURL'
  $AutoConfigURLSave   = $AutoConfigURL + 'SAVE'
  $AutoDetect          = 'AutoDetect'
  $ProxyEnable         = 'ProxyEnable'
  $ProxyValues         = 'AutoConfig ProxyEnable Autodetect'
  $urlEnvironment      = $Env:AutoConfigUrl
  $urlCurrent          = If ($P = get-itemproperty $InternetSettingsKey $AutoConfigURL     -ea ignore) {
                           $P.$AutoConfigURL } else { '' }  
  $urlSaved            = If ($P = get-itemproperty $InternetSettingsKey $AutoConfigURLSave -ea ignore) {
                           $P.$AutoConfigURLSAVE } Else { '' }  
  $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  If ($Enable -eq $Disable) {
    Write-Warning "Specify either Enable or Disable (alias: On or Off)"
    $Verbose = $True
  } elseif ($Disable) {
    if ($urlCurrent) {
      set-itemproperty $InternetSettingsKey $AutoConfigURLSave $urlCurrent -force -ea ignore
      remove-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" 'AutoConfigURL' -ea ignore
    }
    Set-ItemProperty $InternetSettingsKey $AutoDetect  0 -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $ProxyEnable 0 -force -ea ignore
  } elseif ($Enable) {
    $Url = switch ($True) {
      { [boolean]$Url            } { $Url            ; break }
      { [boolean]$UrlEnvironment } { $UrlEnvironment ; break }
      { [boolean]$UrlCurrent     } { $UrlCurrent     ; break }
      { [boolean]$urlSaved       } { $UrlSaved       ; break }
      { [boolean]$urlDefault     } { $UrlDefault     ; break }
      Default {
        Write-Warning "Supply URL for enabling and setting AutoConfigURL Proxy"
        return
      }
    }
    Write-Warning "Setting registry keys including ProxyEnable"
    Set-Itemproperty $InternetSettingsKey $AutoConfigURL $url -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $AutoDetect    1    -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $ProxyEnable   1    -force -ea ignore
  }
  $Settings = get-itemproperty $InternetSettingsKey -ea ignore | 
    FindStr /i $ProxyValues | Sort-Object
  ForEach ($Line in $Settings) {
    Write-Verbose $Line 
  }
}

Function Set-GitProxy {
  [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low',
    DefaultParameterSetName='Proxy')]
  Param(
    [Parameter(ParameterSetName='Proxy')]
    [string]$Proxy      = 'http://proxy-us.glb.my-it-solutions.net:84',
    [Parameter(ParameterSetName='HTTP')]
    [string]$HttpProxy  = 'http://proxy-us.glb.my-it-solutions.net:84',
    [Parameter(ParameterSetName='HTTP')]
    [string]$HttpsProxy = 'http://proxy-us.glb.my-it-solutions.net:84',
    [Parameter(ParameterSetName='HTTP')]
    [Parameter(ParameterSetName='Proxy')][string]$UserName = '',
    [Parameter(ParameterSetName='HTTP')]
    [Parameter(ParameterSetName='Proxy')][switch]$CurrentUser,
    [Alias('Remove','Disable')][Parameter(ParameterSetName='Reset')][switch]$Reset
  )
  If ($PSBoundParameters.ContainsKey('CurrentUser') -and $CurrentUser) { 
    $UserName = whoami 
  }
  If ($UserName) {   
    $UserName   = ($UserName  -replace '\b\\\b','\\') + '@'
    $HTTPProxy  = $HTTPProxy  -replace '//([^@]+)$', "//$UserName$1"
    $HTTPSProxy = $HTTPSProxy -replace '//([^@]+)$', "//$UserName$1"
    Set-EnvironmentVariable credential_helper     '' Process 
    Set-EnvironmentVariable GIT_credential_helper '' Process 
    Set-EnvironmentVariable GIT_HTTP_PROXY        '' Process 
    Set-EnvironmentVariable GIT_HTTPS_PROXY       '' Process 
    Set-EnvironmentVariable http_proxy            '' Process 
    Set-EnvironmentVariable https_proxy           '' Process 
  }  
  
  # 
  If ($Reset) {
    remove-item Env:\Git*,Env:\HTTP*,Env:\credential_helper* -ea ignore -force
  } else {
    Write-Verbose "UserName: $UserName"
    Set-Variable Env:\credential_helper     -value 'wincred'     -force -scope Global 
    Set-Variable Env:\GIT_credential_helper -value 'wincred'     -force -scope Global 
    Set-Variable Env:\GIT_HTTP_PROXY        -value "$HTTPProxy"  -force -scope Global 
    Set-Variable Env:\GIT_HTTPS_PROXY       -value "$HTTPSProxy" -force -scope Global 
    Set-Variable Env:\http_proxy            -value "$HTTPProxy"  -force -scope Global 
    Set-Variable Env:\https_proxy           -value "$HTTPSProxy" -force -scope Global 
    Set-EnvironmentVariable credential_helper     'wincred'     Process 
    Set-EnvironmentVariable GIT_credential_helper 'wincred'     Process 
    Set-EnvironmentVariable GIT_HTTP_PROXY        "$HTTPProxy"  Process 
    Set-EnvironmentVariable GIT_HTTPS_PROXY       "$HTTPSProxy" Process 
    Set-EnvironmentVariable http_proxy            "$HTTPProxy"  Process 
    Set-EnvironmentVariable https_proxy           "$HTTPSProxy" Process 
  }
}

Function Get-HTTPProxy {
  [CmdletBinding()][Alias('Show-InternetProxy')]param()
  netsh winhttp show proxy
}
Function Set-HTTPProxy {
  [CmdletBinding()][Alias('Show-InternetProxy')]param(
    [Alias('Proxy')][string]$ProxyHTTP  = '',
                    [string]$ProxyHTTPS = '',
                    [string]$ByPassList = '',
    [Alias('Off','Reset','Clear','Remove')][switch]$Disable
  )
  # set proxy myproxy:80 "<local>;bar"
  # set proxy proxy-server="http=myproxy;https=sproxy:88" bypass-list="*.foo.com"
  If ($Disable) {
    netsh winhttp reset proxy
  } ElseIf ($ProxyHTTP) {
    If (!$ProxyHTTPS) { $ProxyHTTPS = $ProxyHTTP }
    set proxy proxy-server="http=$ProxyHTTP;https=$ProxyHTTPS"
  } Else {
    netsh winhttp set proxy http://proxyconf.my-it-solutions.net/proxy-na.pac
    # netsh winhttp import proxy source=ie
  }
}


<#
setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac
  netsh winhttp show proxy
  netsh winhttp import proxy source=ie
 
https://github.com/dotnet/corefx/issues/29934
WinHttpGetIEProxyConfigForCurrentUser
WinHttpGetProxyForUrl
#>
  

<#
.Notes
    DefaultSecureProtocols 
      Value       Protocol  Enabled
      0x00000008  SSL 2.0   Enable by default
      0x00000020  SSL 3.0   Enable by default
      0x00000080  TLS 1.0   Enable by default
      0x00000200  TLS 1.1   Enable by default
      0x00000800  TLS 1.2   Enable by default
.Link
 https://support.microsoft.com/en-us/help/3140245/update-to-enable-tls-1-1-and-tls-1-2-as-a-default-secure-protocols-in
#>
Function Set-HTTPSecurity {
  [CmdletBinding()] param(
    [Alias('Enabled','On','Set')] [UInt32]$Value = 0x00000A00,
    [Alias('Off','Remove','Disable','Clear')]   [Switch]$Reset
  ) 
  $Drives = 'HKCU:','HKLM:'
  $Keys   = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp',
            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp'         
  ForEach ($Drive in $Drives) {
    ForEach ($Key in $Keys) {
      If ($Reset) {
        Remove-ItemProperty -Path "$Drive\$Key" -Name 'DefaultSecureProtocols' -Force -EA Ignore
      } Else {
        Set-ItemProperty    -Path "$Drive\$Key" -Name 'DefaultSecureProtocols' -Value $Value -Force -EA Ignore  
      }
    } 
  }
}

Function Get-HTTPSecurity {
  [CmdletBinding()] param(
  )
  $Drives = 'HKCU:','HKLM:'
  $Keys    = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp',
            'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp'         
  ForEach ($Drive in $Drives) {
    ForEach ($Key in $Keys) {
        Get-ItemProperty -Path "$Drive\$Key" -Name 'DefaultSecureProtocols' -EA Ignore  
    } 
  }
}

Function Get-Proxy {
  [CmdletBinding()] param(
  )
  Get-HTTPSecurity | Select Default*,PSPath
  Get-HttpProxy 
  dir ENV:*git*,Env:*http*
  Get-DefaultProxy
  Get-InternetProxy
}

If ((!$Enable) -and $MyInvocation.Line -match '\s*\.(?![\w\\.\"''])') {
  Write-Warning "$(FLINE) Dot source, load functions, and exit"
} Else {
  If ($Remove) { 
    Write-Warning "$(FLINE) Reset proxy"
    Set-DefaultProxy @$PSBoundParameters
    Set-InternetProxy -State Disable
    If (Get-Command setproxy.exe -ea Ignore) { 
      setproxy.exe /proxy:disable 
    } Else { Write-Error "SetProxy.exe: NOT found on path" }
    Set-HTTPProxy -Disable    
    Set-GitProxy  -Reset
  } ElseIf ($Proxy) { 
    Write-Warning "$(FLINE) Setting proxy"
    Set-DefaultProxy # @$PSBoundParameters
    Set-InternetProxy -Enable # -url $Proxy
    If (Get-Command setproxy.exe -ea Ignore) { 
      setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac  
    } Else { Write-Error "SetProxy.exe: NOT found on path" } 
    Set-HTTPProxy
    Set-GitProxy
  } Else {
    Write-Warning "$(FLINE) Setting proxy"
    Set-DefaultProxy # @$PSBoundParameters
    Set-InternetProxy -Enable # -url $Proxy
    If ((Get-Command setproxy.exe -ea Ignore)) {  # -and ($Env:ComputerName -like 'MC0*')) { 
      setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac  
    } Else { Write-Error "SetProxy.exe: NOT found on path" } 
    Set-HTTPProxy
    Set-GitProxy
  }
}

# set-proxy -d
# & 'C:\Program Files (x86)\Common Files\Pulse Secure\jamui\pulse.exe' -url ura-us.it-solutions.atos.net/pulsesso -stop
# Get-Process Pulse -ea 4 | Stop-Process
# & 'C:\Program Files (x86)\Common Files\Pulse Secure\jamui\pulse.exe' -url ura-us.it-solutions.atos.net/pulsesso -login
# Click on connect, add pin, enter
# set-proxy -e