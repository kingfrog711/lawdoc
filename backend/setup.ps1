# First-time setup: creates .env with API keys (PowerShell mirror of setup.sh)
$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$EnvFile = Join-Path $ScriptDir ".env"
$ExampleFile = Join-Path $ScriptDir ".env.example"

if (Test-Path $EnvFile) {
    Write-Host "[OK] .env already exists - skipping setup"
    exit 0
}

Write-Host "-- LawDoc backend setup --"
Write-Host ""

Write-Host "1) HuggingFace token  (required - for /consult and /tanya)"
Write-Host "   Model: sirpratama/perdata-gemma4-lora-v2"
Write-Host "   Get one at: https://huggingface.co/settings/tokens"
Write-Host ""
$hfKey = Read-Host "   Paste HF_API_KEY"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($hfKey)) {
    Write-Host "[!] No HF_API_KEY entered. The /consult and /tanya endpoints will not work."
    Write-Host "    Add it manually to .env later: HF_API_KEY=your_token"
    Write-Host ""
}

Write-Host "2) Inference endpoint URL  (recommended)"
Write-Host "   Deploy via Modal: from project root, run: modal deploy modal_app.py"
Write-Host "   Modal prints a URL like https://<user>--lawdoc-vllm-serve.modal.run"
Write-Host "   Leave blank to skip (you can add HF_ENDPOINT_URL to .env later)"
Write-Host ""
$hfEndpoint = Read-Host "   Paste HF_ENDPOINT_URL (or Enter to skip)"
Write-Host ""

Write-Host "3) Google AI Studio API key  (optional - only for /ocr-explain image extraction)"
Write-Host "   Get one free at: https://aistudio.google.com/app/apikey"
Write-Host "   Leave blank if you don't need document image analysis"
Write-Host ""
$googleKey = Read-Host "   Paste GOOGLE_API_KEY (or Enter to skip)"
Write-Host ""

$content = Get-Content $ExampleFile -Raw
$content = $content -replace "HF_API_KEY=.*", "HF_API_KEY=$hfKey"
$content = $content -replace "HF_ENDPOINT_URL=.*", "HF_ENDPOINT_URL=$hfEndpoint"
$content = $content -replace "GOOGLE_API_KEY=.*", "GOOGLE_API_KEY=$googleKey"
Set-Content -Path $EnvFile -Value $content -Encoding utf8

Write-Host "[OK] .env created. Run: .\start.ps1"
