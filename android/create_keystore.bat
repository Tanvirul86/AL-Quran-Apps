@echo off
setlocal EnableDelayedExpansion

cls
echo.
echo ========================================
echo Creating Production Keystore for Al-Quran Pro
echo ========================================
echo.
echo This will create a secure keystore for Play Store publishing
echo.

REM Check if keytool is available
where keytool >nul 2>&1
if errorlevel 1 (
  echo.
  echo ERROR: keytool not found in PATH
  echo Please ensure JDK is installed and JAVA_HOME is set
  echo.
  pause
  exit /b 1
)

REM Check if keystore already exists
if exist upload-keystore.jks (
  echo.
  echo WARNING: upload-keystore.jks already exists
  set /p OVERWRITE="Do you want to overwrite it? (y/N): "
  if /I not "!OVERWRITE!"=="y" (
    echo.
    echo Operation cancelled.
    echo.
    pause
    exit /b 0
  )
  echo.
)

REM Password validation function
:read_passwords
set /p STORE_PASSWORD="Enter keystore password (min 6 characters): "

if not "!STORE_PASSWORD:~5!"=="" (
  set /p CONFIRM_STORE="Confirm keystore password: "
  if not "!STORE_PASSWORD!"=="!CONFIRM_STORE!" (
    echo.
    echo ERROR: Passwords do not match. Please try again.
    echo.
    goto read_passwords
  )
) else (
  echo.
  echo ERROR: Password must be at least 6 characters. Please try again.
  echo.
  goto read_passwords
)

set /p KEY_PASSWORD="Enter key password (min 6 characters): "

if not "!KEY_PASSWORD:~5!"=="" (
  set /p CONFIRM_KEY="Confirm key password: "
  if not "!KEY_PASSWORD!"=="!CONFIRM_KEY!" (
    echo.
    echo ERROR: Passwords do not match. Please try again.
    echo.
    goto read_passwords
  )
) else (
  echo.
  echo ERROR: Password must be at least 6 characters. Please try again.
  echo.
  goto read_passwords
)

echo.
echo Creating keystore...
echo.

keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quran-app-key -storepass "!STORE_PASSWORD!" -keypass "!KEY_PASSWORD!" -dname "CN=Quran App, OU=Apps, O=YourOrg, L=City, ST=State, C=US"

if errorlevel 1 (
  echo.
  echo ERROR: Keystore creation failed. Check output above.
  echo.
  pause
  exit /b 1
)

echo.
echo ========================================
echo Keystore created successfully!
echo ========================================
echo.
echo Now creating key.properties file...

(
echo storePassword=!STORE_PASSWORD!
echo keyPassword=!KEY_PASSWORD!
echo keyAlias=quran-app-key
echo storeFile=upload-keystore.jks
) > key.properties

echo.
echo key.properties file created!
echo.
echo ========================================
echo IMPORTANT SECURITY REMINDERS:
echo ========================================
echo 1. Keep upload-keystore.jks and key.properties safe and NEVER commit to git
echo 2. Add these files to .gitignore immediately
echo 3. Backup these files securely in a safe location
echo 4. You CANNOT recover these files if lost
echo 5. Do not share these files or passwords with anyone
echo.
echo Your app is now ready for production build!
echo.
pause
