from datetime import timedelta, datetime
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session

from app import crud
from app.core import security
from app.core.config import settings
from app.models import Token, UserPublic, UserCreate

from app.api.deps import get_db, SessionDep

router = APIRouter()


def create_access_token(subject: str, expires_delta: int | None = None) -> str:
    to_encode: dict[str, Any] = {"sub": subject}
    expire = datetime.utcnow() + timedelta(minutes=(expires_delta or settings.ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    # prefer existing helper in core.security if present
    if hasattr(security, "create_access_token"):
        return security.create_access_token(to_encode)
    import jwt
    alg = getattr(security, "ALGORITHM", "HS256")
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=alg)


@router.post("/access-token", response_model=Token)
def login_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_db)
) -> Token:
    user = crud.authenticate(session=session, email=form_data.username, password=form_data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect email or password")
    access_token = create_access_token(subject=str(user.id))
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/register", response_model=UserPublic, status_code=201)
def register_user(user_in: UserCreate, session: Session = Depends(get_db)) -> UserPublic:
    # This endpoint is for development/demo only (no email verification).
    existing = crud.get_user_by_email(session=session, email=user_in.email)
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = crud.create_user(session=session, user_create=user_in)
    return UserPublic.model_validate(user)
