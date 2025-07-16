# Firebase Configuration Guide for AceIt App

## The Problem
The app is experiencing timeouts when trying to create an account or login because Firebase Authentication has not been properly configured in the Firebase Console.

## Solution Steps

### 1. Access Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with the Google account that has access to the Firebase project
3. Select the project: `aceit-bd1c9`

### 2. Configure Authentication
1. In the Firebase Console, click on **Authentication** in the left sidebar
2. Click on the **Sign-in method** tab
3. Find **Email/Password** in the list of providers
4. Click the pencil icon to edit
5. Toggle the switch to **Enable**
6. Make sure "Email link (passwordless sign-in)" is set according to your needs
7. Click **Save**

### 3. Verify Configuration
After enabling Email/Password authentication:
1. Wait a few minutes for changes to propagate
2. Restart the app completely
3. Try to create an account again

### 4. Additional Configuration Steps (if needed)

#### For Android:
1. In Firebase Console, go to Project settings (gear icon)
2. Under "Your apps" section, find or add your Android app
3. Make sure the package name matches your app's package name
4. Download the `google-services.json` file
5. Place it in the `android/app/` directory of your Flutter project

#### For iOS:
1. In Firebase Console, go to Project settings (gear icon)
2. Under "Your apps" section, find or add your iOS app
3. Make sure the Bundle ID matches your app's bundle identifier
4. Download the `GoogleService-Info.plist` file
5. Place it in the `ios/Runner/` directory of your Flutter project

### 5. Update Firebase configuration in the app (if needed)
If you need to change the Firebase project or update credentials:
1. Update the `lib/env_example.dart` file with new API keys and credentials
2. Rebuild the app

## Troubleshooting

### CONFIGURATION_NOT_FOUND Error
This error indicates that the Email/Password authentication provider is not enabled in your Firebase project.

### Network-related Errors
If you see "network-request-failed" errors:
1. Ensure the device has internet connectivity
2. Check if Firebase services are not blocked by any firewall
3. Verify the API key is correct and hasn't been restricted

### Email Already in Use
This means the email has already been registered. You can:
1. Use a different email
2. Go to Firebase Console > Authentication > Users to manage existing users

## Important Notes
- Changes in Firebase Console may take a few minutes to propagate
- Make sure your app has Internet permission in the manifest
- For security, restrict your API keys in the Firebase Console to prevent unauthorized use

## Current Firebase Project Information
- Project ID: `aceit-bd1c9`
- Web API Key: `AIzaSyAWzo_h2UVb_fR7yY3gqGz4hKkLBZ0MJUw` 