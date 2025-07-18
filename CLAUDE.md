# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
AceIt is a Flutter mobile application for Nigerian SS2/SS3 students to prepare for WAEC, JAMB, and NECO examinations. The app provides mock exams, daily quizzes, flashcards, and progress tracking with Firebase backend.

## Architecture
- **Pattern**: Feature-first architecture with Provider state management
- **Structure**: Features organized by domain (`lib/features/`), shared core utilities (`lib/core/`), and reusable widgets (`lib/widgets/`)
- **State Management**: Provider pattern for authentication and app state
- **Backend**: Firebase (Auth, Firestore) with offline-first approach

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run app in development
flutter run

# Build for release
flutter build apk --release
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Clean build artifacts
flutter clean
```

### Firebase Setup
Firebase configuration files are required:
- `android/app/google-services.json` for Android
- `ios/Runner/GoogleService-Info.plist` for iOS

The app includes fallback Firebase configuration and will show diagnostic screens if Firebase is not properly configured.

## Code Standards

### Linting Rules
The project uses strict linting with custom rules defined in `analysis_options.yaml`:
- Prefer single quotes (`prefer_single_quotes: true`)
- Use const constructors (`prefer_const_constructors: true`)
- Package imports only (`always_use_package_imports: true`)
- Strict type checking enabled

### Code Style
- Use single quotes for strings
- Prefer const constructors where possible
- Follow Flutter naming conventions
- Keep widgets focused and composable
- Use proper error handling with try-catch blocks

## Project Structure

### Key Directories
- `lib/features/` - Feature modules (auth, dashboard, profile, etc.)
- `lib/core/` - Shared utilities, services, constants, and themes
- `lib/widgets/` - Reusable UI components
- `lib/models/` - Data models and DTOs
- `assets/` - Images, icons, and animations

### Authentication Flow
- Email/password authentication via Firebase Auth
- Email verification required
- Department and subject selection post-registration
- Automatic routing based on auth state (uninitialized, authenticated, unauthenticated, emailNotVerified)

## Development Guidelines

### Firebase Integration
- Use `FirebaseService` for all Firebase operations
- Handle Firebase initialization errors gracefully
- Implement proper error messages for Firebase Auth errors
- Use Firestore for user profiles and app data

### State Management
- Use Provider for global state (authentication, user data)
- Local state for UI-specific data (form inputs, loading states)
- Implement proper dispose methods for listeners

### Error Handling
- Wrap Firebase operations in try-catch blocks
- Provide user-friendly error messages
- Use logging for debugging (avoid print statements)
- Implement proper loading states

### Testing
- Write unit tests for services and business logic
- Create widget tests for UI components
- Mock Firebase services for testing
- Run `flutter test` before committing

### Flashcard System
- Use `FlashcardService` for all flashcard operations
- Implement session tracking with `FlashcardSessionModel`
- Track confidence levels and study progress
- Support subject-based flashcard organization
- Calculate points based on accuracy and completion

### Quiz System
- Use `QuizService` for quiz session management
- Implement timer functionality and question navigation
- Track detailed analytics in `ExamResultModel`
- Support multiple quiz types (daily, mock_exam, practice)
- Generate comprehensive performance reports

## Dependencies
- **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`
- **State Management**: `provider`
- **UI**: `google_fonts`, `flutter_svg`, `cached_network_image`, `lottie`
- **Storage**: `shared_preferences`
- **Network**: `http`
- **Environment**: `flutter_dotenv`

## Common Issues
- Firebase configuration missing: Check diagnostic screens in settings
- Build errors: Run `flutter clean` and `flutter pub get`
- Authentication issues: Verify Firebase project settings
- iOS build issues: Check `ios/Podfile` and run `pod install`

## Feature Implementation Status
- ✅ Authentication system with Firebase
- ✅ User onboarding and profile setup
- ✅ Basic dashboard structure
- ✅ Firebase diagnostics and configuration
- ✅ Quiz engine with timer and navigation
- ✅ Mock exam system with result analytics
- ✅ Daily quizzes with subject selection
- ✅ Flashcard study system with session tracking
- ✅ Sample data seeding system
- 🔄 Progress analytics dashboard (in progress)
- 🔄 Achievement and gamification system (planned)

## Memories
- to memorize
- Implement function to memorize and recall key project details quickly
- Develop a memory management feature for project-specific knowledge retention