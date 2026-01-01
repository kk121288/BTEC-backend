"""Health check endpoint"""

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
def health_check():
    """
    Health check endpoint
    
    Returns:
        Status message
    """
    return {"status": "ok"}
