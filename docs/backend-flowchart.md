# AceIt App - Backend Flowchart

## Firebase Architecture

```
+-------------------------------------+
|                                     |
|           Firebase Project          |
|                                     |
+--+---------------+---------------+--+
   |               |               |
   v               v               v
+--+-----+    +----+----+    +-----+----+
|        |    |         |    |          |
| Auth   |    | Firestore|    | Storage  |
|        |    |         |    |          |
+--+-----+    +----+----+    +-----+----+
   |               |               |
   v               v               v
+--+-----+    +----+----+    +-----+----+
|        |    |         |    |          |
| Users  |    | Database |    | Images/  |
| Auth   |    | Services |    | Media    |
|        |    |         |    |          |
+--------+    +---------+    +----------+
```

## Data Models Structure

### Users Collection
```
users/
  ├── user_id/
  │     ├── displayName: String
  │     ├── email: String
  │     ├── photoURL: String
  │     ├── department: String
  │     ├── subjects: Array<String>
  │     ├── createdAt: Timestamp
  │     ├── lastLogin: Timestamp
  │     ├── streak: Number
  │     ├── totalPoints: Number
  │     ├── deviceToken: String
  │     └── settings: Map
  │           ├── notifications: Boolean
  │           ├── darkMode: Boolean
  │           └── language: String
```

### User Progress
```
user_progress/
  ├── user_id/
  │     ├── exams/
  │     │     ├── exam_id/
  │     │     │     ├── startedAt: Timestamp
  │     │     │     ├── completedAt: Timestamp
  │     │     │     ├── score: Number
  │     │     │     ├── totalQuestions: Number
  │     │     │     ├── correctAnswers: Number
  │     │     │     └── answers: Map
  │     │     │           └── question_id: String (selected option)
  │     ├── quizzes/
  │     │     ├── quiz_id/
  │     │     │     ├── date: Timestamp
  │     │     │     ├── score: Number
  │     │     │     └── answers: Map
  │     └── flashcards/
  │           ├── deck_id/
  │                 ├── lastReviewed: Timestamp
  │                 ├── mastered: Array<String>
  │                 ├── learning: Array<String>
  │                 └── difficult: Array<String>
```

### Subject Content
```
subjects/
  ├── subject_id/
  │     ├── name: String
  │     ├── description: String
  │     ├── icon: String
  │     └── departments: Array<String>
```

### Exam Content
```
exams/
  ├── exam_id/
  │     ├── title: String
  │     ├── subject: String
  │     ├── description: String
  │     ├── durationMinutes: Number
  │     ├── totalQuestions: Number
  │     ├── passingScore: Number
  │     ├── difficulty: String
  │     ├── createdAt: Timestamp
  │     ├── lastUpdated: Timestamp
  │     └── questions: Array<Reference>
```

### Questions Bank
```
questions/
  ├── question_id/
  │     ├── text: String
  │     ├── subject: String
  │     ├── topic: String
  │     ├── difficulty: String
  │     ├── type: String (MCQ/True-False/Fill-in)
  │     ├── options: Array<String>
  │     ├── correctOption: Number/String
  │     ├── explanation: String
  │     └── media: String (URL to image if applicable)
```

### Flashcards
```
flashcards/
  ├── deck_id/
  │     ├── title: String
  │     ├── subject: String
  │     ├── description: String
  │     ├── createdAt: Timestamp
  │     ├── lastUpdated: Timestamp
  │     └── cards: Array<Map>
  │           ├── id: String
  │           ├── front: String
  │           ├── back: String
  │           └── media: String (optional)
```

### Leaderboard
```
leaderboard/
  ├── weekly/
  │     ├── date: String (YYYY-WW format)
  │     └── rankings: Array<Map>
  │           ├── userId: String
  │           ├── displayName: String
  │           ├── photoURL: String
  │           ├── points: Number
  │           └── position: Number
  │
  └── monthly/
        ├── date: String (YYYY-MM format)
        └── rankings: Array<Map>
              ├── userId: String
              ├── displayName: String
              ├── photoURL: String
              ├── points: Number
              └── position: Number
```

## Authentication Flow

1. User initiates login/signup
2. Firebase Authentication handles credentials
3. On successful authentication:
   - For new users: Create user document in Firestore
   - For existing users: Update lastLogin timestamp
4. Return authentication state to app
5. App navigates based on authentication state:
   - If new user: Department selection
   - If existing user: Dashboard

## Data Access Flow

### Reading Data
1. App requests data via Firebase service
2. Firebase security rules validate user access permissions
3. If authorized, data is fetched and delivered to app
4. App updates UI with received data

### Writing Data
1. App sends data update via Firebase service
2. Firebase security rules validate operation permissions
3. If authorized, data is written to Firestore
4. Success/failure response is returned to app

## Cloud Functions (Future Implementation)

Planned cloud functions to handle:
- User streak calculations
- Weekly/monthly leaderboard generation
- Notification scheduling
- Content recommendation algorithm 