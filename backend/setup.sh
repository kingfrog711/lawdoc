#!/bin/bash
# First-time setup: creates .env from .env.example if it doesn't exist
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
echo "You need a Google AI Studio API key."
echo "Get one free at: https://aistudio.google.com/app/apikey"
echo ""
read -r -p "Paste your GOOGLE_API_KEY: " key

if [ -z "$key" ]; then
  echo "Error: no key entered. Run setup.sh again when you have the key."
  exit 1
fi

cp "$EXAMPLE_FILE" "$ENV_FILE"
# Replace the placeholder line
sed -i.bak "s|GOOGLE_API_KEY=.*|GOOGLE_API_KEY=$key|" "$ENV_FILE"
rm -f "$ENV_FILE.bak"

echo ""
echo "✓ .env created. Run: bash start.sh"
