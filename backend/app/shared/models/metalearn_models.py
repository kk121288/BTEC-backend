"""
MetaLearn Pro Database Models
Comprehensive database schema for the educational platform
"""

from sqlmodel import SQLModel, Field, Relationship
from typing import Optional, List
from datetime import datetime
from enum import Enum

# Enums
class UserRole(str, Enum):
    STUDENT = "student"
    TEACHER = "teacher"
    PARENT = "parent"
    ADMIN = "admin"

class CourseLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"
    EXPERT = "expert"

class AssessmentType(str, Enum):
    QUIZ = "quiz"
    ASSIGNMENT = "assignment"
    PROJECT = "project"
    EXAM = "exam"
    SIMULATION = "simulation"

class SimulationType(str, Enum):
    CHEMISTRY_LAB = "chemistry_lab"
    PHYSICS_LAB = "physics_lab"
    SURGERY = "surgery"
    SPACE = "space"
    ENGINEERING = "engineering"
    COURTROOM = "courtroom"

# Base Models
class UserBase(SQLModel):
    """Base User model"""
    email: str = Field(unique=True, index=True)
    full_name: str
    role: UserRole
    is_active: bool = True
    avatar_url: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class User(UserBase, table=True):
    """User table"""
    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str
    # Relationships
    student_profile: Optional["Student"] = Relationship(back_populates="user")
    teacher_profile: Optional["Teacher"] = Relationship(back_populates="user")
    parent_profile: Optional["Parent"] = Relationship(back_populates="user")

class Student(SQLModel, table=True):
    """Student profile"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)
    student_number: str = Field(unique=True)
    grade_level: str
    date_of_birth: datetime
    enrolled_at: datetime = Field(default_factory=datetime.utcnow)
    # Gamification
    total_points: int = 0
    current_level: int = 1
    # Relationships
    user: User = Relationship(back_populates="student_profile")
    enrollments: List["CourseEnrollment"] = Relationship(back_populates="student")
    progress: List["Progress"] = Relationship(back_populates="student")
    achievements: List["Achievement"] = Relationship(back_populates="student")

class Teacher(SQLModel, table=True):
    """Teacher profile"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)
    employee_id: str = Field(unique=True)
    department: str
    specialization: str
    hired_at: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    user: User = Relationship(back_populates="teacher_profile")
    courses: List["Course"] = Relationship(back_populates="teacher")

class Parent(SQLModel, table=True):
    """Parent profile"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id", unique=True)
    phone: str
    address: Optional[str] = None
    # Relationships
    user: User = Relationship(back_populates="parent_profile")
    children: List["StudentParent"] = Relationship(back_populates="parent")

class StudentParent(SQLModel, table=True):
    """Student-Parent relationship"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: int = Field(foreign_key="student.id")
    parent_id: int = Field(foreign_key="parent.id")
    relationship_type: str  # father, mother, guardian
    # Relationships
    parent: Parent = Relationship(back_populates="children")

class Course(SQLModel, table=True):
    """Course model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    description: str
    subject: str
    level: CourseLevel
    teacher_id: int = Field(foreign_key="teacher.id")
    duration_weeks: int
    is_vr_enabled: bool = False
    thumbnail_url: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    teacher: Teacher = Relationship(back_populates="courses")
    lessons: List["Lesson"] = Relationship(back_populates="course")
    enrollments: List["CourseEnrollment"] = Relationship(back_populates="course")

class Lesson(SQLModel, table=True):
    """Lesson model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    course_id: int = Field(foreign_key="course.id")
    title: str
    description: str
    content: str
    order: int
    duration_minutes: int
    video_url: Optional[str] = None
    is_vr_lesson: bool = False
    vr_scene_id: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    course: Course = Relationship(back_populates="lessons")
    assessments: List["Assessment"] = Relationship(back_populates="lesson")

class CourseEnrollment(SQLModel, table=True):
    """Course enrollment"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: int = Field(foreign_key="student.id")
    course_id: int = Field(foreign_key="course.id")
    enrolled_at: datetime = Field(default_factory=datetime.utcnow)
    completed_at: Optional[datetime] = None
    progress_percentage: float = 0.0
    # Relationships
    student: Student = Relationship(back_populates="enrollments")
    course: Course = Relationship(back_populates="enrollments")

class Assessment(SQLModel, table=True):
    """Assessment model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    lesson_id: int = Field(foreign_key="lesson.id")
    title: str
    description: str
    type: AssessmentType
    max_score: float
    passing_score: float
    time_limit_minutes: Optional[int] = None
    is_ai_graded: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    lesson: Lesson = Relationship(back_populates="assessments")
    submissions: List["AssessmentSubmission"] = Relationship(back_populates="assessment")

class AssessmentSubmission(SQLModel, table=True):
    """Assessment submission"""
    id: Optional[int] = Field(default=None, primary_key=True)
    assessment_id: int = Field(foreign_key="assessment.id")
    student_id: int = Field(foreign_key="student.id")
    answers: str  # JSON string
    score: Optional[float] = None
    feedback: Optional[str] = None
    ai_feedback: Optional[str] = None
    submitted_at: datetime = Field(default_factory=datetime.utcnow)
    graded_at: Optional[datetime] = None
    # Relationships
    assessment: Assessment = Relationship(back_populates="submissions")

class Progress(SQLModel, table=True):
    """Student progress tracking"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: int = Field(foreign_key="student.id")
    lesson_id: int = Field(foreign_key="lesson.id")
    completed: bool = False
    completion_percentage: float = 0.0
    time_spent_minutes: int = 0
    last_accessed: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    student: Student = Relationship(back_populates="progress")

class Certificate(SQLModel, table=True):
    """Course completion certificate"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: int = Field(foreign_key="student.id")
    course_id: int = Field(foreign_key="course.id")
    certificate_hash: str  # Blockchain hash
    ipfs_hash: Optional[str] = None  # IPFS storage
    nft_token_id: Optional[str] = None
    issued_at: datetime = Field(default_factory=datetime.utcnow)
    verification_url: str

class VirtualClassroom(SQLModel, table=True):
    """Virtual classroom"""
    id: Optional[int] = Field(default=None, primary_key=True)
    course_id: int = Field(foreign_key="course.id")
    name: str
    description: str
    vr_scene_url: str
    max_participants: int
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Simulation(SQLModel, table=True):
    """Interactive simulation"""
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str
    description: str
    type: SimulationType
    subject: str
    vr_scene_url: str
    difficulty_level: CourseLevel
    estimated_duration_minutes: int
    instructions: str
    learning_objectives: str
    created_at: datetime = Field(default_factory=datetime.utcnow)

class Achievement(SQLModel, table=True):
    """Student achievement/badge"""
    id: Optional[int] = Field(default=None, primary_key=True)
    student_id: int = Field(foreign_key="student.id")
    badge_id: str
    badge_name: str
    badge_description: str
    icon_url: str
    earned_at: datetime = Field(default_factory=datetime.utcnow)
    # Relationships
    student: Student = Relationship(back_populates="achievements")

class Notification(SQLModel, table=True):
    """User notifications"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    title: str
    message: str
    type: str
    is_read: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    read_at: Optional[datetime] = None

class AnalyticsEvent(SQLModel, table=True):
    """Analytics event tracking"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: int = Field(foreign_key="user.id")
    event_type: str
    event_data: str  # JSON string
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    session_id: Optional[str] = None
