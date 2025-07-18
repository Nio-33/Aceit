import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aceit/models/flashcard_model.dart';
import 'package:aceit/models/study_session_model.dart';
import 'package:aceit/core/services/database_service.dart';

class FlashcardService {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _flashcardsCollection = 'flashcards';
  static const String _flashcardSessionsCollection = 'flashcard_sessions';
  static const String _studySessionsCollection = 'study_sessions';

  // Get flashcards by subject
  Future<List<FlashcardModel>> getFlashcardsBySubject(String subject) async {
    try {
      final querySnapshot = await _firestore
          .collection(_flashcardsCollection)
          .where('subject', isEqualTo: subject)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FlashcardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get flashcards: $e');
    }
  }

  // Get all flashcards
  Future<List<FlashcardModel>> getAllFlashcards() async {
    try {
      final querySnapshot = await _firestore
          .collection(_flashcardsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FlashcardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get flashcards: $e');
    }
  }

  // Get flashcards by IDs
  Future<List<FlashcardModel>> getFlashcardsByIds(
      List<String> flashcardIds) async {
    try {
      final flashcards = <FlashcardModel>[];

      // Firestore 'in' queries are limited to 10 items, so we need to batch
      for (int i = 0; i < flashcardIds.length; i += 10) {
        final batch = flashcardIds.skip(i).take(10).toList();
        final querySnapshot = await _firestore
            .collection(_flashcardsCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        flashcards.addAll(
          querySnapshot.docs
              .map((doc) => FlashcardModel.fromJson(doc.data()))
              .toList(),
        );
      }

      return flashcards;
    } catch (e) {
      throw Exception('Failed to get flashcards by IDs: $e');
    }
  }

  // Get unique subjects from flashcards
  Future<List<String>> getFlashcardSubjects() async {
    try {
      final querySnapshot =
          await _firestore.collection(_flashcardsCollection).get();

      final subjects = <String>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['subject'] != null) {
          subjects.add(data['subject'] as String);
        }
      }

      return subjects.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get flashcard subjects: $e');
    }
  }

  // Start a new flashcard study session
  Future<FlashcardSessionModel> startFlashcardSession({
    required String userId,
    required String subject,
    List<String>? specificFlashcardIds,
  }) async {
    try {
      // Get flashcards for the session
      final flashcards = specificFlashcardIds != null
          ? await getFlashcardsByIds(specificFlashcardIds)
          : await getFlashcardsBySubject(subject);

      if (flashcards.isEmpty) {
        throw Exception('No flashcards found for subject: $subject');
      }

      // Shuffle flashcards for variety
      flashcards.shuffle();
      final flashcardIds = flashcards.map((f) => f.id).toList();

      // Create base study session
      final baseSession = StudySessionModel(
        id: _firestore.collection(_studySessionsCollection).doc().id,
        userId: userId,
        sessionType: 'flashcard',
        subject: subject,
        startTime: DateTime.now(),
        itemsStudied: flashcards.length,
      );

      // Create flashcard session
      final flashcardSession = FlashcardSessionModel(
        id: _firestore.collection(_flashcardSessionsCollection).doc().id,
        userId: userId,
        subject: subject,
        flashcardIds: flashcardIds,
        startTime: DateTime.now(),
        baseSession: baseSession,
      );

      // Save sessions to Firestore
      await _firestore
          .collection(_studySessionsCollection)
          .doc(baseSession.id)
          .set(baseSession.toJson());

      await _firestore
          .collection(_flashcardSessionsCollection)
          .doc(flashcardSession.id)
          .set(flashcardSession.toJson());

      return flashcardSession;
    } catch (e) {
      throw Exception('Failed to start flashcard session: $e');
    }
  }

  // Get flashcard session by ID
  Future<FlashcardSessionModel> getFlashcardSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection(_flashcardSessionsCollection)
          .doc(sessionId)
          .get();

      if (!doc.exists) {
        throw Exception('Flashcard session not found');
      }

