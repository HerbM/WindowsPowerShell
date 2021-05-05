BeforeAll {
  ## . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
  $TestProgram = 'D:\Library\Rust\ipcheck\target\release\ripcheck.exe'
  & $TestProgram --file .\hostlist.txt -l -t 2  -p 80-88
  & $TestProgram .\hostlist.txt -l -t 2  -p 80-88
  & $TestProgram -N 192.168.239.0/28 -p 135-139 445 -R -A -M
  & $TestProgram 192.168.239.0/28 -p 135-139 445 -R -A -M
  & $TestProgram 192.168.239.0/28 135-139 445 -RAM
  & $TestProgram 192.168.239.0/28 135-139 445 -RAMs
  & $TestProgram 192.168.239.0/28 135-139 445 -RAMs | ConvertFrom-CSV | Format-Table -Auto
  & $TestProgram 192.168.239.0/28 135-139 -i  -RAMs | ConvertFrom-CSV | Format-Table -Auto

  # hostname
  # netsh int ip show addr | sls 'IP Address'
}

Describe "RipCheck" {
  It "Returns expected output" {
    RipCheck | Should -Be "YOUR_EXPECTED_VALUE"
  }
}

<#
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.149 -p 135 445 -R -A -M
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 -p 135 445 -R -A -M 2>t.txt
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 -p 135 445 -R -A -M 2>t.txt >$Null
$(D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 -p 135 445 -R -A -M 2>t.txt >$Null)
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 -p 135 445 -R -A -M --verbose 2>t.txt >$Null
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 -p 135 445 -R -A -M
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/24 -p 135 445 -R -A -M
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/24 -p 135 445 -RAM | findstr /i "timethis address true -"
upx -9 --ultra-brute -o rc.exe D:\Library\Rust\ipcheck\target\release\deps\ripcheck.exe
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/255 -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/32 -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.10/32 -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.10/33 -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --path .\hostlist.txt -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --path .\hostlist.tx -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.30 --path .\hostlist.tx -p 135 445 -RAM # | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25--path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/25 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0/25 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0/25 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -" --verbose
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0/25 --path .\hostlist.txt -p 135 445 -RAM --verbose | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0/25 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe  --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0-192.168.239.12 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.0-192.168.239.12 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --cidr 192.168.239.0/29 --path .\hostlist.txt -p 135 445 -RAM | findstr /i "timethis address true -"
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.0-192.168.239.12 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.0-192.168.239.12 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.0-192.168.239.12 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 192.168.239.1-192.168.239.1 -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.1-192.168.239.1 -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --cidr 192.168.239.0/29 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt -p 135 445 -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe --range 192.168.239.1-192.168.239.1 445 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 445 --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 445 -host localhost --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 445 -a localhost --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 445 192.168.239.30 -a localhost --range 192.168.239.1-192.168.239.1 --path .\hostlist.txt  -RAM
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/24 -p 135 445 -R -A -M -s | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto
D:\Library\Rust\ipcheck\target\release\ripcheck.exe -N 192.168.239.0/29 -p 135 445 -R -A -M -s | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 135 -N 192.168.239.0/29 -p 135 445 -R -A -M -s # | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 135 -N 192.168.239.0/29  -R -A -M -s # | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 135 -N 192.168.239.0/29  -R -A -M -s 445 # | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto
D:\Library\Rust\ipcheck\target\release\ripcheck.exe 135 -N 192.168.239.0/29  -R -A -M 445 # | ConvertFrom-Csv | Where-Object { $_.MacAddress -or $_.Port135 -eq 'true' } | ft -auto

#>
