"""
LawDoc FastAPI backend v2.0
/consult  — stateful legal consultant (Gemma 4 via Google AI Studio)
/tanya    — preserved legacy endpoint (Gemma via Google AI Studio)
/ocr-explain — preserved multimodal endpoint (Google AI Studio)
"""

import asyncio
import os
import json
import re
import urllib.parse
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY", "")
HF_API_KEY = os.getenv("HF_API_KEY", "")
CONSULT_MODEL = "gemma-4-31b-it"

_missing_keys = [k for k, v in {"GOOGLE_API_KEY": GOOGLE_API_KEY, "HF_API_KEY": HF_API_KEY}.items() if not v]
if _missing_keys:
    raise RuntimeError(f"Missing required API keys: {', '.join(_missing_keys)}. Set them in backend/.env and restart.")

genai.configure(api_key=GOOGLE_API_KEY)

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
    source_url: Optional[str] = None


class DocGuide(BaseModel):
    doc: str
    steps: list[str]
    tutorial_url: Optional[str] = None


class StructuredOutput(BaseModel):
    legal_basis: Optional[LegalBasisOut] = None
    docs_needed: Optional[list[str]] = None
    docs_guides: Optional[list[DocGuide]] = None
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


# ── Google AI Studio helpers ───────────────────────────────────────────────────

async def _call_gemini(system: str, history: list[HistoryMessage], message: str) -> str:
    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY not set")

    def _sync_call() -> str:
        model = genai.GenerativeModel(
            model_name=CONSULT_MODEL,
            system_instruction=system,
            generation_config=genai.GenerationConfig(temperature=0.4, max_output_tokens=2048),
        )
        chat_history = [
            {"role": msg.role, "parts": [msg.content]}
            for msg in history
        ]
        chat = model.start_chat(history=chat_history)
        response = chat.send_message(message)
        return response.text

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


# ── URL helpers ───────────────────────────────────────────────────────────────

_DOC_URL_MAP: list[tuple[list[str], str]] = [
    (["ktp", "kartu tanda penduduk", "e-ktp"], "https://dukcapil.kemendagri.go.id/layanan"),
    (["kartu keluarga", " kk ", "kk)"], "https://dukcapil.kemendagri.go.id/layanan"),
    (["akta kelahiran", "akta lahir"], "https://dukcapil.kemendagri.go.id/layanan"),
    (["akta kematian", "surat kematian"], "https://dukcapil.kemendagri.go.id/layanan"),
    (["akta nikah", "surat nikah", "buku nikah"], "https://simkah4.kemenag.go.id"),
    (["akta cerai", "surat cerai", "akta perceraian", "putusan cerai"], "https://www.mahkamahagung.go.id/id/layanan/pengadilan-agama"),
    (["shm", "sertifikat hak milik", "sertifikat tanah", "sertipikat tanah"], "https://www.atrbpn.go.id/Layanan/Layanan-Pendaftaran-Tanah"),
    (["shgb", "hgb", "hak guna bangunan", "sertifikat hgb"], "https://www.atrbpn.go.id/Layanan/Layanan-Pendaftaran-Tanah"),
    (["npwp", "nomor pokok wajib pajak"], "https://www.pajak.go.id/id/npwp"),
    (["meterai", "materai", "bea meterai"], "https://www.pajak.go.id/id/bea-meterai"),
    (["surat kuasa"], "https://www.hukumonline.com/klinik/a/contoh-surat-kuasa-lt5d6dc9462b282/"),
    (["surat wasiat", "wasiat"], "https://www.hukumonline.com/klinik/a/cara-membuat-surat-wasiat-lt50d2c12acb3ab/"),
    (["surat perjanjian", "perjanjian", "kontrak"], "https://www.hukumonline.com/klinik/"),
    (["rekening koran", "mutasi rekening", "buku tabungan"], "https://www.ojk.go.id/id/kanal/perbankan/Pages/default.aspx"),
    (["surat gugatan", "gugatan", "permohonan"], "https://www.mahkamahagung.go.id/id/layanan"),
    (["surat somasi", "somasi"], "https://www.hukumonline.com/klinik/a/format-surat-somasi-lt4f3a1bc7d23a8/"),
    (["pas foto", "foto"], None),
]


