@echo off
echo Downloading Bangla and Quranic fonts...
echo.

cd /d "%~dp0..\assets\fonts"

echo Downloading Noto Sans Bengali Regular...
curl -L -o "NotoSansBengali-Regular.ttf" "https://github.com/notofonts/bengali/releases/download/NotoSansBengali-v2.004/NotoSansBengali-Regular.ttf"

echo Downloading Noto Sans Bengali Bold...
curl -L -o "NotoSansBengali-Bold.ttf" "https://github.com/notofonts/bengali/releases/download/NotoSansBengali-v2.004/NotoSansBengali-Bold.ttf"

echo.
echo ====================================
echo Font download complete!
echo ====================================
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get
echo 3. Test the app
echo.
pause
