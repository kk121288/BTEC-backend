from typing import Any, List
from fastapi import APIRouter, Depends
from sqlmodel import Session
from app import models
from app.api import deps
from app.virtual_tutor import recommend_remediation

router = APIRouter()

@router.get("/recommendations", response_model=List[models.StudentProgress])
def get_tutor_recommendations(
    db: Session = Depends(deps.get_db),
    current_user: models.User = Depends(deps.get_current_active_user),
) -> Any:
    return recommend_remediation(db, user=current_user)
