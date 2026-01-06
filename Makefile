# Simple developer Makefile for common tasks
.PHONY: setup docker-up backend-run backend-test format lint

setup:
	@echo "Setting up backend virtualenv and installing requirements..."
	cd backend && python -m venv .venv \
		&& . .venv/bin/activate && pip install -U pip && pip install -r requirements.txt || \
		(powershell -Command "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass; .\\.venv\\Scripts\\Activate.ps1; pip install -r requirements.txt")

docker-up:
	docker compose up --build

backend-run:
	@echo "Run backend (activate venv manually on Windows)"
	cd backend && . .venv/bin/activate && uvicorn app.main:app --reload

backend-test:
	cd backend && . .venv/bin/activate && bash scripts/test.sh

format:
	cd backend && bash scripts/format.sh

lint:
	cd backend && bash scripts/lint.sh
