"""
LawDoc FastAPI backend v2.1
/consult     — stateful legal consultant (sirpratama/perdata-gemma4-lora-v2 via HuggingFace)
/tanya       — legacy Q&A endpoint (same HF model)
/ocr-explain — hybrid: Google AI Studio extracts image text → HF model for legal analysis
"""

import asyncio
import os
import json
import re
import tempfile
from typing import Optional

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from huggingface_hub import InferenceClient
import google.generativeai as genai  # kept for /ocr-explain image extraction only

load_dotenv()

HF_API_KEY = os.getenv("HF_API_KEY", "")
HF_ENDPOINT_URL = os.getenv("HF_ENDPOINT_URL", "")  # OpenAI-compat endpoint (Modal/vLLM)
HF_LORA_ADAPTER_NAME = os.getenv("HF_LORA_ADAPTER_NAME", "perdata-lora")  # vLLM --lora-modules name
CONSULT_MODEL = "sirpratama/perdata-gemma4-lora-v2"

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")  # only used by /ocr-explain image step
if GOOGLE_API_KEY:
    genai.configure(api_key=GOOGLE_API_KEY)

LLAMA_CLOUD_API_KEY = os.getenv("LLAMA_CLOUD_API_KEY", "")  # for /parse-document
MAX_UPLOAD_BYTES = 15 * 1024 * 1024  # 15 MB
PARSE_ALLOWED_EXTS = {
    ".pdf", ".docx", ".doc", ".pptx", ".ppt", ".xlsx", ".xls",
    ".txt", ".md", ".rtf", ".html", ".htm", ".odt", ".epub",
    ".png", ".jpg", ".jpeg", ".webp", ".bmp", ".gif", ".tiff",
}

app = FastAPI(title="LawDoc API", version="2.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Pydantic models ────────────────────────────────────────────────────────────

class SessionContext(BaseModel):
    agama: Optional[str] = None
    domicile: Optional[str] = None
    budget: Optional[str] = None
    case_type: Optional[str] = None
    confirmed: bool = False
    flow_state: str = "extracting"


class HistoryMessage(BaseModel):
    role: str  # "user" | "model"
    content: str


class ConsultRequest(BaseModel):
    session_id: str
    message: str
    document_text: Optional[str] = None
    context: SessionContext
    history: list[HistoryMessage] = []


class LegalBasisOut(BaseModel):
    pasal: str
    text: str
    application: Optional[str] = None


class StructuredOutput(BaseModel):
    legal_basis: Optional[LegalBasisOut] = None
    docs_needed: Optional[list[str]] = None
    steps: Optional[list[str]] = None
    outcome: Optional[str] = None
    refer_to_lawyer: bool = False


class ContextUpdate(BaseModel):
    agama: Optional[str] = None
    domicile: Optional[str] = None
    budget: Optional[str] = None
    case_type: Optional[str] = None
    confirmed: bool = False
    flow_state: str = "extracting"


class ConsultResponse(BaseModel):
    message: str
    flow_state: str
    context_update: ContextUpdate
    structured: Optional[StructuredOutput] = None
    disclaimer: str = (
        "Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. "
        "Hubungi pengacara atau LBH terdekat untuk pendampingan kasus Anda."
    )


# Legacy models (preserved for /tanya and /ocr-explain)
class TanyaRequest(BaseModel):
    message: str
    document_text: Optional[str] = None


class LegalBasis(BaseModel):
    pasal: str
    text: str
    application: Optional[str] = None


class LegalResponse(BaseModel):
    summary: str
    legal_basis: LegalBasis
    steps: list[str]
    disclaimer: str


# ── HuggingFace inference helper ──────────────────────────────────────────────

async def _call_hf(system: str, history: list[HistoryMessage], message: str) -> str:
    def _sync_call() -> str:
        messages: list[dict] = [{"role": "system", "content": system}]
        for msg in history:
            role = "assistant" if msg.role == "model" else msg.role
            messages.append({"role": role, "content": msg.content})
        messages.append({"role": "user", "content": message})

        if HF_ENDPOINT_URL:
            # OpenAI-compatible endpoint (Modal/vLLM). Adapter name routes to the LoRA.
            client = InferenceClient(base_url=HF_ENDPOINT_URL, token=HF_API_KEY or None)
            resp = client.chat_completion(
                messages=messages,
                model=HF_LORA_ADAPTER_NAME,
                max_tokens=2048,
                temperature=0.4,
            )
        else:
            # Fallback: try HF serverless inference by model ID (unlikely to work for private LoRA)
            if not HF_API_KEY:
                raise HTTPException(status_code=500, detail="HF_API_KEY not configured in .env")
            client = InferenceClient(model=CONSULT_MODEL, token=HF_API_KEY)
            resp = client.chat_completion(messages=messages, max_tokens=2048, temperature=0.4)

        return resp.choices[0].message.content

    return await asyncio.to_thread(_sync_call)


def _extract_json(text: str) -> dict:
    text = re.sub(r"```(?:json)?", "", text).replace("```", "").strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    candidates, depth, start = [], 0, None
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}" and depth > 0:
            depth -= 1
            if depth == 0 and start is not None:
                candidates.append(text[start: i + 1])
    for chunk in reversed(candidates):
        try:
            return json.loads(chunk)
        except json.JSONDecodeError:
            continue
    raise ValueError("No valid JSON found in model output")


