# BTEC Smart Platform - Backend API

[![Test Backend](https://github.com/kk121288/BTEC-backend/actions/workflows/test.yml/badge.svg)](https://github.com/kk121288/BTEC-backend/actions/workflows/test.yml)
[![Lint](https://github.com/kk121288/BTEC-backend/actions/workflows/lint.yml/badge.svg)](https://github.com/kk121288/BTEC-backend/actions/workflows/lint.yml)
[![Build](https://github.com/kk121288/BTEC-backend/actions/workflows/build.yml/badge.svg)](https://github.com/kk121288/BTEC-backend/actions/workflows/build.yml)

A comprehensive FastAPI-based backend for the BTEC Smart Platform educational assessment system with AI integration.

## 🚀 Features

- ✅ **FastAPI Framework** - Modern, fast, type-safe Python web framework
- 🔐 **JWT Authentication** - Secure token-based authentication
- 🗄️ **PostgreSQL Database** - Robust relational database with SQLAlchemy ORM
- 🔄 **Database Migrations** - Alembic for version-controlled schema changes
- 📝 **Auto-generated API Documentation** - Interactive Swagger UI and ReDoc
- 🧪 **Comprehensive Testing** - pytest with coverage reporting
- 🐳 **Docker Support** - Containerized deployment
- 🚀 **CI/CD Pipeline** - Automated testing, linting, and deployment
- 📊 **Type Safety** - Full type hints with mypy validation
- 🎨 **Code Quality** - Automated formatting with Ruff

## 📋 Requirements

* [Docker](https://www.docker.com/) for containerized development
* [uv](https://docs.astral.sh/uv/) for Python package and environment management
* Python 3.10 or higher
* PostgreSQL 13 or higher

## 🛠️ Quick Start

### Option 1: Docker Compose (Recommended)

Start the local development environment with Docker Compose following the guide in [../development.md](../development.md).

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f backend

# Run migrations
docker compose exec backend alembic upgrade head

# Create initial superuser
docker compose exec backend python app/initial_data.py
```

### Option 2: Local Development with uv

### Option 2: Local Development with uv

By default, the dependencies are managed with [uv](https://docs.astral.sh/uv/), go there and install it.

From `./backend/` you can install all the dependencies with:

```console
$ uv sync
```

Then you can activate the virtual environment with:

```console
$ source .venv/bin/activate
```

Make sure your editor is using the correct Python virtual environment, with the interpreter at `backend/.venv/bin/python`.

Modify or add SQLModel models for data and SQL tables in `./backend/app/models.py`, API endpoints in `./backend/app/api/`, CRUD (Create, Read, Update, Delete) utils in `./backend/app/crud.py`.

## VS Code

There are already configurations in place to run the backend through the VS Code debugger, so that you can use breakpoints, pause and explore variables, etc.

The setup is also already configured so you can run the tests through the VS Code Python tests tab.

## Docker Compose Override

During development, you can change Docker Compose settings that will only affect the local development environment in the file `docker-compose.override.yml`.

The changes to that file only affect the local development environment, not the production environment. So, you can add "temporary" changes that help the development workflow.

For example, the directory with the backend code is synchronized in the Docker container, copying the code you change live to the directory inside the container. That allows you to test your changes right away, without having to build the Docker image again. It should only be done during development, for production, you should build the Docker image with a recent version of the backend code. But during development, it allows you to iterate very fast.

There is also a command override that runs `fastapi run --reload` instead of the default `fastapi run`. It starts a single server process (instead of multiple, as would be for production) and reloads the process whenever the code changes. Have in mind that if you have a syntax error and save the Python file, it will break and exit, and the container will stop. After that, you can restart the container by fixing the error and running again:

```console
$ docker compose watch
```

There is also a commented out `command` override, you can uncomment it and comment the default one. It makes the backend container run a process that does "nothing", but keeps the container alive. That allows you to get inside your running container and execute commands inside, for example a Python interpreter to test installed dependencies, or start the development server that reloads when it detects changes.

To get inside the container with a `bash` session you can start the stack with:

```console
$ docker compose watch
```

and then in another terminal, `exec` inside the running container:

```console
$ docker compose exec backend bash
```

You should see an output like:

```console
root@7f2607af31c3:/app#
```

that means that you are in a `bash` session inside your container, as a `root` user, under the `/app` directory, this directory has another directory called "app" inside, that's where your code lives inside the container: `/app/app`.

There you can use the `fastapi run --reload` command to run the debug live reloading server.

```console
$ fastapi run --reload app/main.py
```

...it will look like:

```console
root@7f2607af31c3:/app# fastapi run --reload app/main.py
```

and then hit enter. That runs the live reloading server that auto reloads when it detects code changes.

Nevertheless, if it doesn't detect a change but a syntax error, it will just stop with an error. But as the container is still alive and you are in a Bash session, you can quickly restart it after fixing the error, running the same command ("up arrow" and "Enter").

...this previous detail is what makes it useful to have the container alive doing nothing and then, in a Bash session, make it run the live reload server.

## Backend tests

To test the backend run:

```console
$ bash ./scripts/test.sh
```

The tests run with Pytest, modify and add tests to `./backend/tests/`.

If you use GitHub Actions the tests will run automatically.

### Test running stack

If your stack is already up and you just want to run the tests, you can use:

```bash
docker compose exec backend bash scripts/tests-start.sh
```

That `/app/scripts/tests-start.sh` script just calls `pytest` after making sure that the rest of the stack is running. If you need to pass extra arguments to `pytest`, you can pass them to that command and they will be forwarded.

For example, to stop on first error:

```bash
docker compose exec backend bash scripts/tests-start.sh -x
```

### Test Coverage

When the tests are run, a file `htmlcov/index.html` is generated, you can open it in your browser to see the coverage of the tests.

## Migrations

As during local development your app directory is mounted as a volume inside the container, you can also run the migrations with `alembic` commands inside the container and the migration code will be in your app directory (instead of being only inside the container). So you can add it to your git repository.

Make sure you create a "revision" of your models and that you "upgrade" your database with that revision every time you change them. As this is what will update the tables in your database. Otherwise, your application will have errors.

* Start an interactive session in the backend container:

```console
$ docker compose exec backend bash
```

* Alembic is already configured to import your SQLModel models from `./backend/app/models.py`.

* After changing a model (for example, adding a column), inside the container, create a revision, e.g.:

```console
$ alembic revision --autogenerate -m "Add column last_name to User model"
```

* Commit to the git repository the files generated in the alembic directory.

* After creating the revision, run the migration in the database (this is what will actually change the database):

```console
$ alembic upgrade head
```

If you don't want to use migrations at all, uncomment the lines in the file at `./backend/app/core/db.py` that end in:

```python
SQLModel.metadata.create_all(engine)
```

and comment the line in the file `scripts/prestart.sh` that contains:

```console
$ alembic upgrade head
```

If you don't want to start with the default models and want to remove them / modify them, from the beginning, without having any previous revision, you can remove the revision files (`.py` Python files) under `./backend/app/alembic/versions/`. And then create a first migration as described above.

## Email Templates

The email templates are in `./backend/app/email-templates/`. Here, there are two directories: `build` and `src`. The `src` directory contains the source files that are used to build the final email templates. The `build` directory contains the final email templates that are used by the application.

Before continuing, ensure you have the [MJML extension](https://marketplace.visualstudio.com/items?itemName=attilabuti.vscode-mjml) installed in your VS Code.

Once you have the MJML extension installed, you can create a new email template in the `src` directory. After creating the new email template and with the `.mjml` file open in your editor, open the command palette with `Ctrl+Shift+P` and search for `MJML: Export to HTML`. This will convert the `.mjml` file to a `.html` file and now you can save it in the build directory.

## 🚀 Deployment to Render

This project is configured for easy deployment to Render using the `render.yaml` blueprint.

### Prerequisites

1. Create a [Render account](https://render.com/)
2. Generate a Render API key from your account settings
3. Fork/clone this repository to your GitHub account

### Deployment Steps

1. **Connect GitHub Repository:**
   - Go to Render Dashboard
   - Click "New +" → "Blueprint"
   - Connect your GitHub repository
   - Render will detect `render.yaml` automatically

2. **Configure Environment Variables:**
   Set these in Render Dashboard after deployment:
   - `SECRET_KEY` - Generate with: `python -c "import secrets; print(secrets.token_urlsafe(32))"`
   - `FIRST_SUPERUSER` - Your admin email
   - `FIRST_SUPERUSER_PASSWORD` - Secure password
   - `BACKEND_CORS_ORIGINS` - Your frontend URL(s)

3. **Deploy:**
   - Render will automatically build and deploy
   - Database will be created and connected automatically
   - Migrations run automatically on startup

See [../.secrets_placeholders.md](../.secrets_placeholders.md) for detailed secrets configuration.

## 📊 API Documentation

Once running, visit these URLs:

- **Swagger UI** (Interactive): http://localhost:8000/docs
- **ReDoc** (Alternative): http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/api/v1/openapi.json

### Authentication Example

```bash
# Login and get access token
curl -X POST http://localhost:8000/api/v1/login/access-token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin@example.com&password=changethis123"

# Use token in subsequent requests
curl http://localhost:8000/api/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## 📁 Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application entry point
│   ├── api/                 # API routes
│   │   ├── api_v1/
│   │   │   ├── api.py       # API router aggregation
│   │   │   └── endpoints/   # Individual endpoint modules
│   │   └── deps.py          # Dependency injection
│   ├── core/                # Core functionality
│   │   ├── config.py        # Settings and configuration
│   │   ├── db.py            # Database connection
│   │   └── security.py      # Authentication & security
│   ├── models.py            # SQLAlchemy models
│   ├── crud.py              # Database operations
│   ├── alembic/             # Database migrations
│   └── utils.py             # Utility functions
├── tests/                   # Test suite
│   ├── conftest.py          # Test fixtures
│   ├── api/                 # API endpoint tests
│   └── utils/               # Test utilities
├── scripts/                 # Utility scripts
├── Dockerfile               # Docker image definition
├── pyproject.toml           # Dependencies and config
└── README.md                # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run tests: `uv run pytest`
5. Run linting: `uv run ruff check . && uv run ruff format .`
6. Commit your changes
7. Push and create a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 📞 Support

- Documentation: http://localhost:8000/docs
- Issues: [GitHub Issues](https://github.com/kk121288/BTEC-backend/issues)
- Architecture: [architecture.md](../architecture.md)

---

Made with ❤️ for BTEC Smart Platform
