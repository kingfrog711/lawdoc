# LawDoc — Session Handoff Report
**Date:** 2026-05-19
**Branch:** feat/rafi
**Project:** LawDoc — Indonesian civil law consultation app (Flutter + FastAPI)

---

## TL;DR

- AI model is now the custom HF LoRA fine-tune `sirpratama/perdata-gemma4-lora-v2` (Gemma 4 E4B + KUHPerdata data).
- **Hosting moved off HF Inference Endpoints → Modal** because Gemma 4 isn't in HF's Catalog yet (vLLM/TGI engines are locked for it) and the Custom-task toolkit is incompatible with the transformers version Gemma 4 requires.
- Modal runs vLLM in our own container — no catalog gating, scales to zero between requests.

---

## What's in the repo now

### `modal_app.py` (new, project root)
Modal app definition. Runs `vllm serve unsloth/gemma-4-E4B-it --enable-lora --lora-modules perdata-lora=sirpratama/perdata-gemma4-lora-v2` on an L4 GPU, OpenAI-compatible API on port 8000. Scales to zero after 5 min idle.

### `backend/main.py`
- `_call_hf()` rewritten: when `HF_ENDPOINT_URL` is set, builds an `InferenceClient(base_url=..., token=...)` and passes `model=HF_LORA_ADAPTER_NAME` to `chat_completion()` so vLLM routes to the LoRA adapter.
- New env var `HF_LORA_ADAPTER_NAME` (default `perdata-lora`). Must match `LORA_NAME` in `modal_app.py`.
- Fallback path (no `HF_ENDPOINT_URL`) tries HF serverless by model ID — almost certainly fails for a private custom LoRA, kept only as a "code still runs" safety net.

### `backend/.env.example`
Three keys:
- `HF_API_KEY` — required; HF token with read access to the private LoRA repo.
- `HF_ENDPOINT_URL` — paste the Modal URL after deploy.
- `HF_LORA_ADAPTER_NAME` — defaults to `perdata-lora`.
- `GOOGLE_API_KEY` — optional, only for `/ocr-explain` image OCR.

### `hf_handler/` (untouched, stale)
Custom HF Inference Endpoint handler from the previous attempt. **No longer used.** Keeping it for now in case we ever need to revisit. Delete once Modal is verified end-to-end.

---

## What you need to do (in order)

1. **Install Modal**
   ```
   pip install modal
   modal setup       # one-time browser auth
   ```

2. **Create the HF secret on Modal**
   ```
   modal secret create huggingface-secret HF_TOKEN=hf_xxxxxxxxxxxx
   ```
   The token must have READ access to `sirpratama/perdata-gemma4-lora-v2` (it's private). Public access to `unsloth/gemma-4-E4B-it` requires no auth but the same token works.

3. **Deploy**
   ```
   modal deploy modal_app.py
   ```
   First deploy builds the image (~5 min). First request triggers cold start (~3–8 min: download base ~8 GB + adapter, load on GPU, start server). Subsequent requests reuse the warm container until the 5-min idle timeout.

4. **Get the URL**
   Modal prints something like `https://your-username--lawdoc-vllm-serve.modal.run`. Copy it.

5. **Wire it into the backend**
   In `backend/.env`:
   ```
   HF_ENDPOINT_URL=https://your-username--lawdoc-vllm-serve.modal.run
   ```
   Leave `HF_LORA_ADAPTER_NAME=perdata-lora` (default).

6. **Test**
   ```
   cd backend && bash start.sh
   curl http://localhost:8000/health
   # Then exercise /consult or /tanya from the Flutter app
   ```
   First call after deploy will be slow (cold start). Subsequent calls fast.

---

## Why Modal instead of HF Inference Endpoints

The previous session tried to deploy via HF Endpoints. Found three hard blockers:

1. **HF's Custom-task container ships with `huggingface_inference_toolkit` that does `from transformers.file_utils import is_tf_available`.** This import path was removed in modern transformers. Gemma 4 requires a modern transformers. Incompatible — the toolkit crashes before our `handler.py` even loads.

2. **HF's "streamlined" engines (vLLM, TGI, SGLang) only work for Catalog-verified models.** Gemma 4 is not in HF's Catalog as of 2026-05. Neither `google/gemma-4-E4B-it` nor any unsloth variant. So vLLM stays grayed out in the UI.

3. **Net effect:** every Gemma 4 deploy path on HF Endpoints is closed for now.

Modal sidesteps all of this — we run our own vLLM container, no catalog gating, no toolkit. Cost-wise, scale-to-zero means we only pay while the model is actively serving, which is ideal for an MVP/demo.

---

## Backend Architecture (unchanged)

```
Flutter app
    └── AiService.consult() → POST /consult
Backend (FastAPI, port 8000)
    ├── /consult  — stateful (extracting → confirming → consulting state machine)
    │     └── _call_hf() → InferenceClient → Modal vLLM endpoint → perdata-lora adapter
    ├── /tanya    — legacy simple Q&A → same _call_hf()
    ├── /ocr-explain — hybrid: Google gemini-1.5-flash (OCR) → _call_hf (legal analysis)
    └── /health   — returns model name + version
```

Session state remains client-side in Flutter (`SessionService` → `lawdoc_session.json`).

---

## Potential issues to watch on first deploy

| Symptom | Likely cause | Fix |
|---|---|---|
| `gemma4` architecture not recognized in vLLM logs | vLLM version too old | Bump `vllm>=0.7.0` in modal_app.py to a newer pin (e.g. `>=0.8.0`) |
| LoRA fails to load — base mismatch | Adapter's `base_model_name_or_path` references unsloth bnb-4bit, but we use unsloth fp16 | Pass `base_model_name` override via `--lora-modules '{"name":"perdata-lora","path":"...","base_model_name":"unsloth/gemma-4-E4B-it"}'` |
| OOM on L4 (24 GB) | KV cache too large for context window | Lower `MAX_MODEL_LEN` in modal_app.py |
| HF token rejected | Secret name mismatch or token scope | Verify `modal secret list` shows `huggingface-secret` and the token has read access to the LoRA repo |
| Cold start >15 min | Network / HF download slow | Bump `STARTUP_TIMEOUT` in modal_app.py |

---

## Teammate parallel work

Backend + Flutter deployment can proceed without waiting for the model URL:
- Backend deploys with a placeholder `HF_ENDPOINT_URL`; only `/consult` and `/tanya` will 500. `/health` still works.
- Once the Modal URL is live, update the env var in the backend's hosting platform — no code change.

---

## Minor inconsistency noted

`backend/main.py:31` declares `FastAPI(title="LawDoc API", version="2.0.0")` but `/health` returns `"version": "2.1.0"`. Worth bumping the FastAPI constructor to match (or to `2.2.0` for the Modal migration).
