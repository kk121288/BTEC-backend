#!/usr/bin/env bash
# audit_project.sh
# Usage: chmod +x audit_project.sh && ./audit_project.sh
# هدف السكربت: مراجعة سريعة لحالة المشروع وإظهار مشكلات شائعة.
set -o pipefail
ROOT="$(pwd)"
echo "== Project audit started: $(date) =="
echo "Repo root: $ROOT"
echo

# Helpers
print_header(){
  echo
  echo "=== $1 ==="
}

# 1) Basic environment
print_header "Environment"
python --version 2>/dev/null || echo "python: NOT FOUND"
pip --version 2>/dev/null || echo "pip: NOT FOUND"
git --version 2>/dev/null || echo "git: NOT FOUND"
echo "Current git branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
echo

# 2) Check .env at repo root
print_header ".env check (repo root)"
ENV_PATH="$ROOT/.env"
if [ -f "$ENV_PATH" ]; then
  echo ".env found at $ENV_PATH"
  echo "Preview (first 200 chars):"
  head -n 50 "$ENV_PATH" | sed -n '1,50p'
else
  echo "WARNING: .env not found at repo root ($ENV_PATH)"
fi

# 3) Clean BOM check for .env and other text files
print_header "BOM checks (utf-8-sig)"
python - <<'PY'
import os,sys
root=os.getcwd()
found=[]
for dirpath,_,files in os.walk(root):
    for f in files:
        if f.endswith(('.py','.env','.ini','.cfg','.toml','.yaml','.yml','.md','.txt')):
            p=os.path.join(dirpath,f)
            try:
                b=open(p,'rb').read(3)
                if b==b'\xef\xbb\xbf':
                    found.append(os.path.relpath(p,root))
            except Exception:
                pass
if not found:
    print("No BOM found in common text files.")
else:
    print("Files with BOM (first 100 shown):")
    for x in found[:100]:
        print(" -", x)
PY

# 4) Required env keys check (from typical settings)
print_header "Check required environment keys in .env (best-effort)"
REQUIRED_KEYS=("PROJECT_NAME" "POSTGRES_SERVER" "POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "FIRST_SUPERUSER" "FIRST_SUPERUSER_PASSWORD" "SECRET_KEY")
missing=()
if [ -f "$ENV_PATH" ]; then
  for k in "${REQUIRED_KEYS[@]}"; do
    if ! grep -q -E "^[[:space:]]*${k}=" "$ENV_PATH"; then
      missing+=("$k")
    fi
  done
  if [ ${#missing[@]} -eq 0 ]; then
    echo "All required keys found in .env (checked list)."
  else
    echo "Missing keys in .env: ${missing[*]}"
  fi
else
  echo ".env missing; cannot check keys."
fi

# 5) Attempt to import package 'app' with current Python
print_header "Python import test: import app"
python - <<'PY'
import importlib,sys,traceback,os
# Ensure backend is on path if present
root=os.getcwd()
backend_path=os.path.join(root,'backend')
if backend_path not in sys.path and os.path.isdir(backend_path):
    sys.path.insert(0, backend_path)
try:
    m=importlib.import_module('app')
    print("OK: imported 'app' from", getattr(m,'__file__','<module>'))
except Exception as e:
    print("IMPORT FAILED:", type(e).__name__)
    traceback.print_exc()
PY

# 6) Quick check: pytest invocation (run tests under backend/tests); do NOT abort whole script if tests fail
print_header "Run pytest (inside backend) - this may take time"
if [ -d "backend" ]; then
  ( cd backend && \
    # ensure pytest uses backend as module path
    PYTHONPATH=$(pwd) pytest -q || echo "Pytest run completed with failures or errors.")
else
  echo "backend directory not found; skipping pytest run."
fi

# 7) Requirements / dependency quick-scan
print_header "requirements.txt scan (presence of critical packages)"
REQ="requirements.txt"
if [ -f "$REQ" ]; then
  echo "requirements.txt present"
  for pkg in sqlmodel alembic pytest pydantic-settings httpx psycopg; do
    if grep -i "$pkg" "$REQ" >/dev/null 2>&1; then
      echo "  - $pkg: FOUND in requirements.txt"
    else
      echo "  - $pkg: NOT FOUND in requirements.txt (may be transitive)"
    fi
  done
else
  echo "No requirements.txt at repo root"
fi

# 8) Alembic checks
print_header "Alembic checks"
if [ -f "backend/alembic.ini" ] || [ -f "alembic.ini" ]; then
  # find versions directory
  VERS="backend/app/alembic/versions"
  if [ -d "$VERS" ]; then
    echo "Found alembic versions dir: $VERS"
    ls -1 "$VERS" | sed -n '1,200p' || true
  else
    echo "No backend/app/alembic/versions directory found. Check backend/alembic.ini and alembic cfg."
  fi
else
  echo "No alembic.ini in repo root or backend; unable to check migrations."
fi

# 9) Scan imports in backend/app for top-level module names and test importability
print_header "Scan imports in backend/app and test top-level modules"
if [ -d "backend/app" ]; then
  # collect imported module names (rough)
  mods=$(grep -hR --line-number -E "^\s*(from|import) [a-zA-Z0-9_\.]+" backend/app | sed -E "s/.*(from|import) //g" | awk '{print $1}' | sed "s/\..*//" | sort -u)
  echo "Top-level modules imported (first 80):"
  echo "$mods" | sed -n '1,80p'
  echo
  echo "Attempting to import each top-level module with Python (reports failures):"
  python - <<'PY'
import sys,subprocess,os,importlib,traceback
root=os.getcwd()
if os.path.isdir(os.path.join(root,'backend')):
    sys.path.insert(0, os.path.join(root,'backend'))
mods = """$(echo "$mods")""".splitlines()
fails = []
for m in mods:
    if m.strip()=='':
        continue
    # skip local package 'app'
    if m=="app":
        continue
    try:
        importlib.import_module(m)
    except Exception as e:
        fails.append((m, repr(e)))
for m,e in fails[:200]:
    print("FAIL:", m, "->", e)
if not fails:
    print("All listed top-level modules imported successfully (or are part of standard lib).")
PY
else
  echo "backend/app not present; skipping import scan."
fi

# 10) Git status hint
print_header "Git status (short)"
git status --short -uno 2>/dev/null || echo "git status not available."

# Summary
print_header "Summary / Next steps suggestions"
echo "- If Settings ValidationError appears: ensure ../.env exists (repo root) and contains required keys (PROJECT_NAME, POSTGRES_*, FIRST_SUPERUSER, FIRST_SUPERUSER_PASSWORD, SECRET_KEY)."
echo "- If BOM files were found: re-save them without BOM (use python script or editors like VSCode Save with UTF-8 no BOM)."
echo "- If 'import app' fails: either run pytest from backend or install package editable (cd backend && python -m pip install -e .) or set PYTHONPATH to backend."
echo "- If pytest failed: inspect failing tests above; fix missing deps or adjust conftest to set env vars for tests."
echo
echo "== Audit finished: $(date) =="