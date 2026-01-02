# 📚 BTEC Smart Platform - Assignment Management System

A comprehensive file upload and grading system for educational institutions, featuring role-based access control for teachers and students.

## 🌟 Features

### For Students
- 📤 **Upload Assignments** - Submit homework in multiple formats (PDF, DOC, DOCX, ZIP, images)
- 📊 **Track Progress** - View submission status and grades in real-time
- 📈 **Personal Dashboard** - See statistics including average grades and pending assignments
- 💾 **Download Files** - Access previously submitted assignments

### For Teachers
- 📋 **View All Submissions** - Access all student assignments in one place
- ✅ **Grade Assignments** - Add scores and detailed feedback
- 📥 **Download Files** - Review student work offline
- 📊 **Analytics Dashboard** - Track class performance and ungraded assignments
- 👥 **Student Management** - View individual student progress

## 🚀 Quick Start

### Prerequisites
- Python 3.10+
- PostgreSQL database
- pip or uv package manager

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/kk121288/BTEC-backend.git
cd BTEC-backend
```

2. **Set up environment**
```bash
# Copy environment template
cp .env.example .env
# Edit .env with your database credentials
```

3. **Install dependencies**
```bash
cd backend
pip install fastapi sqlmodel pydantic pydantic-settings alembic psycopg passlib bcrypt pyjwt email-validator python-multipart
```

4. **Run database migrations**
```bash
export PYTHONPATH=$(pwd):$PYTHONPATH
alembic upgrade head
```

5. **Initialize test users**
```bash
python -m app.initial_data
```

This creates:
- **1 Teacher**: username `teacher1`, email `teacher1@btec.edu`, password `1234`
- **10 Students**: usernames `user1` to `user10`, emails `user1@btec.edu` to `user10@btec.edu`, password `1234`

6. **Start the server**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

7. **Access the API**
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc

## 📖 Documentation

### Complete Guides
- **[API Documentation](ASSIGNMENT_API_DOCS.md)** - Detailed API reference with curl examples
- **[Setup Guide](ASSIGNMENT_SETUP_GUIDE.md)** - Comprehensive setup and troubleshooting
- **[Postman Collection](BTEC_Assignment_API.postman_collection.json)** - Ready-to-use API tests

### Quick API Overview

#### Authentication
```bash
# Login
curl -X POST "http://localhost:8000/api/v1/login/access-token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user1@btec.edu&password=1234"
```

#### Upload Assignment (Student)
```bash
curl -X POST "http://localhost:8000/api/v1/assignments/upload" \
  -H "Authorization: Bearer $TOKEN" \
  -F "title=Homework 1" \
  -F "description=Chapter 3 exercises" \
  -F "file=@homework.pdf"
```

#### Grade Assignment (Teacher)
```bash
curl -X PUT "http://localhost:8000/api/v1/assignments/{id}/grade" \
  -H "Authorization: Bearer $TEACHER_TOKEN" \
  -F "grade=95" \
  -F "comments=Great work!"
```

## 🧪 Testing

### Run Component Tests
```bash
python test_assignment_api.py
```

### Run Demo Script
```bash
./demo_assignment_api.sh
```

This demonstrates the complete workflow:
1. Student login and file upload
2. Teacher viewing and grading
3. Statistics and downloads

## 🗄️ Database Schema

### User Table
```sql
- id (UUID, Primary Key)
- email (String, Unique)
- username (String, Unique)
- role (String: 'student' or 'teacher')
- hashed_password (String)
- full_name (String)
- is_active (Boolean)
- is_superuser (Boolean)
```

### Assignment Table
```sql
- id (UUID, Primary Key)
- title (String)
- description (String, Optional)
- student_id (UUID, FK → user.id)
- teacher_id (UUID, FK → user.id, Optional)
- file_path (String)
- file_name (String)
- file_size (Integer)
- uploaded_at (DateTime)
- graded_at (DateTime, Optional)
- grade (Float, Optional, 0-100)
- status (String: 'pending' or 'graded')
- comments (String, Optional)
```

## 🔐 Security Features

- **JWT Authentication** - Secure token-based authentication
- **Role-Based Access Control** - Separate permissions for students and teachers
- **File Validation** - Type and size checks (max 10MB)
- **Secure File Storage** - UUID-based file naming prevents conflicts
- **SQL Injection Protection** - Parameterized queries
- **CORS Configuration** - Controlled cross-origin access

## 📁 File Storage

Uploaded files are stored in:
```
backend/uploads/assignments/
```

### Supported File Types
- Documents: `.pdf`, `.doc`, `.docx`, `.txt`
- Archives: `.zip`
- Images: `.jpg`, `.jpeg`, `.png`

### File Size Limit
Maximum 10 MB per file

## 🎯 API Endpoints

| Method | Endpoint | Role | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/assignments/upload` | Student | Upload assignment |
| GET | `/api/v1/assignments/my` | All | Get user's assignments |
| GET | `/api/v1/assignments/all` | Teacher | Get all assignments |
| PUT | `/api/v1/assignments/{id}/grade` | Teacher | Grade assignment |
| GET | `/api/v1/assignments/{id}/download` | All* | Download file |
| GET | `/api/v1/assignments/stats` | All | Get statistics |
| DELETE | `/api/v1/assignments/{id}` | All* | Delete assignment |

