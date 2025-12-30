# BTEC Smart Platform - System Architecture

## 📐 Overview

The BTEC Smart Platform is a comprehensive educational assessment system built with modern web technologies, featuring a FastAPI backend, Flutter frontend, and AI-powered assessment capabilities.

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     BTEC Smart Platform                      │
└─────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐
│  Flutter Web/    │         │   Admin Panel    │
│  Mobile Client   │◄───────►│   (Future)       │
└────────┬─────────┘         └──────────────────┘
         │
         │ HTTPS/REST
         │
         ▼
┌─────────────────────────────────────────────────┐
│           API Gateway / Load Balancer            │
│              (Render / Nginx)                    │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│              FastAPI Backend                     │
│  ┌──────────────────────────────────────────┐  │
│  │         API Layer (FastAPI)               │  │
│  │  - Authentication (JWT)                   │  │
│  │  - User Management                        │  │
│  │  - Assessment APIs                        │  │
│  │  - AI Integration                         │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │         Business Logic Layer              │  │
│  │  - CRUD Operations                        │  │
│  │  - Validation                             │  │
│  │  - Business Rules                         │  │
│  └──────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────┐  │
│  │         Data Access Layer                 │  │
│  │  - SQLAlchemy ORM                         │  │
│  │  - Database Models                        │  │
│  │  - Migrations (Alembic)                   │  │
│  └──────────────────────────────────────────┘  │
└───────────────────┬─────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────┐
│           PostgreSQL Database                    │
│  - User Data                                     │
│  - Assessment Data                               │
│  - AI Model Results                              │
│  - Audit Logs                                    │
└─────────────────────────────────────────────────┘

         ┌──────────────────────┐
         │  External Services    │
         │  - Email (SMTP)       │
         │  - Sentry (Monitoring)│
         │  - AI Services        │
         └──────────────────────┘
```

## 🔧 Backend Components

### 1. API Layer (`app/api/`)

**Responsibilities:**
- HTTP request/response handling
- Route definitions and endpoint logic
- Request validation using Pydantic
- Response serialization
- Authentication and authorization

**Key Files:**
- `app/api/main.py` - Main API router
- `app/api/api_v1/api.py` - API v1 router aggregation
- `app/api/api_v1/endpoints/` - Individual endpoint modules
- `app/api/deps.py` - Dependency injection (DB sessions, auth)

### 2. Core Layer (`app/core/`)

**Responsibilities:**
- Configuration management
- Database connection
- Security utilities (JWT, password hashing)
- Global settings

**Key Files:**
- `app/core/config.py` - Settings class with environment variables
- `app/core/db.py` - Database session management
- `app/core/security.py` - JWT creation, password hashing

### 3. Data Layer (`app/models.py`, `app/crud.py`)

**Responsibilities:**
- Database models (SQLModel/SQLAlchemy)
- CRUD operations
- Data validation schemas (Pydantic)

**Key Components:**
- `models.py` - SQLModel database models
- `crud.py` - Create, Read, Update, Delete operations
- Schema classes for request/response validation

### 4. Database Migrations (`app/alembic/`)

**Responsibilities:**
- Version-controlled database schema changes
- Migration scripts
- Database initialization

**Key Files:**
- `alembic/env.py` - Alembic configuration
- `alembic/versions/` - Migration files

## 🔐 Authentication & Security

### JWT Authentication Flow

```
1. User Login
   ├─> Client sends credentials (email + password)
   ├─> Backend validates credentials
   ├─> Backend generates JWT token
   └─> Client receives token

2. Authenticated Request
   ├─> Client includes token in Authorization header
   ├─> Backend validates token signature
   ├─> Backend extracts user info from token
   └─> Backend processes request with user context

3. Token Expiration
   ├─> Tokens expire after ACCESS_TOKEN_EXPIRE_MINUTES
   └─> Client must re-authenticate
```

### Security Features

- **Password Hashing**: bcrypt via passlib
- **JWT Tokens**: HS256 algorithm
- **CORS**: Configurable origins
- **HTTPS**: Required in production
- **Environment Variables**: Sensitive data via env vars
- **SQL Injection Protection**: SQLAlchemy ORM
- **Input Validation**: Pydantic schemas

## 📊 Data Flow

### User Registration

```
Client                Backend              Database
  │                     │                     │
  │ POST /register      │                     │
  ├────────────────────>│                     │
  │                     │ Validate data       │
  │                     │ Hash password       │
  │                     │ Create user         │
  │                     ├────────────────────>│
  │                     │                     │
  │                     │<────────────────────│
  │                     │ Generate JWT        │
  │<────────────────────│                     │
  │ Return token + user │                     │
```

### Authenticated Request

```
Client                Backend              Database
  │                     │                     │
  │ GET /users/me       │                     │
  │ + Bearer Token      │                     │
  ├────────────────────>│                     │
  │                     │ Verify JWT          │
  │                     │ Extract user ID     │
  │                     │ Query user          │
  │                     ├────────────────────>│
  │                     │                     │
  │                     │<────────────────────│
  │<────────────────────│                     │
  │ Return user data    │                     │
