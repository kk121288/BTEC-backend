#!/usr/bin/env bash
set -e

echo "Bootstrapping backend environment..."
cd backend
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt

echo "Backend environment ready. Activate with: source backend/.venv/bin/activate"
