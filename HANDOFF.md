# LawDoc — Session Handoff Report
**Date:** 2026-05-19  
**Branch:** main  
**Project:** LawDoc — Indonesian civil law consultation app (Flutter + FastAPI)

---

## What Was Done This Session

Migrated the AI backend from **Google AI Studio (gemma-4-31b-it)** to a custom HuggingFace LoRA fine-tune: **`sirpratama/perdata-gemma4-lora-v2`** (Gemma 4 4B, trained on KUHPerdata data).

---

## Files Changed

### `backend/main.py`
- Replaced `google-generativeai` with `huggingface_hub.InferenceClient`
- `_call_gemini()` → `_call_hf()` — calls `HF_ENDPOINT_URL` (dedicated endpoint) or falls back to model ID
- `/tanya` endpoint now uses `_call_hf` instead of `genai.GenerativeModel`
- `/ocr-explain` now hybrid: **Step 1** Google `gemini-1.5-flash` extracts text from image → **Step 2** HF model does legal analysis
- `GOOGLE_API_KEY` kept but only used by `/ocr-explain` image step
- Version bumped to `2.1.0`

### `backend/requirements.txt`
- Added `huggingface_hub>=0.24.0`
- Kept `google-generativeai==0.8.3` (for OCR only)

### `backend/.env.example`
```
HF_API_KEY=your_huggingface_token_here
HF_ENDPOINT_URL=                          # paste endpoint URL here after deployment
GOOGLE_API_KEY=your_google_key_here       # optional, only for /ocr-explain
```

### `backend/setup.sh`
Updated to prompt for HF token (required), HF endpoint URL (recommended), Google key (optional).

### `hf_handler/handler.py` ← uploaded to HF model repo
Custom HuggingFace Inference Endpoint handler. Key details:
- Base model: `unsloth/gemma-4-e4b-it-unsloth-bnb-4bit`
- Loads LoRA adapter from `path` using PEFT
- **Monkey-patches** `transformers.tokenization_utils_base._set_model_specific_special_tokens` to fix Gemma 4 tokenizer bug (`extra_special_tokens` list vs dict)
- Returns OpenAI-compatible response format for `InferenceClient.chat_completion`

### `hf_handler/requirements.txt` ← uploaded to HF model repo
```
transformers>=4.52.0
peft>=0.10.0
bitsandbytes>=0.43.0
accelerate>=0.27.0
```

---

## HuggingFace Endpoint Status

**Model repo:** `sirpratama/perdata-gemma4-lora-v2`  
**Deployment config:**
- Cloud: Google Cloud Platform
- Hardware: Nvidia T4 · 1 GPU · 16 GB VRAM · $0.50/h
- Region: us-east4
- Authentication: Private (uses HF token)
- Scale to Zero: enabled (after 1 hour idle)
- Task: Custom (uses `handler.py`)

**Deployment was in progress at end of session.** Previous attempts failed with:
1. Missing `handler.py` → fixed by creating custom handler
2. Tokenizer `extra_special_tokens` list/dict bug → fixed with monkey-patch in handler.py
3. `gemma4` architecture not recognized → fixed by pinning `transformers>=4.52.0` in HF repo requirements.txt
4. `is_tf_available` import error (caused by git HEAD transformers) → fixed by switching from `git+https://...` back to `>=4.52.0` PyPI release

**Next step:** Confirm endpoint starts successfully. If it does, copy the endpoint URL and add to `backend/.env`:
```
HF_ENDPOINT_URL=https://your-endpoint-id.us-east4.gcp.endpoints.huggingface.cloud
```

---

## If Endpoint Still Fails

Check the logs for the new error. Common next issues:
- **OOM / out of memory** → T4 has 16 GB, model needs ~5-6 GB in 4-bit, should be fine
- **`gemma4` still not recognized** → `transformers>=4.52.0` may need to be bumped to `>=4.53.0`
- **PEFT load error** → check if `adapter_config.json` base model path is accessible from HF hub
- **Slow cold start** → normal, T4 takes 3-8 minutes to load a 4B model on first request after scale-to-zero

---

## Backend Architecture Summary

```
Flutter app
    └── AiService.consult() → POST /consult
Backend (FastAPI, port 8000)
    ├── /consult  — stateful (extracting → confirming → consulting state machine)
    │     └── _call_hf() → InferenceClient → HF Endpoint → perdata-gemma4-lora-v2
    ├── /tanya    — legacy simple Q&A → same _call_hf()
    ├── /ocr-explain — hybrid: Google gemini-1.5-flash (OCR) → _call_hf (legal analysis)
    └── /health   — returns model name + version
```

Session state is managed **client-side** in Flutter (`SessionService` → `lawdoc_session.json`). Every `/consult` request includes full context + history.

---

## Key Env Variables

| Variable | Used by | Required? |
|---|---|---|
| `HF_API_KEY` | `/consult`, `/tanya`, `/ocr-explain` | Yes |
| `HF_ENDPOINT_URL` | All HF calls (overrides model ID) | Strongly recommended |
| `GOOGLE_API_KEY` | `/ocr-explain` image step only | Optional |

---

## How to Start the Backend

```bash
cd backend
bash start.sh          # prompts for keys on first run, starts uvicorn on :8000
```
