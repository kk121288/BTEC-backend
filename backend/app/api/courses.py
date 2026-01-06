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