      return FlashcardSessionModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get flashcard session: $e');
    }
  }

  // Update flashcard session
  Future<FlashcardSessionModel> updateFlashcardSession(
      FlashcardSessionModel session) async {
    try {
      await _firestore
          .collection(_flashcardSessionsCollection)
          .doc(session.id)
          .update(session.toJson());

      return session;
    } catch (e) {
      throw Exception('Failed to update flashcard session: $e');
    }
  }

  // Record flashcard progress
  Future<FlashcardSessionModel> recordFlashcardProgress({
    required String sessionId,
    required String flashcardId,
    required bool wasCorrect,
    required int timeSpentInSeconds,
    required int confidenceLevel,
  }) async {
    try {
      final session = await getFlashcardSession(sessionId);

      final progress = FlashcardProgress(
        flashcardId: flashcardId,
        wasCorrect: wasCorrect,
        timeSpentInSeconds: timeSpentInSeconds,
        studiedAt: DateTime.now(),
        confidenceLevel: confidenceLevel,
      );

      // Update session with progress
      final updatedProgress =
          Map<String, FlashcardProgress>.from(session.cardProgress);
      updatedProgress[flashcardId] = progress;

      int newCorrectCount = session.correctCount;
      int newIncorrectCount = session.incorrectCount;

      if (wasCorrect) {
        newCorrectCount++;
      } else {
        newIncorrectCount++;
      }

      final updatedSession = session.copyWith(
        cardProgress: updatedProgress,
        currentCardIndex: session.currentCardIndex + 1,
        correctCount: newCorrectCount,
        incorrectCount: newIncorrectCount,
      );

      return await updateFlashcardSession(updatedSession);
    } catch (e) {
      throw Exception('Failed to record flashcard progress: $e');
    }
  }

  // Skip flashcard
  Future<FlashcardSessionModel> skipFlashcard({
    required String sessionId,
    required String flashcardId,
  }) async {
    try {
      final session = await getFlashcardSession(sessionId);

      final updatedSession = session.copyWith(
        currentCardIndex: session.currentCardIndex + 1,
        skippedCount: session.skippedCount + 1,
      );

      return await updateFlashcardSession(updatedSession);
    } catch (e) {
      throw Exception('Failed to skip flashcard: $e');
    }
  }

  // Complete flashcard session
  Future<FlashcardSessionModel> completeFlashcardSession(
      String sessionId) async {
    try {
      final session = await getFlashcardSession(sessionId);

      if (session.isCompleted) {
        throw Exception('Flashcard session already completed');
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(session.startTime);

      // Update base session
      final updatedBaseSession = session.baseSession.copyWith(
        endTime: endTime,
        durationInSeconds: duration.inSeconds,
        itemsStudied: session.studiedCards,
        isCompleted: true,
        pointsEarned: _calculateFlashcardPoints(session),
      );

      // Update flashcard session
      final completedSession = session.copyWith(
        endTime: endTime,
        isCompleted: true,
        baseSession: updatedBaseSession,
      );

      // Save both sessions
      await _firestore
          .collection(_studySessionsCollection)
          .doc(updatedBaseSession.id)
          .update(updatedBaseSession.toJson());

      await updateFlashcardSession(completedSession);

      // Update user progress
      await _updateUserFlashcardProgress(completedSession);

      return completedSession;
    } catch (e) {
      throw Exception('Failed to complete flashcard session: $e');
    }
  }

  // Get user's flashcard history
  Future<List<FlashcardSessionModel>> getUserFlashcardHistory(String userId,
      {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_flashcardSessionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FlashcardSessionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user flashcard history: $e');
    }
  }

  // Get user's flashcard statistics
  Future<Map<String, dynamic>> getUserFlashcardStats(String userId) async {
    try {
      final sessions = await getUserFlashcardHistory(userId, limit: 100);

      if (sessions.isEmpty) {
        return {
          'totalSessions': 0,
          'totalCardsStudied': 0,
          'averageAccuracy': 0.0,
          'totalStudyTime': 0,
          'subjectStats': <String, dynamic>{},
        };
      }

      final totalSessions = sessions.length;
      final totalCardsStudied =
          sessions.map((s) => s.studiedCards).reduce((a, b) => a + b);
      final totalCorrect =
          sessions.map((s) => s.correctCount).reduce((a, b) => a + b);
      final totalIncorrect =
          sessions.map((s) => s.incorrectCount).reduce((a, b) => a + b);
      final averageAccuracy = (totalCorrect + totalIncorrect) > 0
          ? (totalCorrect / (totalCorrect + totalIncorrect)) * 100
          : 0.0;

      final totalStudyTime = sessions
          .where((s) => s.endTime != null)
          .map((s) => s.endTime!.difference(s.startTime).inSeconds)
          .fold(0, (a, b) => a + b);

      // Subject-wise statistics
      final subjectStats = <String, Map<String, dynamic>>{};
      for (final session in sessions) {
        if (!subjectStats.containsKey(session.subject)) {
          subjectStats[session.subject] = {
            'sessions': 0,
            'cardsStudied': 0,
            'correctCount': 0,
            'incorrectCount': 0,
            'studyTime': 0,
          };
        }
        subjectStats[session.subject]!['sessions'] += 1;
        subjectStats[session.subject]!['cardsStudied'] += session.studiedCards;
        subjectStats[session.subject]!['correctCount'] += session.correctCount;
        subjectStats[session.subject]!['incorrectCount'] +=
            session.incorrectCount;
        if (session.endTime != null) {
          subjectStats[session.subject]!['studyTime'] +=
              session.endTime!.difference(session.startTime).inSeconds;
        }
      }

      // Calculate averages for each subject
      subjectStats.forEach((subject, stats) {
        final correct = stats['correctCount'] as int;
        final incorrect = stats['incorrectCount'] as int;
        stats['accuracy'] = (correct + incorrect) > 0
            ? (correct / (correct + incorrect)) * 100
            : 0.0;
      });

      return {
        'totalSessions': totalSessions,
        'totalCardsStudied': totalCardsStudied,
        'averageAccuracy': averageAccuracy,
        'totalStudyTime': totalStudyTime,
        'subjectStats': subjectStats,
      };
    } catch (e) {
      throw Exception('Failed to get user flashcard stats: $e');
    }
  }

  // Get single flashcard by ID
  Future<FlashcardModel> getFlashcard(String flashcardId) async {
    try {
      final doc = await _firestore
          .collection(_flashcardsCollection)
          .doc(flashcardId)
          .get();

      if (!doc.exists) {
        throw Exception('Flashcard not found');
      }

      return FlashcardModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get flashcard: $e');
    }
  }

  // Private helper methods
  int _calculateFlashcardPoints(FlashcardSessionModel session) {
    // Base points for completing session
    int basePoints = 20;

    // Bonus for accuracy
    final accuracy = session.accuracy;
    int accuracyBonus = 0;
    if (accuracy >= 90)
      accuracyBonus = 30;
    else if (accuracy >= 80)
      accuracyBonus = 20;
    else if (accuracy >= 70) accuracyBonus = 10;

    // Bonus for completion
    int completionBonus = session.isCompleted ? 10 : 0;

    // Bonus for number of cards studied
    int volumeBonus = (session.studiedCards / 5).floor() * 5;

    return basePoints + accuracyBonus + completionBonus + volumeBonus;
  }

  Future<void> _updateUserFlashcardProgress(
      FlashcardSessionModel session) async {
    try {
      // Update user's overall progress
      await _databaseService.updateUserProgress(
        session.userId,
        'flashcards_studied',
        session.studiedCards,
      );

      // Add points to user
      await _databaseService.addUserPoints(
        session.userId,
        session.baseSession.pointsEarned,
      );
    } catch (e) {
      // Log error but don't throw - session is already saved
      print('Warning: Failed to update user flashcard progress: $e');
    }
  }
}
