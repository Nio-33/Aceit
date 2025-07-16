import 'package:cloud_firestore/cloud_firestore.dart';

class MockExamModel {
  final String id;
  final String title;
  final String subject;
  final String examType;
  final int durationInMinutes;
  final int numberOfQuestions;
  final List<String> questionIds;
  final int passMarkPercentage;
  final DateTime createdAt;
  
  MockExamModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.examType,
    required this.durationInMinutes,
    required this.numberOfQuestions,
    required this.questionIds,
    this.passMarkPercentage = 50,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // From JSON constructor
  factory MockExamModel.fromJson(Map<String, dynamic> json) {
    return MockExamModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      examType: json['examType'] as String,
      durationInMinutes: json['durationInMinutes'] as int,
      numberOfQuestions: json['numberOfQuestions'] as int,
      questionIds: (json['questionIds'] is Iterable) 
          ? List<String>.from(json['questionIds'] as Iterable) 
          : <String>[],
      passMarkPercentage: json['passMarkPercentage'] as int? ?? 50,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'examType': examType,
      'durationInMinutes': durationInMinutes,
      'numberOfQuestions': numberOfQuestions,
      'questionIds': questionIds,
      'passMarkPercentage': passMarkPercentage,
      'createdAt': createdAt,
    };
  }
  
  // Copy with method for updates
  MockExamModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? examType,
    int? durationInMinutes,
    int? numberOfQuestions,
    List<String>? questionIds,
    int? passMarkPercentage,
    DateTime? createdAt,
  }) {
    return MockExamModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      questionIds: questionIds ?? this.questionIds,
      passMarkPercentage: passMarkPercentage ?? this.passMarkPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 