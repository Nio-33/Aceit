import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aceit/models/quiz_session_model.dart';
import 'package:aceit/models/exam_result_model.dart';
import 'package:aceit/models/question_model.dart';
import 'package:aceit/models/mock_exam_model.dart';
import 'package:aceit/core/services/database_service.dart';

class QuizService {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _quizSessionsCollection = 'quiz_sessions';
  static const String _examResultsCollection = 'exam_results';
  static const String _questionsCollection = 'questions';
  static const String _mockExamsCollection = 'mock_exams';

  // Start a new quiz session
  Future<QuizSessionModel> startQuizSession({
    required String userId,
    required String quizType,
    required String subject,
    required String examType,
    required int durationInMinutes,
    String? mockExamId,
  }) async {
    try {
      List<String> questionIds = [];

      if (mockExamId != null) {
        // Get questions from mock exam
        final mockExam = await getMockExam(mockExamId);
        questionIds = mockExam.questionIds;
      } else {
        // Get random questions for subject and exam type
        questionIds = await _getRandomQuestions(
          subject: subject,
          examType: examType,
          limit: quizType == 'daily' ? 10 : 40,
        );
      }

      final session = QuizSessionModel(
        id: _firestore.collection(_quizSessionsCollection).doc().id,
        userId: userId,
        quizType: quizType,
        subject: subject,
        examType: examType,
        questionIds: questionIds,
        startTime: DateTime.now(),
        durationInMinutes: durationInMinutes,
        totalQuestions: questionIds.length,
      );

      await _firestore
          .collection(_quizSessionsCollection)
          .doc(session.id)
          .set(session.toJson());

      return session;
    } catch (e) {
      throw Exception('Failed to start quiz session: $e');
    }
  }

  // Get quiz session by ID
  Future<QuizSessionModel> getQuizSession(String sessionId) async {
    try {
      final doc = await _firestore
          .collection(_quizSessionsCollection)
          .doc(sessionId)
          .get();

      if (!doc.exists) {
        throw Exception('Quiz session not found');
      }

      return QuizSessionModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get quiz session: $e');
    }
  }

  // Update quiz session
  Future<QuizSessionModel> updateQuizSession(QuizSessionModel session) async {
    try {
      await _firestore
          .collection(_quizSessionsCollection)
          .doc(session.id)
          .update(session.toJson());

      return session;
    } catch (e) {
      throw Exception('Failed to update quiz session: $e');
    }
  }

  // Submit answer for current question
  Future<QuizSessionModel> submitAnswer({
    required String sessionId,
    required String questionId,
    required int selectedAnswerIndex,
    required int timeSpentInSeconds,
  }) async {
    try {
      final session = await getQuizSession(sessionId);

      // Get question to check if answer is correct
      final question = await getQuestion(questionId);
      final isCorrect = selectedAnswerIndex == question.correctAnswerIndex;

      final answer = QuizAnswerModel(
        questionId: questionId,
        selectedAnswerIndex: selectedAnswerIndex,
        isCorrect: isCorrect,
        answeredAt: DateTime.now(),
        timeSpentInSeconds: timeSpentInSeconds,
      );

      // Update session with answer
      final updatedAnswers = Map<String, QuizAnswerModel>.from(session.answers);
      updatedAnswers[questionId] = answer;

      final updatedSession = session.copyWith(
        answers: updatedAnswers,
        currentQuestionIndex: session.currentQuestionIndex + 1,
      );

      return await updateQuizSession(updatedSession);
    } catch (e) {
      throw Exception('Failed to submit answer: $e');
    }
  }

  // Complete quiz session and generate result
  Future<ExamResultModel> completeQuizSession(String sessionId) async {
    try {
      final session = await getQuizSession(sessionId);

      if (session.isCompleted) {
        // If session is already completed, get the existing result
        return await getQuizResult(sessionId);
      }

      // Mark session as completed
      final completedSession = session.copyWith(
        isCompleted: true,
        endTime: DateTime.now(),
      );
      await updateQuizSession(completedSession);

      // Calculate results
      final result = await _calculateResults(completedSession);

      // Save result to database
      await _firestore
          .collection(_examResultsCollection)
          .doc(result.id)
          .set(result.toJson());

      // Update user progress
      await _updateUserProgress(result);

      return result;
    } catch (e) {
      throw Exception('Failed to complete quiz session: $e');
    }
  }

  // Get quiz result for an already completed session
  Future<ExamResultModel> getQuizResult(String sessionId) async {
    try {
      // First, try to get the result from the exam_results collection
      final resultQuery = await _firestore
          .collection(_examResultsCollection)
          .where('sessionId', isEqualTo: sessionId)
          .limit(1)
          .get();

      if (resultQuery.docs.isNotEmpty) {
        // Result exists, return it
        return ExamResultModel.fromJson(resultQuery.docs.first.data());
      }

      // If no result exists, calculate it from the completed session
      final session = await getQuizSession(sessionId);

      if (!session.isCompleted) {
        throw Exception('Quiz session is not completed yet');
      }

      // Calculate results for the completed session
      final result = await _calculateResults(session);

      // Save result to database for future use
      await _firestore
          .collection(_examResultsCollection)
          .doc(result.id)
          .set(result.toJson());

      return result;
    } catch (e) {
      throw Exception('Failed to get quiz result: $e');
    }
  }

