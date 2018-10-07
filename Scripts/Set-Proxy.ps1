[CmdletBinding()] param(
  [Alias('InternetProxy','InetProxy')]
                          [string]$Proxy = 'proxy-us.glb.my-it-solutions.net:84',
           [Net.NetworkCredential]$Credential,
                        [string[]]$BypassList,  # Array of regexes
  [Alias('UseLocal')]     [switch]$UseProxyOnLocal=$Null,
  [Alias('NDC','NoCred')] [switch]$NoDefaultCredential=$Null,
  [Alias('Reset','Clear')][switch]$Remove=$Null
)


Function Set-DefaultProxy {
  [CmdletBinding()] param(
    [Alias('InternetProxy','InetProxy')]
                            [string]$Proxy = 'proxy-us.glb.my-it-solutions.net:84',
             [Net.NetworkCredential]$Credential,
                          [string[]]$BypassList,  # Array of regexes
    [Alias('UseLocal')]     [switch]$UseProxyOnLocal=$Null,
    [Alias('NDC','NoCred')] [switch]$NoDefaultCredential=$Null,
    [Alias('Reset','Clear')][switch]$Remove=$Null
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
    [Alias('Off')][switch]$Disable=$Null
  )
  $Verbose = $PSBoundParameters.ContainsKey('Verbose') -and $PSBoundParameters.Verbose
  If ($State -match '^(On|Ena)') { $Enable = $True  }
  If ($State -match '^(Of|Dis)') { $Disable = $True }
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
    Set-Itemproperty $InternetSettingsKey $AutoConfigURL $url -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $AutoDetect    1    -force -ea ignore
    Set-ItemProperty $InternetSettingsKey $ProxyEnable   1    -force -ea ignore
  }
  $Settings = get-itemproperty $InternetSettingsKey -ea ignore | findstr /i $ProxyValues | Sort-Object
  ForEach ($Line in $Settings) {
    Write-Verbose $Line 
  }
}

If ($MyInvocation.Line -match '\s*\.(?![\w\\.\"''])') {
  Write-Warning "$(FLINE) Dot source, load functions, and exit"
} Else {
  If ($Proxy -and !$Remove) { 
    Write-Warning "$(FLINE) Setting proxy"
    Set-DefaultProxy @$PSBoundParameters
    Set-InternetProxy -State Enable -url $Proxy
    If (Get-Command setproxy.exe) { 
      setproxy /pac:http://proxyconf.my-it-solutions.net/proxy-na.pac  
    }  
  } ElseIf ($Remove) { 
    Write-Warning "$(FLINE) Reset proxy"
    Set-DefaultProxy @$PSBoundParameters
    Set-InternetProxy -State Disable  
    If (Get-Command setproxy.exe) { setproxy.exe /reset }
  }
}

