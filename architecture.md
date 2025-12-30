# BTEC Backend Architecture

## Overview

The BTEC Backend is a production-ready FastAPI application designed with a modular, layered architecture that follows best practices for maintainability, scalability, and security.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Client Layer                         │
│  (Web Frontend, Mobile Apps, Third-party Integrations)      │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        │ HTTPS/REST
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway Layer                       │
│                    (FastAPI Application)                     │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │   CORS     │  │ Auth Middleware │  │  Rate Limiting  │   │
│  │ Middleware │  │                │  │   (Future)      │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      Route Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Health     │  │     Auth     │  │   Future Routes  │  │
│  │   Routes     │  │   Routes     │  │                  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │     CRUD     │  │   Security   │  │   Validation     │  │
│  │  Operations  │  │   Services   │  │    (Pydantic)    │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                     Data Access Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  SQLAlchemy  │  │   Database   │  │     Alembic      │  │
│  │     ORM      │  │   Session    │  │   Migrations     │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                      Database Layer                          │
│        SQLite (Development) / PostgreSQL (Production)        │
└─────────────────────────────────────────────────────────────┘
```

## Component Description

### 1. API Gateway Layer (FastAPI)

**Location:** `app/main.py`

The entry point of the application that:
- Initializes the FastAPI application
- Configures middleware (CORS, authentication)
- Includes route modules
- Handles request/response lifecycle
- Provides OpenAPI documentation

**Key Features:**
- Automatic OpenAPI/Swagger documentation
- Request validation
- Response serialization
- Error handling

### 2. Route Layer

**Location:** `app/api/routes/`

Contains endpoint definitions organized by domain:
- `health.py` - Health check endpoints
- `auth.py` - Authentication endpoints (register, login)

**Responsibilities:**
- Define HTTP endpoints
- Extract request data
- Call business logic
- Return responses

### 3. Business Logic Layer

**Location:** `app/crud/`, `app/core/security.py`

Contains the core business logic:
- **CRUD Operations** (`app/crud/user.py`): Database operations
- **Security Services** (`app/core/security.py`): JWT creation, password hashing
- **Validation**: Pydantic schemas in `app/schemas/`

### 4. Data Access Layer

**Location:** `app/db/`, `app/models/`

Manages database interactions:
- **Session Management** (`app/db/session.py`): Database connection and session lifecycle
- **Models** (`app/models/user.py`): SQLAlchemy ORM models
- **Migrations** (`alembic/`): Version-controlled database schema changes

### 5. Configuration Layer

**Location:** `app/core/config.py`

Centralized application configuration:
- Environment variable management
- Settings validation
- Default values
- Type safety with Pydantic

## Data Flow

### 1. Registration Flow

```
Client → POST /api/auth/register
  ↓
FastAPI validates request (Pydantic)
  ↓
auth.py route handler
  ↓
Check if user exists (CRUD)
  ↓
Hash password (Security)
  ↓
Create user in database (CRUD)
  ↓
Return user data (Pydantic schema)
  ↓
Client receives response
```

### 2. Login Flow

```
Client → POST /api/auth/login
  ↓
FastAPI validates OAuth2 form
  ↓
auth.py route handler
  ↓
Authenticate user (CRUD + Security)
  ↓
Verify password hash
  ↓
Create JWT token (Security)
  ↓
Return access token
  ↓
Client receives token
```

### 3. Authenticated Request Flow

```
Client → Request with JWT token
  ↓
OAuth2 scheme extracts token
  ↓
deps.py validates token
  ↓
Decode JWT (Security)
  ↓
Get user from database (CRUD)
  ↓
Return current user
  ↓
Route handler processes request
  ↓
Client receives response
```

## Security Architecture

### 1. Authentication

- **Method:** JWT (JSON Web Tokens)
- **Library:** python-jose
- **Token Location:** Authorization header (Bearer token)
- **Token Expiry:** 8 days (configurable)
- **Subject:** User email

### 2. Password Security

- **Hashing:** Bcrypt via passlib
- **Salt:** Automatic per-password salt
- **Rounds:** Default bcrypt rounds (12)

### 3. CORS Policy

- **Configuration:** Environment-based
- **Default Development:** Allow all origins
- **Production:** Specific allowed origins

## Database Architecture

### Development

- **Database:** SQLite
- **File:** `./dev.db`
- **Connection:** File-based, synchronous
- **Advantages:** Zero configuration, portable

### Production (Render)

- **Database:** PostgreSQL
- **Connection:** Managed by Render
- **Migration:** Automatic via Alembic on deploy
- **Advantages:** ACID compliance, scalability, concurrent connections

### Schema

```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    email VARCHAR UNIQUE NOT NULL,
    hashed_password VARCHAR NOT NULL,
    full_name VARCHAR,
    is_active BOOLEAN DEFAULT TRUE,
    is_superuser BOOLEAN DEFAULT FALSE
);

