# LawDoc: legal literacy before legal representation

## A Gemma 4 civil-law tutor for Indonesians who need to understand their options before they can afford a lawyer

**Selected Kaggle track:** Future of Education  
**Special technology track:** Unsloth  

LawDoc started from a simple problem: many Indonesians do not know what legal path they are supposed to take until it is already expensive. A person dealing with inheritance, divorce, debt, land, or a confusing legal document may not need a courtroom strategy on day one. They need to know what the issue is called, which institution handles it, what documents matter, and whether the case is safe to handle alone or should go straight to a lawyer or legal aid office.

That is why we treated legal access as an education problem. LawDoc is a Flutter app that gives plain-language civil-law guidance in Indonesian. It asks for enough context to avoid generic answers: religion, domicile, budget, case type, chat history, and optional document text. Then it explains the legal basis, applies it to the user's facts, lists documents to prepare, gives next steps, estimates the likely process, and recommends a lawyer when the case looks too complex.

LawDoc is not an AI lawyer. It is a first step before a lawyer.

## What we built

The working prototype has four user-facing areas:

- **Tanya Dulu**, the main Gemma-powered consultation chat.
- **Browse Lawyers**, a mock directory for lawyer discovery and referral UI.
- **Pro Bono**, a legal-aid eligibility flow.
- **Knowledge Base**, short civil-law explainers for common cases.

The main engineering work is in Tanya Dulu. The chat does not simply send one prompt and display text. It keeps a session, builds context across turns, parses uploaded documents, and renders structured results as cards: legal basis, document checklist, next steps, expected outcome, and referral warning.

## Architecture

The client is a Flutter app in `lawdoc/`. Routing uses GoRouter, while the consultation session is stored locally through `path_provider` as `lawdoc_session.json`. This was a deliberate choice. We did not want the MVP to require accounts, a database, or server-side personal-history storage. The client owns the session and sends the full context to the backend on every request.

The backend is a FastAPI service in `backend/main.py`. Its main endpoint is `/consult`. The endpoint is stateless, but it behaves like a state machine because the client sends the current `flow_state`.

The flow is:

1. `extracting`: infer religion, domicile, and budget from the user's message.
2. `confirming`: ask the user to confirm the detected profile.
3. `consulting`: produce legal analysis with structured JSON.
4. `referring`: continue the conversation while showing a referral recommendation.

This design made the app easier to test and safer to iterate on. If the backend restarts, no session is lost. If the user edits their context, the next request contains the new truth.

For document uploads, Flutter sends the file to `/parse-document`. The backend validates type and size, then uses LlamaParse to turn PDF, DOCX, image, or text files into clean markdown. That text is attached to the next `/consult` call as `document_text`. We chose this instead of asking the model to interpret raw files because it keeps the legal model focused on reasoning, not file handling.

The model server runs separately on Modal. `modal_app.py` starts an OpenAI-compatible vLLM server with `unsloth/gemma-4-E4B-it` as the base model and `sirpratama/perdata-gemma4-lora-v2` as a LoRA adapter exposed as `perdata-lora`. FastAPI calls it through `huggingface_hub.InferenceClient`.

## How we used Gemma 4

Gemma 4 is used as the legal reasoning engine behind `/consult` and the legacy `/tanya` endpoint. We did not want a thin chatbot wrapper. The backend constrains the model into a legal-education workflow.

The backend prompts Gemma to return valid JSON with fields the app can render:

- `message`
- `case_type`
- `legal_basis`
- `docs_needed`
- `steps`
- `outcome`
- `refer_to_lawyer`

The `legal_basis.application` field is the most important field. It forces the model to explain how the law applies to the user's facts instead of quoting a rule and stopping there. For example, inheritance guidance changes depending on religion, domicile, family members, and whether adat law may matter. Divorce guidance changes by religion and court route. Debt guidance changes depending on whether there is a written agreement, a notarial deed, transfer evidence, or only a verbal promise.

We also used Gemma in two different modes. In extraction mode, it behaves like a careful interviewer and asks only for missing context. In consulting mode, it behaves like a legal tutor that explains options and preparation steps. Splitting those modes made the chat feel less like a wall of advice and more like a guided intake process.

## Why Unsloth mattered

We chose the Unsloth track because legal triage needs domain adaptation. The base model is strong, but Indonesian civil-law answers need local vocabulary, recurring statutes, court routes, and document patterns. The LoRA fine-tune lets us adapt Gemma 4 toward KUHPerdata-style reasoning and structured output without training or serving a full model from scratch.

Serving was harder than training. Hugging Face's managed endpoint path was not practical for this setup because Gemma 4 support and custom LoRA serving were blocked by endpoint/runtime constraints. We moved to Modal and vLLM so we could control the container, load the base model, attach the LoRA, and expose a simple OpenAI-compatible endpoint. It is not glamorous, but it works. Cold starts are still a tradeoff, especially on GPU-backed infrastructure, but scale-to-zero is acceptable for an MVP and hackathon demo.

## Challenges

Keeping answers structured took more work than expected. Legal users need checklists and next steps, not long paragraphs. Gemma can occasionally return extra text around JSON, so the backend includes a JSON extractor that searches the response for the last valid object. It is not perfect, but it makes the app much more resilient during demos.

Context was the other hard part. A generic legal answer can be actively unhelpful in Indonesia because religion and domicile affect court route and applicable rules. We solved this by making context collection a first-class part of the chat instead of burying it in the prompt.

Document handling had its own trap. Users often start with a document, not a clean legal question. Instead of pretending the model can safely handle every upload directly, we added a parse step and send only extracted text into the legal flow.

We also had to be honest about scope. The app includes lawyer cards and pro-bono UX, but those are mock data today. We kept them because they show the intended product path, but the real system would need verified lawyer data, legal-aid integrations, authentication, and better privacy controls.

## Why this fits Future of Education

LawDoc is educational because it teaches a process, not a one-line answer. A user learns what court or office may matter, what documents to collect, why a legal basis applies, and when self-help becomes risky. The app adapts the lesson to the user's situation instead of asking them to read a static article and guess which parts apply.

For underserved users, that difference matters. Knowing that a land dispute should go to BPN first, or that a divorce case requires mediation, or that a debt claim needs evidence and possibly a somasi, can save time and prevent bad early decisions.

## What is next

The next version should connect the referral flow to real legal-aid and lawyer data, add stronger evaluation against Indonesian legal test cases, expand the KUHPerdata/adat/KHI coverage, and improve privacy for uploaded documents. I would also like to add a small offline mode for common explainers, because many users who need this kind of tool will not have reliable connectivity.

LawDoc is still an MVP. But the core idea works: Gemma 4 can power a practical legal-literacy tutor when it is wrapped in intake logic, local context, document parsing, and a UI that turns model output into actions a person can actually take.
