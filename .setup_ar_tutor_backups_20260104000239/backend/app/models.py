from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

# For Item model (SQLModel) used by some services/crud
from sqlmodel import SQLModel, Field
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, default="student")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, role={self.role})>"

class BTECAssessment(Base):
    __tablename__ = "btec_assessments"

    id = Column(Integer, primary_key=True, index=True)
    student_name = Column(String, index=True, nullable=False)
    competency_unit = Column(String, index=True, nullable=False)
    score = Column(Float, nullable=False)
    feedback = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User")

    def __repr__(self):
        return f"<BTECAssessment(id={self.id}, student_name='{self.student_name}', score={self.score})>"


# Lightweight `Item` model used by CRUD and frontend. This is a SQLModel
# so it exposes `model_validate()` and works with Pydantic-style inputs.
class Item(SQLModel, table=True):
    __tablename__ = "item"

    id: int | None = Field(default=None, primary_key=True)
    name: str
    description: str | None = None
    owner_id: int | None = Field(default=None, foreign_key="users.id")
    ar_model_url: str | None = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        arbitrary_types_allowed = True


class StudentProgress(Base):
    __tablename__ = "student_progress"

    id = Column(Integer, primary_key=True, index=True)
    # student_id uses UUID to match migrated user IDs
    student_id = Column(UUID(as_uuid=True), index=True, nullable=False)
    course = Column(String, index=True, nullable=False)
    progress = Column(Float, nullable=False, default=0.0)  # 0.0 - 100.0
    last_updated = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    def __repr__(self):
        return f"<StudentProgress(id={self.id}, student_id={self.student_id}, course='{self.course}', progress={self.progress})>"
