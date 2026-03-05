# Production Signing Setup Guide

## Generate Keystore

### Step 1: Generate the keystore file

**Windows:**
```bash
keytool -genkey -v -keystore c:\Users\YourName\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Linux/Mac:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important:**
- Remember the password you enter
- Remember the alias name (e.g., "upload")
- Keep the keystore file secure - you'll need it for all future updates

### Step 2: Create key.properties file

Create `android/key.properties`:

```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=upload
storeFile=path/to/upload-keystore.jks
```

**Important:** Add `android/key.properties` to `.gitignore` - NEVER commit this file!

### Step 3: Update build.gradle

Update `android/app/build.gradle` to use the signing config:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            ...
        }
    }
}
```

### Step 4: Build Release

```bash
flutter build appbundle --release
```

The AAB file will be signed with your production key.

## Security Notes

- **NEVER** commit `key.properties` or keystore file to version control
- **BACKUP** your keystore file securely
- **REMEMBER** your passwords - you cannot recover them
- Keep keystore file in a secure location

## Troubleshooting

**Error: "key.properties not found"**
- Make sure the file exists at `android/key.properties`
- Check the path in the file is correct

**Error: "Wrong password"**
- Double-check your passwords
- Make sure there are no extra spaces

**Error: "Alias not found"**
- Verify the alias name matches what you used when creating the keystore
