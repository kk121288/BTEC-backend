#!/usr/bin/env bash

set -e
set -x

# Prefer coverage if installed, otherwise run pytest directly
if command -v coverage >/dev/null 2>&1; then
	coverage run -m pytest tests/
	coverage report || true
	coverage html --title "${@-coverage}" || true
else
	echo "coverage not found, running pytest directly"
	if command -v pytest >/dev/null 2>&1; then
		pytest -q tests/
	else
		echo "pytest not found, running simple Python test runner"
		python -B scripts/run_simple_tests.py
	fi
fi
