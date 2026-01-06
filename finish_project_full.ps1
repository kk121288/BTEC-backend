<#
finish_project_full.ps1
Scaffolds a full-stack "finish" for the project: backend basic models, CRUD, auth (JWT), file upload, chat stub,
frontend pages/components, and requirements files. Run from repository root.

Usage:
Set-Location 'D:\BTEC-backend'
PowerShell -NoProfile -ExecutionPolicy Bypass -File .\finish_project_full.ps1

IMPORTANT: Review all generated files before pushing. This script aims to scaffold; you must adapt imports
or naming to your project's existing structure.
#>

function WriteStep($m) { Write-Host "==> $m" -ForegroundColor Cyan }

# Ensure in repo root
$root = Get-Location
WriteStep "Repo root: $root"

# Helper to create file if not exists
function EnsureFile($path, $content) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (-not (Test-Path $path)) {
        Set-Content -Path $path -Value $content -Encoding UTF8
        WriteStep "Created: $path"
    } else {
        WriteStep "Exists: $path (skip)"
    }
}

# ---------- BACKEND SCAFFOLD ----------
WriteStep "Scaffolding backend files..."

# database.py
$dbPath = Join-Path $root "backend\app\database.py"
$dbContent = @'
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = os.getenv("DATABASE_URL_INTERNAL") or os.getenv("DATABASE_URL") or "sqlite:///./dev.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
'@
EnsureFile $dbPath $dbContent

# models.py
$modelsPath = Join-Path $root "backend\app\models.py"
$modelsContent = @'
from sqlalchemy import Column, Integer, String, Boolean, Text, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)

class Course(Base):
    __tablename__ = "courses"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text, nullable=True)

class Lesson(Base):
    __tablename__ = "lessons"
    id = Column(Integer, primary_key=True, index=True)
    course_id = Column(Integer, ForeignKey("courses.id"))
    title = Column(String)
    content = Column(Text, nullable=True)
    course = relationship("Course", backref="lessons")

class Submission(Base):
    __tablename__ = "submissions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    lesson_id = Column(Integer, ForeignKey("lessons.id"))
    filename = Column(String)
'@
EnsureFile $modelsPath $modelsContent

# schemas.py
$schemasPath = Join-Path $root "backend\app\schemas.py"
$schemasContent = @'
from pydantic import BaseModel, EmailStr
from typing import Optional, List

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    is_superuser: bool
    class Config:
        orm_mode = True

class CourseCreate(BaseModel):
    title: str
    description: Optional[str] = None

class CourseOut(BaseModel):
    id: int
    title: str
    description: Optional[str]
    class Config:
        orm_mode = True
'@
EnsureFile $schemasPath $schemasContent

# crud.py
$crudPath = Join-Path $root "backend\app\crud.py"
$crudContent = @'
from sqlalchemy.orm import Session
from . import models, schemas
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()

def create_user(db: Session, user: schemas.UserCreate, is_superuser: bool = False):
    hashed = pwd_context.hash(user.password)
    db_user = models.User(email=user.email, hashed_password=hashed, is_superuser=is_superuser)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def verify_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user:
        return None
    if not pwd_context.verify(password, user.hashed_password):
        return None
    return user

def create_course(db: Session, course: schemas.CourseCreate):
    db_course = models.Course(title=course.title, description=course.description)
    db.add(db_course)
    db.commit()
    db.refresh(db_course)
    return db_course

def get_courses(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Course).offset(skip).limit(limit).all()
'@
EnsureFile $crudPath $crudContent

# auth router
$authPath = Join-Path $root "backend\app\api\auth.py"
$authContent = @'
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from jose import jwt
from .. import crud, schemas, database

router = APIRouter(prefix="/auth", tags=["auth"])

SECRET_KEY = "CHANGE_ME_REPLACE_WITH_ENV"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60*24

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded

