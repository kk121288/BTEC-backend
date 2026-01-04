from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from typing import List
from datetime import datetime
import os
import uuid
import shutil

from sqlmodel import Session, select

from app.api.deps import SessionDep, CurrentUser
from app.models import User
from backend.app.models_files import UserFile, UserFilePublic

router = APIRouter()
UPLOAD_ROOT = os.environ.get("UPLOADS_DIR", "uploads")


@router.post("/upload", response_model=UserFilePublic)
def upload_file(file: UploadFile = File(...), session: Session = Depends(SessionDep), current_user: User = Depends(CurrentUser)):
    user_id = str(current_user.id)
    uid = str(uuid.uuid4())
    user_dir = os.path.join(UPLOAD_ROOT, user_id)
    os.makedirs(user_dir, exist_ok=True)
    ext = os.path.splitext(file.filename)[1]
    stored_name = f"{uid}{ext}"
    path = os.path.join(user_dir, stored_name)
    with open(path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    uf = UserFile(id=uid, owner_id=user_id, original_filename=file.filename, stored_path=path, content_type=file.content_type, size=os.path.getsize(path), created_at=datetime.utcnow())
    session.add(uf)
    session.commit()
    session.refresh(uf)
    return UserFilePublic.model_validate(uf)


@router.get("/", response_model=List[UserFilePublic])
def list_files(session: Session = Depends(SessionDep), current_user: User = Depends(CurrentUser)):
    stmt = select(UserFile).where(UserFile.owner_id == str(current_user.id))
    results = session.exec(stmt).all()
    return [UserFilePublic.model_validate(r) for r in results]


@router.get("/{file_id}")
def download_file(file_id: str, session: Session = Depends(SessionDep), current_user: User = Depends(CurrentUser)):
    stmt = select(UserFile).where(UserFile.id == file_id, UserFile.owner_id == str(current_user.id))
    uf = session.exec(stmt).first()
    if not uf:
        raise HTTPException(status_code=404, detail="File not found")
    return FileResponse(path=uf.stored_path, filename=uf.original_filename)


@router.delete("/{file_id}", status_code=204)
def delete_file(file_id: str, session: Session = Depends(SessionDep), current_user: User = Depends(CurrentUser)):
    stmt = select(UserFile).where(UserFile.id == file_id, UserFile.owner_id == str(current_user.id))
    uf = session.exec(stmt).first()
    if not uf:
        raise HTTPException(status_code=404, detail="File not found")
    if os.path.exists(uf.stored_path):
        os.remove(uf.stored_path)
    session.delete(uf)
    session.commit()
    return {}
