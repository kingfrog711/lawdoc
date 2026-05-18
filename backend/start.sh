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

# ── Validate required API keys ─────────────────────────────────────────────────
_missing=0

if [ -z "$GOOGLE_API_KEY" ]; then
  echo "✗ GOOGLE_API_KEY is not set. Add it to $ENV_FILE and retry."
  _missing=1
fi

if [ -z "$HF_API_KEY" ]; then
  echo "✗ HF_API_KEY is not set. Get a free token at https://huggingface.co/settings/tokens"
  echo "  Add it to $ENV_FILE and retry."
  _missing=1
fi

if [ "$_missing" -eq 1 ]; then
  echo ""
  echo "Both GOOGLE_API_KEY and HF_API_KEY are required. Server not started."
  exit 1
fi

echo "✓ GOOGLE_API_KEY present"
echo "✓ HF_API_KEY present"
echo ""

# ── Start server ───────────────────────────────────────────────────────────────
echo "Starting LawDoc backend on http://localhost:8000 ..."
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
