import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardModel {
  final String id;
  final String front;
  final String back;
  final String subject;
  final String? imageUrl;
  final DateTime createdAt;
  
  FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    required this.subject,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // From JSON constructor
  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      front: json['front'] as String,
      back: json['back'] as String,
      subject: json['subject'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'subject': subject,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
    };
  }
  
  // Copy with method for updates
  FlashcardModel copyWith({
    String? id,
    String? front,
    String? back,
    String? subject,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      subject: subject ?? this.subject,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 