CREATE INDEX ix_users_email ON users(email);
CREATE INDEX ix_users_id ON users(id);
```

## Deployment Architecture

### CI/CD Pipeline

```
Developer commits → GitHub
  ↓
GitHub Actions triggered
  ↓
┌──────────┬──────────┬──────────┐
│   Lint   │   Test   │  Build   │
│ (ruff,   │ (pytest) │ (Docker) │
│  black)  │          │          │
└──────────┴──────────┴──────────┘
  ↓
All checks pass
  ↓
Merge to main
  ↓
Trigger Render deployment
  ↓
Render pulls code
  ↓
Install dependencies
  ↓
Run migrations
  ↓
Start application
  ↓
Health check
  ↓
Route traffic to new version
```

### Infrastructure (Render)

```
┌─────────────────────────────────────┐
│         Render Platform              │
│                                      │
│  ┌────────────────────────────────┐ │
│  │   Web Service                  │ │
│  │   - FastAPI App                │ │
│  │   - Uvicorn Server             │ │
│  │   - Auto-scaling               │ │
│  │   - HTTPS/SSL                  │ │
│  └────────────┬───────────────────┘ │
│               │                      │
│               ▼                      │
│  ┌────────────────────────────────┐ │
│  │   PostgreSQL Database          │ │
│  │   - Managed instance           │ │
│  │   - Automatic backups          │ │
│  │   - Connection pooling         │ │
│  └────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

## Scalability Considerations

### Horizontal Scaling

- Stateless application design
- JWT tokens (no session storage)
- Database connection pooling
- Ready for load balancer

### Vertical Scaling

- Async support ready (SQLAlchemy 2.0)
- Efficient ORM queries
- Minimal memory footprint

### Future Enhancements

1. **Caching Layer** - Redis for session/token caching
2. **Message Queue** - Celery for background tasks
3. **API Gateway** - Rate limiting, request throttling
4. **Monitoring** - Sentry, Prometheus, Grafana
5. **CDN** - Static asset delivery
6. **Multi-region** - Geographic distribution

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Web Framework | FastAPI 0.109.2 | High-performance async web framework |
| Web Server | Uvicorn 0.27.1 | ASGI server |
| ORM | SQLAlchemy 2.0.27 | Database abstraction |
| Migration | Alembic 1.13.1 | Schema versioning |
| Auth | python-jose 3.3.0 | JWT handling |
| Password | passlib + bcrypt | Secure password hashing |
| Validation | Pydantic 2.6.1 | Data validation |
| Testing | Pytest 8.0.0 | Test framework |
| Linting | Ruff, Black, isort | Code quality |
| Database (Dev) | SQLite | Development database |
| Database (Prod) | PostgreSQL | Production database |
| Deployment | Render | Cloud platform |
| CI/CD | GitHub Actions | Automation |

## Development Principles

1. **Separation of Concerns** - Clear boundaries between layers
2. **Dependency Injection** - FastAPI's dependency system
3. **Type Safety** - Pydantic models and Python type hints
4. **Test-Driven** - Comprehensive test coverage
5. **Configuration as Code** - Environment-based settings
6. **Security by Default** - Secure defaults, explicit overrides
7. **API-First** - OpenAPI documentation as contract
8. **12-Factor App** - Cloud-native best practices

## Error Handling

- HTTP status codes follow REST conventions
- Structured error responses
- Validation errors return field-level detail
- Authentication errors return 401
- Authorization errors return 403
- Not found errors return 404

## Logging and Monitoring

**Current:**
- Uvicorn access logs
- FastAPI automatic request logging

**Future:**
- Structured logging (JSON)
- Log aggregation (CloudWatch, Datadog)
- Error tracking (Sentry)
- Performance monitoring (New Relic, Datadog)
- Custom application metrics

## Security Best Practices

1. ✅ Password hashing with bcrypt
2. ✅ JWT token authentication
3. ✅ SQL injection protection (ORM parameterized queries)
4. ✅ CORS configuration
5. ✅ Environment variable secrets
6. ✅ No secrets in code
7. 🔄 HTTPS in production (Render provided)
8. 🔄 Rate limiting (planned)
9. 🔄 Input sanitization (Pydantic validation)
10. 🔄 Security headers (planned)

---

*This architecture document is maintained alongside the codebase and should be updated with significant architectural changes.*
