```instructions
# 🧠 Copilot Instructions — BTEC Smart Platform & Backend
Short, actionable guidance to get an AI coding agent productive in this repo.

---

## Big picture
- Components: `Flutter/` (mobile/web UI), `backend/` (FastAPI microservices), `BTEC-Virtual-World/` (read-only submodule for assets/simulations).
- Primary pattern: thin HTTP routes delegate to `backend/app/services/*` where business rules, validation, and AI scoring live. DB access uses `SQLModel` models in `backend/app/models.py`.

## Quick dev commands (examples)
- Start full stack locally: `docker compose up --build`
- Enter backend container: `docker compose exec backend bash`
- Run backend locally (repo root):
  - `cd backend`
  - `python -m venv .venv && source .venv/bin/activate` (or use Windows PowerShell venv activation)
  - `uvicorn app.main:app --reload`
- Run tests: `bash backend/scripts/test.sh` or `cd backend && pytest -q`
- Create migrations (from `backend/`): `alembic revision --autogenerate -m "msg"` then `alembic upgrade head`
- Update submodule: `git submodule update --init --recursive`

## Backend conventions (concrete)
- Routes: place thin routers under `backend/app/api/` (see `backend/app/api/main.py`) and compose them on `app` in `backend/app/main.py`.
- Services: put business logic in `backend/app/services/<feature>.py`; tests should target services directly under `backend/tests/`.
- Models & schemas: use `SQLModel` in `backend/app/models.py`; use Pydantic request/response models (co-locate with the route or use a `schemas.py` per feature).
- Migrations: Alembic lives under `backend/alembic/` and revisions under `backend/alembic/versions/`.

## Frontend (Flutter) conventions
- Feature layout: `Flutter/lib/features/<feature>/` with `view.dart`, `controller.dart`, and `widgets/`.
- Keep business logic in controllers/services (not StatefulWidgets).
- Fonts/assets: declared in `Flutter/pubspec.yaml` (primary font: Cairo).

## Integration notes
- CORS: configured in `backend/app/main.py` and can be extended via the `EXTRA_CORS_ORIGINS` env var.
- Services communicate over HTTP; prefer `docker compose` for integration testing to mirror network topology.

## Key files to inspect
- `backend/app/main.py` — app bootstrap and CORS setup
- `backend/app/api/main.py` — router composition
- `backend/app/services/` — business logic and AI scoring
- `backend/app/models.py` — `SQLModel` definitions
- `backend/alembic/` — migration config and versions
- `backend/scripts/test.sh` — test runner helper

## Practical checklist — add a backend endpoint
1. Add/update `SQLModel` in `backend/app/models.py` (add Alembic revision if persistent).
2. Add Pydantic request/response models (near route or in `schemas.py`).
3. Implement logic in `backend/app/services/<feature>.py` and add unit tests in `backend/tests/`.
4. Add thin router in `backend/app/api/<feature>.py` and include it via `backend/app/api/main.py`.
5. Run migrations and CI tests.

---
If you'd like, I can:
- scaffold an example endpoint + service + test (pick a feature name), or
- replace the original `.github/copilot-instructions.md` with this cleaned draft.
```