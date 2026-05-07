#!/bin/bash
# Start the LawDoc backend.
# On first run (no .env): runs setup.sh to collect API keys.
# On subsequent runs: checks for missing HF_API_KEY and prompts if needed.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

# ── First-time setup ───────────────────────────────────────────────────────────
if [ ! -f "$ENV_FILE" ]; then
  echo ".env not found — running setup..."
  bash "$SCRIPT_DIR/setup.sh"
fi

# ── Source existing .env ───────────────────────────────────────────────────────
set -a
source "$ENV_FILE"
set +a

# ── Check for missing HF_API_KEY (handles old .env without it) ────────────────
if [ -z "$HF_API_KEY" ]; then
  echo ""
  echo "── HuggingFace API key required ──"
  echo ""
  echo "The /consult endpoint uses sirpratama/perdata-gemma4-lora via HuggingFace."
  echo "Get a free token at: https://huggingface.co/settings/tokens"
  echo ""
  read -r -p "Paste your HF_API_KEY: " hf_key
  echo ""

  if [ -z "$hf_key" ]; then
    echo "⚠ Skipped. The /consult endpoint will return errors until HF_API_KEY is set."
    echo "  Add it manually: echo 'HF_API_KEY=your_token' >> $ENV_FILE"
    echo ""
  else
    # Append or update HF_API_KEY in .env
    if grep -q "^HF_API_KEY=" "$ENV_FILE"; then
      sed -i.bak "s|^HF_API_KEY=.*|HF_API_KEY=$hf_key|" "$ENV_FILE"
      rm -f "$ENV_FILE.bak"
    else
      echo "HF_API_KEY=$hf_key" >> "$ENV_FILE"
    fi
    export HF_API_KEY="$hf_key"
    echo "✓ HF_API_KEY saved to .env"
    echo ""
  fi
fi

# ── Start server ───────────────────────────────────────────────────────────────
echo "Starting LawDoc backend on http://localhost:8000 ..."
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
