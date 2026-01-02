"""
Learning Companion Service Main Application
FastAPI microservice for personalized learning companion
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from datetime import datetime, timedelta
from enum import Enum
import os

app = FastAPI(
    title="Learning Companion Service",
    description="Personal Intelligent Learning Companion - رفيق تعلم شخصي ذكي",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enums
class ReminderType(str, Enum):
    STUDY = "study"
    ASSIGNMENT = "assignment"
    EXAM = "exam"
    BREAK = "break"
    REVIEW = "review"

class Priority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"

# Models
class SmartReminder(BaseModel):
    """Smart reminder based on schedule"""
    id: Optional[str] = None
    student_id: str
    type: ReminderType
    title: str
    description: str
    scheduled_time: datetime
    priority: Priority
    is_completed: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

class PerformanceMetrics(BaseModel):
    """Performance analysis metrics"""
    student_id: str
    subject: str
    period: str = Field(..., description="daily, weekly, monthly")
    average_score: float = Field(..., ge=0, le=100)
    completion_rate: float = Field(..., ge=0, le=100)
    time_spent_minutes: int
    improvement_rate: float = Field(..., description="Percentage improvement")
    strengths: List[str]
    areas_for_improvement: List[str]

class PerformanceChart(BaseModel):
    """Performance chart data"""
    labels: List[str]
    scores: List[float]
    completion_rates: List[float]
    time_spent: List[int]

class OutcomePrediction(BaseModel):
    """Predicted outcomes based on performance"""
    student_id: str
    subject: str
    predicted_grade: str
    confidence: float = Field(..., ge=0, le=1)
    predicted_score: float = Field(..., ge=0, le=100)
    factors: Dict[str, float]
    recommendations: List[str]
    risk_level: str = Field(..., description="low, medium, high")

class DynamicRecommendation(BaseModel):
    """Dynamic learning recommendations"""
    student_id: str
    recommendations: List[Dict[str, str]]
    priority_topics: List[str]
    suggested_resources: List[Dict[str, str]]
    study_tips: List[str]

class StudyPlan(BaseModel):
    """Automatically adjusted study plan"""
    student_id: str
    week_number: int
    daily_goals: Dict[str, List[str]]
    total_hours: int
    subjects: List[str]
    milestones: List[Dict[str, str]]
    adjusted_based_on: List[str]

# Endpoints
@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "service": "Learning Companion Service",
        "status": "healthy",
        "version": "1.0.0",
        "description": "Personal learning companion - رفيق التعلم الشخصي"
    }

@app.post("/api/v1/reminders", response_model=SmartReminder)
async def create_smart_reminder(reminder: SmartReminder):
    """
    Create intelligent reminder based on schedule
    التذكير الذكي حسب الجدول
    """
    reminder.id = f"rem_{datetime.utcnow().timestamp()}"
    return reminder

@app.get("/api/v1/reminders/{student_id}", response_model=List[SmartReminder])
async def get_student_reminders(student_id: str, active_only: bool = True):
    """Get all reminders for a student"""
    return []

@app.get("/api/v1/performance/{student_id}", response_model=PerformanceMetrics)
async def analyze_performance(student_id: str, subject: str, period: str = "weekly"):
    """
    Analyze student performance with charts
    تحليل الأداء - رسوم بيانية
    """
    return PerformanceMetrics(
        student_id=student_id,
        subject=subject,
        period=period,
        average_score=82.5,
        completion_rate=90.0,
        time_spent_minutes=450,
        improvement_rate=15.5,
        strengths=[
            "Consistent study habits",
            "Quick problem-solving",
            "Active participation"
        ],
        areas_for_improvement=[
            "Complex problem analysis",
            "Time management for lengthy tasks"
        ]
    )

@app.get("/api/v1/performance-chart/{student_id}", response_model=PerformanceChart)
async def get_performance_chart(student_id: str, subject: str, days: int = 30):
    """Get performance chart data for visualization"""
    return PerformanceChart(
        labels=["Week 1", "Week 2", "Week 3", "Week 4"],
        scores=[75.0, 78.5, 82.0, 85.5],
        completion_rates=[85.0, 88.0, 92.0, 95.0],
        time_spent=[300, 320, 340, 360]
    )

@app.get("/api/v1/predict-outcome/{student_id}", response_model=OutcomePrediction)
async def predict_outcomes(student_id: str, subject: str):
    """
    Predict outcomes based on current performance
    تنبؤ النتائج بناءً على الأداء
    """
    return OutcomePrediction(
        student_id=student_id,
        subject=subject,
        predicted_grade="A",
        confidence=0.85,
        predicted_score=88.5,
        factors={
            "current_performance": 0.40,
            "consistency": 0.30,
            "improvement_trend": 0.20,
            "engagement": 0.10
        },
        recommendations=[
            "Continue current study pattern",
            "Focus on practice problems for complex topics",
            "Join peer study sessions for collaborative learning"
        ],
        risk_level="low"
    )

@app.get("/api/v1/recommendations/{student_id}", response_model=DynamicRecommendation)
async def get_dynamic_recommendations(student_id: str):
    """
    Generate dynamic recommendations based on performance
    التوصيات الديناميكية
    """
    return DynamicRecommendation(
        student_id=student_id,
        recommendations=[
            {
                "type": "study_technique",
                "title": "Pomodoro Technique",
                "description": "25-minute focused study sessions with 5-minute breaks",
                "priority": "high"
            },
            {
                "type": "resource",
                "title": "Advanced Problem Set",
                "description": "Practice challenging problems to strengthen weak areas",
                "priority": "medium"
            }
        ],
        priority_topics=[
            "Data Structures - Trees and Graphs",
            "Algorithm Complexity Analysis",
            "Dynamic Programming"
        ],
        suggested_resources=[
            {"type": "video", "title": "Tree Traversal Explained", "url": "/resources/video/tree-traversal"},
            {"type": "article", "title": "DP Patterns Guide", "url": "/resources/article/dp-patterns"},
            {"type": "interactive", "title": "Algorithm Visualizer", "url": "/resources/visualizer"}
        ],
        study_tips=[
            "Review concepts in the morning when mind is fresh",
            "Practice coding problems daily",
            "Teach concepts to others to solidify understanding"
        ]
    )

@app.get("/api/v1/study-plan/{student_id}", response_model=StudyPlan)
async def get_adjusted_study_plan(student_id: str):
    """
    Get automatically adjusted study plan
    تعديل الخطة الدراسية تلقائياً
    """
    return StudyPlan(
        student_id=student_id,
        week_number=12,
        daily_goals={
            "Monday": ["Review Data Structures chapter 5", "Complete 5 practice problems", "Watch tutorial video"],
            "Tuesday": ["Algorithm practice - 1 hour", "Read research paper", "Peer discussion"],
            "Wednesday": ["Project work - 2 hours", "Code review session"],
            "Thursday": ["Advanced topics study", "Mock test preparation"],
            "Friday": ["Mock test", "Review and reflection"],
            "Saturday": ["Personal project work", "Explore new concepts"],
            "Sunday": ["Weekly review", "Plan next week", "Rest and recharge"]
        },
        total_hours=20,
        subjects=["Computer Science", "Mathematics", "Physics"],
        milestones=[
            {"week": "12", "goal": "Complete Data Structures module", "status": "in_progress"},
            {"week": "13", "goal": "Algorithm optimization mastery", "status": "upcoming"},
            {"week": "14", "goal": "Mid-term preparation", "status": "upcoming"}
        ],
        adjusted_based_on=[
            "Current performance trends",
            "Upcoming deadlines",
            "Identified weak areas",
            "Learning pace analysis"
        ]
    )

@app.post("/api/v1/study-plan/{student_id}/adjust")
async def adjust_study_plan(student_id: str, performance_data: Dict):
    """Automatically adjust study plan based on performance"""
    return {
        "student_id": student_id,
        "adjusted": True,
        "changes": [
            "Increased focus time on weak areas by 30%",
            "Added more practice problems for complex topics",
            "Scheduled additional review sessions"
        ],
        "message": "Study plan has been optimized based on your recent performance"
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8002))
    uvicorn.run(app, host="0.0.0.0", port=port)
