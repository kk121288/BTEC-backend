<#
Automate fixes, tests and PR creation for BTEC-backend (PowerShell).
Usage:
  1) Open PowerShell in repo root
  2) Temporarily allow script execution:
       Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  3) Run:
       .\automate_fix.ps1

Summary:
- Creates/activates .venv if missing
- Cleans .env from BOM and ensures required keys (session defaults if missing)
- Installs essential packages (psycopg-binary, sqlmodel, alembic, pytest, httpx)
- Runs pytest inside backend, patches tests/conftest.py with safe defaults if needed
- If tests pass, creates branch, commits, pushes, and attempts to open PR with gh
- Makes backups of edited files under .automate_backups_<timestamp>
Note: review script before running. Do not commit secrets.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = (Get-Location).Path
$Timestamp = (Get-Date -Format "yyyyMMddHHmmss")
$BackupDir = Join-Path $RepoRoot ".automate_backups_$Timestamp"
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

Write-Host "Repo root: $RepoRoot"
Write-Host "Backups will be saved to: $BackupDir"

# Default env values (edit before running if you want different)
$EnvDefaults = @{
    POSTGRES_USER = "myuser"
    POSTGRES_PASSWORD = "mypassword"
    POSTGRES_DB = "btec_db"
    REDIS_PASSWORD = "myredispassword"
    PROJECT_NAME = "BTEC Assessment Engine"
    POSTGRES_SERVER = "db"
    FIRST_SUPERUSER = "admin@example.com"
    FIRST_SUPERUSER_PASSWORD = "changeme"
    ENVIRONMENT = "local"
    SECRET_KEY = "REPLACE_WITH_STRONG_SECRET_KEY"
}

# helper: backup a file
function Backup-File([string]$path) {
    if (Test-Path $path) {
        $rel = (Resolve-Path $path).Path.Substring($RepoRoot.Length).TrimStart('\','/')
        $dest = Join-Path $BackupDir $rel
        $dir = Split-Path $dest -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        Copy-Item -Path $path -Destination $dest -Force
        Write-Host "Backed up $path -> $dest"
    }
}

# Ensure .env exists at repo root
$EnvPath = Join-Path $RepoRoot ".env"
if (-not (Test-Path $EnvPath)) {
    Write-Host ".env not found at repo root. Creating .env with placeholders (edit after run)."
    $content = $EnvDefaults.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }
    $content -join "`n" | Out-File -FilePath $EnvPath -Encoding UTF8
    Write-Host ".env created at $EnvPath"
} else {
    Backup-File $EnvPath
    # rewrite without BOM (read as utf8 then write utf8)
    try {
        $s = Get-Content $EnvPath -Raw -Encoding UTF8
    } catch {
        $s = Get-Content $EnvPath -Raw
    }
    $s | Out-File -FilePath $EnvPath -Encoding UTF8
    Write-Host ".env cleaned/rewritten (without BOM if present)."
}

# Ensure .env is gitignored
$GitIgnore = Join-Path $RepoRoot ".gitignore"
if (Test-Path $GitIgnore) {
    $gi = Get-Content $GitIgnore -Raw
    if ($gi -notmatch "(?m)^\s*\.env\s*$") {
        Backup-File $GitIgnore
        "`n.env`n" | Out-File -FilePath $GitIgnore -Append -Encoding UTF8
        Write-Host "Added .env to .gitignore"
    }
} else {
    ".env" | Out-File -FilePath $GitIgnore -Encoding UTF8
    Write-Host "Created .gitignore and added .env"
}

# Create or activate venv (.venv)
$VenvPath = Join-Path $RepoRoot ".venv"
if (-not (Test-Path $VenvPath)) {
    Write-Host "Creating virtualenv at $VenvPath..."
    python -m venv $VenvPath
}
$Activate = Join-Path $VenvPath "Scripts\Activate.ps1"
if (Test-Path $Activate) {
    Write-Host "Activating virtualenv..."
    . $Activate
    $pythonExe = (Get-Command python).Source
    Write-Host "Using Python executable: $pythonExe"
} else {
    $pythonExe = (Get-Command python).Source
    Write-Host "Venv activation script not found; using current Python: $pythonExe"
}

# Install essential packages
Write-Host "Installing essential packages (may take a few minutes)..."
# upgrade pip silently
& $pythonExe -m pip install --upgrade pip setuptools wheel | Out-Null
& $pythonExe -m pip install psycopg-binary sqlmodel alembic pytest httpx --no-input

# Set PYTHONPATH for this session to backend
$BackendPath = Join-Path $RepoRoot "backend"
$env:PYTHONPATH = $BackendPath
Write-Host "PYTHONPATH set to: $env:PYTHONPATH"

