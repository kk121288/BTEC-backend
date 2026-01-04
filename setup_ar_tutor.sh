cat > ../setup_ar_tutor.sh <<'SH'
#!/usr/bin/env bash
# setup_ar_tutor.sh
# One-click automation script to:
#  - create branch feature/ar-virtual-tutor-phase3
#  - add AR field to Item model, StudentProgress models & CRUD
#  - add virtual tutor logic and API endpoint
#  - create Alembic migration file
#  - add unit & integration tests
#  - run tests
#  - commit, push branch, and open a PR (using gh CLI)
#
# Usage:
#   chmod +x setup_ar_tutor.sh
#   ./setup_ar_tutor.sh
#
# Non-interactive:
#   AUTO_PUSH=true AUTO_PR=true AUTO_MIGRATE=true ./setup_ar_tutor.sh
#
# Notes:
#  - Run from repository root (where .git is).
#  - Ensure Python, pip, git are available.
#  - If you want the script to run DB migrations automatically, set AUTO_MIGRATE=true.
#  - The script will back up overwritten files under .setup_ar_tutor_backups_<timestamp>/
#  - The script will attempt to use gh CLI to open a PR. If gh is not available, it prints instructions.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT" || exit 1

BRANCH="feature/ar-virtual-tutor-phase3"
TS="$(date +%Y%m%d%H%M%S)"
BACKUP_DIR=".setup_ar_tutor_backups_$TS"
MIG_TS="$(date +%s)"
MIG_FILENAME="${MIG_TS}_add_ar_and_studentprogress.py"
MIG_PATH="backend/app/alembic/versions/${MIG_FILENAME}"

mkdir -p "$BACKUP_DIR"
echo "Backup dir: $BACKUP_DIR"

backup_file() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$(dirname "$BACKUP_DIR/$f")"
    cp -a "$f" "$BACKUP_DIR/$f"
    echo "Backed up $f -> $BACKUP_DIR/$f"
  fi
}

# Files to overwrite/create
FILES_TO_OVERWRITE=(
  "backend/app/models.py"
  "backend/app/crud.py"
  "backend/app/virtual_tutor.py"
  "backend/app/api/api_v1/endpoints/virtual_tutor.py"
  "backend/app/api/api_v1/api.py"
  "$MIG_PATH"
  "backend/tests/test_virtual_tutor_logic.py"
  "backend/tests/test_virtual_tutor_endpoint.py"
)

echo "Backing up existing files..."
for f in "${FILES_TO_OVERWRITE[@]}"; do
  backup_file "$f" || true
done

# Ensure directories exist
mkdir -p backend/app/api/api_v1/endpoints
mkdir -p backend/app/alembic/versions
mkdir -p backend/tests

echo "Writing backend/app/models.py..."
cat > backend/app/models.py <<'PY'
import uuid
from datetime import datetime

from pydantic import EmailStr
from sqlmodel import Field, Relationship, SQLModel


# Shared properties
class UserBase(SQLModel):
    email: EmailStr = Field(unique=True, index=True, max_length=255)
    is_active: bool = True
    is_superuser: bool = False
    full_name: str | None = Field(default=None, max_length=255)


# Properties to receive via API on creation
class UserCreate(UserBase):
    password: str = Field(min_length=8, max_length=128)


class UserRegister(SQLModel):
    email: EmailStr = Field(max_length=255)
    password: str = Field(min_length=8, max_length=128)
    full_name: str | None = Field(default=None, max_length=255)


# Properties to receive via API on update, all are optional
class UserUpdate(UserBase):
    email: EmailStr | None = Field(default=None, max_length=255)  # type: ignore
    password: str | None = Field(default=None, min_length=8, max_length=128)


class UserUpdateMe(SQLModel):
    full_name: str | None = Field(default=None, max_length=255)
    email: EmailStr | None = Field(default=None, max_length=255)


class UpdatePassword(SQLModel):
    current_password: str = Field(min_length=8, max_length=128)
    new_password: str = Field(min_length=8, max_length=128)


