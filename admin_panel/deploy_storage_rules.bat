@echo off
echo Deploying Firebase Storage Rules...
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Firebase CLI is not installed!
    echo Please install Firebase CLI first:
    echo npm install -g firebase-tools
    echo.
    pause
    exit /b 1
)

echo Firebase CLI found. Deploying storage rules...
echo.

REM Deploy storage rules
firebase deploy --only storage

if errorlevel 1 (
    echo.
    echo ERROR: Failed to deploy storage rules!
    echo Please check your Firebase configuration.
    echo.
    pause
    exit /b 1
)

echo.
echo SUCCESS: Storage rules deployed successfully!
echo.
echo You can now test image uploads in the admin panel.
echo.
pause
