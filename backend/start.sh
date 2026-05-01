#!/bin/bash
# Start the LawDoc backend. Runs setup.sh first if .env is missing.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
  echo ".env not found — running setup..."
  bash "$SCRIPT_DIR/setup.sh"
fi

set -a
source "$SCRIPT_DIR/.env"
set +a

uvicorn main:app --host 0.0.0.0 --port 8000 --reload
