class AppConstants {
  // App Info
  static const String appName = 'AceIt';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String authRoute = '/auth';
  static const String registerRoute = '/register';
  static const String loginRoute = '/login';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String emailVerificationRoute = '/email-verification';
  static const String departmentSelectionRoute = '/department-selection';
  static const String homeRoute = '/home';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String subjectsRoute = '/subjects';
  static const String mockExamRoute = '/mock-exam';
  static const String quizRoute = '/quiz';
  static const String flashcardsRoute = '/flashcards';
  static const String leaderboardRoute = '/leaderboard';
  static const String firebaseDiagnosticRoute = '/firebase-diagnostic';
  
  // Shared Preferences Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String selectedSubjectsKey = 'selected_subjects';
  static const String selectedDepartmentKey = 'selected_department';
  static const String currentStreakKey = 'current_streak';
  static const String lastLoginDateKey = 'last_login_date';
  static const String pointsKey = 'points';
  static const String emailVerifiedKey = 'email_verified';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String subjectsCollection = 'subjects';
  static const String questionsCollection = 'questions';
  static const String quizzesCollection = 'quizzes';
  static const String mockExamsCollection = 'mock_exams';
  static const String flashcardsCollection = 'flashcards';
  static const String userProgressCollection = 'user_progress';
  static const String leaderboardCollection = 'leaderboard';
  
  // Departments
  static const List<String> departments = [
    'Science',
    'Arts',
    'Commercial',
  ];
  
  // Subjects By Department
  static const Map<String, List<String>> subjectsByDepartment = {
    'Science': [
      'Mathematics',
      'English',
      'Physics',
      'Chemistry',
      'Biology',
    ],
    'Arts': [
      'Mathematics',
      'English',
      'Literature',
      'Government',
      'History',
      'CRK/IRK',
    ],
    'Commercial': [
      'Mathematics',
      'English',
      'Accounting',
      'Commerce',
      'Economics',
    ],
  };
  
  // Common Subjects (Core)
  static const List<String> coreSubjects = [
    'Mathematics',
    'English',
  ];
  
  // Exam Types
  static const List<String> examTypes = [
    'WAEC',
    'JAMB',
    'NECO',
  ];
} 