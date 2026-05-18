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

# HuggingFace token (required for /consult and /tanya)
echo "1) HuggingFace token  (required — for /consult and /tanya)"
echo "   Model: sirpratama/perdata-gemma4-lora-v2"
echo "   Get one at: https://huggingface.co/settings/tokens"
echo ""
read -r -p "   Paste HF_API_KEY: " hf_key
echo ""

if [ -z "$hf_key" ]; then
  echo "⚠ No HF_API_KEY entered. The /consult and /tanya endpoints will not work."
  echo "  Add it manually to .env later: HF_API_KEY=your_token"
  echo ""
fi

# HuggingFace Inference Endpoint URL (strongly recommended)
echo "2) HuggingFace Inference Endpoint URL  (recommended)"
echo "   The LoRA model is not on HF serverless API — deploy it as a dedicated endpoint:"
echo "   https://huggingface.co/sirpratama/perdata-gemma4-lora-v2 → Deploy → Inference Endpoints"
echo "   Leave blank to skip (you can add HF_ENDPOINT_URL to .env later)"
echo ""
read -r -p "   Paste HF_ENDPOINT_URL (or Enter to skip): " hf_endpoint
echo ""

# Google AI Studio key (optional, only for /ocr-explain image step)
echo "3) Google AI Studio API key  (optional — only for /ocr-explain image extraction)"
echo "   Get one free at: https://aistudio.google.com/app/apikey"
echo "   Leave blank if you don't need document image analysis"
echo ""
read -r -p "   Paste GOOGLE_API_KEY (or Enter to skip): " google_key
echo ""

cp "$EXAMPLE_FILE" "$ENV_FILE"
sed -i.bak "s|HF_API_KEY=.*|HF_API_KEY=$hf_key|" "$ENV_FILE"
sed -i.bak "s|HF_ENDPOINT_URL=.*|HF_ENDPOINT_URL=$hf_endpoint|" "$ENV_FILE"
sed -i.bak "s|GOOGLE_API_KEY=.*|GOOGLE_API_KEY=$google_key|" "$ENV_FILE"
rm -f "$ENV_FILE.bak"

echo "✓ .env created. Run: bash start.sh"
