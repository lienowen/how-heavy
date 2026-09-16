param([string]$Version = '0.22.0-alpha')
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$OutputRoot = Join-Path $ProjectRoot 'release/packages'
$WindowsZip = Join-Path $OutputRoot "TheWeightWeCarry-$Version-windows-x86_64.zip"
$WebZip = Join-Path $OutputRoot "TheWeightWeCarry-$Version-web.zip"
New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
if (Test-Path -LiteralPath $WindowsZip) { Remove-Item -LiteralPath $WindowsZip }
if (Test-Path -LiteralPath $WebZip) { Remove-Item -LiteralPath $WebZip }
Compress-Archive -LiteralPath (Join-Path $ProjectRoot 'build/windows/TheWeightWeCarry.exe') -DestinationPath $WindowsZip -CompressionLevel Optimal
Compress-Archive -Path (Join-Path $ProjectRoot 'build/web/*') -DestinationPath $WebZip -CompressionLevel Optimal
$Lines = foreach ($File in @($WindowsZip, $WebZip)) {
    $Hash = Get-FileHash -Algorithm SHA256 -LiteralPath $File
    "$($Hash.Hash.ToLowerInvariant())  $([IO.Path]::GetFileName($File))"
}
[IO.File]::WriteAllLines((Join-Path $OutputRoot 'SHA256SUMS.txt'), $Lines)
Write-Host "PACKAGE_PASS $Version"
$Lines | ForEach-Object { Write-Host $_ }
