from pydantic import BaseModel, EmailStr, ConfigDict
from datetime import datetime
from typing import Optional

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    role: Optional[str] = "student"

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: str
    role: str
    created_at: datetime

    # التحديث الجديد لـ Pydantic V2
    model_config = ConfigDict(from_attributes=True)

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse

class TokenData(BaseModel):
    email: Optional[str] = None


# User update schema used by CRUD update operations
class UserUpdate(BaseModel):
    password: Optional[str] = None
    is_superuser: Optional[bool] = False
    disabled: Optional[bool] = False


# BTEC assessment create schema
class BTECAssessmentCreate(BaseModel):
    student_name: str
    competency_unit: str
    score: float
    feedback: Optional[str] = None


# Virtual Tutor / Student Progress schemas
class TutorGreetRequest(BaseModel):
    name: str


class TutorGreetResponse(BaseModel):
    message: str


class RecommendationResponse(BaseModel):
    recommendations: list[str]


class StudentProgressCreate(BaseModel):
    student_id: int
    course: str
    progress: float


class StudentProgressResponse(BaseModel):
    id: int
    student_id: int
    course: str
    progress: float
    last_updated: Optional[datetime]

    # التحديث الجديد لـ Pydantic V2
    model_config = ConfigDict(from_attributes=True)


# Item schemas (AR-ready)
class ItemCreate(BaseModel):
    name: str
    description: Optional[str] = None
    ar_model_url: Optional[str] = None


class ItemResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    ar_model_url: Optional[str]
    owner_id: Optional[int]
    created_at: Optional[datetime]

    # التحديث الجديد لـ Pydantic V2
    model_config = ConfigDict(from_attributes=True)