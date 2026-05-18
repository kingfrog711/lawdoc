# Start the LawDoc backend (PowerShell mirror of start.sh).
# On first run (no .env): runs setup.ps1 to collect API keys.
# On subsequent runs: checks for missing HF_API_KEY and prompts if needed.
$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$EnvFile = Join-Path $ScriptDir ".env"

# -- First-time setup ----------------------------------------------------------
if (-not (Test-Path $EnvFile)) {
    Write-Host ".env not found - running setup..."
    & (Join-Path $ScriptDir "setup.ps1")
}

# -- Source existing .env into the current process environment ----------------
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match "^\s*([^#=\s][^=]*)=(.*)$") {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") {
            $value = $matches[1]
        }
        Set-Item -Path "env:$name" -Value $value
    }
}

# -- Check for missing HF_API_KEY (handles old .env without it) ---------------
if ([string]::IsNullOrWhiteSpace($env:HF_API_KEY)) {
    Write-Host ""
    Write-Host "-- HuggingFace API key required --"
    Write-Host ""
    Write-Host "The /consult endpoint uses sirpratama/perdata-gemma4-lora via HuggingFace."
    Write-Host "Get a token at: https://huggingface.co/settings/tokens"
    Write-Host ""
    $hfKey = Read-Host "Paste your HF_API_KEY"
    Write-Host ""

    if ([string]::IsNullOrWhiteSpace($hfKey)) {
        Write-Host "[!] Skipped. The /consult endpoint will return errors until HF_API_KEY is set."
        Write-Host "    Add it manually: HF_API_KEY=your_token in $EnvFile"
        Write-Host ""
    } else {
        $content = Get-Content $EnvFile -Raw
        if ($content -match "(?m)^HF_API_KEY=") {
            $content = $content -replace "(?m)^HF_API_KEY=.*", "HF_API_KEY=$hfKey"
            Set-Content -Path $EnvFile -Value $content -Encoding utf8
        } else {
            Add-Content -Path $EnvFile -Value "HF_API_KEY=$hfKey" -Encoding utf8
        }
        $env:HF_API_KEY = $hfKey
        Write-Host "[OK] HF_API_KEY saved to .env"
        Write-Host ""
    }
}

# -- Start server -------------------------------------------------------------
Write-Host "Starting LawDoc backend on http://localhost:8000 ..."
Set-Location $ScriptDir
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
