# setup.ps1 - One-time project setup script for StudyMate AI
# Run after Flutter SDK is installed and on PATH

Write-Host '======================================' -ForegroundColor Cyan
Write-Host '  StudyMate AI - Project Setup' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan
Write-Host ''

# Ensure C:\flutter\bin is in current session PATH if present
if (Test-Path 'C:\flutter\bin') {
    if ($env:PATH -notlike '*C:\flutter\bin*') {
        $env:PATH = 'C:\flutter\bin;' + $env:PATH
    }
}

# 1. Check Flutter
Write-Host '[1/5] Checking Flutter...' -ForegroundColor Yellow
$flutterVer = flutter --version 2>&1 | Select-String 'Flutter ' | Select-Object -First 1
if ($flutterVer) {
    Write-Host "  OK: $flutterVer" -ForegroundColor Green
} else {
    Write-Host '  ERROR: Flutter not found.' -ForegroundColor Red
    exit 1
}

# 2. Install dependencies
Write-Host '[2/5] Installing pub dependencies...' -ForegroundColor Yellow
flutter pub get
Write-Host '  OK: Dependencies installed' -ForegroundColor Green

# 3. Code generation
Write-Host '[3/5] Running code generation...' -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs
Write-Host '  OK: Code generation complete' -ForegroundColor Green

# 4. Firebase check
Write-Host '[4/5] Firebase setup check...' -ForegroundColor Yellow
if (Select-String -Path 'lib\firebase_options.dart' -Pattern 'YOUR_ANDROID_API_KEY' -Quiet) {
    Write-Host '  NOTE: firebase_options.dart contains placeholder values.' -ForegroundColor Yellow
    Write-Host '  Run: flutterfire configure' -ForegroundColor Yellow
} else {
    Write-Host '  OK: Firebase configured' -ForegroundColor Green
}

# 5. Done
Write-Host ''
Write-Host '[5/5] Setup complete!' -ForegroundColor Green
Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '  1. Set AI API key in app Settings'
Write-Host '  2. Run on web:     flutter run -d chrome'
Write-Host '  3. Run on Android: flutter run -d android'
Write-Host ''
