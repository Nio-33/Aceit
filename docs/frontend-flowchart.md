# AceIt App - Frontend Flowchart

## User Flow

```
+-------------------+     +----------------+     +-----------------+
|                   |     |                |     |                 |
|   Splash Screen   +---->+   Onboarding   +---->+  Authentication |
|                   |     |                |     |                 |
+-------------------+     +----------------+     +-------+---------+
                                                         |
                                                         v
+-------------------+     +----------------+     +-----------------+
|                   |     |                |     |                 |
|     Settings      +<----+    Dashboard   +<----+    Department   |
|                   |     |                |     |    Selection    |
+-------------------+     ++--+--------+--++     +-----------------+
                           |  |        |  |
                           |  |        |  |
                           v  v        v  v
          +----------------+  |        |  +----------------+
          |                |  |        |  |                |
          |  Mock Exams    |  |        |  |   Flashcards   |
          |                |  |        |  |                |
          +----------------+  v        v  +----------------+
                           +--+--------+--+
                           |             |
                           |  Daily Quiz |
                           |             |
                           +------+------+
                                  |
                                  v
                           +------+------+
                           |             |
                           | Leaderboard |
                           |             |
                           +-------------+
```

## Screen Components

### Onboarding
- Onboarding Carousel
- Skip/Next Navigation
- Get Started Button

### Authentication
- Login Form
- Registration Form
- Social Login Buttons (Google, Apple, Facebook)
- Password Reset
- Email Verification

### Department Selection
- Department Cards
- Subject Selection Checkboxes
- Save & Continue Button

### Dashboard
- User Profile Summary
- Quick Access Tiles
- Streak Counter
- Today's Challenge
- Progress Charts
- Navigation Menu

### Mock Exams
- Exam List/Categories
- Exam Timer
- Question Navigation
- Answer Selection
- Results Summary
- Performance Analytics

### Flashcards
- Subject/Topic Selection
- Flashcard Display
- Flip Animation
- Mark Known/Unknown
- Progress Tracking

### Daily Quiz
- Question Display
- Multiple Choice Answers
- Timer
- Results Screen
- Streak Update

### Leaderboard
- Global Rankings
- Friend Rankings
- Weekly/Monthly Toggles
- User Score Display
- Achievement Badges

### Settings
- Profile Management
- Notification Controls
- Theme Selection
- Help & Support
- About App
- Logout

## State Management

The app uses Provider for state management with the following providers:
- AuthProvider - Manages user authentication state
- UserProvider - Manages user data and preferences
- QuizProvider - Manages quiz state and progress
- ExamProvider - Manages mock exam state and history
- FlashcardProvider - Manages flashcard collections and progress
- LeaderboardProvider - Manages leaderboard data and rankings

## Navigation

The app uses named routes for navigation with a bottom navigation bar on main screens and drawer navigation for additional options. 