# ── Prompts ────────────────────────────────────────────────────────────────────

def _extraction_system(ctx: SessionContext) -> str:
    known_lines = []
    if ctx.agama:
        known_lines.append(f"- Agama: {ctx.agama}")
    if ctx.domicile:
        known_lines.append(f"- Domisili: {ctx.domicile}")
    if ctx.budget:
        known_lines.append(f"- Budget: {ctx.budget}")
    known = "\n".join(known_lines) if known_lines else "- Belum ada yang diketahui"

    missing = []
    if not ctx.agama:
        missing.append("agama (Islam/Kristen/Hindu/Buddha/Konghucu)")
    if not ctx.domicile:
        missing.append("domisili (kota atau provinsi)")
    if not ctx.budget:
        missing.append("kemampuan biaya (pro_bono, <500rb, 500rb-2jt, >2jt)")
    missing_str = ", ".join(missing) if missing else "–"

    return f"""Anda adalah LawDoc, konsultan hukum perdata Indonesia yang membantu warga biasa memahami hak hukum mereka.

KONTEKS YANG SUDAH DIKETAHUI:
{known}

INFORMASI YANG MASIH PERLU DIGALI: {missing_str}

INSTRUKSI:
1. Respons dengan empati dalam Bahasa Indonesia sehari-hari
2. Tunjukkan bahwa Anda memahami masalah pengguna
3. Jika ada informasi yang belum diketahui dan relevan untuk saran yang tepat, tanyakan SATU pertanyaan secara natural — jangan tanyakan semua sekaligus
4. Ekstrak dari pesan terbaru pengguna (null jika tidak disebutkan):
   - agama: Islam | Kristen | Hindu | Buddha | Konghucu | null
   - domicile: nama kota atau provinsi Indonesia | null
   - budget: "pro_bono" | "<500rb" | "500rb-2jt" | ">2jt" | null

WAJIB kembalikan HANYA JSON valid, tidak ada teks di luar JSON:
{{
  "message": "respons natural Anda",
  "extracted": {{
    "agama": null,
    "domicile": null,
    "budget": null
  }}
}}"""