def _pasal_source_url(pasal_str: str) -> str:
    query = urllib.parse.quote_plus(pasal_str)
    return f"https://www.hukumonline.com/pusatdata/search/?q={query}"


def _doc_tutorial_url(doc_name: str) -> Optional[str]:
    doc_lower = f" {doc_name.lower()} "
    for keywords, url in _DOC_URL_MAP:
        if any(kw in doc_lower for kw in keywords):
            return url
    query = urllib.parse.quote_plus(f"cara mengurus {doc_name} Indonesia")
    return f"https://www.google.com/search?q={query}"


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


def _followup_system(ctx: SessionContext) -> str:
    budget_label = {
        "pro_bono": "mencari bantuan pro bono / LBH",
        "<500rb": "budget di bawah Rp500rb",
        "500rb-2jt": "budget Rp500rb–Rp2jt",
        ">2jt": "budget di atas Rp2jt",
    }.get(ctx.budget or "", ctx.budget or "tidak ditentukan")

    case_label = {
        "perceraian": "PERCERAIAN",
        "warisan": "WARIS",
        "tanah": "SENGKETA TANAH",
        "utang": "PIUTANG/UTANG",
    }.get(ctx.case_type or "", (ctx.case_type or "tidak diketahui").upper())

    if ctx.domicile and "aceh" in (ctx.domicile or "").lower():
        jurisdiction = "Mahkamah Syar'iyah Aceh — Qanun dan KHI berlaku"
    elif ctx.agama == "Islam":
        jurisdiction = "Pengadilan Agama — KHI berlaku untuk pernikahan dan waris; KUHPerdata untuk perdata umum"
    else:
        jurisdiction = "Pengadilan Negeri — KUHPerdata berlaku"

    return f"""Anda adalah LawDoc, konsultan hukum perdata Indonesia.

KONTEKS SESI (sudah dianalisis dan disampaikan ke pengguna):
- Agama: {ctx.agama}
- Domisili: {ctx.domicile}
- {budget_label}
- Jenis kasus: {case_label}
- Yurisdiksi: {jurisdiction}

Pengguna sudah menerima analisis hukum awal. Kini mereka mengajukan pertanyaan lanjutan atau klarifikasi. Lihat riwayat percakapan untuk konteks lengkap analisis sebelumnya.

INSTRUKSI:
1. Jawab pertanyaan lanjutan secara SPESIFIK — gunakan konteks sesi dan riwayat percakapan
2. JANGAN ulangi seluruh analisis awal; fokus hanya pada pertanyaan yang diajukan sekarang
3. Boleh merujuk ke analisis sebelumnya ("seperti yang saya jelaskan tadi...") tapi tambahkan informasi baru yang relevan
4. Jika pertanyaan menyentuh aspek hukum baru (pasal lain, dokumen tambahan, langkah prosedural baru), isi legal_basis / docs_needed / steps yang relevan — jangan biarkan null
5. Jika hanya klarifikasi, penjelasan ulang, atau pertanyaan prosedur umum, kembalikan semua field structured sebagai null dan jawab di message
6. Gunakan bahasa sehari-hari Indonesia yang hangat dan mudah dipahami
7. Jika pertanyaan memerlukan pendampingan hukum formal di luar jangkauan AI, set refer_to_lawyer ke true

WAJIB kembalikan HANYA JSON valid:
{{
  "message": "jawaban spesifik, natural, dan empatis untuk pertanyaan pengguna",
  "case_type": "{ctx.case_type}",
  "legal_basis": null,
  "docs_needed": null,
  "docs_guides": null,
  "steps": null,
  "outcome": null,
  "refer_to_lawyer": false
}}

PENTING: Isi legal_basis / docs_needed / docs_guides / steps / outcome HANYA jika pertanyaan membutuhkan informasi hukum BARU yang belum ada di riwayat percakapan. Untuk klarifikasi atau penjelasan dari analisis yang sudah diberikan, cukup jawab di message dan biarkan field lain null."""


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
5. Untuk setiap dokumen di docs_needed, berikan 3-5 langkah konkret cara mempersiapkannya (bahasa sehari-hari, bukan jargon) di docs_guides
6. Langkah konkret yang bisa langsung dilakukan — bukan saran generik
7. Perkiraan hasil dan timeline yang realistis
8. Jika kasus di luar 4 kategori atau sangat kompleks, set refer_to_lawyer ke true

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
  "docs_guides": [
    {{
      "doc": "dokumen 1",
      "steps": ["Langkah 1 cara menyiapkan dokumen ini", "Langkah 2", "Langkah 3"]
    }},
    {{
      "doc": "dokumen 2",
      "steps": ["Langkah 1", "Langkah 2"]
    }}
  ],
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

    raw = await _call_gemini(_extraction_system(req.context), req.history, user_msg)
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

    # Once case_type is set the user has already received a verdict — switch to follow-up mode
    is_followup = bool(req.context.case_type)
    system = _followup_system(req.context) if is_followup else _consulting_system(req.context)

    raw = await _call_gemini(system, req.history, user_msg)
    data = _extract_json(raw)

    case_type = data.get("case_type") or req.context.case_type
    lb_data = data.get("legal_basis")

    dg_raw = data.get("docs_guides") or []
    docs_guides = (
        [
            DocGuide(doc=g["doc"], steps=g.get("steps", []), tutorial_url=_doc_tutorial_url(g["doc"]))
            for g in dg_raw if isinstance(g, dict) and g.get("doc")
        ] or None
    )

    lb_out = None
    if lb_data:
        lb_out = LegalBasisOut(
            pasal=lb_data.get("pasal", ""),
            text=lb_data.get("text", ""),
            application=lb_data.get("application"),
            source_url=_pasal_source_url(lb_data["pasal"]) if lb_data.get("pasal") else None,
        )

    structured = None
    if lb_out or data.get("docs_needed") or data.get("steps"):
        structured = StructuredOutput(
            legal_basis=lb_out,
            docs_needed=data.get("docs_needed") or None,
            docs_guides=docs_guides,
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
    return {"status": "ok", "model": CONSULT_MODEL, "version": "2.0.0"}


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

LEGACY_MODEL_NAME = "gemma-4-31b-it"


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
    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY not set")
    model = genai.GenerativeModel(
        model_name=LEGACY_MODEL_NAME,
        system_instruction=LEGACY_SYSTEM_PROMPT,
        generation_config=genai.GenerationConfig(temperature=0.4, max_output_tokens=2048),
    )
    try:
        prompt = req.message
        if req.document_text:
            prompt = f"{req.message}\n\n[DOKUMEN TERLAMPIR]\n{req.document_text}"
        response = model.generate_content(prompt)
        data = _extract_json_legacy(response.text.strip())
        return LegalResponse(**data)
    except (json.JSONDecodeError, ValueError, KeyError) as e:
        raise HTTPException(status_code=500, detail=f"Model returned unparseable output: {e}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/ocr-explain")
async def ocr_explain(doc_base64: str, filename: str = "document"):
    if not GOOGLE_API_KEY:
        raise HTTPException(status_code=500, detail="GOOGLE_API_KEY not set")
    import base64
    model = genai.GenerativeModel(LEGACY_MODEL_NAME)
    prompt = """Anda melihat sebuah dokumen hukum Indonesia.
    Tolong:
    1. Identifikasi jenis dokumen ini
    2. Ekstrak 3-5 klausul atau poin penting
    3. Jelaskan setiap klausul dalam bahasa sederhana
    4. Tandai klausul yang perlu perhatian khusus

    Format respons dalam Bahasa Indonesia yang mudah dipahami."""
    try:
        image_data = base64.b64decode(doc_base64)
        response = model.generate_content([prompt, {"mime_type": "image/jpeg", "data": image_data}])
        return {"explanation": response.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