  // Get questions for a quiz session
  Future<List<QuestionModel>> getQuestionsForSession(String sessionId) async {
    try {
      final session = await getQuizSession(sessionId);
      final questions = <QuestionModel>[];

      for (final questionId in session.questionIds) {
        final question = await getQuestion(questionId);
        questions.add(question);
      }

      return questions;
    } catch (e) {
      throw Exception('Failed to get questions for session: $e');
    }
  }

  // Get single question by ID
  Future<QuestionModel> getQuestion(String questionId) async {
    try {
      final doc = await _firestore
          .collection(_questionsCollection)
          .doc(questionId)
          .get();

      if (!doc.exists) {
        throw Exception('Question not found');
      }

      return QuestionModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get question: $e');
    }
  }

  // Get mock exam by ID
  Future<MockExamModel> getMockExam(String examId) async {
    try {
      final doc =
          await _firestore.collection(_mockExamsCollection).doc(examId).get();

      if (!doc.exists) {
        throw Exception('Mock exam not found');
      }

      return MockExamModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get mock exam: $e');
    }
  }

  // Get user's quiz history
  Future<List<ExamResultModel>> getUserQuizHistory(String userId,
      {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_examResultsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ExamResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user quiz history: $e');
    }
  }

  // Get user's quiz statistics
  Future<Map<String, dynamic>> getUserQuizStats(String userId) async {
    try {
      final results = await getUserQuizHistory(userId, limit: 100);

      if (results.isEmpty) {
        return {
          'totalQuizzes': 0,
          'averageScore': 0.0,
          'totalTimeSpent': 0,
          'bestScore': 0.0,
          'totalPointsEarned': 0,
          'subjectStats': <String, dynamic>{},
        };
      }

      final totalQuizzes = results.length;
      final averageScore =
          results.map((r) => r.score).reduce((a, b) => a + b) / totalQuizzes;
      final totalTimeSpent =
          results.map((r) => r.totalTimeInSeconds).reduce((a, b) => a + b);
      final bestScore =
          results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
      final totalPointsEarned =
          results.map((r) => r.pointsEarned).reduce((a, b) => a + b);

      // Subject-wise statistics
      final subjectStats = <String, Map<String, dynamic>>{};
      for (final result in results) {
        if (!subjectStats.containsKey(result.subject)) {
          subjectStats[result.subject] = {
            'count': 0,
            'totalScore': 0.0,
            'bestScore': 0.0,
          };
        }
        subjectStats[result.subject]!['count'] += 1;
        subjectStats[result.subject]!['totalScore'] += result.score;
        if (result.score >
            (subjectStats[result.subject]!['bestScore'] as num)) {
          subjectStats[result.subject]!['bestScore'] = result.score;
        }
      }

      // Calculate averages
      subjectStats.forEach((subject, stats) {
        stats['averageScore'] = stats['totalScore'] / stats['count'];
      });

      return {
        'totalQuizzes': totalQuizzes,
        'averageScore': averageScore,
        'totalTimeSpent': totalTimeSpent,
        'bestScore': bestScore,
        'totalPointsEarned': totalPointsEarned,
        'subjectStats': subjectStats,
      };
    } catch (e) {
      throw Exception('Failed to get user quiz stats: $e');
    }
  }

  // Private helper methods
  Future<List<String>> _getRandomQuestions({
    required String subject,
    required String examType,
    required int limit,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_questionsCollection)
          .where('subject', isEqualTo: subject)
          .where('examType', isEqualTo: examType)
          .limit(limit * 2) // Get more to randomize
          .get();

      final questionIds = querySnapshot.docs.map((doc) => doc.id).toList();

      // Shuffle and return requested number
      questionIds.shuffle();
      return questionIds.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get random questions: $e');
    }
  }

  Future<ExamResultModel> _calculateResults(QuizSessionModel session) async {
    final totalQuestions = session.questionIds.length;
    final answeredQuestions = session.answers.length;
    final correctAnswers =
        session.answers.values.where((a) => a.isCorrect).length;
    final wrongAnswers =
        session.answers.values.where((a) => !a.isCorrect).length;
    final skippedQuestions = totalQuestions - answeredQuestions;

    final score =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
    final grade = ExamResultModel.calculateGrade(score);
    final passed = score >= 60.0; // 60% pass mark
    final pointsEarned =
        ExamResultModel.calculatePoints(score, session.quizType);

    final totalTimeInSeconds = session.endTime != null
        ? session.endTime!.difference(session.startTime).inSeconds
        : 0;

    final incorrectQuestionIds = session.answers.entries
        .where((entry) => !entry.value.isCorrect)
        .map((entry) => entry.key)
        .toList();

    return ExamResultModel(
      id: _firestore.collection(_examResultsCollection).doc().id,
      userId: session.userId,
      sessionId: session.id,
      examType: session.examType,
      subject: session.subject,
      quizType: session.quizType,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      skippedQuestions: skippedQuestions,
      score: score,
      totalTimeInSeconds: totalTimeInSeconds,
      completedAt: DateTime.now(),
      incorrectQuestionIds: incorrectQuestionIds,
      grade: grade,
      passed: passed,
      pointsEarned: pointsEarned,
    );
  }

  Future<void> _updateUserProgress(ExamResultModel result) async {
    try {
      await _databaseService.saveQuizResult(
        userId: result.userId,
        subject: result.subject,
        examType: result.examType,
        score: result.correctAnswers,
        totalQuestions: result.totalQuestions,
        timeTaken: Duration(seconds: result.totalTimeInSeconds),
      );
    } catch (e) {
      // Log error but don't throw - result is already saved
      print('Warning: Failed to update user progress: $e');
    }
  }
}
