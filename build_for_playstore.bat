@echo off
echo ========================================
echo Building Al-Quran Pro for Play Store
echo ========================================
echo.

cd /d "%~dp0"

REM Check if keystore exists
if not exist "android\key.properties" (
    echo ERROR: Keystore not found!
    echo.
    echo Please run android\create_keystore.bat first to create your signing key.
    echo.
    pause
    exit /b 1
)

echo Keystore found! Building signed App Bundle...
echo.

echo Step 1: Cleaning previous builds...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building signed App Bundle for Play Store...
call flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo Your App Bundle is ready at:
    echo build\app\outputs\bundle\release\app-release.aab
    echo.
    echo Next steps:
    echo 1. Go to https://play.google.com/console
    echo 2. Create new app or select existing app
    echo 3. Upload app-release.aab
    echo 4. Complete store listing
    echo 5. Submit for review
    echo.
    echo IMPORTANT: Backup your keystore files!
    echo - android\upload-keystore.jks
    echo - android\key.properties
    echo.
) else (
    echo.
    echo ========================================
    echo BUILD FAILED!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo Common issues:
    echo - Flutter not in PATH
    echo - Incorrect keystore password
    echo - Missing dependencies
    echo.
)

echo ========================================
pause
