from typing import List
from sqlmodel import Session, select
from app import crud
from app.models import StudentProgress, User

def recommend_remediation(db: Session, user: User, threshold: float = 0.5) -> List[StudentProgress]:
    statement = select(StudentProgress).where(StudentProgress.user_id == user.id, StudentProgress.progress < threshold)
    return db.exec(statement).all()
