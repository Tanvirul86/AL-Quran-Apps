#!/bin/bash

echo "========================================"
echo "Creating Production Keystore for Al-Quran Pro"
echo "========================================"
echo ""
echo "This will create a secure keystore for Play Store publishing"
echo ""

read -sp "Enter keystore password (min 6 characters): " STORE_PASSWORD
echo ""
read -sp "Enter key password (min 6 characters): " KEY_PASSWORD
echo ""

echo ""
echo "Creating keystore..."
echo ""

keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias quran-app-key -storepass "$STORE_PASSWORD" -keypass "$KEY_PASSWORD"

echo ""
echo "========================================"
echo "Keystore created successfully!"
echo "========================================"
echo ""
echo "Now creating key.properties file..."

cat > key.properties << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=quran-app-key
storeFile=../upload-keystore.jks
EOF

echo ""
echo "key.properties file created!"
echo ""
echo "IMPORTANT:"
echo "1. Keep upload-keystore.jks and key.properties safe and NEVER commit to git"
echo "2. Backup these files securely"
echo "3. You CANNOT recover these if lost"
echo ""
echo "Your app is now ready for production build!"
echo ""
