from fastapi import APIRouter, Depends, HTTPException
from typing import List

from app.api import deps
from app.schemas import (
    TutorGreetRequest,
    TutorGreetResponse,
    RecommendationResponse,
    StudentProgressCreate,
    StudentProgressResponse,
)
from app.services import virtual_tutor_service

router = APIRouter()


@router.post("/greet", response_model=TutorGreetResponse)
def greet(request: TutorGreetRequest):
    message = virtual_tutor_service.greet_student(request.name)
    return {"message": message}


@router.post("/recommendations", response_model=RecommendationResponse)
def recommendations(student_id: int | None = None, db: deps.SessionDep = Depends(deps.get_db)):
    recs = virtual_tutor_service.recommend_learning(db, student_id)
    return {"recommendations": recs}


@router.post("/progress", response_model=StudentProgressResponse)
def upsert_progress(payload: StudentProgressCreate, db: deps.SessionDep = Depends(deps.get_db)):
    if payload.progress < 0 or payload.progress > 100:
        raise HTTPException(status_code=400, detail="progress must be between 0 and 100")
    obj = virtual_tutor_service.record_progress(db, payload.student_id, payload.course, payload.progress)
    return obj
