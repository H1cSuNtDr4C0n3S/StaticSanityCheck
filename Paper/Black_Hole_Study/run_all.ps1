$ErrorActionPreference = "Stop"
$ws = "C:\Program Files\Wolfram Research\WolframScript\wolframscript.exe"

if (-not (Test-Path $ws)) {
  throw "wolframscript non trovato in $ws"
}

Set-Location $PSScriptRoot
$logsDir = Join-Path $PSScriptRoot "logs"
New-Item -ItemType Directory -Path $logsDir -Force | Out-Null

function Invoke-CloudWolframScript {
  param(
    [Parameter(Mandatory = $true)][string]$ScriptPath
  )

  $raw = & $ws -o -file $ScriptPath 2>&1 | Out-String
  if ($LASTEXITCODE -ne 0) {
    throw "Errore Wolfram Cloud su $ScriptPath`n$raw"
  }

  $match = [regex]::Match($raw, "__RESULT__(\{.*\})", [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $match.Success) {
    throw "Payload JSON non trovato in output per $ScriptPath`n$raw"
  }

  return ($match.Groups[1].Value | ConvertFrom-Json)
}

function Save-ResultPayload {
  param(
    [Parameter(Mandatory = $true)]$Payload
  )

  $nbPath = Join-Path $PSScriptRoot $Payload.nbName
  $logPath = Join-Path $logsDir $Payload.logName

  $nbBytes = [Convert]::FromBase64String($Payload.nbBase64)
  [System.IO.File]::WriteAllBytes($nbPath, $nbBytes)
  Set-Content -Path $logPath -Value $Payload.logText -Encoding ASCII
}

$scriptFiles = Get-ChildItem -Path ".\scripts" -File -Filter "*.wl" | Sort-Object Name
if ($scriptFiles.Count -eq 0) {
  throw "Nessuno script .wl trovato in .\scripts"
}

$results = @()
foreach ($sf in $scriptFiles) {
  Write-Host "Eseguo $($sf.Name) in Wolfram Cloud..."
  $payload = Invoke-CloudWolframScript -ScriptPath $sf.FullName
  Save-ResultPayload -Payload $payload
  $results += $payload
}

Write-Host "`nGenerazione/validazione completata (Wolfram Cloud)."
Write-Host "Script eseguiti:"
foreach ($r in $results) {
  Write-Host " - $($r.script)"
}
Write-Host "Notebook disponibili:"
Get-ChildItem -File -Filter "*.nb" | ForEach-Object { Write-Host " - $($_.FullName)" }
Write-Host "`nLog disponibili:"
Get-ChildItem -File ".\logs" | ForEach-Object { Write-Host " - $($_.FullName)" }
