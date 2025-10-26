@echo off
echo ========================================
echo Deploying Updated Firebase Functions
echo ========================================
echo.

echo Installing dependencies...
cd functions
call npm install
cd ..

echo.
echo Deploying functions to Firebase...
call firebase deploy --only functions

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo.
echo The following functions have been updated:
echo - sendNotification (with image, email, SMS support)
echo - sendEmailNotifications (ready for service integration)
echo - sendSMSNotifications (ready for service integration)
echo.
echo Next steps:
echo 1. Test push notifications with images
echo 2. Set up SendGrid for email (optional)
echo 3. Set up Twilio for SMS (optional)
echo.
pause

