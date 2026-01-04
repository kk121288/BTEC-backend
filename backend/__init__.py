"""Compatibility shim to ensure `import backend.app` works in tests.

This file makes the `backend` directory a Python package so tests that import
`backend.app.main` continue to work when `PYTHONPATH` is set to the project
root or when running tests inside the container.
"""

__all__ = ["app"]
