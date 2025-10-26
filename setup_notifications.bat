@echo off
echo 🚀 Complete Notification System Setup
echo =====================================
echo.

echo 📋 Prerequisites Check:
echo - Firebase CLI installed
echo - Node.js installed
echo - Flutter SDK installed
echo - Firebase project configured
echo.

echo 🔧 Step 1: Deploy Firebase Functions
echo ====================================
cd admin_panel\functions
echo Installing dependencies...
npm install
echo.
echo Deploying Firebase Functions...
firebase deploy --only functions
echo.

if %errorlevel% neq 0 (
    echo ❌ Firebase Functions deployment failed
    echo Please check your Firebase configuration and try again
    pause
    exit /b 1
)

echo ✅ Firebase Functions deployed successfully!
echo.

echo 🎯 Step 2: Start Admin Panel
echo ============================
cd ..
echo Starting admin panel server...
echo Open http://localhost:8000 in your browser
echo.
start python -m http.server 8000
echo.

echo 📱 Step 3: Flutter App Setup
echo ============================
cd ..\..\..
echo Cleaning Flutter project...
flutter clean
echo.
echo Getting Flutter dependencies...
flutter pub get
echo.
echo Starting Flutter app...
echo Check console for FCM token and notification registration
echo.
start flutter run
echo.

echo 🧪 Step 4: Test the System
echo ==========================
echo 1. Open admin panel: http://localhost:8000
echo 2. Use test page: http://localhost:8000/test_notification.html
echo 3. Send test notification
echo 4. Check Flutter app receives notification
echo 5. Test navigation and interaction
echo.

echo ✅ Setup Complete!
echo ==================
echo Your notification system is now ready to use!
echo.
echo 📚 Documentation: NOTIFICATION_SETUP_COMPLETE.md
echo 🧪 Test Page: http://localhost:8000/test_notification.html
echo 📊 Admin Panel: http://localhost:8000
echo.

pause
