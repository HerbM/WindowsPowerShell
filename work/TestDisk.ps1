[CmdletBinding()]Param (
  $Path  = 'D:\Test',
  $Base  = 'SubTest',
  $Count = 100,
  $Start = 1000
)

$BaseCharInt = [int][char]'0' - 1
$Characters = (1..(5*16) | ForEach-Object { [char]($BaseCharInt + $_) }) -Join ''
$Content    = ($Characters * 12500)

$StartTime = Get-Date
$End = $Start + $Count - 1
Try {
  ForEach ($DirectoryCount in ($Start..$End)) {
    $Directory = Join-Path $Path ($Base + $DirectoryCount)
    $Null = mkdir $Directory -Force -ea STOP
    If ($DirectoryCount % 100 -eq 0) { Write-Verbose "Directory $DirectoryCount" }
    If (Test-Path $Directory) {
      ForEach ($FileCount in ($Start..$End)) {
        $FileName = 'File' + ($Base + $FileCount) + '.txt'
        $FullName = Join-Path $Directory $FileName
        Set-Content -path $FullName -Value $Content -NoNewline -ea STOP
        $FileContent = Get-Content -Raw -Path $FullName -ea STOP
        If ($FileContent -ne $Content) {
          Write-Warning "Contents are not equal $FullName"
        }
      }
    } else {
      Write-Errror "Unable to create directory $Directory"
    }
  }
} Catch {
  Write $_
} Finally {
  $EndTime = Get-Date
  Write-Warning "$(($EndTime - $StartTime).TotalSeconds)"
}
