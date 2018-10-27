[CmdletBinding()] param(
  [Alias('InternetProxy','InetProxy')]
                 [string]$Proxy = 'proxy-us.glb.my-it-solutions.net:84',
  [Net.NetworkCredential]$Credential,
               [string[]]$BypassList,   # Array of regexes
  [Alias('UseLocal')]     [switch]$UseProxyOnLocal        = $Null,
  [Alias('NDC','NoCred')] [switch]$NoDefaultCredential    = $Null,
  [Alias('On','Set','Add','Default')]     [switch]$Enable = $Null,
  [Alias('Off','Reset','Clear','Disable')][switch]$Remove = $Null
)


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
  $urlEnvironment      = $Env:AutoConfigUrl
  $urlDefault          = 'http://proxyconf.my-it-solutions.net/proxy-na.pac'
  $ProxyValues         = 'AutoConfig ProxyEnable Autodetect'
  write-verbose "`$Env:AutoConfigUrl        : $($Env:AutoConfigUrl)"
  write-verbose  "Default proxy             : $urlDefault"
  $Settings = get-itemproperty $InternetSettingsKey -ea ignore | findstr /i $ProxyValues | Sort-Object
    Write-Output "             Registry settings"
    ForEach ($Line in $Settings) {
    Write-Output $Line
  }
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
    [Parameter(ParameterSetName='Reset')][switch]$Reset
  )
  If ($PSBoundParameters.ContainsKey('CurrentUser') -and $CurrentUser) { 
    $UserName = whoami 
  }
  If ($UserName) {   
    $UserName = ($UserName -replace '\b\\\b','\\') + '@'
    $HTTPProxy  = $HTTPProxy -replace  '//([^@]+)$', "//$UserName$1"
    $HTTPSProxy = $HTTPSProxy -replace '//([^@]+)$', "//$UserName$1"
  }  
  If ($Reset) {
    remove-item Env:Git*,Env:HTTP*,Env:credential_helper* -ea ignore
  } else {
    Write-Verbose "UserName: $UserName"
    $Env:credential_helper     = 'wincred'
    $Env:GIT_credential_helper = 'wincred'
    $Env:GIT_HTTP_PROXY        = "$HTTPProxy"
    $Env:GIT_HTTPS_PROXY       = "$HTTPSProxy" 
    $Env:http_proxy            = "$HTTPProxy"
    $Env:https_proxy           = "$HTTPSProxy"
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

If ((!$Enable) -and $MyInvocation.Line -match '\s*\.(?![\w\\.\"''])') {
  Write-Warning "$(FLINE) Dot source, load functions, and exit"
} Else {
  If ($Proxy -and !$Remove) { 
    Write-Warning "$(FLINE) Setting proxy"
    Set-DefaultProxy # @$PSBoundParameters
    Set-InternetProxy -Enable # -url $Proxy
    If (Get-Command setproxy.exe -ea Ignore) { 
      setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac  
    }  
    Set-HTTPProxy
    Set-GitProxy
  } ElseIf ($Remove) { 
    Write-Warning "$(FLINE) Reset proxy"
    Set-DefaultProxy @$PSBoundParameters
    Set-InternetProxy -State Disable
    If (Get-Command setproxy.exe -ea Ignore) { setproxy.exe /proxy:disable }
    Set-HTTPProxy -Disable    
    Set-GitProxy  -Reset
  } Else {
    Write-Warning "$(FLINE) Setting proxy"
    Set-DefaultProxy # @$PSBoundParameters
    Set-InternetProxy -Enable # -url $Proxy
    If ((Get-Command setproxy.exe -ea Ignore) -and ($Env:ComputerName -like 'MC0*')) { 
      setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac  
    }  
    Set-HTTPProxy
    Set-GitProxy
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
<#
String pattern = @"^[-/]+(\w+)(?:(?:[:=]+)(.+))?";
foreach (Match m in Regex.Matches(s, pattern)) {
  String name  = Groups[1].Value;
  String value = Groups[2].Value;
}
#>