from fastapi import APIRouter
from .endpoints import btec, virtual_tutor
from .endpoints import healthcheck

api_router = APIRouter()

# ربط راوتر نقاط النهاية الخاصة بـ btec
api_router.include_router(btec.router, prefix="/btec", tags=["btec"])
# Virtual tutor (uses student progress)
api_router.include_router(virtual_tutor.router, prefix="/virtual-tutor", tags=["virtual_tutor"])
# Healthcheck endpoint
api_router.include_router(healthcheck.router, prefix="/health", tags=["health"])
