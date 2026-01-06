from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from .api.main import api_router

def create_app():
    app = FastAPI(title="BTEC-backend (Keitagorus foundation)")
    origins = ["http://localhost:3001"]
    extra = os.environ.get("EXTRA_CORS_ORIGINS")
    if extra:
        origins.extend([o.strip() for o in extra.split(",") if o.strip()])
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(api_router)
    return app

app = create_app()
