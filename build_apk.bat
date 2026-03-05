@echo off
echo ========================================
echo Building Al-Quran Pro APK
echo ========================================
echo.
echo This will create an APK you can share with anyone
echo.

cd /d "%~dp0"

echo Step 1: Cleaning previous builds...
call flutter clean

echo.
echo Step 2: Getting dependencies...
call flutter pub get

echo.
echo Step 3: Building release APK...
call flutter build apk --release

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Your APK is ready at:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo APK Size: 
for %%A in (build\app\outputs\flutter-apk\app-release.apk) do echo %%~zA bytes (approximately %%~zA KB)
echo.
echo You can now:
echo 1. Share this APK via WhatsApp, email, Drive, etc.
echo 2. Install on any Android device (enable "Unknown Sources")
echo 3. Test before publishing to Play Store
echo.
echo ========================================
pause
