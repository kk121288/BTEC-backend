# 🎓 MetaLearn Pro - نظام المنصة التعليمية الذكية الشاملة

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.10%2B-blue.svg)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.114%2B-green.svg)](https://fastapi.tiangolo.com)
[![Docker](https://img.shields.io/badge/docker-ready-blue.svg)](https://docker.com)

## 🌟 نظرة عامة | Overview

MetaLearn Pro is a comprehensive intelligent educational platform that combines Virtual Reality (VR), Advanced Artificial Intelligence, and Adaptive Learning to create an immersive, personalized learning experience.

منصة تعليمية ذكية متكاملة تجمع بين الواقع الافتراضي (VR)، الذكاء الاصطناعي المتقدم، والتعلم التكيفي لتوفير تجربة تعليمية غامرة ومخصصة.

## ✨ الميزات الرئيسية | Key Features

### 🤖 AI-Powered Services
- **AI Tutor Service** - معلم افتراضي ذكي متعدد التخصصات
  - Automatic student level assessment
  - Adaptive learning (content adjustment based on student abilities)
  - Instant feedback
  - Intelligent diagnosis (strengths and weaknesses)
  - Personalized recommendations
  - Emotional support (sentiment analysis)

- **Learning Companion Service** - رفيق تعلم شخصي ذكي
  - Smart reminders based on schedule
  - Performance analysis with charts
  - Outcome prediction based on performance
  - Dynamic recommendations
  - Automatic study plan adjustment

### 🎮 Gamification Engine
- Points and badges system
- Levels and challenges
- Leaderboards
- Daily quests
- Digital avatar (customizable and upgradeable)
- Educational rewards system

### 🏛️ Virtual Campus
- Full virtual campus
- Smart interactive classrooms
- Virtual labs (chemistry, physics, programming)
- Smart library (interactive digital books)
- Lecture theaters (live lectures in virtual worlds)
- Collaboration zones (spaces for teamwork)
- Historical worlds (visit ancient civilizations)
- Scientific worlds (journeys inside human body, space)

### 🔬 Interactive Simulations
- Virtual chemistry lab
- Virtual surgery simulator
- Space simulation
- Engineering construction
- Virtual courtrooms

### 📊 Analytics & Reporting
- Student performance analysis
- Detailed reports for teachers
- Class statistics
- Grade prediction
- Interactive charts

### 🔐 Blockchain Certificates
- Tamper-proof certificates
- NFT Certificates
- Permanent educational record

## 🏗️ Architecture

### Microservices Structure

```
metalearn-pro/
├── services/
│   ├── ai_tutor/              # AI Tutor microservice
│   ├── learning_companion/    # Learning Companion microservice
│   ├── gamification/          # Gamification Engine microservice
│   ├── virtual_campus/        # Virtual Campus microservice
│   ├── simulations/           # Interactive Simulations microservice
│   ├── analytics/             # Analytics & Reporting microservice
│   └── blockchain/            # Blockchain Certificates microservice
├── backend/
│   └── app/
│       ├── api/               # API routes
│       ├── core/              # Core configurations
│       ├── models.py          # Database models
│       ├── shared/
│       │   ├── ai_integration/  # AI integration layer
│       │   └── models/          # Shared models
│       └── main.py
├── frontend/                  # Next.js frontend (optional)
├── Flutter/                   # Flutter mobile app
└── docker-compose.metalearn.yml
```

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- OpenAI API Key (for AI features)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/kk121288/BTEC-backend.git
cd BTEC-backend
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env and add your configuration
```

Required environment variables:
```env
# OpenAI
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4-turbo-preview

# Database
POSTGRES_USER=admin
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=metalearn_pro

# Redis
REDIS_PASSWORD=your_redis_password

# Security
SECRET_KEY=your_secret_key
JWT_SECRET_KEY=your_jwt_secret
```

3. **Start with Docker Compose**
```bash
docker-compose -f docker-compose.metalearn.yml up -d
```

4. **Or run services individually**

**Backend:**
```bash
cd backend
pip install -e .
uvicorn app.main:app --reload --port 8000
```

**AI Tutor Service:**
```bash
cd services/ai_tutor
pip install -r requirements.txt
python main.py
```

**Learning Companion Service:**
```bash
cd services/learning_companion
pip install -r requirements.txt
python main.py
```

**Gamification Service:**
```bash
cd services/gamification
pip install -r requirements.txt
python main.py
```

### Access the Services

- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs
- **AI Tutor Service**: http://localhost:8001
- **Learning Companion**: http://localhost:8002
- **Gamification Engine**: http://localhost:8003

## 📚 API Documentation

### AI Tutor Service Endpoints

- `POST /api/v1/assess-level` - Assess student level
- `POST /api/v1/feedback` - Get instant feedback
- `GET /api/v1/adaptive-path/{student_id}` - Get adaptive learning path
- `POST /api/v1/diagnose` - Intelligent diagnosis
- `POST /api/v1/emotional-support` - Sentiment analysis and support

### Learning Companion Endpoints

- `POST /api/v1/reminders` - Create smart reminder
- `GET /api/v1/reminders/{student_id}` - Get student reminders
- `GET /api/v1/performance/{student_id}` - Analyze performance
- `GET /api/v1/performance-chart/{student_id}` - Get performance charts
- `GET /api/v1/predict-outcome/{student_id}` - Predict outcomes
- `GET /api/v1/recommendations/{student_id}` - Get dynamic recommendations
- `GET /api/v1/study-plan/{student_id}` - Get adjusted study plan

### Gamification Endpoints

- `GET /api/v1/points/{student_id}` - Get student points
- `POST /api/v1/points/{student_id}/add` - Add points
- `GET /api/v1/badges/{student_id}` - Get student badges
- `GET /api/v1/level/{student_id}` - Get student level
- `GET /api/v1/challenges/{student_id}` - Get challenges
- `GET /api/v1/leaderboard` - Get leaderboard
- `GET /api/v1/avatar/{student_id}` - Get student avatar
- `POST /api/v1/avatar/{student_id}/customize` - Customize avatar

## 🗄️ Database Schema

### Core Models
- **User** (Student, Teacher, Parent, Admin)
- **Course**
- **Lesson**
- **Assessment**
- **Progress**
- **Certificate**
- **VirtualClassroom**
- **Simulation**
- **Achievement**
- **Notification**

## 🔧 Development

### Running Tests
```bash
cd backend
pytest
```

### Code Quality
```bash
# Linting
ruff check .

# Type checking
mypy .

# Format code
ruff format .
```

### Database Migrations
```bash
cd backend
alembic upgrade head
```

## 🌍 Internationalization

The platform supports:
- **Arabic (العربية)** - Full RTL support
- **English** - Full LTR support

## 🔐 Security Features

- End-to-End (E2E) encryption
- Multi-factor authentication (fingerprint, face, voice)
- Student data protection (GDPR, COPPA compliant)
- API Rate limiting
- JWT Authentication
- Secure password hashing with bcrypt

## 📱 Applications

### VR Application
- Full 360-degree VR experience
- Natural interaction (hand movement, gestures, voice)
- Smart conversations with virtual teachers
- Interactive laboratories
- Virtual tours

### Mobile App (Flutter)
- Micro-learning (short lessons)
- Smart notifications
- Quick assessment
- Mobile library
- Chat with teachers and colleagues
- AR support for mobile

### Web Platform (Next.js)
- Comprehensive dashboard
- Content management
- Forums and chats
- Video conferences
- Digital library
- Certified tests and certificates

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: Hamza Al-Manaseer
- **Project**: MetaLearn Pro - Smart Educational Platform
- **Type**: Intelligent Educational System

## 📞 Support

For support, email support@metalearnpro.com or join our Discord community.

## 🗺️ Roadmap

- [x] Core Backend Services (AI Tutor, Learning Companion, Auth)
- [x] Gamification Engine
- [x] Database Models
- [ ] Virtual Campus & VR Infrastructure
- [ ] Smart Dashboards (All roles)
- [ ] Mobile App (Flutter)
- [ ] Blockchain Integration
- [ ] Advanced AI Features
- [ ] Production Deployment

## 🙏 Acknowledgments

- OpenAI for GPT-4 and DALL-E 3
- FastAPI framework
- The open-source community

---

**Built with ❤️ for the future of education**

**بُني بكل ❤️ من أجل مستقبل التعليم**
