import 'package:flutter/foundation.dart';
import 'package:aceit/models/quiz_session_model.dart';
import 'package:aceit/models/exam_result_model.dart';
import 'package:aceit/models/question_model.dart';
import 'package:aceit/core/services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();

  // Current quiz session
  QuizSessionModel? _currentSession;
  QuizSessionModel? get currentSession => _currentSession;

  // Current questions for the session
  List<QuestionModel> _questions = [];
  List<QuestionModel> get questions => _questions;

  // Current question being displayed
  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  // Current question
  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  // Quiz state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Timer state
  int _remainingTimeInSeconds = 0;
  int get remainingTimeInSeconds => _remainingTimeInSeconds;

  // Question timer
  DateTime? _questionStartTime;
  DateTime? get questionStartTime => _questionStartTime;

  // Quiz history
  List<ExamResultModel> _quizHistory = [];
  List<ExamResultModel> get quizHistory => _quizHistory;

  // User stats
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? get userStats => _userStats;

  // Start a new quiz session
  Future<void> startQuiz({
    required String userId,
    required String quizType,
    required String subject,
    required String examType,
    required int durationInMinutes,
    String? mockExamId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Start quiz session
      _currentSession = await _quizService.startQuizSession(
        userId: userId,
        quizType: quizType,
        subject: subject,
        examType: examType,
        durationInMinutes: durationInMinutes,
        mockExamId: mockExamId,
      );

      // Load questions for the session
      _questions =
          await _quizService.getQuestionsForSession(_currentSession!.id);

      // Initialize quiz state
      _currentQuestionIndex = 0;
      _remainingTimeInSeconds = durationInMinutes * 60;
      _questionStartTime = DateTime.now();

      // Start countdown timer
      _startTimer();

      notifyListeners();
    } catch (e) {
      _setError('Failed to start quiz: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Submit answer for current question
  Future<void> submitAnswer(int selectedAnswerIndex) async {
    if (_currentSession == null || currentQuestion == null) return;

    try {
      _setLoading(true);
      _clearError();

      // Calculate time spent on this question
      final timeSpent = _questionStartTime != null
          ? DateTime.now().difference(_questionStartTime!).inSeconds
          : 0;

      // Submit answer
      _currentSession = await _quizService.submitAnswer(
        sessionId: _currentSession!.id,
        questionId: currentQuestion!.id,
        selectedAnswerIndex: selectedAnswerIndex,
        timeSpentInSeconds: timeSpent,
      );

      // Move to next question or finish quiz
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _questionStartTime = DateTime.now();
      } else {
        // Quiz completed
        await _completeQuiz();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to submit answer: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Skip current question
  Future<void> skipQuestion() async {
    if (_currentSession == null || currentQuestion == null) return;

    // Move to next question without submitting answer
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _questionStartTime = DateTime.now();
      notifyListeners();
    } else {
      // Quiz completed
      await _completeQuiz();
    }
  }

  // Navigate to specific question
  void navigateToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      _questionStartTime = DateTime.now();
      notifyListeners();
    }
  }

  // Complete quiz and get results
  Future<ExamResultModel?> completeQuiz() async {
    return await _completeQuiz();
  }

  // Get quiz history for user
  Future<void> loadQuizHistory(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _quizHistory = await _quizService.getUserQuizHistory(userId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load quiz history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get user quiz statistics
  Future<void> loadUserStats(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _userStats = await _quizService.getUserQuizStats(userId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load user stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset quiz state
  void resetQuiz() {
    _currentSession = null;
    _questions = [];
    _currentQuestionIndex = 0;
    _remainingTimeInSeconds = 0;
    _questionStartTime = null;
    _clearError();
    notifyListeners();
  }

  // Check if answer is selected for current question
  bool isAnswerSelected(String questionId) {
    return _currentSession?.answers.containsKey(questionId) ?? false;
  }

  // Get selected answer for question
  int? getSelectedAnswer(String questionId) {
    return _currentSession?.answers[questionId]?.selectedAnswerIndex;
  }

  // Check if quiz is completed
  bool get isQuizCompleted => _currentSession?.isCompleted ?? false;

  // Get quiz progress percentage
  double get progressPercentage => _currentSession?.progressPercentage ?? 0.0;

  // Get answered questions count
  int get answeredQuestions => _currentSession?.answeredQuestions ?? 0;

  // Get total questions count
  int get totalQuestions => _questions.length;

  // Private methods
  Future<ExamResultModel?> _completeQuiz() async {
    if (_currentSession == null) return null;

    try {
      _setLoading(true);
      _clearError();

      final result =
          await _quizService.completeQuizSession(_currentSession!.id);

      // Update session state
      _currentSession = _currentSession!.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );

      notifyListeners();
      return result;
    } catch (e) {
      _setError('Failed to complete quiz: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _startTimer() {
    // Timer logic would be implemented here
    // For now, we'll just track the remaining time
    // A real implementation would use a periodic timer
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any timers or listeners
    super.dispose();
  }

  // Helper methods for UI
  String get formattedRemainingTime {
    final minutes = _remainingTimeInSeconds ~/ 60;
    final seconds = _remainingTimeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get currentQuestionNumber => '${_currentQuestionIndex + 1}';

  bool get hasNextQuestion => _currentQuestionIndex < _questions.length - 1;

  bool get hasPreviousQuestion => _currentQuestionIndex > 0;

  // Check if current question is answered
  bool get isCurrentQuestionAnswered =>
      currentQuestion != null && isAnswerSelected(currentQuestion!.id);
}
