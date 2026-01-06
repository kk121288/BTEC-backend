"""Compatibility package to map `backend.app` to the real `app` package.

This module adjusts the package search path so imports like
`backend.app.main` resolve to the project's `app` package directory.
"""
import os

# Prepend the actual `app` directory (project-root/app) to this package's __path__
real_app_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "app"))
if os.path.isdir(real_app_path):
    __path__.insert(0, real_app_path)
