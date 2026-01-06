```instructions
# 🧠 Copilot Instructions — BTEC Smart Platform & Backend
These instructions help AI coding agents become productive in this repository. Keep guidance actionable and repository-specific.

---

## Big picture
- Components: `Flutter/` (mobile/web UI), `backend/` (FastAPI services), `BTEC-Virtual-World/` (read-only submodule for assets/simulations).
- Data & flow: HTTP API (gateway → backend FastAPI) and DB via SQLModel; business rules and AI scoring live in `backend/app/services/`.

## Quick dev commands
- Local dev stack: `docker compose up --build` (use `docker compose exec backend bash` for a shell).
- Run backend (inside `backend/` venv or container): `uvicorn app.main:app --reload`.
- Tests: `bash backend/scripts/test.sh` (or run `pytest` in `backend/`).
- Migrations: from `backend/`: `alembic revision --autogenerate -m "msg"` then `alembic upgrade head`.
- Update submodule: `git submodule update --init --recursive`.

## Backend conventions (follow these exactly)
- Routes are thin: put route definitions in `backend/app/api/` (or `backend/app/routes/`) and call services in `backend/app/services/`.
- Models: prefer `SQLModel` in `backend/app/models.py`; keep Alembic revisions under `backend/alembic/versions/`.
- Schemas: use Pydantic request/response models (co-locate with related route or in a `schemas.py`).
- Business logic, permissions, and scoring belong in `backend/app/services/*` (search this folder for examples).

## Frontend (Flutter) conventions
- UI: `Flutter/lib/features/<feature>/` with `view.dart`, `controller.dart`, `widgets/` folders.
- Keep business logic out of widgets; use controllers/services under `lib/`.
- Fonts/assets declared in `Flutter/pubspec.yaml` (primary font: Cairo).

## Tests & CI
- Backend tests live in `backend/tests/` and use `pytest` (see `backend/scripts/test.sh`).
- CI expects thin routes, service tests, and Alembic migrations when models change.

## Integration & deployment notes
- The Docker Compose setup in `docker-compose.yml` runs the full stack locally; prefer it for integration testing.
- Services communicate over HTTP; CORS origins are configured in `backend/app/main.py` (uses `EXTRA_CORS_ORIGINS`).

## Key files to inspect (quick links)
- App entry: [backend/app/main.py](backend/app/main.py)
- Models: [backend/app/models.py](backend/app/models.py)
- Services: [backend/app/services/](backend/app/services/)
- API routes: [backend/app/api/](backend/app/api/)
- Backend scripts/tests: [backend/scripts/test.sh](backend/scripts/test.sh)
- Docker compose: [docker-compose.yml](docker-compose.yml)
- Flutter features: [Flutter/lib/](Flutter/lib/)

## How to add a backend endpoint (practical checklist)
1. Add or update a `SQLModel` in `backend/app/models.py` (create alembic rev if persistent).
2. Add request/response Pydantic models (in `schemas.py` or next to the route).
3. Implement logic in `backend/app/services/<feature>.py` and add unit tests under `backend/tests/`.
4. Add a thin route in `backend/app/api/<feature>.py` that calls the service and returns the response model.
5. Add an Alembic migration and update `backend/tests/` to cover the new behavior.

---
If any part of this needs more detail (scaffold example, test template, or a migration example), tell me which feature and I will add it.
```