@echo off
echo 🚀 Setting up Complete Notification System
echo ==========================================

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Firebase CLI not found. Please install it first:
    echo npm install -g firebase-tools
    pause
    exit /b 1
)

REM Check if user is logged in to Firebase
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Please login to Firebase first:
    echo firebase login
    pause
    exit /b 1
)

echo ✅ Firebase CLI is ready

REM Navigate to functions directory
cd admin_panel\functions

echo 📦 Installing dependencies...
npm install

echo 🔧 Deploying Firebase Functions...
firebase deploy --only functions

if %errorlevel% equ 0 (
    echo ✅ Firebase Functions deployed successfully!
    echo.
    echo 🎯 Next Steps:
    echo 1. Open admin panel: cd admin_panel ^&^& python -m http.server 8000
    echo 2. Open http://localhost:8000 in your browser
    echo 3. Test sending notifications from admin panel
    echo 4. Check Flutter app receives notifications
    echo.
    echo 📱 Flutter App Setup:
    echo 1. Run: flutter clean ^&^& flutter pub get
    echo 2. Run: flutter run
    echo 3. Check console for FCM token
    echo 4. Test notification flow
) else (
    echo ❌ Firebase Functions deployment failed
    pause
    exit /b 1
)

pause