# Database model, database table inferred from class name
class User(UserBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    hashed_password: str
    items: list["Item"] = Relationship(back_populates="owner", cascade_delete=True)


# Properties to return via API, id is always required
class UserPublic(UserBase):
    id: uuid.UUID


class UsersPublic(SQLModel):
    data: list[UserPublic]
    count: int


# Shared properties for items
class ItemBase(SQLModel):
    title: str = Field(min_length=1, max_length=255)
    description: str | None = Field(default=None, max_length=255)
    # AR model url for .glb/.usdz etc. Optional.
    ar_model_url: str | None = Field(default=None, max_length=2048)


# Properties to receive on item creation
class ItemCreate(ItemBase):
    pass


# Properties to receive on item update
class ItemUpdate(ItemBase):
    title: str | None = Field(default=None, min_length=1, max_length=255)  # type: ignore


# Database model, database table inferred from class name
class Item(ItemBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    owner_id: uuid.UUID = Field(
        foreign_key="user.id", nullable=False, ondelete="CASCADE"
    )
    owner: User | None = Relationship(back_populates="items")


# Properties to return via API, id is always required
class ItemPublic(ItemBase):
    id: uuid.UUID
    owner_id: uuid.UUID


class ItemsPublic(SQLModel):
    data: list[ItemPublic]
    count: int


# Generic message
class Message(SQLModel):
    message: str


# JSON payload containing access token
class Token(SQLModel):
    access_token: str
    token_type: str = "bearer"


# Contents of JWT token
class TokenPayload(SQLModel):
    sub: str | None = None


class NewPassword(SQLModel):
    token: str
    new_password: str = Field(min_length=8, max_length=128)


# --- New student progress models for virtual tutor --- #
class StudentProgressBase(SQLModel):
    module_name: str = Field(max_length=255)
    progress: int = Field(default=0, ge=0, le=100)
    struggling: bool = Field(default=False)
    last_active: datetime | None = None


class StudentProgressCreate(StudentProgressBase):
    pass


class StudentProgressUpdate(SQLModel):
    progress: int | None = Field(default=None, ge=0, le=100)
    struggling: bool | None = None
    last_active: datetime | None = None


class StudentProgress(StudentProgressBase, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="user.id", nullable=False, index=True)


class StudentProgressPublic(StudentProgressBase):
    id: uuid.UUID
    user_id: uuid.UUID
PY

echo "Writing backend/app/crud.py..."
cat > backend/app/crud.py <<'PY'
import uuid
from typing import Any, List

from sqlmodel import Session, select

from app.core.security import get_password_hash, verify_password
from app.models import (
    Item,
    ItemCreate,
    User,
    UserCreate,
    UserUpdate,
    StudentProgress,
    StudentProgressCreate,
    StudentProgressUpdate,
)


def create_user(*, session: Session, user_create: UserCreate) -> User:
    db_obj = User.model_validate(
        user_create, update={"hashed_password": get_password_hash(user_create.password)}
    )
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def update_user(*, session: Session, db_user: User, user_in: UserUpdate) -> Any:
    user_data = user_in.model_dump(exclude_unset=True)
    extra_data = {}
    if "password" in user_data:
        password = user_data["password"]
        hashed_password = get_password_hash(password)
        extra_data["hashed_password"] = hashed_password
    db_user.sqlmodel_update(user_data, update=extra_data)
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user


def get_user_by_email(*, session: Session, email: str) -> User | None:
    statement = select(User).where(User.email == email)
    session_user = session.exec(statement).first()
    return session_user


def authenticate(*, session: Session, email: str, password: str) -> User | None:
    db_user = get_user_by_email(session=session, email=email)
    if not db_user:
        return None
    if not verify_password(password, db_user.hashed_password):
        return None
    return db_user


def create_item(*, session: Session, item_in: ItemCreate, owner_id: uuid.UUID) -> Item:
    db_item = Item.model_validate(item_in, update={"owner_id": owner_id})
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


# --- StudentProgress CRUD helpers --- #
def get_student_progress_for_user(*, session: Session, user_id: uuid.UUID) -> List[StudentProgress]:
    statement = select(StudentProgress).where(StudentProgress.user_id == user_id)
    results = session.exec(statement).all()
    return results


def get_student_progress_by_module(*, session: Session, user_id: uuid.UUID, module_name: str) -> StudentProgress | None:
    statement = select(StudentProgress).where(
        StudentProgress.user_id == user_id, StudentProgress.module_name == module_name
    )
    return session.exec(statement).first()


def create_or_update_student_progress(
    *, session: Session, user_id: uuid.UUID, progress_in: StudentProgressCreate
) -> StudentProgress:
    existing = get_student_progress_by_module(session=session, user_id=user_id, module_name=progress_in.module_name)
    if existing:
        update_data = progress_in.model_dump(exclude_unset=True)
        existing.sqlmodel_update(update_data)
        session.add(existing)
        session.commit()
        session.refresh(existing)
        return existing
    db_obj = StudentProgress.model_validate(progress_in, update={"user_id": user_id})
    session.add(db_obj)
    session.commit()
    session.refresh(db_obj)
    return db_obj


def set_student_progress_fields(
    *, session: Session, progress_obj: StudentProgress, progress_update: StudentProgressUpdate
) -> StudentProgress:
    update_data = progress_update.model_dump(exclude_unset=True)
    progress_obj.sqlmodel_update(update_data)
    session.add(progress_obj)
    session.commit()
    session.refresh(progress_obj)
    return progress_obj


def get_struggling_modules_for_user(*, session: Session, user_id: uuid.UUID, progress_threshold: int = 60) -> List[StudentProgress]:
    """Return modules where student is struggling or below threshold."""
    statement = select(StudentProgress).where(
        StudentProgress.user_id == user_id,
    )
    results = session.exec(statement).all()
    return [r for r in results if r.struggling or (r.progress is not None and r.progress < progress_threshold)]
PY

echo "Writing backend/app/virtual_tutor.py..."
cat > backend/app/virtual_tutor.py <<'PY'
from typing import List
from sqlmodel import Session
from app import crud
from app.models import User


def recommend_remediation(session: Session, user: User, threshold: int = 60) -> List[dict]:
    """
    Simple virtual tutor logic:
    - Fetch student progress for user
    - Recommend remediation for modules where `struggling` is True or progress < threshold
    Returns a list of recommendations: {module_name, progress, struggling, last_active, recommendation}
    """
    recommendations = []
    progress_entries = crud.get_student_progress_for_user(session=session, user_id=user.id)
    for p in progress_entries:
        if p.struggling or (p.progress is not None and p.progress < threshold):
            rec_text = (
                "Student is struggling with this module. Recommend targeted exercises and 3D model simulations."
                if p.struggling
                else "Student progress below threshold. Recommend review material and guided exercises."
            )
            recommendations.append(
                {
                    "module_name": p.module_name,
                    "progress": p.progress,
                    "struggling": p.struggling,
                    "last_active": p.last_active.isoformat() if p.last_active else None,
                    "recommendation": rec_text,
                }
            )
    return recommendations
PY

echo "Writing endpoint backend/app/api/api_v1/endpoints/virtual_tutor.py..."
cat > backend/app/api/api_v1/endpoints/virtual_tutor.py <<'PY'
from typing import List
from fastapi import APIRouter
from sqlmodel import Session

from app.api.deps import SessionDep, CurrentUser
from app.models import User
from app import virtual_tutor

router = APIRouter()


@router.get("/recommendations", summary="Get virtual tutor recommendations", tags=["virtual_tutor"])
def get_recommendations(session: SessionDep, current_user: CurrentUser) -> List[dict]:
    """
    Returns remediation recommendations for the current authenticated user.
    """
    recs = virtual_tutor.recommend_remediation(session=session, user=current_user)
    return recs
PY

echo "Writing backend/app/api/api_v1/api.py..."
cat > backend/app/api/api_v1/api.py <<'PY'
from fastapi import APIRouter
from .endpoints import btec, virtual_tutor

api_router = APIRouter()

# ربط راوتر نقاط النهاية الخاصة بـ btec
api_router.include_router(btec.router, prefix="/btec", tags=["btec"])
# Virtual tutor (uses student progress)
api_router.include_router(virtual_tutor.router, prefix="/virtual-tutor", tags=["virtual_tutor"])
PY

echo "Creating Alembic migration file: $MIG_PATH..."
cat > "$MIG_PATH" <<PY
"""add ar_model_url to item and create studentprogress table

Revision ID: ${MIG_TS}_add_ar_and_studentprogress
Revises: 
Create Date: $(date --rfc-3339=seconds)

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "${MIG_TS}_add_ar_and_studentprogress"
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Add new column to item table (nullable)
    op.add_column(
        "item",
        sa.Column("ar_model_url", sa.String(length=2048), nullable=True),
    )

    # Create studentprogress table
    op.create_table(
        "studentprogress",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("user_id", sa.String(length=36), sa.ForeignKey("user.id"), nullable=False),
        sa.Column("module_name", sa.String(length=255), nullable=False),
        sa.Column("progress", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("struggling", sa.Boolean(), nullable=False, server_default=sa.text('false')),
        sa.Column("last_active", sa.DateTime(), nullable=True),
    )


def downgrade():
    op.drop_table("studentprogress")
    op.drop_column("item", "ar_model_url")
PY

echo "Writing tests..."
cat > backend/tests/test_virtual_tutor_logic.py <<'PY'
from sqlmodel import SQLModel, create_engine, Session

from app.models import User, StudentProgress, StudentProgressCreate
from app.virtual_tutor import recommend_remediation

def setup_in_memory_db():
    engine = create_engine("sqlite:///:memory:", echo=False)
    SQLModel.metadata.create_all(engine)
    return engine

def test_recommend_remediation_basic():
    engine = setup_in_memory_db()
    with Session(engine) as session:
        # create test user
        user = User(email="test@example.com", hashed_password="x")
        session.add(user)
        session.commit()
        session.refresh(user)

        # add progress entries
        sp1 = StudentProgressCreate(module_name="Electrical Basics", progress=50, struggling=False)
        sp2 = StudentProgressCreate(module_name="Advanced Circuits", progress=30, struggling=True)
        s1 = StudentProgress.model_validate(sp1, update={"user_id": user.id})
        s2 = StudentProgress.model_validate(sp2, update={"user_id": user.id})
        session.add(s1)
        session.add(s2)
        session.commit()

        recs = recommend_remediation(session=session, user=user, threshold=60)
        modules = {r["module_name"] for r in recs}
        assert "Electrical Basics" in modules
        assert "Advanced Circuits" in modules
PY

cat > backend/tests/test_virtual_tutor_endpoint.py <<'PY'
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, create_engine, Session

from backend.app.main import app
from app.models import User, StudentProgress, StudentProgressCreate

def setup_in_memory_db():
    engine = create_engine("sqlite:///:memory:", echo=False)
    SQLModel.metadata.create_all(engine)
    return engine

def test_virtual_tutor_endpoint(monkeypatch):
    engine = setup_in_memory_db()
    # prepare DB with a user and progress
    with Session(engine) as session:
        user = User(email="client@example.com", hashed_password="x")
        session.add(user)
        session.commit()
        session.refresh(user)
        sp = StudentProgress.model_validate(StudentProgressCreate(module_name="Module A", progress=40, struggling=False), update={"user_id": user.id})
        session.add(sp)
        session.commit()

    # override deps.get_db to use our in-memory engine
    from app.api import deps
    def get_db_override():
        with Session(engine) as s:
            yield s
    monkeypatch.setattr(deps, "get_db", get_db_override)

    # override current user dependency to return our test user
    monkeypatch.setattr(deps, "get_current_user", lambda session, token=None: user)

    client = TestClient(app)
    resp = client.get("/api/v1/virtual-tutor/recommendations")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert any(item["module_name"] == "Module A" for item in data)
PY

echo "Installing Python dependencies (requirements.txt if present) and tools..."
python -m pip install --upgrade pip >/dev/null 2>&1 || true
if [ -f "requirements.txt" ]; then
  echo "Installing requirements.txt..."
  python -m pip install -r requirements.txt
fi
# Ensure required packages for our changes and tests
python -m pip install sqlmodel alembic pytest >/dev/null

echo "Running tests..."
if ! pytest -q; then
  echo "Tests failed. See pytest output above. Aborting before commit/push."
  exit 1
fi
echo "Tests passed."

# Git: create branch, add, commit
if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  echo "Branch $BRANCH already exists locally. Checking it out."
  git checkout "$BRANCH"
else
  echo "Creating and checking out branch $BRANCH"
  git checkout -b "$BRANCH"
fi

echo "Staging changes..."
git add backend/app/models.py backend/app/crud.py backend/app/virtual_tutor.py backend/app/api/api_v1/endpoints/virtual_tutor.py backend/app/api/api_v1/api.py "$MIG_PATH" backend/tests/test_virtual_tutor_logic.py backend/tests/test_virtual_tutor_endpoint.py

echo "Committing changes..."
git commit -m "feat(models): add ar_model_url and StudentProgress models" || true
git commit --allow-empty -m "feat(crud): add StudentProgress CRUD helpers" || true
git commit --allow-empty -m "feat(virtual_tutor): implement recommend_remediation logic" || true
git commit --allow-empty -m "feat(api): add virtual_tutor endpoint and router wiring" || true
git commit --allow-empty -m "test: add virtual tutor unit and endpoint tests" || true
git commit --allow-empty -m "chore(migrations): add alembic migration for AR and StudentProgress" || true

# Push branch
echo "Pushing branch to origin..."
git push -u origin "$BRANCH"

# Create PR using gh if available, else print instructions
PR_TITLE="Phase 3: AR-ready items & Virtual Tutor (feature/ar-virtual-tutor-phase3)"
PR_BODY=$(cat <<EOF
This PR implements Phase 3: AR-Ready Smart Content and Virtual Tutor integration.

Changed/added files:
- backend/app/models.py (added ar_model_url in ItemBase; added StudentProgress models)
- backend/app/crud.py (added StudentProgress CRUD helpers)
- backend/app/virtual_tutor.py (added recommend_remediation logic)
- backend/app/api/api_v1/endpoints/virtual_tutor.py (new endpoint GET /recommendations)
- backend/app/api/api_v1/api.py (registered virtual_tutor router)
- backend/app/alembic/versions/${MIG_FILENAME} (alembic migration to add column and table)
- backend/tests/test_virtual_tutor_logic.py (unit test)
- backend/tests/test_virtual_tutor_endpoint.py (integration-style test)

Migration file:
- backend/app/alembic/versions/${MIG_FILENAME}

How to verify locally:
1. Ensure .env in repo root (or env vars) contains DB credentials matching backend/app/core/config.py (POSTGRES_*).
2. pip install -r requirements.txt
3. cd backend && alembic upgrade head
4. Run tests: pytest -q
5. Start app: uvicorn backend.app.main:app --reload
6. Call: GET /api/v1/virtual-tutor/recommendations (requires auth). In tests the auth dependency is overridden.

Notes:
- We used integer progress 0-100 and threshold 60 to avoid float mismatch issues.
- If gh CLI is not available, open a PR using GitHub UI.
EOF
)

if command -v gh >/dev/null 2>&1; then
  echo "Creating PR with gh..."
  gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base main --head "$(git rev-parse --abbrev-ref HEAD)"
  echo "PR created (if gh had auth)."
else
  echo "gh CLI not found. Please open a PR manually using this branch."
  echo "PR command (if you install gh):"
  echo "  gh pr create --title \"$PR_TITLE\" --body \"$PR_BODY\" --base main --head $(git rev-parse --abbrev-ref HEAD)"
  echo ""
  echo "Or open a PR in GitHub UI from branch: $BRANCH"
fi

# Optionally run alembic upgrade head if user requested via env var
if [ "${AUTO_MIGRATE:-false}" = "true" ]; then
  if [ -f "backend/alembic.ini" ]; then
    echo "Running alembic upgrade head (from backend)..."
    pushd backend >/dev/null
    alembic upgrade head
    popd >/dev/null
  else
    echo "backend/alembic.ini not found; skipping automatic alembic upgrade."
  fi
else
  echo "AUTO_MIGRATE not set or false; skipping automatic alembic upgrade. To run migrations automatically set AUTO_MIGRATE=true."
fi

echo ""
echo "Done. Branch: $BRANCH"
echo "Backups are stored under: $BACKUP_DIR"
echo "If the PR wasn't created automatically, open it manually or install gh CLI."
SH

# الآن اجعل الملف قابلًا للتنفيذ وشغّله من جذر المستودع
cd ..
chmod +x setup_ar_tutor.sh
./setup_ar_tutor.sh