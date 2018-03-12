function Get-AESKey([uint16]$length=256) {
  if ($length -gt 32) { [uint16]$length = $length / 8 }
	$length = &{switch ($length) {
	  {$_ -le  8 } {  8; break }
    {$_ -le 16 } { 16; break }
		default {32}
	}}
	$AES = New-Object Byte[] $length
	[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AES)
	$AES
}

function Set-EncryptedContent([string]$Path, [string]$content, [switch]$Append) {
	$secstr = ConvertTo-SecureString -String $content -AsPlainText -Force
	$Key = Get-AesKey 
	$EncryptedString = $SecStr | ConvertFrom-SecureString -Key $Key
	if ($Append) { Append-Content $PwdFile $EncryptedString } 
	else         { Set-Content    $PwdFile $EncryptedString }
	$Key
}

# C:\Program Files (x86)\Common Files\McAfee\Engine

function Get-EncryptedContent([string]$Path, $key, [switch]$Delete) {
	$EncString = Get-Content $Path
	$EncString | ConvertTo-SecureString -Key $Key
}

$PwdFile  = 't.txt'
$password = 'AbCd4321!'
$Username = '127.0.0.1\Administrator'

[Byte[]]$key = Set-EncryptedContent $PwdFile $password 
$securePwd = Get-EncryptedContent $PwdFile $Key 
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
$credObject.GetNetworkCredential().password

# get DNS server for domain
# get credentials
# save encrypted password
# put files on target
# send user, key & command to target, DNS IPs

# On target: (running script)
# Set interface DNS
# get encrypted password
# make credential with username/pwd
# run domain join
# send response, 
# reboot?  -- maybe BES relay should reboot
