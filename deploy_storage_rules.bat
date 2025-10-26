@echo off
echo Deploying Firebase Storage Rules...
echo.

firebase deploy --only storage

if %errorlevel% equ 0 (
    echo.
    echo ✅ Storage rules deployed successfully!
    echo.
    echo The admin panel should now be able to upload images.
    echo Try uploading a project image in the admin panel.
) else (
    echo.
    echo ❌ Failed to deploy storage rules.
    echo Please check your Firebase configuration and try again.
)

echo.
pause
