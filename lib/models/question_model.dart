class QuestionModel {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String subject;
  final String examType;
  final String? imageUrl;
  final int difficultyLevel; // 1: Easy, 2: Medium, 3: Hard
  
  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    required this.subject,
    required this.examType,
    this.imageUrl,
    this.difficultyLevel = 2,
  });
  
  // From JSON constructor
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] is Iterable) 
          ? List<String>.from(json['options'] as Iterable) 
          : <String>[],
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String?,
      subject: json['subject'] as String,
      examType: json['examType'] as String,
      imageUrl: json['imageUrl'] as String?,
      difficultyLevel: json['difficultyLevel'] as int? ?? 2,
    );
  }
  
  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'subject': subject,
      'examType': examType,
      'imageUrl': imageUrl,
      'difficultyLevel': difficultyLevel,
    };
  }
  
  // Copy with method for updates
  QuestionModel copyWith({
    String? id,
    String? text,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? subject,
    String? examType,
    String? imageUrl,
    int? difficultyLevel,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      imageUrl: imageUrl ?? this.imageUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }
} 