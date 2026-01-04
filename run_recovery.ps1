# run_recovery.ps1
$ErrorActionPreference = 'Stop'
Write-Host 'Stopping and removing conflicting containers...'
docker rm -f btec-db -v -f 2>$null | Out-Null

Write-Host 'Bringing down compose (removing volumes)...'
docker compose down -v --remove-orphans

Write-Host 'Bringing up compose...'
docker compose up --build -d

Write-Host 'Waiting 8s for services to initialize...'
Start-Sleep -s 8

Write-Host 'Checking alembic heads inside backend...'
$heads = docker compose exec backend bash -lc "cd /app && python - <<'PY'
from alembic.config import Config
from alembic.script import ScriptDirectory
cfg = Config('alembic.ini')
sd = ScriptDirectory.from_config(cfg)
print(' '.join(sd.get_heads()))
PY"
Write-Host "Heads: $heads"

if ($heads -and ($heads -split '\s+').Count -gt 1) {
  Write-Host "Merging heads: $heads"
  docker compose exec backend bash -lc "cd /app && python -m alembic merge -m 'merge heads' $heads"
}

Write-Host 'Upgrading alembic to head...'
docker compose exec backend bash -lc "cd /app && python -m alembic upgrade head"

Write-Host 'Running init_db to seed superuser...'
docker compose exec backend bash -lc "cd /app && python - <<'PY'
from sqlmodel import Session
from app.core.db import engine, init_db
with Session(engine) as s:
    init_db(s)
print('init_db complete')
PY"

Write-Host 'Running healthcheck pytest...'
docker compose exec backend bash -lc "cd /app && pytest backend/tests/test_healthcheck.py -q"