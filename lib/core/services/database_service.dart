import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/question_model.dart';
import '../../models/mock_exam_model.dart';
import '../../models/flashcard_model.dart';
import '../../models/user_model.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User methods
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
  
  Future<void> updateUserStreak(String userId, int streak) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'currentStreak': streak,
        'lastLoginDate': DateTime.now(),
      });
    } catch (e) {
      print('Error updating user streak: $e');
      rethrow;
    }
  }
  
  Future<void> updateUserPoints(String userId, int points) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'points': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error updating user points: $e');
      rethrow;
    }
  }
  
  // Mock Exam methods
  Future<List<MockExamModel>> getMockExams({
    required String subject,
    required String examType,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.mockExamsCollection)
          .where('subject', isEqualTo: subject)
          .where('examType', isEqualTo: examType)
          .get();
      
      return snapshot.docs.map((doc) {
        return MockExamModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      print('Error getting mock exams: $e');
      return [];
    }
  }
  
  Future<MockExamModel?> getMockExamById(String mockExamId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(AppConstants.mockExamsCollection)
          .doc(mockExamId)
          .get();
      
      if (doc.exists) {
        return MockExamModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      
      return null;
    } catch (e) {
      print('Error getting mock exam by ID: $e');
      return null;
    }
  }
  
  // Question methods
  Future<List<QuestionModel>> getQuestionsByIds(List<String> questionIds) async {
    try {
      final List<QuestionModel> questions = [];
      
      // Firestore has a limit of 10 IDs for 'in' queries
      // Split into chunks if necessary
      final chunks = <List<String>>[];
      for (var i = 0; i < questionIds.length; i += 10) {
        chunks.add(
          questionIds.sublist(
            i, 
            i + 10 > questionIds.length ? questionIds.length : i + 10,
          ),
        );
      }
      
      for (final chunk in chunks) {
        final QuerySnapshot snapshot = await _firestore
            .collection(AppConstants.questionsCollection)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        
        questions.addAll(snapshot.docs.map((doc) {
          return QuestionModel.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });
        }));
      }
      
      return questions;
    } catch (e) {
      print('Error getting questions by IDs: $e');
      return [];
    }
  }
  
  Future<List<QuestionModel>> getQuestionsBySubject({
    required String subject,
    required String examType,
    int limit = 10,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.questionsCollection)
          .where('subject', isEqualTo: subject)
          .where('examType', isEqualTo: examType)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        return QuestionModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      print('Error getting questions by subject: $e');
      return [];
    }
  }
  
  // Flashcard methods
  Future<List<FlashcardModel>> getFlashcardsBySubject(String subject) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.flashcardsCollection)
          .where('subject', isEqualTo: subject)
          .get();
      
      return snapshot.docs.map((doc) {
        return FlashcardModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      print('Error getting flashcards by subject: $e');
      return [];
    }
  }
  
  // Leaderboard methods
  Future<List<UserModel>> getLeaderboard({int limit = 20}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        return UserModel.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
  
  // Progress tracking methods
  Future<void> saveQuizResult({
    required String userId,
    required String subject,
    required String examType,
    required int score,
    required int totalQuestions,
    required Duration timeTaken,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.userProgressCollection)
          .add({
        'userId': userId,
        'subject': subject,
        'examType': examType,
        'score': score,
        'totalQuestions': totalQuestions,
        'timeTaken': timeTaken.inSeconds,
        'percentage': score / totalQuestions,
        'date': DateTime.now(),
      });
      
      // Update user points based on performance
      final int points = (score / totalQuestions * 10).ceil();
      await updateUserPoints(userId, points);
    } catch (e) {
      print('Error saving quiz result: $e');
      rethrow;
    }
  }
  
  Future<Map<String, double>> getUserProgressBySubject(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.userProgressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      final Map<String, List<double>> subjectScores = {};
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subject = data['subject'] as String;
        final percentage = data['percentage'] as double;
        
        if (!subjectScores.containsKey(subject)) {
          subjectScores[subject] = [];
        }
        
        subjectScores[subject]!.add(percentage);
      }
      
      // Calculate average score for each subject
      final Map<String, double> result = {};
      
      subjectScores.forEach((subject, scores) {
        final double average = scores.reduce((a, b) => a + b) / scores.length;
        result[subject] = average;
      });
      
      return result;
    } catch (e) {
      print('Error getting user progress by subject: $e');
      return {};
    }
  }
} 