def _consulting_system(ctx: SessionContext) -> str:
    budget_label = {
        "pro_bono": "mencari bantuan pro bono / LBH",
        "<500rb": "budget di bawah Rp500rb",
        "500rb-2jt": "budget Rp500rb–Rp2jt",
        ">2jt": "budget di atas Rp2jt",
    }.get(ctx.budget or "", ctx.budget or "tidak ditentukan")

    if ctx.domicile and "aceh" in (ctx.domicile or "").lower():
        jurisdiction = "Mahkamah Syar'iyah Aceh — Qanun dan KHI berlaku"
    elif ctx.agama == "Islam":
        jurisdiction = "Pengadilan Agama — KHI berlaku untuk pernikahan dan waris; KUHPerdata untuk perdata umum"
    else:
        jurisdiction = "Pengadilan Negeri — KUHPerdata berlaku"

    return f"""Anda adalah LawDoc, konsultan hukum perdata Indonesia spesialis KUHPerdata dan hukum keluarga.

PROFIL PENGGUNA:
- Agama: {ctx.agama}
- Domisili: {ctx.domicile}
- {budget_label}
- Yurisdiksi: {jurisdiction}

INSTRUKSI:
1. Klasifikasikan kasus ke: perceraian | warisan | tanah | utang | unclear
2. Berikan konsultasi mendalam dengan nuansa yang tepat:
   PERCERAIAN: wajib mediasi dulu (PERMA 1/2016, maks 30 hari), cek beda agama (UU 1/1974)
   WARISAN: pertimbangkan sistem adat (Minangkabau=matrilineal via KAN, Batak=patrilineal via Dalihan na Tolu, Bali=purusa, Jawa=bilateral sepikul segendong), KHI faraidh untuk Muslim, KUHPerdata 4 golongan untuk non-Muslim
   TANAH: SHM = bukti terkuat (UUPA 5/1960), ajukan ke BPN dulu sebelum litigasi
   UTANG: wanprestasi → somasi dulu (Pasal 1243), PMH → langsung PN (Pasal 1365); gugatan sederhana jika <Rp500jt
3. Kutip pasal yang PALING RELEVAN dengan bunyi aslinya
4. Daftar dokumen yang dibutuhkan sesuai profil pengguna
5. Langkah konkret yang bisa langsung dilakukan — bukan saran generik
6. Perkiraan hasil dan timeline yang realistis
7. Jika kasus di luar 4 kategori atau sangat kompleks, set refer_to_lawyer ke true

WAJIB kembalikan HANYA JSON valid:
{{
  "message": "respons konsultasi natural dan empatis",
  "case_type": "perceraian|warisan|tanah|utang|unclear",
  "legal_basis": {{
    "pasal": "KUHPerdata Pasal XXX",
    "text": "Bunyi lengkap pasal yang dikutip",
    "application": "Penerapan konkret pada kasus pengguna — gunakan detail spesifik mereka"
  }},
  "docs_needed": ["dokumen 1", "dokumen 2"],
  "steps": ["Langkah 1 konkret", "Langkah 2"],
  "outcome": "Perkiraan hasil dan timeline realistis",
  "refer_to_lawyer": false
}}

Jika masih perlu info lebih atau kasus unclear: set legal_basis/docs_needed/steps/outcome ke null, refer_to_lawyer ke false, dan tanyakan di message."""


# ── State machine ──────────────────────────────────────────────────────────────

_DISCLAIMER = (
    "Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi. "
    "Hubungi pengacara atau LBH terdekat untuk pendampingan kasus Anda."
)
_CONFIRM_WORDS = {"ya", "iya", "benar", "betul", "correct", "bener", "yap", "yep", "ok", "oke", "setuju", "tepat"}


def _budget_label(budget: str) -> str:
    return {
        "pro_bono": "mencari bantuan pro bono",
        "<500rb": "budget di bawah Rp500rb",
        "500rb-2jt": "budget Rp500rb–Rp2jt",
        ">2jt": "budget di atas Rp2jt",
    }.get(budget, budget)


async def _handle_extracting(req: ConsultRequest) -> ConsultResponse:
    user_msg = req.message
    if req.document_text:
        user_msg += f"\n\n[DOKUMEN TERLAMPIR]\n{req.document_text}"

    raw = await _call_hf(_extraction_system(req.context), req.history, user_msg)
    data = _extract_json(raw)

    extracted = data.get("extracted", {})
    message = data.get("message", raw)

    new_agama = extracted.get("agama") or req.context.agama
    new_domicile = extracted.get("domicile") or req.context.domicile
    new_budget = extracted.get("budget") or req.context.budget

    # All 3 known → generate confirmation message, no extra model call
    if new_agama and new_domicile and new_budget:
        confirm_msg = (
            f"Saya deteksi Anda beragama {new_agama}, berdomisili di {new_domicile}, "
            f"dan {_budget_label(new_budget)} — apakah informasi ini benar?"
        )
        return ConsultResponse(
            message=confirm_msg,
            flow_state="confirming",
            context_update=ContextUpdate(
                agama=new_agama,
                domicile=new_domicile,
                budget=new_budget,
                flow_state="confirming",
                confirmed=False,
            ),
            disclaimer=_DISCLAIMER,
        )

    return ConsultResponse(
        message=message,
        flow_state="extracting",
        context_update=ContextUpdate(
            agama=new_agama,
            domicile=new_domicile,
            budget=new_budget,
            flow_state="extracting",
            confirmed=False,
        ),
        disclaimer=_DISCLAIMER,
    )


