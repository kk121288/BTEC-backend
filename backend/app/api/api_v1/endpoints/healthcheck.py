from fastapi import APIRouter
from app.services.healthcheck_service import get_health_status

router = APIRouter()


@router.get("/", tags=["health"])
def health_root():
    """Thin route that delegates to `backend/app/services/healthcheck_service.py`."""
    status = get_health_status()
    return {"status": status}
