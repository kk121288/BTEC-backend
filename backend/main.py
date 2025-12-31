<<<<<<< HEAD
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import jwt
from passlib.context import CryptContext
import os

# =========================
# إعدادات JWT
# =========================
SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key")
ALGORITHM = os.getenv("ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

# استخدم bcrypt_sha256 لتجنب حد 72 بايت
pwd_context = CryptContext(schemes=["bcrypt_sha256"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

# =========================
# Fake DB (سيتم استبدالها لاحقًا بقاعدة بيانات حقيقية)
# =========================
fake_user = {
    "id": 1,
    "email": "admin",
    "name": "Admin User",
    "role": "teacher",
    "hashed_password": pwd_context.hash("testpassword")
}

# =========================
# FastAPI App
# =========================
app = FastAPI()

# =========================
# CORS
# =========================
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:10000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# نماذج البيانات
# =========================
class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: dict

# =========================
# دوال مساعدة
# =========================
def verify_password(plain, hashed):
    return pwd_context.verify(plain, hashed)

def authenticate_user(username: str, password: str):
    if username != fake_user["email"]:
        return None
    if not verify_password(password, fake_user["hashed_password"]):
        return None
    return fake_user

def create_access_token(data: dict, expires_minutes: int = 60):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=expires_minutes)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# =========================
# Endpoint: تسجيل الدخول
# =========================
@app.post("/token", response_model=TokenResponse)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({"sub": user["email"]}, ACCESS_TOKEN_EXPIRE_MINUTES)

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": user
    }

# =========================
# Endpoint محمي
# =========================
@app.get("/protected")
async def protected_route(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return {"message": "Access granted", "user": payload["sub"]}
    except:
        raise HTTPException(status_code=401, detail="Invalid token")

# =========================
# Health Check
# =========================
@app.get("/api/health")
def health():
    return {"status": "ok", "time": datetime.utcnow()}
=======
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

# إعداد CORS للسماح للواجهة الأمامية بالاتصال
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        # أضف رابط Vercel عند النشر
        # "https://your-frontend.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# نموذج بيانات تسجيل الدخول
class LoginRequest(BaseModel):
    username: str
    password: str

@app.post("/token")
async def login(data: LoginRequest):
    # تحقق بسيط — سيتم استبداله بقاعدة بيانات لاحقًا
    if data.username != "admin" or data.password != "admin":
        raise HTTPException(status_code=401, detail="Invalid credentials")

    return {
        "access_token": "test_token_123",
        "token_type": "bearer",
        "user": {
            "id": 1,
            "email": data.username,
            "name": "Test User",
            "role": "teacher"
        }
    }
>>>>>>> c28529155f1135dcbcd75db61d9578cbbe1b700b
