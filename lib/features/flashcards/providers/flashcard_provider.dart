import 'package:flutter/foundation.dart';
import 'package:aceit/models/flashcard_model.dart';
import 'package:aceit/models/study_session_model.dart';
import 'package:aceit/core/services/flashcard_service.dart';

class FlashcardProvider with ChangeNotifier {
  final FlashcardService _flashcardService = FlashcardService();

  // Current flashcard session
  FlashcardSessionModel? _currentSession;
  FlashcardSessionModel? get currentSession => _currentSession;

  // Current flashcards for the session
  List<FlashcardModel> _flashcards = [];
  List<FlashcardModel> get flashcards => _flashcards;

  // Current flashcard being studied
  int _currentCardIndex = 0;
  int get currentCardIndex => _currentCardIndex;

  // Current flashcard
  FlashcardModel? get currentFlashcard =>
      _flashcards.isNotEmpty && _currentCardIndex < _flashcards.length
          ? _flashcards[_currentCardIndex]
          : null;

  // Card display state
  bool _isFlipped = false;
  bool get isFlipped => _isFlipped;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error state
  String? _error;
  String? get error => _error;

  // Available subjects
  List<String> _subjects = [];
  List<String> get subjects => _subjects;

  // Flashcard history
  List<FlashcardSessionModel> _sessionHistory = [];
  List<FlashcardSessionModel> get sessionHistory => _sessionHistory;

  // User statistics
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? get userStats => _userStats;

  // All flashcards (for browsing)
  List<FlashcardModel> _allFlashcards = [];
  List<FlashcardModel> get allFlashcards => _allFlashcards;

  // Start a new flashcard study session
  Future<void> startFlashcardSession({
    required String userId,
    required String subject,
    List<String>? specificFlashcardIds,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Start flashcard session
      _currentSession = await _flashcardService.startFlashcardSession(
        userId: userId,
        subject: subject,
        specificFlashcardIds: specificFlashcardIds,
      );

      // Load flashcards for the session
      _flashcards = await _flashcardService
          .getFlashcardsByIds(_currentSession!.flashcardIds);

      // Initialize session state
      _currentCardIndex = 0;
      _isFlipped = false;

      notifyListeners();
    } catch (e) {
      _setError('Failed to start flashcard session: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Flip current flashcard
  void flipCard() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  // Mark flashcard as correct/incorrect and move to next
  Future<void> markFlashcard({
    required bool wasCorrect,
    required int confidenceLevel,
  }) async {
    if (_currentSession == null || currentFlashcard == null) return;

    try {
      _setLoading(true);
      _clearError();

      // Record progress
      _currentSession = await _flashcardService.recordFlashcardProgress(
        sessionId: _currentSession!.id,
        flashcardId: currentFlashcard!.id,
        wasCorrect: wasCorrect,
        timeSpentInSeconds: 10, // Default time, could be tracked more precisely
        confidenceLevel: confidenceLevel,
      );

      // Move to next card or complete session
      if (_currentCardIndex < _flashcards.length - 1) {
        _currentCardIndex++;
        _isFlipped = false;
      } else {
        // Session completed
        await _completeSession();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to mark flashcard: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Skip current flashcard
  Future<void> skipFlashcard() async {
    if (_currentSession == null || currentFlashcard == null) return;

    try {
      _setLoading(true);
      _clearError();

      // Record skip
      _currentSession = await _flashcardService.skipFlashcard(
        sessionId: _currentSession!.id,
        flashcardId: currentFlashcard!.id,
      );

      // Move to next card or complete session
      if (_currentCardIndex < _flashcards.length - 1) {
        _currentCardIndex++;
        _isFlipped = false;
      } else {
        // Session completed
        await _completeSession();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to skip flashcard: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Navigate to specific card
  void navigateToCard(int index) {
    if (index >= 0 && index < _flashcards.length) {
      _currentCardIndex = index;
      _isFlipped = false;
      notifyListeners();
    }
  }

  // Complete current session
  Future<FlashcardSessionModel?> completeSession() async {
    return await _completeSession();
  }

  // Load available subjects
  Future<void> loadSubjects() async {
    try {
      _setLoading(true);
      _clearError();

      _subjects = await _flashcardService.getFlashcardSubjects();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load subjects: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load all flashcards for browsing
  Future<void> loadAllFlashcards() async {
    try {
      _setLoading(true);
      _clearError();

      _allFlashcards = await _flashcardService.getAllFlashcards();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load flashcards: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load flashcards by subject
  Future<void> loadFlashcardsBySubject(String subject) async {
    try {
      _setLoading(true);
      _clearError();

      _allFlashcards = await _flashcardService.getFlashcardsBySubject(subject);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load flashcards for $subject: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user's flashcard history
  Future<void> loadSessionHistory(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _sessionHistory = await _flashcardService.getUserFlashcardHistory(userId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load session history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user's flashcard statistics
  Future<void> loadUserStats(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _userStats = await _flashcardService.getUserFlashcardStats(userId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to load user stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Reset flashcard state
  void resetFlashcardState() {
    _currentSession = null;
    _flashcards = [];
    _currentCardIndex = 0;
    _isFlipped = false;
    _clearError();
    notifyListeners();
  }

  // Private methods
  Future<FlashcardSessionModel?> _completeSession() async {
    if (_currentSession == null) return null;

    try {
      _setLoading(true);
      _clearError();

      final completedSession =
          await _flashcardService.completeFlashcardSession(_currentSession!.id);

      _currentSession = completedSession;

      notifyListeners();
      return completedSession;
    } catch (e) {
      _setError('Failed to complete session: $e');
      return null;
    } finally {
      _setLoading(false);
    }
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
  int get totalCards => _flashcards.length;
  int get studiedCards => _currentSession?.studiedCards ?? 0;
  double get progressPercentage =>
      totalCards > 0 ? ((_currentCardIndex + 1) / totalCards) * 100 : 0;

  bool get isSessionCompleted => _currentSession?.isCompleted ?? false;
  bool get hasNextCard => _currentCardIndex < _flashcards.length - 1;
  bool get hasPreviousCard => _currentCardIndex > 0;

  String get currentCardNumber => '${_currentCardIndex + 1}';

  // Get current session stats
  int get correctCount => _currentSession?.correctCount ?? 0;
  int get incorrectCount => _currentSession?.incorrectCount ?? 0;
  int get skippedCount => _currentSession?.skippedCount ?? 0;
  double get sessionAccuracy => _currentSession?.accuracy ?? 0.0;

  // Check if current card has been studied
  bool get isCurrentCardStudied {
    if (_currentSession == null || currentFlashcard == null) return false;
    return _currentSession!.cardProgress.containsKey(currentFlashcard!.id);
  }

  // Get confidence level for current card
  int? get currentCardConfidence {
    if (_currentSession == null || currentFlashcard == null) return null;
    return _currentSession!.cardProgress[currentFlashcard!.id]?.confidenceLevel;
  }
}
