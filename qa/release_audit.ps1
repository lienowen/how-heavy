$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Failures = [System.Collections.Generic.List[string]]::new()

function Require-File([string]$RelativePath, [int64]$MinimumBytes = 1) {
    $Path = Join-Path $ProjectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $Failures.Add("Missing file: $RelativePath")
        return
    }
    if ((Get-Item -LiteralPath $Path).Length -lt $MinimumBytes) {
        $Failures.Add("File too small: $RelativePath")
    }
}

Require-File 'build/web/index.html' 1000
Require-File 'build/web/index.js' 100000
Require-File 'build/web/index.wasm' 10000000
Require-File 'build/web/index.pck' 1000000
Require-File 'build/web/index.manifest.json' 100
Require-File 'build/web/index.service.worker.js' 1000
Require-File 'build/windows/TheWeightWeCarry.exe' 50000000
Require-File 'steam/STORE_COPY_en-US.md' 500
Require-File 'steam/ACHIEVEMENTS.csv' 500
Require-File 'legal/ASSET_LEDGER.md' 300

$Manifest = Get-Content -LiteralPath (Join-Path $ProjectRoot 'build/web/index.manifest.json') -Raw | ConvertFrom-Json
if (-not $Manifest.name) { $Failures.Add('PWA manifest has no name') }

$CampaignSource = Get-Content -LiteralPath (Join-Path $ProjectRoot 'systems/campaign.gd') -Raw
if (($CampaignSource | Select-String -Pattern '\{"id":\d+,"name":' -AllMatches).Matches.Count -ne 24) {
    $Failures.Add('Campaign metadata does not contain exactly 24 rooms')
}

$SteamTemplate = Get-Content -LiteralPath (Join-Path $ProjectRoot 'steam/scripts/app_build.vdf.template') -Raw
if ($SteamTemplate -notmatch 'APP_ID_REQUIRED') {
    $Failures.Add('Steam template must retain safe App ID placeholder until publisher credentials exist')
}

$WebBytes = (Get-ChildItem -LiteralPath (Join-Path $ProjectRoot 'build/web') -File | Measure-Object Length -Sum).Sum
if ($WebBytes -gt 70000000) { $Failures.Add("Web package exceeds 70 MB: $WebBytes") }

if ($Failures.Count -gt 0) {
    $Failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "AUDIT_PASS dual-platform artifacts, PWA, 24-room metadata, store/legal handoff"
Write-Host ("WEB_SIZE_MB {0:N2}" -f ($WebBytes / 1MB))
