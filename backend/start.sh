#!/bin/bash
# Load env and start the backend
set -a
source .env
set +a
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
