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
