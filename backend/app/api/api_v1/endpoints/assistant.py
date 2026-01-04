from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Any, Dict
router = APIRouter()

class AssistantQuery(BaseModel):
    prompt: str
    context: Dict[str, Any] = {}

@router.post("/query")
def query_assistant(body: AssistantQuery):
    # Mock deterministic assistant for demo
    prompt = body.prompt.lower()
    answer = "هذه إجابة نموذجية من مساعد قيتاغورس التجريبي."
    recommendations = []
    actions = []
    if "خطة" in prompt or "تعلم" in prompt:
        recommendations.append({"type": "plan", "text": "ابدأ بالأساسيات: 4 أسابيع من المفاهيم ثم تطبيق عملي."})
        actions.append({"type": "enroll", "target": "course_basic"})
    if "امتحان" in prompt or "اختبار" in prompt:
        recommendations.append({"type": "practice", "text": "حلّ 20 سؤالًا تدريبيًا لمدة أسبوع."})
    return {"answer": answer, "recommendations": recommendations, "actions": actions}
