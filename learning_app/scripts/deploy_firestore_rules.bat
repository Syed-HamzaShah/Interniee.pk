@echo off
echo Deploying Firestore security rules...
echo.

REM Check if Firebase CLI is installed
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Firebase CLI is not installed. Please install it first:
    echo npm install -g firebase-tools
    echo.
    echo Then login with: firebase login
    pause
    exit /b 1
)

REM Deploy Firestore rules
echo Deploying Firestore rules...
firebase deploy --only firestore:rules

if %errorlevel% equ 0 (
    echo.
    echo ✅ Firestore rules deployed successfully!
    echo Your app should now work without permission errors.
) else (
    echo.
    echo ❌ Failed to deploy Firestore rules.
    echo Please check your Firebase project configuration.
)

echo.
pause
