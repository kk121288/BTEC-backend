"""
Gamification Engine Service
Points, badges, levels, challenges, and avatars
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
from datetime import datetime
from enum import Enum
import os

app = FastAPI(
    title="Gamification Engine Service",
    description="Educational Gamification System - نظام الألعاب التعليمية",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enums
class BadgeCategory(str, Enum):
    ACHIEVEMENT = "achievement"
    MILESTONE = "milestone"
    SKILL = "skill"
    SOCIAL = "social"
    SPECIAL = "special"

class ChallengeType(str, Enum):
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    SPECIAL = "special"

# Models
class Points(BaseModel):
    """Points system"""
    student_id: str
    total_points: int = 0
    earned_today: int = 0
    earned_this_week: int = 0
    earned_this_month: int = 0
    level: int = 1
    points_to_next_level: int = 100

class Badge(BaseModel):
    """Achievement badge"""
    id: str
    name: str
    description: str
    category: BadgeCategory
    icon_url: str
    earned_at: Optional[datetime] = None
    rarity: str = Field(..., description="common, rare, epic, legendary")

class Level(BaseModel):
    """Student level information"""
    current_level: int
    experience_points: int
    total_exp_required: int
    progress_percentage: float
    title: str
    perks: List[str]

class Challenge(BaseModel):
    """Learning challenge"""
    id: str
    title: str
    description: str
    type: ChallengeType
    points_reward: int
    badge_reward: Optional[str] = None
    requirements: Dict[str, int]
    progress: Dict[str, int] = Field(default_factory=dict)
    is_completed: bool = False
    expires_at: Optional[datetime] = None

class Leaderboard(BaseModel):
    """Leaderboard entry"""
    rank: int
    student_id: str
    student_name: str
    points: int
    level: int
    badges_count: int
    avatar_url: str

class Avatar(BaseModel):
    """Student avatar"""
    student_id: str
    avatar_url: str
    customizations: Dict[str, str]
    unlocked_items: List[str]
    equipped_items: List[str]
    avatar_level: int

class Reward(BaseModel):
    """Educational reward"""
    id: str
    title: str
    description: str
    type: str = Field(..., description="unlock, bonus, privilege")
    cost_points: int
    icon_url: str
    is_claimed: bool = False

# Endpoints
@app.get("/")
async def root():
    """Health check"""
    return {
        "service": "Gamification Engine Service",
        "status": "healthy",
        "version": "1.0.0"
    }

@app.get("/api/v1/points/{student_id}", response_model=Points)
async def get_student_points(student_id: str):
    """Get student points"""
    return Points(
        student_id=student_id,
        total_points=2850,
        earned_today=150,
        earned_this_week=680,
        earned_this_month=2100,
        level=12,
        points_to_next_level=150
    )

@app.post("/api/v1/points/{student_id}/add")
async def add_points(student_id: str, points: int, reason: str):
    """Add points to student"""
    return {
        "student_id": student_id,
        "points_added": points,
        "reason": reason,
        "new_total": 2850 + points,
        "level_up": points >= 150
    }

@app.get("/api/v1/badges/{student_id}", response_model=List[Badge])
async def get_student_badges(student_id: str):
    """Get all student badges"""
    return [
        Badge(
            id="badge_1",
            name="First Steps",
            description="Complete your first lesson",
            category=BadgeCategory.MILESTONE,
            icon_url="/badges/first-steps.png",
            earned_at=datetime.utcnow(),
            rarity="common"
        ),
        Badge(
            id="badge_2",
            name="Quick Learner",
            description="Complete 10 lessons in one week",
            category=BadgeCategory.ACHIEVEMENT,
            icon_url="/badges/quick-learner.png",
            earned_at=datetime.utcnow(),
            rarity="rare"
        )
    ]

@app.get("/api/v1/level/{student_id}", response_model=Level)
async def get_student_level(student_id: str):
    """Get student level details"""
    return Level(
        current_level=12,
        experience_points=2850,
        total_exp_required=3000,
        progress_percentage=95.0,
        title="Master Learner",
        perks=[
            "Access to advanced courses",
            "Priority support",
            "Custom avatar items"
        ]
    )

@app.get("/api/v1/challenges/{student_id}", response_model=List[Challenge])
async def get_student_challenges(student_id: str, active_only: bool = True):
    """Get student challenges"""
    return [
        Challenge(
            id="challenge_daily_1",
            title="Daily Dedication",
            description="Complete 3 lessons today",
            type=ChallengeType.DAILY,
            points_reward=50,
            requirements={"lessons": 3},
            progress={"lessons": 2},
            is_completed=False
        ),
        Challenge(
            id="challenge_weekly_1",
            title="Weekly Warrior",
            description="Study for 10 hours this week",
            type=ChallengeType.WEEKLY,
            points_reward=200,
            badge_reward="badge_weekly_warrior",
            requirements={"study_hours": 10},
            progress={"study_hours": 7},
            is_completed=False
        )
    ]

@app.get("/api/v1/leaderboard", response_model=List[Leaderboard])
async def get_leaderboard(category: str = "global", limit: int = 100):
    """Get leaderboard"""
    return [
        Leaderboard(
            rank=1,
            student_id="std_1",
            student_name="Sarah Ahmed",
            points=5200,
            level=15,
            badges_count=24,
            avatar_url="/avatars/sarah.png"
        ),
        Leaderboard(
            rank=2,
            student_id="std_2",
            student_name="Mohammed Ali",
            points=4850,
            level=14,
            badges_count=21,
            avatar_url="/avatars/mohammed.png"
        )
    ]

@app.get("/api/v1/avatar/{student_id}", response_model=Avatar)
async def get_student_avatar(student_id: str):
    """Get student avatar"""
    return Avatar(
        student_id=student_id,
        avatar_url="/avatars/custom/student_123.png",
        customizations={
            "skin_tone": "medium",
            "hair_style": "short",
            "hair_color": "brown",
            "outfit": "casual_blue"
        },
        unlocked_items=["hat_1", "glasses_2", "outfit_3"],
        equipped_items=["glasses_2"],
        avatar_level=5
    )

@app.post("/api/v1/avatar/{student_id}/customize")
async def customize_avatar(student_id: str, customizations: Dict[str, str]):
    """Customize student avatar"""
    return {
        "student_id": student_id,
        "customizations": customizations,
        "success": True,
        "message": "Avatar updated successfully"
    }

@app.get("/api/v1/rewards", response_model=List[Reward])
async def get_available_rewards(student_id: str):
    """Get available rewards"""
    return [
        Reward(
            id="reward_1",
            title="Unlock Advanced Course",
            description="Get early access to advanced courses",
            type="unlock",
            cost_points=500,
            icon_url="/rewards/advanced-course.png"
        ),
        Reward(
            id="reward_2",
            title="Custom Avatar Pack",
            description="Unlock exclusive avatar items",
            type="unlock",
            cost_points=300,
            icon_url="/rewards/avatar-pack.png"
        )
    ]

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8003))
    uvicorn.run(app, host="0.0.0.0", port=port)
