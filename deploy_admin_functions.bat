@echo off
echo ========================================
echo Deploying Admin Panel Firebase Functions
echo ========================================

cd admin_panel

echo.
echo Installing dependencies...
npm install

echo.
echo Deploying Firebase Functions...
firebase deploy --only functions

echo.
echo ========================================
echo Deployment completed!
echo ========================================
echo.
echo Admin Panel Features:
echo - Enhanced notification management
echo - Upcoming projects CRUD operations
echo - Image upload to Firebase Storage
echo - Analytics dashboard with charts
echo - User engagement metrics
echo.
echo Access your admin panel at:
echo https://antella-estates.firebaseapp.com/admin_panel
echo.
pause
