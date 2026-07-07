# GEMINI.md

Instructions for Gemini (Antigravity) working in this repo. This complements `CLAUDE.md` (full architecture/commands reference) — read that too, it's not duplicated here.

## Session protocol (do this every session)

1. **Before doing anything else, read `PROGRESS.md`** at the repo root. It has the current status, the last session's notes, and what to do next.
2. If `PROGRESS.md` does not exist, create it using the template at the bottom of this file, with an initial entry noting "session start, file created".
3. Work from what `PROGRESS.md` says is next — don't restart planning from scratch or re-read the whole codebase blind.
4. When you finish a task from the roadmap checklist (section 8 of the roadmap doc, below), **check it off there** (`- [ ]` → `- [x]`) — that checklist is the source of truth for what's done, not `PROGRESS.md`.
5. **Before ending the session**, append a new entry to the top of the Session Log in `PROGRESS.md` (see format below).
   - **If nothing notable happened** (no checklist items completed, no decisions made, nothing a future session needs to know) — write the shortest possible entry: just the date and one line, e.g. `### 2026-07-09 — Tidak ada progres dicatat.` Don't pad it with a "what was done" / "next" breakdown if there's nothing to say.
   - If real work happened, use the full format (what was done, decisions, blockers, **Next:**).

## Current initiative

We are implementing the redesign described in:
- [`docs/superpowers/roadmap-elearning-redesign-pulse-gamifikasi.md`](docs/superpowers/roadmap-elearning-redesign-pulse-gamifikasi.md) — the active spec: replaces PDF materials with a gamified "Learning Board", moves PULSE scoring off self-report angket, makes materials belong to a class (not a shared grade-level bank). Section 8 has the phase checklist (check items off as you complete them) and section 9 has decided points — both are the source of truth for what to build.
- [`docs/superpowers/meeting-summary-2026-07-07-prototype-review.md`](docs/superpowers/meeting-summary-2026-07-07-prototype-review.md) — background on why (dosen review feedback), only needed if you need the "why" behind a decision.

Frontend (this repo) and backend are separate codebases:
- Backend (Laravel, not pulled/synced into a repo here yet): `\\wsl.localhost\Ubuntu\home\andndre\Code\civic_pulse_backend`
- Frontend (Flutter, mobile + web): this repo, see `CLAUDE.md` for architecture.

## PROGRESS.md template

Use this structure when creating `PROGRESS.md` for the first time:

```markdown
# PROGRESS.md

## Status Saat Ini

(1-3 kalimat: fase apa yang sedang dikerjakan, apa yang sudah jalan, apa yang belum)

## Session Log

(Entri terbaru di paling atas. Satu entri per sesi kerja.)

### 2026-07-08 — Session start, file dibuat
- File `PROGRESS.md` dibuat oleh Gemini (Antigravity).
- Belum ada implementasi kode untuk redesain PULSE Activity Engine. Roadmap sudah final di `docs/superpowers/roadmap-elearning-redesign-pulse-gamifikasi.md`.
- **Next:** mulai Fase 1 — finalisasi isi materi contoh "Toleransi Antar Umat Beragama" (lihat bagian 4 roadmap).
```

Each new entry should have: date, what was done, what changed/decided, blockers if any, and a **Next:** line telling the next session exactly where to resume — **unless nothing happened**, in which case just write one line (see rule 5 above), for example:

```markdown
### 2026-07-09 — Tidak ada progres dicatat.
```
