# LawDoc

**Private, offline-capable legal triage for Indonesians who can't afford a lawyer — powered by Gemma 4.**

Built for the [Kaggle × Google DeepMind Gemma 4 Good Hackathon](https://www.kaggle.com/competitions/gemma-4-good-hackathon) · Deadline May 18, 2026.

> "The only offline-capable, privacy-first legal triage app for Indonesian civil law."

---

## What is LawDoc?

Around 60 million lower-middle income Indonesians have legal problems but cannot afford a lawyer. LawDoc gives them a starting point:

- **Ask a question in plain Indonesian** → get a structured answer: what the law says, how it applies to your specific situation, and what to do next
- **Upload a legal document** → get a plain-language breakdown of what it means
- **Find a pro-bono lawyer** → filter by specialization and eligibility
- **Learn the basics** → plain-language articles on Indonesian civil law

LawDoc is not an AI lawyer. It's a triage tool — it helps people understand their situation before they talk to one.

---

## Demo

| Screen | Description |
|---|---|
| Tanya Dulu | AI chat powered by Gemma 4 — ask any civil law question in Indonesian |
| Browse Lawyers | PERADI-verified lawyers with transparent pricing and pro-bono filter |
| Pro Bono Checker | Income-based eligibility form connected to the LBH network |
| Knowledge Base | Bite-sized legal explainers on divorce, inheritance, debt, and land |

---

## Tech Stack

| Layer | Tech |
|---|---|
| Mobile app | Flutter 3.35.7 (Android + Web) |
| Backend | FastAPI (Python) |
| AI model | **Gemma 4** (`gemma-4-31b-it`) via Google AI Studio API |
| Navigation | GoRouter with ShellRoute bottom nav |
| Fonts | Playfair Display (headings) · Inter (body) via google_fonts |

---

## Quick Start

### Prerequisites

| Tool | Version needed |
|---|---|
| Flutter | 3.x |
| Java | **21** — Gradle 8.14 requires 17–23. Java 25 breaks the build. |
| Python | 3.10+ |
| Google AI Studio API key | [Get one here](https://aistudio.google.com) |

> **Java 21 on macOS:** `brew install --cask temurin@21` then `flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"`

---

### 1. Backend

```bash
cd backend

# Create virtualenv and install
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Set your API key
echo 'GOOGLE_API_KEY=your_key_here' > .env

# Start
bash start.sh
```

If you see `[Errno 48] Address already in use`:
```bash
lsof -ti :8000 | xargs kill -9
bash start.sh
```

Verify it's running:
```bash
curl http://localhost:8000/health
# → {"status":"ok","model":"gemma-4-31b-it"}
```

---

### 2. Flutter app

```bash
cd lawdoc
flutter pub get
flutter analyze          # should report 0 issues

flutter run -d chrome                  # web
flutter run -d <device-id>             # android (flutter devices to list)
flutter build apk --debug              # build APK
```

> **Physical device:** change `localhost` to your machine's LAN IP in `lawdoc/lib/services/ai_service.dart` (`_base` constant).

---

### 3. Running both together

Open two terminals:

```bash
# Terminal 1
cd backend && bash start.sh

# Terminal 2
cd lawdoc && flutter run -d chrome
```

---

## Testing the chatbot

Test prompts are in [`testcases/prompts.md`](testcases/prompts.md) organized by category.

| Category | Prompt IDs |
|---|---|
| Waris — inheritance | W-01 to W-05 |
| Perceraian — divorce | P-01 to P-05 |
| Utang piutang — debt | U-01 to U-05 |
| Sengketa tanah — land | T-01 to T-05 |
| Edge cases | E-01 to E-05 |

Mock legal documents for file-attachment testing: [`testcases/documents/`](testcases/documents/)

**Quick manual test:**
```bash
curl -X POST http://localhost:8000/tanya \
  -H "Content-Type: application/json" \
  -d '{"message": "Ayah saya meninggal tanpa wasiat. Ada 3 anak dan istri masih hidup. Bagaimana harta dibagi?"}'
```

---

## AI Response Format

Every `/tanya` response uses this schema:

```json
{
  "summary": "2-3 sentences specific to the user's situation",
  "legal_basis": {
    "pasal": "KUHPerdata Pasal 852",
    "text": "Full pasal text as written in law",
    "application": "How this pasal applies to THIS user's specific facts"
  },
  "steps": ["Step 1", "Step 2", "Step 3"],
  "disclaimer": "..."
}
```

The `application` field is the key design decision — it forces Gemma to tie the legal text to the user's actual details (number of heirs, debt amounts, relationship, etc.) rather than giving a generic quote.

---

## Project Structure

```
GEMMA 4/
├── lawdoc/                         Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart                GoRouter
│   │   ├── theme/                  colors.dart, theme.dart
│   │   ├── models/                 legal_response.dart, lawyer.dart, article.dart
│   │   ├── data/                   mock_lawyers, mock_articles, mock_ai_responses
│   │   ├── services/               ai_service.dart
│   │   ├── screens/                7 screens
│   │   └── widgets/                shell_scaffold.dart (bottom nav)
│   └── assets/data/
│       └── kuhperdata.json         7 seeded KUHPerdata pasals
├── backend/
│   ├── main.py                     FastAPI app — /tanya + /ocr-explain
│   ├── requirements.txt
│   ├── start.sh
│   └── .env                        API key — gitignored, never commit
├── testcases/
│   ├── prompts.md                  Organized test prompts
│   └── documents/                  Mock legal documents for file upload tests
└── README.md
```

---

## Design Tokens

| Name | Hex | Used for |
|---|---|---|
| Navy deep | `#162040` | Buttons, headers, primary text |
| Cream | `#EDE8E1` | App background |
| Gold | `#C9A844` | PERADI badge, accents |
| Amber card | `#F5E3C0` | Pro-bono hero, disclaimer banners |

---

## Common Issues

| Problem | Fix |
|---|---|
| `flutter build apk` fails with a version number as the error | Gradle is using the wrong Java. Run `flutter config --jdk-dir=".../jdk-21.jdk/Contents/Home"` |
| App shows mock responses even though backend is running | On a physical device, `localhost` doesn't resolve. Update `_base` in `ai_service.dart` to your LAN IP |
| Backend returns 500 on `/tanya` | Check that `.env` exists and contains a valid `GOOGLE_API_KEY`. Restart server after changes |
| `Address already in use` on backend start | `lsof -ti :8000 \| xargs kill -9` then retry |

---

## For Developers

This section describes what is **incomplete, stubbed, or known-rough** so contributors and AI tools have accurate context and don't build on wrong assumptions.

### What's done ✓

- All 7 Flutter screens built and navigable
- Real Gemma 4 (`gemma-4-31b-it`) calls via FastAPI backend
- Structured JSON response schema with `application` field (contextual pasal application)
- File attachment in chat (txt/pdf → sent as `document_text` to backend)
- Graceful offline fallback to keyword-matched mock responses
- Live backend status indicator in chat screen (green = Gemma live, red = offline/mock)
- Per-message source badge ("Gemini AI" vs "Offline · Template lokal")
- Android APK builds successfully (debug)
- Web build works (`flutter build web`)
- Test prompts and mock legal documents in `testcases/`
- README and setup guide complete

### What's missing / stubbed ✗

**Kaggle notebook** ← most critical gap for hackathon judging
- A standalone Jupyter notebook demonstrating Gemma 4 doing the Tanya Dulu flow end-to-end is required for the hackathon submission
- Input: plain Indonesian text describing a legal problem
- Output: structured JSON (summary, pasal reference, action steps) using function calling against the KUHPerdata dataset
- Not yet started

**`/ocr-explain` endpoint — stubbed, untested**
- The endpoint exists in `backend/main.py` and accepts a base64 image
- It has never been tested with a real image
- The Flutter app has no UI for image capture (only text file attachment)
- The multimodal flow (user photographs a document → Gemma reads it) would be a strong demo but is not working end-to-end

**Gemma 4 response latency**
- `gemma-4-31b-it` responses take 15–40 seconds via AI Studio API
- The app shows a typing indicator during this time but there's no timeout feedback for the user
- `gemma-4-26b-a4b-it` (MoE variant, 4B active params) is available and faster — worth testing if latency is a problem

**Real Android device testing**
- The APK builds but has not been tested on a physical device
- `localhost` must be changed to the dev machine's LAN IP for the backend to be reachable from Android

**Lawyer and article data is all mock**
- `lib/data/mock_lawyers.dart` — 4 hardcoded lawyers (Wibowo, Kartika, Pranoto, Ratna)
- `lib/data/mock_articles.dart` — 6 hardcoded articles
- No real PERADI API, no database, no backend for lawyer search
- For the hackathon demo this is fine; for a real product these need replacing

**No authentication**
- The home screen greets "Pak Budi" — hardcoded, no user accounts
- No session persistence beyond the current Flutter session

**KUHPerdata dataset is minimal**
- `assets/data/kuhperdata.json` has 7 pasals (832, 833, 207, 209, 1233, 1313, 1365)
- Gemma still cites the correct pasals from its training data — the JSON is used as a reference for the mock fallback only, not injected into the Gemma prompt

**Pro-bono eligibility form is not connected to anything**
- The form collects income and case type but submits to a local state change (shows a success screen)
- No backend, no real LBH network lookup

**iOS not supported**
- Xcode is not fully installed on the dev machine
- Android + Web are the only tested targets

### Key files to look at first

| File | Why |
|---|---|
| `backend/main.py` | System prompt, `/tanya` endpoint, `_extract_json()` for Gemma 4 reasoning output |
| `lawdoc/lib/services/ai_service.dart` | HTTP call, health check, mock fallback, `AiResult` type |
| `lawdoc/lib/models/legal_response.dart` | All data models including `LegalBasis.application` |
| `lawdoc/lib/screens/chat/tanya_dulu_screen.dart` | Chat UI, file attachment, backend status indicator |

### Notes on Gemma 4 output

Gemma 4 (`gemma-4-31b-it`) is a reasoning model — it emits chain-of-thought text before the final answer. The `_extract_json()` function in `backend/main.py` handles this by walking all brace-matched blocks from the end of the response and returning the last valid JSON that contains `summary` and `legal_basis`. If the model output changes shape, this is the first place to debug.

The system prompt is in `backend/main.py` as `SYSTEM_PROMPT`. It explicitly instructs Gemma to apply the pasal to the user's specific facts using their stated details (number of heirs, names, amounts, etc.). Changes to this prompt have the highest leverage on response quality.

---

## Current Architecture (as of May 2026)

This section reflects the actual built state. Use it as ground truth when picking up the project.

### `/consult` endpoint — the main chatbot

The chatbot now uses a **stateless backend state machine**. Flutter owns the full session and sends it with every request; the backend applies logic and returns the next state.

```
Flutter app
  └─ SessionService (path_provider JSON at lawdoc_session.json — survives restarts)
  └─ AiService.consult(message, session, documentText?)
       └─ POST http://localhost:8000/consult
            └─ FastAPI state machine (routes by flow_state)
                 └─ gemma-4-31b-it via Google AI Studio (asyncio.to_thread)
                      └─ Returns structured JSON + next_state + context_update
```

**Fallback:** if backend is offline or returns an error → shows `"Model sedang tidak tersedia, coba lagi nanti."` as a system message in chat. No mock responses for `/consult`.

**Legacy:** `/tanya` and `/ocr-explain` are preserved and untouched. They still use `gemma-4-31b-it` via Google AI Studio.

### Consultant flow (5 states)

| State | What happens |
|---|---|
| `extracting` | AI reads user message passively, extracts agama / domicile / budget, asks natural follow-ups if missing |
| `confirming` | Once all 3 are known, AI says "Saya deteksi Anda beragama X, domisili Y, budget Z — apakah benar?" — no model call, backend generates the string directly |
| `consulting` | User confirms → backend immediately calls model with full history for deep legal analysis |
| `referring` | Model sets `refer_to_lawyer: true` → shows referral banner |
| (correction) | User says something other than "ya/iya/benar" during confirming → re-runs extraction on the correction |

Context (agama / domicile / budget / case_type / flow_state) is sent in the request body by Flutter and persisted client-side in `lawdoc_session.json`.

### Session schema (client-side JSON)

```json
{
  "session_id": "uuid",
  "agama": "Islam|Kristen|Hindu|Buddha|Konghucu|null",
  "domicile": "province string | null",
  "budget": "pro_bono|<500rb|500rb-2jt|>2jt|null",
  "case_type": "perceraian|warisan|tanah|utang|unclear|null",
  "flow_state": "extracting|confirming|consulting|referring",
  "confirmed": false,
  "messages": [],
  "created_at": "ISO8601",
  "updated_at": "ISO8601"
}
```

### `/consult` request / response schema

**Request:**
```json
{
  "session_id": "uuid",
  "message": "user's message",
  "context": { "flow_state": "extracting", "agama": null, "domicile": null, "budget": null, "confirmed": false },
  "history": [{ "role": "user|model", "content": "..." }],
  "document_text": "optional — text extracted from attached file"
}
```

**Response:**
```json
{
  "message": "natural language response",
  "flow_state": "next state",
  "context_update": {
    "agama": "extracted or null",
    "domicile": "extracted or null",
    "budget": "extracted or null",
    "case_type": "classified or null",
    "confirmed": true
  },
  "structured": {
    "legal_basis": { "pasal": "KUHPerdata Pasal XXX", "text": "...", "application": "..." },
    "docs_needed": ["doc1", "doc2"],
    "steps": ["step1", "step2"],
    "outcome": "realistic outcome + timeline",
    "refer_to_lawyer": false
  },
  "disclaimer": "..."
}
```

`structured` is null during extracting/confirming. Only populated once consulting begins.

### Jurisdiction routing (inside backend prompts)

- Domicile contains "aceh" → Mahkamah Syar'iyah (Qanun + KHI)
- Agama = Islam → Pengadilan Agama for marriage/inheritance; KUHPerdata for general civil
- Otherwise → Pengadilan Negeri, KUHPerdata

Adat nuance injected for inheritance: Minangkabau = matrilineal (KAN), Batak = patrilineal (Dalihan na Tolu), Bali = purusa, Jawa = bilateral.

### New files added (not in the original structure above)

| File | Purpose |
|---|---|
| `lawdoc/lib/models/consult_session.dart` | `SessionContextModel`, `ConsultResponse`, `ConsultSession` — session + context state models |
| `lawdoc/lib/services/session_service.dart` | `SessionService.load()` / `.save()` / `.clear()` — JSON file persistence via path_provider |
| `legal_consultant_ai_flow_v2.mmd` | Mermaid flow diagram — the consultant decision tree the backend implements |

### Updated files (since initial commit)

| File | What changed |
|---|---|
| `backend/main.py` | Added `/consult` state machine; `_call_gemini()` replaces `_call_hf()`; legacy endpoints untouched |
| `backend/setup.sh` | Prompts for both `GOOGLE_API_KEY` and `HF_API_KEY` on first run |
| `backend/start.sh` | Checks for missing `HF_API_KEY` after sourcing `.env`, prompts and saves if empty |
| `backend/.env.example` | Added `HF_API_KEY` placeholder |
| `lawdoc/pubspec.yaml` | Added `path_provider: ^2.1.4` |
| `lawdoc/lib/models/legal_response.dart` | Added `ConsultStructured`; updated `ChatMessage` with `consultStructured`, `isSystemMessage`, `toJson()`/`fromJson()` |
| `lawdoc/lib/services/ai_service.dart` | Added `ConsultResult` + `consult()` method; legacy `query()` preserved |
| `lawdoc/lib/screens/chat/tanya_dulu_screen.dart` | Full rewrite — context bar, case badge, structured output cards, session load/save, system message rendering |

### Fine-tuned model note

`sirpratama/perdata-gemma4-lora` (LoRA fine-tune of Gemma 4 4B on KUHPerdata, trained via Unsloth) exists on HuggingFace but has no `pipeline_tag` and no inference providers configured — it cannot be served via HF Serverless Inference API. It is showcased in the Kaggle notebook as a training artifact. The live app uses `gemma-4-31b-it` via Google AI Studio.

### API key setup

Only `GOOGLE_API_KEY` is required to run the app. `HF_API_KEY` is prompted by `start.sh` for completeness (notebook use) but the server starts fine without it.

```bash
cd backend && bash start.sh   # prompts for keys on first run, saves to .env
```
