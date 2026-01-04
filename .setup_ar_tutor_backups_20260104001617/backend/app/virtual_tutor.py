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
