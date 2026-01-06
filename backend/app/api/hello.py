from fastapi import APIRouter
from pydantic import BaseModel
from ..services.hello import say_hello

router = APIRouter(prefix="/hello", tags=["hello"])


class HelloRequest(BaseModel):
    name: str


class HelloResponse(BaseModel):
    message: str


@router.post("/", response_model=HelloResponse)
async def hello(req: HelloRequest):
    return say_hello(req.name)