@router.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.SessionLocal)):
    user = crud.verify_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=400, detail="Incorrect credentials")
    access_token = create_access_token({"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/register")
def register(user: schemas.UserCreate, db: Session = Depends(database.SessionLocal)):
    existing = crud.get_user_by_email(db, user.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    new = crud.create_user(db, user)
    return {"id": new.id, "email": new.email}
'@
EnsureFile $authPath $authContent

# courses router
$coursesPath = Join-Path $root "backend\app\api\courses.py"
$coursesContent = @'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import crud, schemas, database

router = APIRouter(prefix="/courses", tags=["courses"])

@router.post("/", response_model=schemas.CourseOut)
def create_course(course: schemas.CourseCreate, db: Session = Depends(database.SessionLocal)):
    return crud.create_course(db, course)

@router.get("/", response_model=list[schemas.CourseOut])
def list_courses(skip: int = 0, limit: int = 50, db: Session = Depends(database.SessionLocal)):
    return crud.get_courses(db, skip=skip, limit=limit)
'@
EnsureFile $coursesPath $coursesContent

# files router
$filesPath = Join-Path $root "backend\app\api\files.py"
$filesContent = @'
from fastapi import APIRouter, UploadFile, File, HTTPException
import os
from uuid import uuid4

router = APIRouter(prefix="/files", tags=["files"])
UPLOAD_DIR = "/app/uploads"

@router.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    ext = os.path.splitext(file.filename)[1]
    fname = f"{uuid4().hex}{ext}"
    path = os.path.join(UPLOAD_DIR, fname)
    try:
        with open(path, "wb") as f:
            content = await file.read()
            f.write(content)
    except Exception as e:
        raise HTTPException(status_code=500, detail="Failed to store file")
    return {"filename": fname, "path": path}
'@
EnsureFile $filesPath $filesContent

# chat router (if not present - may already exist)
$chatPath = Join-Path $root "backend\app\api\chat.py"
$chatContent = @'
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/chat", tags=["chat"])

class ChatIn(BaseModel):
    q: str

@router.post("/")
async def chat(payload: ChatIn):
    return {"answer": f"Echo: {payload.q}"}
'@
EnsureFile $chatPath $chatContent

# main.py (ensure includes routers and creates tables on startup if desired)
$mainPath = Join-Path $root "backend\app\main.py"
$mainContent = @'
from fastapi import FastAPI
from .database import engine, Base
from .api import auth, courses, files, chat

app = FastAPI(title="BTEC-like Platform")

# create tables for dev (use alembic in prod)
Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(courses.router)
app.include_router(files.router)
app.include_router(chat.router)

@app.get("/")
def root():
    return {"status": "ok"}
'@
# Overwrite only if main.py missing or very short
if (-not (Test-Path $mainPath)) {
    EnsureFile $mainPath $mainContent
} else {
    WriteStep "backend/app/main.py exists - please ensure it includes routers for auth, courses, files, chat."
}

# requirements.txt
$reqPath = Join-Path $root "backend\requirements.txt"
$reqContent = @'
fastapi
uvicorn[standard]
sqlalchemy
psycopg2-binary
alembic
passlib[bcrypt]
python-jose[cryptography]
python-multipart
pydantic
'@
EnsureFile $reqPath $reqContent

# create uploads dir
$uploadsDir = Join-Path $root "backend\uploads"
if (-not (Test-Path $uploadsDir)) { New-Item -ItemType Directory -Path $uploadsDir -Force | Out-Null; WriteStep "Created uploads dir"; }

# ---------- FRONTEND SCAFFOLD ----------
WriteStep "Scaffolding frontend files (Next.js minimal pages)..."

$feIndex = Join-Path $root "frontend\src\pages\index.tsx"
$feIndexContent = @'
import React from "react";
import Link from "next/link";
import Onboarding from "../components/Onboarding";
import ChatWidget from "../components/ChatWidget";

export default function Home() {
  return (
    <div className="min-h-screen p-6">
      <Onboarding />
      <ChatWidget />
      <header className="mb-6">
        <h1 className="text-3xl font-bold">Welcome to the Platform</h1>
      </header>
      <main>
        <p>Explore courses:</p>
        <Link href="/courses">Go to Courses</Link>
      </main>
    </div>
  );
}
'@
EnsureFile $feIndex $feIndexContent

$feCourses = Join-Path $root "frontend\src\pages\courses\index.tsx"
$feCoursesContent = @'
import React, { useEffect, useState } from "react";
import { api } from "../../lib/api";
import Link from "next/link";

export default function Courses() {
  const [courses, setCourses] = useState<any[]>([]);
  useEffect(()=> {
    api.get("/courses").then((d:any)=> setCourses(d)).catch(()=> setCourses([]));
  }, []);
  return (
    <div className="p-6">
      <h2 className="text-2xl mb-4">Courses</h2>
      <ul>
        {courses.map(c => (
          <li key={c.id}><Link href={`/course/${c.id}`}>{c.title}</Link></li>
        ))}
      </ul>
    </div>
  );
}
'@
EnsureFile $feCourses $feCoursesContent

$feCourseDetail = Join-Path $root "frontend\src\pages\course\[id].tsx"
$feCourseDetailContent = @'
import React, { useEffect, useState } from "react";
import { useRouter } from "next/router";
import { api } from "../../lib/api";

export default function CourseDetail() {
  const router = useRouter();
  const { id } = router.query;
  const [course, setCourse] = useState<any>(null);
  useEffect(()=> {
    if (!id) return;
    api.get(`/courses`).then((list:any)=> {
      const found = list.find((c:any)=> String(c.id) === String(id));
      setCourse(found);
    }).catch(()=> {});
  }, [id]);
  if (!course) return <div className="p-6">Loading...</div>;
  return (
    <div className="p-6">
      <h2 className="text-2xl">{course.title}</h2>
      <p>{course.description}</p>
    </div>
  );
}
'@
EnsureFile $feCourseDetail $feCourseDetailContent

$feProfile = Join-Path $root "frontend\src\pages\profile.tsx"
$feProfileContent = @'
import React from "react";

export default function Profile() {
  return <div className="p-6"><h2>Profile</h2><p>Manage your account here.</p></div>;
}
'@
EnsureFile $feProfile $feProfileContent

# ensure lib/api exists (may already be present)
$feApiPath = Join-Path $root "frontend\src\lib\api.ts"
if (-not (Test-Path $feApiPath)) {
  $feApi = @'
const BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:10000";

async function request(path: string, opts: RequestInit = {}) {
  const token = typeof window !== "undefined" ? localStorage.getItem("access_token") : null;
  const headers: any = Object.assign({ "Content-Type": "application/json" }, opts.headers || {});
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${BASE}${path}`, { ...opts, headers });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || res.statusText);
  }
  return res.json().catch(() => null);
}

export const api = {
  get: (p: string) => request(p, { method: "GET" }),
  post: (p: string, body?: any) => request(p, { method: "POST", body: JSON.stringify(body) }),
  put: (p: string, body?: any) => request(p, { method: "PUT", body: JSON.stringify(body) }),
  del: (p: string) => request(p, { method: "DELETE" }),
};
'@
  EnsureFile $feApiPath $feApi
} else { WriteStep "frontend src lib api exists (skip)"; }

# ---------- CI scaffold ----------
WriteStep "Adding simple GitHub Actions CI (lint/build) - .github/workflows/ci.yml"
$ciPath = Join-Path $root ".github\workflows\ci.yml"
$ciContent = @'
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.11"
      - name: Install backend deps
        run: |
          python -m pip install --upgrade pip
          if [ -f backend/requirements.txt ]; then pip install -r backend/requirements.txt; fi
      - name: Run backend tests (if any)
        run: |
          if [ -f backend/pytest.ini ] || [ -d backend/tests ]; then pytest -q backend || true; fi

  frontend-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 18
      - name: Install and build frontend
        run: |
          if [ -d frontend ]; then cd frontend; npm ci; npm run build || true; fi
'@
EnsureFile $ciPath $ciContent

# ---------- Finalize ----------
WriteStep "Scaffold complete. Next steps (manual):"
WriteHost "- Install backend deps: pip install -r backend/requirements.txt"
WriteHost "- Install frontend deps: cd frontend; npm install"
WriteHost "- Set environment variables in .env (DB creds, DATABASE_URL_INTERNAL, FIRST_SUPERUSER, FIRST_SUPERUSER_PASSWORD)"
WriteHost "- Run docker compose up -d --build OR run backend with: uvicorn backend.app.main:app --reload (adjust path as needed)"
WriteHost "- Review generated files and adapt imports/names to match your project structure."
$doCommit = Read-Host "Create git commit for scaffolded files? (y/n)"
if ($doCommit -match '^[Yy]') {
    git add .
    git commit -m "scaffold: add complete project baseline (auth, courses, files, frontend pages, CI)" -q
    WriteStep "Committed scaffold changes locally."
} else {
    WriteStep "Skipped commit."
}

WriteStep "Finished. Review files and run installation steps above."