# Firebase Setup Guide for AceIt App

This guide will help you set up Firebase properly for the AceIt app to enable full functionality including authentication, database, and social sign-in.

## Prerequisites

1. A Firebase account (https://console.firebase.google.com/)
2. Access to the AceIt project: `aceit-bd1c9`

## Step 1: Firebase Console Setup

### 1.1 Access the Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the project: `aceit-bd1c9`
3. If you don't have access, contact the project owner

### 1.2 Enable Authentication Methods
1. Go to **Authentication** → **Sign-in method**
2. Enable the following providers:
   - **Email/Password** ✅

## Step 2: Download Configuration Files

### 2.1 iOS Configuration
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps**
3. Click **Add app** → **iOS**
4. Enter Bundle ID: `com.niostudio.aceit`
5. Download `GoogleService-Info.plist`
6. Replace the existing file in `ios/Runner/GoogleService-Info.plist`

### 2.2 Android Configuration
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **Your apps**
3. Click **Add app** → **Android**
4. Enter Package name: `com.niostudio.aceit`
5. Download `google-services.json`
6. Replace the existing file in `android/app/google-services.json`

## Step 3: Update iOS Bundle ID

Make sure your iOS bundle ID matches the Firebase configuration:

1. Open `ios/Runner.xcodeproj` in Xcode
2. Select the **Runner** project
3. Go to **General** tab
4. Update **Bundle Identifier** to: `com.niostudio.aceit`

## Step 4: Update Android Package Name

Make sure your Android package name matches the Firebase configuration:

1. Open `android/app/build.gradle.kts`
2. Update `applicationId` to: `"com.niostudio.aceit"`

## Step 5: Configure Social Sign-In

## Step 6: Update Configuration Files

### 6.2 Update Android strings.xml
Add to `android/app/src/main/res/values/strings.xml`:

```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
<string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
```

## Step 7: Test the Configuration

1. Clean and rebuild the project:
   ```bash
   flutter clean
   flutter pub get
   ```

2. Run on iOS:
   ```bash
   flutter run -d "YOUR_IOS_SIMULATOR_ID"
   ```

3. Run on Android:
   ```bash
   flutter run -d "YOUR_ANDROID_DEVICE_ID"
   ```

## Troubleshooting

### Common Issues:

1. **"Firebase is not properly configured"**
   - Check that configuration files are in the correct locations
   - Verify bundle ID/package name matches Firebase console

2. **Social sign-in not working**
   - Verify OAuth client IDs are configured
   - Check URL schemes in iOS Info.plist
   - Ensure Facebook app is properly configured

3. **Build errors**
   - Clean the project: `flutter clean`
   - Delete derived data in Xcode
   - Rebuild: `flutter pub get`

### Verification Checklist:

- [ ] Firebase project created and accessible
- [ ] Authentication methods enabled
- [ ] Configuration files downloaded and placed correctly
- [ ] Bundle ID/package name matches Firebase console
- [ ] Social sign-in providers configured
- [ ] URL schemes added to iOS Info.plist
- [ ] App builds and runs without errors
- [ ] Authentication flows work properly

## Support

If you encounter issues:
1. Check the Firebase Console for error messages
2. Verify all configuration files are correct
3. Ensure bundle IDs and package names match
4. Test on both iOS and Android devices

For additional help, refer to:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/) 