async def _handle_confirming(req: ConsultRequest) -> ConsultResponse:
    tokens = set(req.message.lower().split())
    is_confirmed = bool(tokens & _CONFIRM_WORDS)

    if is_confirmed:
        # Jump straight into consultation using the full history the user already provided
        consulting_ctx = SessionContext(
            agama=req.context.agama,
            domicile=req.context.domicile,
            budget=req.context.budget,
            confirmed=True,
            flow_state="consulting",
        )
        synthetic_req = ConsultRequest(
            session_id=req.session_id,
            message="Berdasarkan percakapan kita, tolong berikan analisis hukum untuk masalah saya.",
            document_text=req.document_text,
            context=consulting_ctx,
            history=req.history + [HistoryMessage(role="user", content=req.message)],
        )
        return await _handle_consulting(synthetic_req)

    # User is correcting — re-run extraction on the correction message
    return await _handle_extracting(req)


async def _handle_consulting(req: ConsultRequest) -> ConsultResponse:
    user_msg = req.message
    if req.document_text:
        user_msg += f"\n\n[DOKUMEN TERLAMPIR]\n{req.document_text}"

    raw = await _call_hf(_consulting_system(req.context), req.history, user_msg)
    data = _extract_json(raw)

    case_type = data.get("case_type") or req.context.case_type
    lb_data = data.get("legal_basis")

    structured = None
    if lb_data or data.get("docs_needed") or data.get("steps"):
        structured = StructuredOutput(
            legal_basis=LegalBasisOut(**lb_data) if lb_data else None,
            docs_needed=data.get("docs_needed") or None,
            steps=data.get("steps") or None,
            outcome=data.get("outcome"),
            refer_to_lawyer=data.get("refer_to_lawyer", False),
        )

    next_state = "referring" if data.get("refer_to_lawyer") else "consulting"

    return ConsultResponse(
        message=data.get("message", raw),
        flow_state=next_state,
        context_update=ContextUpdate(
            agama=req.context.agama,
            domicile=req.context.domicile,
            budget=req.context.budget,
            case_type=case_type,
            confirmed=True,
            flow_state=next_state,
        ),
        structured=structured,
        disclaimer=_DISCLAIMER,
    )


# ── Endpoints ──────────────────────────────────────────────────────────────────

@app.get("/health")
def health():
    return {"status": "ok", "model": CONSULT_MODEL, "version": "2.1.0"}


