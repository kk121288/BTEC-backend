from fastapi import APIRouter
from .endpoints import btec, virtual_tutor, healthcheck

api_router = APIRouter()

# ربط راوتر نقاط النهاية الخاصة بـ btec
api_router.include_router(btec.router, prefix="/btec", tags=["btec"])
api_router.include_router(virtual_tutor.router, prefix="/virtual-tutor", tags=["virtual-tutor"])
api_router.include_router(healthcheck.router, prefix="/health", tags=["health"])