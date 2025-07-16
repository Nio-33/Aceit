# AceIt App - Project Structure

This document outlines the comprehensive structure of the AceIt application, detailing the organization of directories, files, and their purposes.

## Root Structure

```
aceit/
├── android/                  # Android-specific code
├── ios/                      # iOS-specific code
├── web/                      # Web platform support
├── macos/                    # macOS platform support
├── linux/                    # Linux platform support
├── windows/                  # Windows platform support
├── lib/                      # Main Flutter application code
├── test/                     # Test files
├── assets/                   # App assets (images, fonts, etc.)
├── pubspec.yaml              # Flutter dependencies and metadata
└── README.md                 # Project overview
```

## Main Application Code (`lib/`)

```
lib/
├── main.dart                 # Application entry point
├── env_example.dart          # Firebase credentials template
├── platform_imports.dart     # Platform-specific imports abstraction
├── platform_imports_io.dart  # Native platform implementations
├── platform_imports_web.dart # Web platform implementations
├── core/                     # Core utilities and services
├── features/                 # Feature-based organization
├── models/                   # Data models
└── widgets/                  # Shared/global widgets
```

## Core Utilities and Services (`lib/core/`)

```
core/
├── config/
│   └── firebase_config.dart  # Firebase configuration
├── constants/
│   └── app_constants.dart    # Application-wide constants
├── services/
│   ├── auth_service.dart     # Authentication service
│   └── database_service.dart # Database interaction service
├── theme/
│   └── app_theme.dart        # Application theming
├── tools/
│   └── env_generator.dart    # .env file generation tools
└── utils/
    ├── app_utils.dart        # General utility functions
    └── asset_helper.dart     # Asset management utilities
```

## Feature-based Organization (`lib/features/`)

```
features/
├── app.dart                  # Main app component
├── auth/                     # Authentication feature
│   ├── providers/
│   │   └── auth_provider.dart # Authentication state management
│   └── screens/
│       ├── login_screen.dart          # Login screen
│       ├── register_screen.dart       # Registration screen
│       └── forgot_password_screen.dart # Password recovery
├── dashboard/                # Main dashboard feature
│   ├── screens/
│   │   └── dashboard_screen.dart      # Main dashboard screen
│   └── widgets/
│       ├── dashboard_card.dart        # Dashboard card widget
│       └── streak_card.dart           # Streak display widget
├── flashcards/               # Flashcards feature
│   └── screens/
│       └── flashcard_list_screen.dart # Flashcards listing screen
├── leaderboard/              # Leaderboard feature
│   └── screens/
│       └── leaderboard_screen.dart    # Leaderboard rankings screen
├── mock_exams/               # Mock exams feature
│   └── screens/
│       └── mock_exam_list_screen.dart # Mock exam listing screen
├── onboarding/               # Onboarding feature
│   └── screens/
│       └── onboarding_screen.dart     # User onboarding flow
├── profile/                  # User profile feature
│   └── screens/
│       └── profile_screen.dart        # User profile screen
├── quizzes/                  # Quizzes feature
│   └── screens/
│       └── daily_quiz_screen.dart     # Daily quiz screen
└── settings/                 # Settings feature
    └── screens/
        └── firebase_config_screen.dart # Firebase configuration screen
```

## Models (`lib/models/`)

```
models/
├── user_model.dart           # User data model
├── question_model.dart       # Question data model
├── mock_exam_model.dart      # Mock exam data model
└── flashcard_model.dart      # Flashcard data model
```

## Shared Widgets (`lib/widgets/`)

```
widgets/
└── common/                   # Common reusable widgets
    └── custom_button.dart    # Custom button implementation
```

## Assets Structure

```
assets/
├── images/                   # Image assets
│   └── placeholder.txt       # Placeholder for images directory
├── icons/                    # Icon assets
│   └── placeholder.txt       # Placeholder for icons directory
└── temp/                     # Temporary assets
    └── logo_placeholder.txt  # Placeholder logo file
```

## Configuration Files

```
android/app/google-services.json     # Firebase Android config
ios/Runner/GoogleService-Info.plist  # Firebase iOS config
.env                                 # Environment variables file (optional)
pubspec.yaml                         # Project dependencies and config
```

## Firebase Configuration

The app uses a flexible approach to Firebase configuration:

1. **Hardcoded Credentials** (`env_example.dart`):
   - Contains the `FirebaseCredentials` class with default credentials
   - Used as fallback when .env file is not available

2. **Environment Variables** (`.env`):
   - Optional file that can be generated from the app
   - Takes precedence over hardcoded credentials
   - Created via profile screen or with `EnvGenerator` utility

3. **Platform-specific Implementation**:
   - Uses platform-specific file access abstraction
   - Special handling for web platforms where file system access is limited

## Feature-First Architecture Benefits

This project structure follows a feature-first architecture approach which:

1. **Improves Development Focus**: Keeps related code together in feature modules
2. **Enhances Maintainability**: Clean separation between different app features
3. **Facilitates Team Collaboration**: Multiple developers can work on separate features
4. **Simplifies Navigation**: Easy to locate and understand feature-specific components
5. **Supports Scalability**: New features can be added as self-contained modules

---

This project structure is designed to be modular, scalable, and maintainable as the AceIt app grows in complexity. Each directory serves a specific purpose, and files are organized to facilitate easy navigation and comprehension of the codebase.