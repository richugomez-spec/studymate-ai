#!/bin/bash
echo "=== StudyMate AI Backend ==="

# Create venv
python3 -m venv venv 2>/dev/null || python -m venv venv
source venv/bin/activate

# Install
pip install -r requirements.txt -q

# Run
echo "Starting on http://localhost:8000  |  Docs: http://localhost:8000/docs"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
