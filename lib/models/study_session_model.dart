import 'package:cloud_firestore/cloud_firestore.dart';

class StudySessionModel {
  final String id;
  final String userId;
  final String sessionType; // 'flashcard', 'reading', 'practice'
  final String subject;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationInSeconds;
  final int itemsStudied;
  final Map<String, dynamic> sessionData;
  final bool isCompleted;
  final int pointsEarned;

  StudySessionModel({
    required this.id,
    required this.userId,
    required this.sessionType,
    required this.subject,
    required this.startTime,
    this.endTime,
    this.durationInSeconds = 0,
    this.itemsStudied = 0,
    Map<String, dynamic>? sessionData,
    this.isCompleted = false,
    this.pointsEarned = 0,
  }) : sessionData = sessionData ?? {};

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sessionType: json['sessionType'] as String,
      subject: json['subject'] as String,
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      durationInSeconds: json['durationInSeconds'] as int? ?? 0,
      itemsStudied: json['itemsStudied'] as int? ?? 0,
      sessionData: json['sessionData'] as Map<String, dynamic>? ?? {},
      isCompleted: json['isCompleted'] as bool? ?? false,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sessionType': sessionType,
      'subject': subject,
      'startTime': startTime,
      'endTime': endTime,
      'durationInSeconds': durationInSeconds,
      'itemsStudied': itemsStudied,
      'sessionData': sessionData,
      'isCompleted': isCompleted,
      'pointsEarned': pointsEarned,
    };
  }

  StudySessionModel copyWith({
    String? id,
    String? userId,
    String? sessionType,
    String? subject,
    DateTime? startTime,
    DateTime? endTime,
    int? durationInSeconds,
    int? itemsStudied,
    Map<String, dynamic>? sessionData,
    bool? isCompleted,
    int? pointsEarned,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionType: sessionType ?? this.sessionType,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      itemsStudied: itemsStudied ?? this.itemsStudied,
      sessionData: sessionData ?? this.sessionData,
      isCompleted: isCompleted ?? this.isCompleted,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }

  // Helper methods
  Duration get actualDuration => endTime != null
      ? endTime!.difference(startTime)
      : Duration(seconds: durationInSeconds);

  String get formattedDuration {
    final duration = actualDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double get studyRate =>
      durationInSeconds > 0 ? itemsStudied / (durationInSeconds / 60.0) : 0;
}

class FlashcardSessionModel {
  final String id;
  final String userId;
  final String subject;
  final List<String> flashcardIds;
  final Map<String, FlashcardProgress> cardProgress;
  final DateTime startTime;
  final DateTime? endTime;
  final int currentCardIndex;
  final bool isCompleted;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final StudySessionModel baseSession;

  FlashcardSessionModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.flashcardIds,
    Map<String, FlashcardProgress>? cardProgress,
    required this.startTime,
    this.endTime,
    this.currentCardIndex = 0,
    this.isCompleted = false,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.skippedCount = 0,
    required this.baseSession,
  }) : cardProgress = cardProgress ?? {};

  factory FlashcardSessionModel.fromJson(Map<String, dynamic> json) {
    Map<String, FlashcardProgress> progressMap = {};
    if (json['cardProgress'] != null && json['cardProgress'] is Map) {
      (json['cardProgress'] as Map).forEach((key, value) {
        progressMap[key as String] =
            FlashcardProgress.fromJson(value as Map<String, dynamic>);
      });
    }

    return FlashcardSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subject: json['subject'] as String,
      flashcardIds: (json['flashcardIds'] is Iterable)
          ? List<String>.from(json['flashcardIds'] as Iterable)
          : <String>[],
      cardProgress: progressMap,
      startTime: json['startTime'] != null
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? (json['endTime'] as Timestamp).toDate()
          : null,
      currentCardIndex: json['currentCardIndex'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      correctCount: json['correctCount'] as int? ?? 0,
      incorrectCount: json['incorrectCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      baseSession: StudySessionModel.fromJson(
          json['baseSession'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> progressJson = {};
    cardProgress.forEach((key, value) {
      progressJson[key] = value.toJson();
    });

    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'flashcardIds': flashcardIds,
      'cardProgress': progressJson,
      'startTime': startTime,
      'endTime': endTime,
      'currentCardIndex': currentCardIndex,
      'isCompleted': isCompleted,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'skippedCount': skippedCount,
      'baseSession': baseSession.toJson(),
    };
  }

  FlashcardSessionModel copyWith({
    String? id,
    String? userId,
    String? subject,
    List<String>? flashcardIds,
    Map<String, FlashcardProgress>? cardProgress,
    DateTime? startTime,
    DateTime? endTime,
    int? currentCardIndex,
    bool? isCompleted,
    int? correctCount,
    int? incorrectCount,
    int? skippedCount,
    StudySessionModel? baseSession,
  }) {
    return FlashcardSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      flashcardIds: flashcardIds ?? this.flashcardIds,
      cardProgress: cardProgress ?? this.cardProgress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      skippedCount: skippedCount ?? this.skippedCount,
      baseSession: baseSession ?? this.baseSession,
    );
  }

  // Helper methods
  int get totalCards => flashcardIds.length;
  int get studiedCards => cardProgress.length;
  double get progressPercentage =>
      totalCards > 0 ? (studiedCards / totalCards) * 100 : 0;
  double get accuracy => (correctCount + incorrectCount) > 0
      ? (correctCount / (correctCount + incorrectCount)) * 100
      : 0;
}

class FlashcardProgress {
  final String flashcardId;
  final bool wasCorrect;
  final int timeSpentInSeconds;
  final DateTime studiedAt;
  final int confidenceLevel; // 1-5 scale

  FlashcardProgress({
    required this.flashcardId,
    required this.wasCorrect,
    required this.timeSpentInSeconds,
    required this.studiedAt,
    required this.confidenceLevel,
  });

  factory FlashcardProgress.fromJson(Map<String, dynamic> json) {
    return FlashcardProgress(
      flashcardId: json['flashcardId'] as String,
      wasCorrect: json['wasCorrect'] as bool,
      timeSpentInSeconds: json['timeSpentInSeconds'] as int,
      studiedAt: json['studiedAt'] != null
          ? (json['studiedAt'] as Timestamp).toDate()
          : DateTime.now(),
      confidenceLevel: json['confidenceLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flashcardId': flashcardId,
      'wasCorrect': wasCorrect,
      'timeSpentInSeconds': timeSpentInSeconds,
      'studiedAt': studiedAt,
      'confidenceLevel': confidenceLevel,
    };
  }
}