*Students can only access their own assignments

## 🛠️ Development

### Project Structure
```
BTEC-backend/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── api_v1/
│   │   │       └── endpoints/
│   │   │           └── assignments.py    # Assignment endpoints
│   │   ├── alembic/
│   │   │   └── versions/
│   │   │       └── a1b2c3d4e5f6_*.py    # Migration
│   │   ├── core/
│   │   │   ├── db.py                     # Database init
│   │   │   └── security.py               # Auth utilities
│   │   ├── models.py                     # Data models
│   │   ├── crud.py                       # CRUD operations
│   │   └── main.py                       # FastAPI app
│   └── uploads/
│       └── assignments/                  # File storage
├── ASSIGNMENT_API_DOCS.md               # API documentation
├── ASSIGNMENT_SETUP_GUIDE.md            # Setup guide
├── test_assignment_api.py               # Test suite
└── demo_assignment_api.sh               # Demo script
```

### Adding New Features

1. **Update Models** (`app/models.py`)
2. **Create Migration** (`alembic revision --autogenerate -m "description"`)
3. **Add CRUD Functions** (`app/crud.py`)
4. **Create API Endpoints** (`app/api/api_v1/endpoints/`)
5. **Update Documentation**

## 🔄 Migration

### Create New Migration
```bash
cd backend
export PYTHONPATH=$(pwd):$PYTHONPATH
alembic revision --autogenerate -m "description"
alembic upgrade head
```

### Rollback Migration
```bash
alembic downgrade -1
```

## 📊 Statistics Dashboard

### Student Statistics
- Total assignments uploaded
- Pending assignments
- Graded assignments
- Average grade

### Teacher Statistics
- Total assignments (all students)
- Ungraded assignments
- Average class grade
- Student activity

## 🚨 Troubleshooting

### Common Issues

**Database Connection Error**
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Verify credentials in .env
cat .env
```

**Import Errors**
```bash
# Set PYTHONPATH
export PYTHONPATH=/path/to/backend:$PYTHONPATH

# Install missing packages
pip install python-multipart
```

**Migration Errors**
```bash
# Check migration status
alembic current

# Reset (WARNING: Deletes data)
alembic downgrade base
alembic upgrade head
```

## 📝 Test Users

### Teacher Account
- **Username**: `teacher1`
- **Email**: `teacher1@btec.edu`
- **Password**: `1234`
- **Role**: Teacher

### Student Accounts
- **Usernames**: `user1` to `user10`
- **Emails**: `user1@btec.edu` to `user10@btec.edu`
- **Password**: `1234` (all students)
- **Role**: Student

## 🎓 Use Cases

### Typical Student Workflow
1. Login with credentials
2. Upload assignment file
3. Check submission status
4. View grade when available
5. Download feedback

### Typical Teacher Workflow
1. Login with credentials
2. View pending assignments
3. Download student files
4. Review and grade
5. Add feedback comments
6. Check class statistics

## 🔮 Future Enhancements

- [ ] Email notifications for grades
- [ ] Assignment deadlines and late submission tracking
- [ ] Bulk grading capabilities
- [ ] Export grades to CSV/Excel
- [ ] File preview in browser
- [ ] Version control for resubmissions
- [ ] Plagiarism detection integration
- [ ] Mobile app support

## 📄 License

See LICENSE file for details.

## 🤝 Contributing

Contributions welcome! Please read the contributing guidelines first.

## 📧 Support

For issues or questions:
1. Check the [Setup Guide](ASSIGNMENT_SETUP_GUIDE.md)
2. Review the [API Documentation](ASSIGNMENT_API_DOCS.md)
3. Run tests: `python test_assignment_api.py`
4. Open an issue on GitHub

## 🙏 Acknowledgments

Built with:
- [FastAPI](https://fastapi.tiangolo.com/) - Modern web framework
- [SQLModel](https://sqlmodel.tiangolo.com/) - SQL databases with Python
- [Alembic](https://alembic.sqlalchemy.org/) - Database migrations
- [Pydantic](https://pydantic-docs.helpmanual.io/) - Data validation

---

Made with ❤️ for BTEC Smart Platform
