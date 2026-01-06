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
