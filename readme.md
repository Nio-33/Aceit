# AceIt App

<p align="center">
  <img src="assets/images/logo.png" alt="AceIt Logo" width="200"/>
</p>

> Helping Nigerian students ace their national exams through interactive learning and practice.

## Overview

AceIt is a mobile application designed to help Nigerian SS2/SS3 students prepare effectively for WAEC, JAMB, and NECO examinations. The app provides a comprehensive suite of learning tools including mock tests, daily quizzes, flashcards, and competitive leaderboards to encourage consistent study habits and improve exam success rates.

## Features

- **User Authentication**: 
  - Secure signup and login with email
- **Personalized Learning**: Department and subject selection tailored to student needs
- **Mock Exams**: Full-length practice tests that simulate actual exam conditions
- **Daily Quizzes**: Short, focused quizzes to build consistent study habits
- **Flashcards**: Quick review of key concepts and definitions
- **Progress Tracking**: Weekly reports showing improvement areas
- **Leaderboard**: Competitive rankings to motivate consistent practice
- **Streak Rewards**: Incentives for daily app usage and consistent studying

## Technical Information

- **Platform**: Cross-platform (Android & iOS)
- **Framework**: Flutter
- **Backend**: Firebase (Authentication + Firestore)
- **State Management**: Provider
- **Authentication**: Firebase Auth (email only)

## Screenshots

<p align="center">
  <img src="screenshots/onboarding.png" width="200" alt="Onboarding Screen"/>
  <img src="screenshots/dashboard.png" width="200" alt="Dashboard"/>
  <img src="screenshots/mock_exam.png" width="200" alt="Mock Exam"/>
  <img src="screenshots/flashcards.png" width="200" alt="Flashcards"/>
</p>

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / Xcode
- Firebase account 

### Setup
1. Clone the repository
   ```
   git clone https://github.com/yourusername/aceit_app.git
   ```

2. Navigate to project directory
   ```
   cd aceit_app
   ```

3. Get dependencies
   ```
   flutter pub get
   ```

4. Add Firebase configuration files
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

5. Configure Social Sign-In

6. Run the app
   ```
   flutter run
   ```

## Development

For detailed development information, please refer to:

- [Development Roadmap](development-roadmap.md)
- [Project Structure](project-structure.md)
- [Frontend Flowchart](frontend-flowchart.md)
- [Backend Flowchart](backend-flowchart.md)

## Authentication Flow

The app supports multiple authentication methods:

1. **Email/Password Authentication**
   - Standard sign-up and login with email verification

All authentication methods are handled through Firebase Authentication, with user profiles stored in Firestore.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

Project Lead - [Your Name](mailto:your.email@example.com)

---

*Note: This README will be updated as the project progresses.*