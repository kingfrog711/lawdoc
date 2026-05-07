#!/bin/bash
# First-time setup: creates .env with API keys
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
EXAMPLE_FILE="$SCRIPT_DIR/.env.example"

if [ -f "$ENV_FILE" ]; then
  echo "✓ .env already exists — skipping setup"
  exit 0
fi

echo "── LawDoc backend setup ──"
echo ""

# Google AI Studio key (for /tanya and /ocr-explain)
echo "1) Google AI Studio API key  (for legacy /tanya endpoint)"
echo "   Get one free at: https://aistudio.google.com/app/apikey"
echo "   Leave blank to skip if you only need /consult"
echo ""
read -r -p "   Paste GOOGLE_API_KEY (or Enter to skip): " google_key
echo ""

# HuggingFace token (for /consult — the main chatbot)
echo "2) HuggingFace token  (for /consult — the main AI chatbot)"
echo "   Get one at: https://huggingface.co/settings/tokens"
echo "   Model used: sirpratama/perdata-gemma4-lora"
echo ""
read -r -p "   Paste HF_API_KEY: " hf_key
echo ""

if [ -z "$hf_key" ]; then
  echo "⚠ No HF_API_KEY entered. The /consult endpoint will not work."
  echo "  Add it manually to .env later: HF_API_KEY=your_token"
  echo ""
fi

cp "$EXAMPLE_FILE" "$ENV_FILE"
sed -i.bak "s|GOOGLE_API_KEY=.*|GOOGLE_API_KEY=$google_key|" "$ENV_FILE"
sed -i.bak "s|HF_API_KEY=.*|HF_API_KEY=$hf_key|" "$ENV_FILE"
rm -f "$ENV_FILE.bak"

echo "✓ .env created. Run: bash start.sh"
