"""
Modal deployment for LawDoc's fine-tuned Gemma 4 + LoRA.

Serves an OpenAI-compatible chat-completion API via vLLM. The FastAPI backend
calls it through huggingface_hub.InferenceClient with model="perdata-lora",
which routes to the LoRA adapter.

One-time setup:
    pip install modal
    modal setup                              # browser-based auth, one-time
    modal secret create huggingface-secret HF_TOKEN=hf_xxx
    # ^ token must have READ access to sirpratama/perdata-gemma4-lora-v2 (private)

Deploy / redeploy:
    modal deploy modal_app.py

After deploy, Modal prints a URL like:
    https://<username>--lawdoc-vllm-serve.modal.run
Put that URL in backend/.env as HF_ENDPOINT_URL.

Cost: ~$0.80/h on L4 *only while serving*. Scales to zero after 5 min idle.
"""

import modal

BASE_MODEL = "unsloth/gemma-4-E4B-it"          # unquantized; matches the LoRA's training base
LORA_REPO = "sirpratama/perdata-gemma4-lora-v2"
LORA_NAME = "perdata-lora"                      # client-side adapter name (model=... in requests)

GPU_TYPE = "L4"            # 24 GB VRAM
MAX_MODEL_LEN = 4096
SCALEDOWN_SECONDS = 300    # spin down after 5 min idle
STARTUP_TIMEOUT = 15 * 60  # first cold start downloads ~8 GB base + adapter

vllm_image = (
    modal.Image.from_registry(
        "nvidia/cuda:12.8.0-devel-ubuntu22.04",
        add_python="3.11",
    )
    .pip_install(
        "vllm>=0.7.0",
        "huggingface_hub[hf_transfer]>=0.24.0",
    )
    .env({"HF_HUB_ENABLE_HF_TRANSFER": "1"})
)

hf_cache_vol = modal.Volume.from_name("huggingface-cache", create_if_missing=True)

app = modal.App("lawdoc-vllm")


@app.function(
    image=vllm_image,
    gpu=GPU_TYPE,
    scaledown_window=SCALEDOWN_SECONDS,
    timeout=30 * 60,
    secrets=[modal.Secret.from_name("huggingface-secret")],
    volumes={"/root/.cache/huggingface": hf_cache_vol},
)
@modal.concurrent(max_inputs=32)
@modal.web_server(port=8000, startup_timeout=STARTUP_TIMEOUT)
def serve():
    import subprocess
    subprocess.Popen([
        "vllm", "serve", BASE_MODEL,
        "--enable-lora",
        "--lora-modules", f"{LORA_NAME}={LORA_REPO}",
        "--max-model-len", str(MAX_MODEL_LEN),
        "--host", "0.0.0.0",
        "--port", "8000",
    ])