@app.post("/consult", response_model=ConsultResponse)
async def consult(req: ConsultRequest):
    try:
        state = req.context.flow_state
        if state == "extracting":
            return await _handle_extracting(req)
        elif state == "confirming":
            return await _handle_confirming(req)
        elif state in ("consulting", "referring"):
            return await _handle_consulting(req)
        else:
            return await _handle_extracting(req)
    except HTTPException:
        raise
    except Exception as e:
        print(f"[consult] Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ── Legacy endpoints (preserved, untouched) ────────────────────────────────────

LEGACY_SYSTEM_PROMPT = """Anda adalah asisten hukum perdata Indonesia dari LawDoc — membantu warga biasa yang tidak mampu membayar pengacara.

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

def _extract_json_legacy(text: str) -> dict:
    text = re.sub(r"```(?:json)?", "", text).replace("```", "").strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    candidates, depth, start = [], 0, None
    for i, ch in enumerate(text):
        if ch == "{":
            if depth == 0:
                start = i
            depth += 1
        elif ch == "}" and depth > 0:
            depth -= 1
            if depth == 0 and start is not None:
                candidates.append(text[start: i + 1])
    for chunk in reversed(candidates):
        try:
            data = json.loads(chunk)
            if "summary" in data and "legal_basis" in data:
                return data
        except json.JSONDecodeError:
            continue
    raise ValueError("No valid LegalResponse JSON found in model output")


@app.post("/tanya", response_model=LegalResponse)
async def tanya(req: TanyaRequest):
    prompt = req.message
    if req.document_text:
        prompt = f"{req.message}\n\n[DOKUMEN TERLAMPIR]\n{req.document_text}"
    try:
        raw = await _call_hf(LEGACY_SYSTEM_PROMPT, [], prompt)
        data = _extract_json_legacy(raw.strip())
        return LegalResponse(**data)
    except (json.JSONDecodeError, ValueError, KeyError) as e:
        raise HTTPException(status_code=500, detail=f"Model returned unparseable output: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── /parse-document — LlamaParse-backed document → text ──────────────────────

async def _llamaparse_to_text(file_bytes: bytes, filename: str) -> str:
    """Parse a document via LlamaParse and return concatenated markdown text."""
    from llama_cloud_services import LlamaParse  # lazy import — heavy deps

    suffix = os.path.splitext(filename)[1] or ".pdf"
    fd, tmp_path = tempfile.mkstemp(suffix=suffix)
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(file_bytes)

        parser = LlamaParse(
            api_key=LLAMA_CLOUD_API_KEY,
            result_type="markdown",
            verbose=False,
        )
        documents = await parser.aload_data(tmp_path)
        return "\n\n".join(doc.text for doc in documents if doc.text).strip()
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


@app.post("/parse-document")
async def parse_document(file: UploadFile = File(...)):
    """
    Parse an uploaded document (PDF, DOCX, image, etc.) into structured text via LlamaParse.
    Returns: {"text": "...", "filename": "...", "char_count": int}
    """
    if not LLAMA_CLOUD_API_KEY:
        raise HTTPException(status_code=500, detail="LLAMA_CLOUD_API_KEY not configured in .env")

    filename = file.filename or "document"
    ext = os.path.splitext(filename)[1].lower()
    if ext and ext not in PARSE_ALLOWED_EXTS:
        raise HTTPException(status_code=415, detail=f"Unsupported file type: {ext}")

    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty file upload")
    if len(contents) > MAX_UPLOAD_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"File too large (max {MAX_UPLOAD_BYTES // 1024 // 1024} MB)",
        )

    try:
        text = await _llamaparse_to_text(contents, filename)
    except Exception as e:
        print(f"[parse-document] LlamaParse error: {e}")
        raise HTTPException(status_code=502, detail=f"Document parse failed: {e}")

    if not text:
        raise HTTPException(status_code=422, detail="Document parsed but no text was extracted")

    return {"text": text, "filename": filename, "char_count": len(text)}


@app.post("/ocr-explain")
async def ocr_explain(doc_base64: str, filename: str = "document"):
    """
    Hybrid pipeline:
      Step 1 — Google AI Studio (gemini-1.5-flash) extracts text from the image.
      Step 2 — Fine-tuned HF model analyses the extracted text for legal insights.
    """
    import base64

    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY required for image extraction step")

    # Step 1: extract text from the image using Google's vision model
    ocr_model = genai.GenerativeModel("gemini-1.5-flash")
    ocr_prompt = (
        "Anda melihat sebuah dokumen hukum Indonesia. "
        "Transkripsi seluruh teks yang terlihat secara lengkap dan akurat. "
        "Kembalikan hanya teks mentah tanpa komentar tambahan."
    )
    try:
        image_data = base64.b64decode(doc_base64)
        ocr_resp = ocr_model.generate_content(
            [ocr_prompt, {"mime_type": "image/jpeg", "data": image_data}]
        )
        extracted_text = ocr_resp.text.strip()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Image extraction error: {e}")

    # Step 2: fine-tuned HF model provides legal analysis on the extracted text
    legal_system = (
        "Anda adalah LawDoc, konsultan hukum perdata Indonesia. "
        "Anda menerima teks yang diekstrak dari dokumen hukum. "
        "Analisis dokumen tersebut: identifikasi jenis dokumen, ekstrak 3-5 klausul penting, "
        "jelaskan setiap klausul dalam bahasa sederhana, dan tandai klausul yang perlu perhatian khusus. "
        "Gunakan Bahasa Indonesia yang mudah dipahami."
    )
    try:
        analysis = await _call_hf(legal_system, [], f"[DOKUMEN TERLAMPIR]\n{extracted_text}")
        return {"explanation": analysis, "extracted_text": extracted_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
