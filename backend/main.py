"""
LawDoc FastAPI backend — calls Gemma 4 via Google AI Studio.
Run: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

import os
import json
import re
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")
genai.configure(api_key=GOOGLE_API_KEY)

app = FastAPI(title="LawDoc API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

SYSTEM_PROMPT = """Anda adalah asisten hukum perdata Indonesia dari LawDoc — membantu warga biasa yang tidak mampu membayar pengacara.

CARA KERJA:
1. Baca situasi pengguna dengan cermat — catat fakta spesifik: siapa saja pihaknya, berapa nilainya, berapa lama, apa yang sudah terjadi.
2. Pilih pasal KUHPerdata yang PALING RELEVAN dengan situasi itu.
3. Kutip bunyi pasal aslinya secara lengkap.
4. WAJIB jelaskan secara konkret bagaimana pasal itu berlaku pada kasus pengguna — gunakan detail dari cerita mereka (nama pihak, jumlah, hubungan keluarga, dsb). Jangan hanya parafrase pasal.
5. Berikan langkah nyata yang bisa langsung dilakukan — konkret, bukan saran generik.

Jika ada dokumen yang dilampirkan (ditandai [DOKUMEN TERLAMPIR]), analisis isi dokumen itu secara spesifik dan kaitkan dengan pertanyaan pengguna.

GAYA BAHASA: Bahasa sehari-hari Indonesia. Hindari jargon hukum — kalau harus pakai istilah hukum, langsung jelaskan artinya.

WAJIB: Kembalikan HANYA JSON valid persis format berikut, tanpa teks atau markdown di luar JSON:
{
  "summary": "Penjelasan 2-3 kalimat yang SPESIFIK pada situasi pengguna — sebutkan fakta dari cerita mereka, bukan jawaban generik",
  "legal_basis": {
    "pasal": "KUHPerdata Pasal XXX",
    "text": "Bunyi lengkap pasal yang dikutip",
    "application": "Penjelasan konkret bagaimana pasal ini berlaku pada kasus pengguna — gunakan angka, nama pihak, dan detail dari cerita mereka. Misal: karena ada 3 anak dan istri masih hidup, maka berdasarkan pasal ini..."
  },
  "steps": [
    "Langkah 1 — spesifik dan bisa langsung dilakukan",
    "Langkah 2",
    "Langkah 3"
  ],
  "disclaimer": "Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. Hubungi pengacara atau LBH terdekat untuk pendampingan kasus Anda."
}"""


class TanyaRequest(BaseModel):
    message: str
    document_text: str | None = None


class LegalBasis(BaseModel):
    pasal: str
    text: str
    application: str | None = None


class LegalResponse(BaseModel):
    summary: str
    legal_basis: LegalBasis
    steps: list[str]
    disclaimer: str


MODEL_NAME = "gemma-4-31b-it"  # gemma-4-26b-a4b-it for faster MoE variant


def _extract_json(text: str) -> dict:
    """
    Gemma 4 is a reasoning model — it may emit chain-of-thought text before
    the final JSON answer. This finds the last well-formed JSON object in the
    output that contains the required 'summary' and 'legal_basis' keys.
    """
    # Strip markdown code fences anywhere in the text
    text = re.sub(r"```(?:json)?", "", text).replace("```", "").strip()

    # Fast path: the whole text is valid JSON
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Find all top-level JSON object candidates (handles nested braces)
    candidates = []
    depth = 0
    start = None
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}" and depth > 0:
            depth -= 1
            if depth == 0 and start is not None:
                candidates.append(text[start : i + 1])

    # Try from last candidate backward — the final JSON block is the answer
    for chunk in reversed(candidates):
        try:
            data = json.loads(chunk)
            if "summary" in data and "legal_basis" in data:
                return data
        except json.JSONDecodeError:
            continue

    raise ValueError("No valid LegalResponse JSON found in model output")


@app.get("/health")
def health():
    return {"status": "ok", "model": MODEL_NAME}


@app.post("/tanya", response_model=LegalResponse)
async def tanya(req: TanyaRequest):
    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY not set")

    model = genai.GenerativeModel(
        model_name=MODEL_NAME,
        system_instruction=SYSTEM_PROMPT,
        generation_config=genai.GenerationConfig(
            temperature=0.4,
            max_output_tokens=2048,
        ),
    )

    try:
        prompt = req.message
        if req.document_text:
            prompt = f"{req.message}\n\n[DOKUMEN TERLAMPIR]\n{req.document_text}"
        response = model.generate_content(prompt)
        raw = response.text.strip()

        data = _extract_json(raw)
        return LegalResponse(**data)

    except (json.JSONDecodeError, ValueError, KeyError) as e:
        print(f"[tanya] JSON extraction failed: {e}")
        raise HTTPException(status_code=500, detail=f"Model returned unparseable output: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/ocr-explain")
async def ocr_explain(doc_base64: str, filename: str = "document"):
    """
    Multimodal endpoint: send base64 image of a legal document,
    Gemma 4 vision extracts and explains key clauses.
    """
    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY not set")

    import base64

    model = genai.GenerativeModel(MODEL_NAME)

    prompt = """Anda melihat sebuah dokumen hukum Indonesia.
    Tolong:
    1. Identifikasi jenis dokumen ini
    2. Ekstrak 3-5 klausul atau poin penting
    3. Jelaskan setiap klausul dalam bahasa sederhana
    4. Tandai klausul yang perlu perhatian khusus

    Format respons dalam Bahasa Indonesia yang mudah dipahami."""

    try:
        image_data = base64.b64decode(doc_base64)
        response = model.generate_content([
            prompt,
            {"mime_type": "image/jpeg", "data": image_data},
        ])
        return {"explanation": response.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