```

## 🗄️ Database Schema

### Core Tables

**Users**
- `id` (UUID, Primary Key)
- `email` (String, Unique)
- `hashed_password` (String)
- `full_name` (String, Optional)
- `is_active` (Boolean)
- `is_superuser` (Boolean)

**Items** (Example resource)
- `id` (UUID, Primary Key)
- `title` (String)
- `description` (String, Optional)
- `owner_id` (UUID, Foreign Key → Users)

### Relationships

- One User → Many Items
- Cascade delete: When user deleted, their items are also deleted

## 🚀 Deployment Architecture

### Development Environment

```
┌──────────────────────────────────────┐
│  Docker Compose                      │
│  ┌────────────┐   ┌──────────────┐  │
│  │  Backend   │   │  PostgreSQL  │  │
│  │  Container │───│  Container   │  │
│  └────────────┘   └──────────────┘  │
│  ┌────────────┐                      │
│  │ Mailcatcher│                      │
│  │  (Testing) │                      │
│  └────────────┘                      │
└──────────────────────────────────────┘
```

### Production Environment (Render)

```
┌───────────────────────────────────────────┐
│  Render Platform                          │
│  ┌─────────────────────────────────────┐  │
│  │  Web Service (FastAPI Backend)      │  │
│  │  - Auto-scaling                      │  │
│  │  - Health checks                     │  │
│  │  - HTTPS/TLS                         │  │
│  │  - Environment variables             │  │
│  └────────────┬────────────────────────┘  │
│               │                            │
│  ┌────────────▼────────────────────────┐  │
│  │  PostgreSQL Database (Managed)      │  │
│  │  - Automated backups                │  │
│  │  - High availability                │  │
│  │  - SSL connections                  │  │
│  └─────────────────────────────────────┘  │
└───────────────────────────────────────────┘
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

```
┌─────────────────────────────────────────────┐
│  Pull Request / Push to Branch              │
└─────────────────┬───────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
    ▼             ▼             ▼
┌────────┐  ┌─────────┐  ┌──────────┐
│  Lint  │  │  Test   │  │  Build   │
│        │  │         │  │          │
│ - Ruff │  │ - pytest│  │ - Docker │
│ - mypy │  │ - Coverage │ - Verify │
└────────┘  └─────────┘  └──────────┘
                  │
                  │ (on merge to main)
                  ▼
          ┌──────────────┐
          │   Deploy     │
          │   to Render  │
          └──────────────┘
```

### Workflow Details

1. **Lint Workflow** (`lint.yml`)
   - Runs Ruff linter
   - Checks code formatting
   - Runs mypy type checking

2. **Test Workflow** (`test.yml`)
   - Sets up PostgreSQL service
   - Runs database migrations
   - Executes pytest with coverage
   - Uploads coverage reports

3. **Build Workflow** (`build.yml`)
   - Builds Docker image
   - Verifies image integrity
   - Tests basic imports

4. **Deploy Workflow** (`deploy-render.yml`)
   - Triggers on merge to main
   - Uses Render API to deploy
   - Only runs if secrets configured

## 📦 Dependencies

### Core Dependencies

- **FastAPI**: Modern web framework
- **SQLAlchemy/SQLModel**: ORM and data modeling
- **Alembic**: Database migrations
- **Pydantic**: Data validation
- **psycopg**: PostgreSQL driver
- **python-jose**: JWT handling
- **passlib**: Password hashing

### Development Dependencies

- **pytest**: Testing framework
- **ruff**: Linting and formatting
- **mypy**: Type checking
- **coverage**: Code coverage
- **httpx**: HTTP client for tests

## 🔍 Monitoring & Logging

### Application Monitoring

- **Sentry** (Optional): Error tracking and performance monitoring
- **FastAPI Logs**: Built-in request/response logging
- **Health Checks**: `/api/v1/health` endpoint

### Metrics

- Request/response times
- Error rates
- Database query performance
- Authentication success/failure rates

## 🔮 Future Enhancements

### Planned Features

1. **Caching Layer**
   - Redis for session management
   - Cache frequently accessed data

2. **Message Queue**
   - Celery for background tasks
   - AI model processing in background

3. **File Storage**
   - S3-compatible storage for user uploads
   - Assessment artifacts and media

4. **API Rate Limiting**
   - Prevent abuse
   - Per-user rate limits

5. **WebSocket Support**
   - Real-time notifications
   - Live assessment updates

6. **Multi-tenancy**
   - Support multiple organizations
   - Isolated data per tenant

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://www.sqlalchemy.org/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [Render Documentation](https://render.com/docs)
- [Backend README](backend/README.md)
- [Deployment Guide](DEPLOYMENT_GUIDE.md)

---

**Version**: 1.0  
**Last Updated**: December 2024  
**Maintained by**: BTEC Platform Team
