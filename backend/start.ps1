# StudyMate AI Backend - Startup Script
Write-Host "=== StudyMate AI Backend ===" -ForegroundColor Cyan

$pyExe = "C:\Users\richu\AppData\Local\Programs\Python311-embed\python.exe"
$pipExe = "C:\Users\richu\AppData\Local\Programs\Python311-embed\Scripts\pip.exe"

if (-not (Test-Path $pyExe)) {
    Write-Error "Python not found at $pyExe"
    exit 1
}

Write-Host "Python: $(& $pyExe --version)" -ForegroundColor Green

# Install dependencies directly (no venv needed - embed has pip)
Write-Host "Installing dependencies..." -ForegroundColor Yellow
& $pyExe -m pip install -r requirements.txt --quiet

# Start server
Write-Host ""
Write-Host "Starting backend on http://localhost:8000" -ForegroundColor Green
Write-Host "API docs:  http://localhost:8000/docs" -ForegroundColor Cyan
& $pyExe -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