# Load .env entries into session env (and set via .NET API)
Write-Host "Loading .env into session environment..."
Get-Content $EnvPath | ForEach-Object {
    if ($_ -match '^\s*([^#=]+?)\s*=\s*(.*)\s*$') {
        $k = $matches[1].Trim()
        $v = $matches[2].Trim().Trim('"')
        [System.Environment]::SetEnvironmentVariable($k, $v, "Process")
    }
}

# Ensure defaults for any missing keys (session-level)
foreach ($k in $EnvDefaults.Keys) {
    $current = [System.Environment]::GetEnvironmentVariable($k, "Process")
    if ([string]::IsNullOrEmpty($current)) {
        [System.Environment]::SetEnvironmentVariable($k, $EnvDefaults[$k], "Process")
        Write-Host "Set missing env var $k to default (session-only)."
    }
}

# Run pytest inside backend and capture output
$LogDir = Join-Path $RepoRoot "automate_logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$PytestLog = Join-Path $LogDir "pytest_$Timestamp.log"

Write-Host "Running pytest inside backend. Logs -> $PytestLog"
Push-Location $BackendPath
try {
    & $pythonExe -m pytest -q *>&1 | Tee-Object -FilePath $PytestLog
} finally {
    Pop-Location
}

# If pytest reported Settings ValidationError or missing DB driver, patch conftest.py
$Conftest = Join-Path $BackendPath "tests\conftest.py"
$log = Get-Content $PytestLog -Raw
if (Test-Path $Conftest) {
    if ($log -match "ValidationError: .* for Settings" -or $log -match "ModuleNotFoundError: No module named 'psycopg'") {
        Write-Host "Detected Settings validation or DB driver error. Patching tests/conftest.py with safe defaults (backup made)."
        Backup-File $Conftest
        $conftestText = Get-Content $Conftest -Raw
        $marker = "# --- AUTO-ENV-DEFAULTS-INJECTED ---"
        if ($conftestText -notmatch [regex]::Escape($marker)) {
            $injection = @"
# $marker
import os
os.environ.setdefault('PROJECT_NAME', '$($EnvDefaults.PROJECT_NAME)')
os.environ.setdefault('POSTGRES_SERVER', '$($EnvDefaults.POSTGRES_SERVER)')
os.environ.setdefault('POSTGRES_USER', '$($EnvDefaults.POSTGRES_USER)')
os.environ.setdefault('POSTGRES_PASSWORD', '$($EnvDefaults.POSTGRES_PASSWORD)')
os.environ.setdefault('POSTGRES_DB', '$($EnvDefaults.POSTGRES_DB)')
os.environ.setdefault('FIRST_SUPERUSER', '$($EnvDefaults.FIRST_SUPERUSER)')
os.environ.setdefault('FIRST_SUPERUSER_PASSWORD', '$($EnvDefaults.FIRST_SUPERUSER_PASSWORD)')
os.environ.setdefault('ENVIRONMENT', '$($EnvDefaults.ENVIRONMENT)')
os.environ.setdefault('SECRET_KEY', '$($EnvDefaults.SECRET_KEY)')
# end injection

"@
            $new = $injection + $conftestText
            $new | Out-File -FilePath $Conftest -Encoding UTF8
            Write-Host "Patched $Conftest (injection marker added)."
            # re-run pytest
            Push-Location $BackendPath
            Write-Host "Re-running pytest after conftest patch..."
            & $pythonExe -m pytest -q *>&1 | Tee-Object -FilePath $PytestLog -Append
            Pop-Location
        } else {
            Write-Host "conftest already patched; skipping."
        }
    } else {
        Write-Host "No Settings/db-driver error detected in pytest log."
    }
} else {
    Write-Host "No backend/tests/conftest.py found; skipping patch."
}

# Check final pytest result for errors/failures
$FinalLog = Get-Content $PytestLog -Raw
if ($FinalLog -match "(?mi)failed|ERROR") {
    Write-Host "Tests have failures or errors. See $PytestLog. Aborting commit/push."
    Exit 1
}

# If tests passed, create branch, commit and push
Write-Host "Tests passed. Preparing branch and commit..."
git rm --cached .env -f 2>$null | Out-Null

$Branch = "feature/ar-virtual-tutor-phase3"
git checkout -b $Branch

git add -A
try {
    git commit -m "feat(models/crud/virtual_tutor): add AR field, StudentProgress, virtual tutor endpoint and tests" -a
} catch {
    Write-Host "Nothing to commit or commit failed: $($_.Exception.Message)"
}

git push -u origin $Branch

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Creating PR via gh..."
    gh pr create --base main --head $Branch --title "Phase 3: AR-ready items & Virtual Tutor" --body "Automated PR: adds AR field, StudentProgress model, CRUD helpers, virtual tutor logic, endpoint, Alembic migration and tests. Please review."
    Write-Host "PR created (if gh authenticated)."
} else {
    Write-Host "gh CLI not found - please create PR manually from branch $Branch."
}

Write-Host "Automation finished. Backups: $BackupDir  Pytest log: $PytestLog"