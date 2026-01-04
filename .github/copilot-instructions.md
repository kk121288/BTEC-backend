# 🧠 Copilot Instructions — BTEC Smart Platform & Backend
These instructions help AI coding agents become productive immediately in this codebase.  
Focus on respecting existing architecture, workflows, and conventions.

---

## 🔷 1. Big Picture Architecture

This project consists of **three coordinated components**:

### **1) Flutter Frontend — `/Flutter`**
## 🧠 Copilot Instructions — BTEC Smart Platform & Backend

Purpose: concise, actionable guidance to get an AI coding agent productive in this repository.

**Big picture**
- Components: `Flutter/` (mobile/web UI), `backend/` (FastAPI services), `BTEC-Virtual-World/` (read-only git submodule for simulations/assets).
- Backend routes are thin: they delegate to `backend/app/services/*` where business rules and AI scoring live.

**Quick commands**
- Setup backend env: `uv sync` then `source backend/.venv/bin/activate`
- Dev stack: `docker compose up --build` (iterative: `docker compose watch`)
- Backend shell: `docker compose exec backend bash`
- FastAPI dev server (in container): `fastapi run --reload app/main.py`
- Tests: `bash backend/scripts/test.sh` or `docker compose exec backend bash scripts/tests-start.sh -- -x`
- Migrations: `alembic revision --autogenerate -m "msg"` then `alembic upgrade head`
- Update submodule: `git submodule update --init --recursive`

**Backend conventions (required)**
- Route files in `backend/app/api/` or `backend/app/routes/` must be thin and call services.
- Every endpoint: include a Pydantic request model, a Pydantic response model, and a service implementation in `backend/app/services/`.
- Prefer `SQLModel` in `backend/app/models.py` and keep Alembic revisions under `backend/app/alembic/versions/`.

**Frontend conventions (Flutter)**
- UI lives under `Flutter/lib/widgets` and `Flutter/lib/features/<feature>/` (use `view.dart`, `controller.dart`, and `widgets/`).
- Keep business logic out of widgets; use controller/service files under `lib/`.
- Fonts/assets declared in `Flutter/pubspec.yaml`; primary font is Cairo.

**Tests & CI**
- Backend tests: `backend/tests/` (pytest). Use `backend/scripts/test.sh` locally.
- Coverage output goes to `htmlcov/index.html`.

**Key files to inspect**
- `backend/app/main.py` — app entry
- `backend/app/models.py` — data models
- `backend/app/services/` — business and AI logic
- `backend/app/api/` — route definitions
- `Flutter/lib/` — frontend feature modules and widgets
- `docker-compose.yml` — local dev stack

**Do not**
- Restructure `BTEC-Virtual-World/` submodule.
- Add global state libraries to Flutter without approval.
- Move business logic from services into route handlers.

**Quick checklist to add a backend endpoint**
1. Add/modify `SQLModel` in `backend/app/models.py` (+ alembic rev if persistent).
2. Add Pydantic request/response models in `models.py` or `schemas.py`.
3. Implement logic in `backend/app/services/<feature>.py`.
4. Add a thin route in `backend/app/api/<feature>.py` that calls the service.
5. Add tests in `backend/tests/` and update migrations.

If you want a short scaffolding example (endpoint + service + test), tell me which feature and I will add it.
