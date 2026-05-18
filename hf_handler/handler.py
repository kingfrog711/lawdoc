from typing import Any, Dict
from transformers import AutoTokenizer, AutoModelForCausalLM, BitsAndBytesConfig
from peft import PeftModel
import torch

# Patch: Gemma 4 / Unsloth tokenizer_config stores extra_special_tokens as a list,
# but this transformers version expects a dict — convert it silently before loading.
import transformers.tokenization_utils_base as _tub
_orig = _tub.PreTrainedTokenizerBase._set_model_specific_special_tokens
def _patched(self, special_tokens):
    if isinstance(special_tokens, list):
        special_tokens = {}
    _orig(self, special_tokens)
_tub.PreTrainedTokenizerBase._set_model_specific_special_tokens = _patched


class EndpointHandler:
    def __init__(self, path=""):
        BASE_MODEL = "unsloth/gemma-4-e4b-it-unsloth-bnb-4bit"

        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.float16,
            bnb_4bit_use_double_quant=True,
        )

        self.tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
        base = AutoModelForCausalLM.from_pretrained(
            BASE_MODEL,
            quantization_config=bnb_config,
            device_map="auto",
        )
        self.model = PeftModel.from_pretrained(base, path)
        self.model.eval()

    def __call__(self, data: Dict[str, Any]) -> Any:
        messages = data.get("messages", [])
        max_tokens = int(data.get("max_tokens", 2048))
        temperature = float(data.get("temperature", 0.4))

        text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )
        inputs = self.tokenizer(text, return_tensors="pt").to(self.model.device)

        with torch.no_grad():
            output_ids = self.model.generate(
                **inputs,
                max_new_tokens=max_tokens,
                temperature=temperature if temperature > 0 else 1.0,
                do_sample=temperature > 0,
                pad_token_id=self.tokenizer.eos_token_id,
            )

        new_tokens = output_ids[0][inputs["input_ids"].shape[1]:]
        result = self.tokenizer.decode(new_tokens, skip_special_tokens=True)

        return {
            "choices": [
                {
                    "index": 0,
                    "message": {"role": "assistant", "content": result},
                    "finish_reason": "stop",
                }
            ]
        }
