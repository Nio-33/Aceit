import 'package:cloud_firestore/cloud_firestore.dart';

class QuizSessionModel {
  final String id;
  final String userId;
  final String quizType; // 'daily', 'mock_exam', 'subject_practice'
  final String subject;
  final String examType; // 'WAEC', 'JAMB', 'NECO'
  final List<String> questionIds;
  final Map<String, QuizAnswerModel> answers;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationInMinutes;
  final int currentQuestionIndex;
  final bool isCompleted;
  final double? score;
  final int? totalQuestions;

  QuizSessionModel({
    required this.id,
    required this.userId,
    required this.quizType,
    required this.subject,
    required this.examType,
    required this.questionIds,
    Map<String, QuizAnswerModel>? answers,
    required this.startTime,
    this.endTime,
    required this.durationInMinutes,
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
    this.score,
    this.totalQuestions,
  }) : answers = answers ?? {};

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    Map<String, QuizAnswerModel> answersMap = {};
    if (json['answers'] != null && json['answers'] is Map) {
      (json['answers'] as Map).forEach((key, value) {
        answersMap[key as String] =
            QuizAnswerModel.fromJson(value as Map<String, dynamic>);
      });
    }

    return QuizSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      quizType: json['quizType'] as String,
      subject: json['subject'] as String,
      examType: json['examType'] as String,
      questionIds: (json['questionIds'] is Iterable)
          ? List<String>.from(json['questionIds'] as Iterable)
          : <String>[],
      answers: answersMap,
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      durationInMinutes: json['durationInMinutes'] as int,
      currentQuestionIndex: json['currentQuestionIndex'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      score: json['score'] as double?,
      totalQuestions: json['totalQuestions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> answersJson = {};
    answers.forEach((key, value) {
      answersJson[key] = value.toJson();
    });

    return {
      'id': id,
      'userId': userId,
      'quizType': quizType,
      'subject': subject,
      'examType': examType,
      'questionIds': questionIds,
      'answers': answersJson,
      'startTime': startTime,
      'endTime': endTime,
      'durationInMinutes': durationInMinutes,
      'currentQuestionIndex': currentQuestionIndex,
      'isCompleted': isCompleted,
      'score': score,
      'totalQuestions': totalQuestions,
    };
  }

  QuizSessionModel copyWith({
    String? id,
    String? userId,
    String? quizType,
    String? subject,
    String? examType,
    List<String>? questionIds,
    Map<String, QuizAnswerModel>? answers,
    DateTime? startTime,
    DateTime? endTime,
    int? durationInMinutes,
    int? currentQuestionIndex,
    bool? isCompleted,
    double? score,
    int? totalQuestions,
  }) {
    return QuizSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      quizType: quizType ?? this.quizType,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      questionIds: questionIds ?? this.questionIds,
      answers: answers ?? this.answers,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
    );
  }

  // Helper methods
  bool get isTimeUp =>
      endTime != null &&
      DateTime.now()
          .isAfter(startTime.add(Duration(minutes: durationInMinutes)));

  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    final total = Duration(minutes: durationInMinutes);
    return total - elapsed;
  }

  int get answeredQuestions => answers.length;

  double get progressPercentage => questionIds.isEmpty
      ? 0.0
      : (currentQuestionIndex / questionIds.length) * 100;
}

class QuizAnswerModel {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeSpentInSeconds;

  QuizAnswerModel({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeSpentInSeconds,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    return QuizAnswerModel(
      questionId: json['questionId'] as String,
      selectedAnswerIndex: json['selectedAnswerIndex'] as int,
      isCorrect: json['isCorrect'] as bool,
      answeredAt: json['answeredAt'] != null
          ? (json['answeredAt'] as Timestamp).toDate()
          : DateTime.now(),
      timeSpentInSeconds: json['timeSpentInSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt,
      'timeSpentInSeconds': timeSpentInSeconds,
    };
  }

  QuizAnswerModel copyWith({
    String? questionId,
    int? selectedAnswerIndex,
    bool? isCorrect,
    DateTime? answeredAt,
    int? timeSpentInSeconds,
  }) {
    return QuizAnswerModel(
      questionId: questionId ?? this.questionId,
      selectedAnswerIndex: selectedAnswerIndex ?? this.selectedAnswerIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      timeSpentInSeconds: timeSpentInSeconds ?? this.timeSpentInSeconds,
    );
  }
}
