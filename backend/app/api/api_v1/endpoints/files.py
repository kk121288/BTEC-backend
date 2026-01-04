from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from sqlmodel import Session, select
import os, uuid, shutil
from typing import List
from datetime import datetime
from sqlmodel import create_engine

router = APIRouter()

UPLOAD_ROOT = os.environ.get("UPLOADS_DIR", "uploads")

# minimal get_engine
def get_engine():
    DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///./dev.db")
    return create_engine(DATABASE_URL, echo=False)

@router.post("/upload")
def upload_file(file: UploadFile = File(...), current_user: dict = None):
    # current_user should be extracted from JWT in production
    user_id = current_user.get("id") if current_user else "anonymous"
    uid = str(uuid.uuid4())
    user_dir = os.path.join(UPLOAD_ROOT, user_id)
    os.makedirs(user_dir, exist_ok=True)
    ext = os.path.splitext(file.filename)[1]
    stored_name = f"{uid}{ext}"
    path = os.path.join(user_dir, stored_name)
    with open(path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    # record to DB (simple)
    from sqlmodel import SQLModel
    from backend.app.models_files import UserFile
    engine = get_engine()
    with Session(engine) as session:
        uf = UserFile(id=uid, owner_id=user_id, original_filename=file.filename, stored_path=path, content_type=file.content_type, size=os.path.getsize(path), created_at=datetime.utcnow())
        session.add(uf)
        session.commit()
        session.refresh(uf)
        return {"id": uf.id, "original_filename": uf.original_filename, "content_type": uf.content_type, "created_at": uf.created_at}

@router.get("/", response_model=List[dict])
def list_files(current_user: dict = None):
    user_id = current_user.get("id") if current_user else "anonymous"
    from backend.app.models_files import UserFile
    engine = get_engine()
    with Session(engine) as session:
        stmt = select(UserFile).where(UserFile.owner_id == user_id)
        results = session.exec(stmt).all()
        return [{"id": r.id, "original_filename": r.original_filename, "content_type": r.content_type, "created_at": r.created_at} for r in results]

@router.get("/{file_id}")
def download_file(file_id: str, current_user: dict = None):
    user_id = current_user.get("id") if current_user else "anonymous"
    from backend.app.models_files import UserFile
    engine = get_engine()
    with Session(engine) as session:
        stmt = select(UserFile).where(UserFile.id == file_id, UserFile.owner_id == user_id)
        uf = session.exec(stmt).first()
        if not uf:
            raise HTTPException(status_code=404, detail="File not found")
        return FileResponse(uf.stored_path, filename=uf.original_filename)

@router.delete("/{file_id}", status_code=204)
def delete_file(file_id: str, current_user: dict = None):
    user_id = current_user.get("id") if current_user else "anonymous"
    from backend.app.models_files import UserFile
    engine = get_engine()
    with Session(engine) as session:
        stmt = select(UserFile).where(UserFile.id == file_id, UserFile.owner_id == user_id)
        uf = session.exec(stmt).first()
        if not uf:
            raise HTTPException(status_code=404, detail="File not found")
        if os.path.exists(uf.stored_path):
            os.remove(uf.stored_path)
        session.delete(uf)
        session.commit()
        return {}
