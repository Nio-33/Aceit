import 'package:cloud_firestore/cloud_firestore.dart';

class ExamResultModel {
  final String id;
  final String userId;
  final String sessionId;
  final String examType; // 'WAEC', 'JAMB', 'NECO'
  final String subject;
  final String quizType; // 'daily', 'mock_exam', 'subject_practice'
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedQuestions;
  final double score; // percentage
  final int totalTimeInSeconds;
  final DateTime completedAt;
  final Map<String, SubjectPerformance> subjectBreakdown;
  final Map<String, DifficultyPerformance> difficultyBreakdown;
  final List<String> incorrectQuestionIds;
  final String grade; // 'A', 'B', 'C', 'D', 'F'
  final bool passed;
  final int pointsEarned;

  ExamResultModel({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.examType,
    required this.subject,
    required this.quizType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedQuestions,
    required this.score,
    required this.totalTimeInSeconds,
    required this.completedAt,
    Map<String, SubjectPerformance>? subjectBreakdown,
    Map<String, DifficultyPerformance>? difficultyBreakdown,
    List<String>? incorrectQuestionIds,
    required this.grade,
    required this.passed,
    required this.pointsEarned,
  })  : subjectBreakdown = subjectBreakdown ?? {},
        difficultyBreakdown = difficultyBreakdown ?? {},
        incorrectQuestionIds = incorrectQuestionIds ?? [];

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    Map<String, SubjectPerformance> subjectBreakdownMap = {};
    if (json['subjectBreakdown'] != null && json['subjectBreakdown'] is Map) {
      (json['subjectBreakdown'] as Map).forEach((key, value) {
        subjectBreakdownMap[key as String] =
            SubjectPerformance.fromJson(value as Map<String, dynamic>);
      });
    }

    Map<String, DifficultyPerformance> difficultyBreakdownMap = {};
    if (json['difficultyBreakdown'] != null &&
        json['difficultyBreakdown'] is Map) {
      (json['difficultyBreakdown'] as Map).forEach((key, value) {
        difficultyBreakdownMap[key as String] =
            DifficultyPerformance.fromJson(value as Map<String, dynamic>);
      });
    }

    return ExamResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      examType: json['examType'] as String,
      subject: json['subject'] as String,
      quizType: json['quizType'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      wrongAnswers: json['wrongAnswers'] as int,
      skippedQuestions: json['skippedQuestions'] as int,
      score: (json['score'] as num).toDouble(),
      totalTimeInSeconds: json['totalTimeInSeconds'] as int,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
      subjectBreakdown: subjectBreakdownMap,
      difficultyBreakdown: difficultyBreakdownMap,
      incorrectQuestionIds: (json['incorrectQuestionIds'] is Iterable)
          ? List<String>.from(json['incorrectQuestionIds'] as Iterable)
          : <String>[],
      grade: json['grade'] as String,
      passed: json['passed'] as bool,
      pointsEarned: json['pointsEarned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> subjectBreakdownJson = {};
    subjectBreakdown.forEach((key, value) {
      subjectBreakdownJson[key] = value.toJson();
    });

    Map<String, dynamic> difficultyBreakdownJson = {};
    difficultyBreakdown.forEach((key, value) {
      difficultyBreakdownJson[key] = value.toJson();
    });

    return {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'examType': examType,
      'subject': subject,
      'quizType': quizType,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'skippedQuestions': skippedQuestions,
      'score': score,
      'totalTimeInSeconds': totalTimeInSeconds,
      'completedAt': completedAt,
      'subjectBreakdown': subjectBreakdownJson,
      'difficultyBreakdown': difficultyBreakdownJson,
      'incorrectQuestionIds': incorrectQuestionIds,
      'grade': grade,
      'passed': passed,
      'pointsEarned': pointsEarned,
    };
  }

  ExamResultModel copyWith({
    String? id,
    String? userId,
    String? sessionId,
    String? examType,
    String? subject,
    String? quizType,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedQuestions,
    double? score,
    int? totalTimeInSeconds,
    DateTime? completedAt,
    Map<String, SubjectPerformance>? subjectBreakdown,
    Map<String, DifficultyPerformance>? difficultyBreakdown,
    List<String>? incorrectQuestionIds,
    String? grade,
    bool? passed,
    int? pointsEarned,
  }) {
    return ExamResultModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      examType: examType ?? this.examType,
      subject: subject ?? this.subject,
      quizType: quizType ?? this.quizType,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedQuestions: skippedQuestions ?? this.skippedQuestions,
      score: score ?? this.score,
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
      completedAt: completedAt ?? this.completedAt,
      subjectBreakdown: subjectBreakdown ?? this.subjectBreakdown,
      difficultyBreakdown: difficultyBreakdown ?? this.difficultyBreakdown,
      incorrectQuestionIds: incorrectQuestionIds ?? this.incorrectQuestionIds,
      grade: grade ?? this.grade,
      passed: passed ?? this.passed,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }

  // Helper methods
  Duration get averageTimePerQuestion =>
      Duration(seconds: totalTimeInSeconds ~/ totalQuestions);

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  String get formattedTime {
    final duration = Duration(seconds: totalTimeInSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String calculateGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  static int calculatePoints(double score, String quizType) {
    int basePoints = 0;

    // Base points by quiz type
    switch (quizType) {
      case 'mock_exam':
        basePoints = 100;
        break;
      case 'daily':
        basePoints = 50;
        break;
      case 'subject_practice':
        basePoints = 30;
        break;
      default:
        basePoints = 20;
    }

    // Multiply by score percentage
    return (basePoints * (score / 100)).round();
  }
}

class SubjectPerformance {
  final String subject;
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  SubjectPerformance({
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  factory SubjectPerformance.fromJson(Map<String, dynamic> json) {
    return SubjectPerformance(
      subject: json['subject'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
    };
  }
}

class DifficultyPerformance {
  final String difficulty;
  final int totalQuestions;
  final int correctAnswers;
  final double score;

  DifficultyPerformance({
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
  });

  factory DifficultyPerformance.fromJson(Map<String, dynamic> json) {
    return DifficultyPerformance(
      difficulty: json['difficulty'] as String,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
    };
  }
}
