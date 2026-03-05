@echo off
REM Complete Data Population Script for Windows
REM This script fetches all Quran data for Play Store publishing

echo ==========================================
echo Quran App - Complete Data Population
echo ==========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is required but not installed.
    echo Please install Python 3 and try again.
    pause
    exit /b 1
)

REM Check if requests library is installed
python -c "import requests" >nul 2>&1
if errorlevel 1 (
    echo Installing required Python packages...
    pip install requests
)

REM Run the data population script
echo Starting data population...
echo This will fetch all 114 surahs with translations.
echo This may take 30-60 minutes. Please be patient.
echo.

python scripts/populate_all_data.py --output assets/data/

echo.
echo ==========================================
echo Data population completed!
echo ==========================================
echo.
echo Next steps:
echo 1. Verify the data files in assets/data/
echo 2. Check for any missing translations
echo 3. Test the app: flutter run
echo 4. Build for release: flutter build appbundle --release
echo.
pause
