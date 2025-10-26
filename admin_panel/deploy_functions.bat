@echo off
echo ========================================
echo  Firebase Functions Deployment Script
echo ========================================
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI is not installed or not in PATH
    echo Please install Firebase CLI: npm install -g firebase-tools
    pause
    exit /b 1
)

echo ✅ Firebase CLI found
echo.

REM Navigate to functions directory
cd functions
if %errorlevel% neq 0 (
    echo ERROR: Cannot navigate to functions directory
    pause
    exit /b 1
)

echo 📦 Installing dependencies...
npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed
echo.

REM Go back to admin_panel directory
cd ..

echo 🚀 Deploying Firebase Functions...
firebase deploy --only functions
if %errorlevel% neq 0 (
    echo ERROR: Failed to deploy functions
    pause
    exit /b 1
)

echo ✅ Functions deployed successfully!
echo.
echo You can now test notifications using:
echo 1. The admin panel at http://localhost:8000
echo 2. The debug tool at http://localhost:8000/debug_notifications.html
echo.
pause
