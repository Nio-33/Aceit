import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String department;
  final List<String> selectedSubjects;
  final int currentStreak;
  final DateTime lastLoginDate;
  final int points;
  final Map<String, dynamic> progress;
  final bool emailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.selectedSubjects,
    this.currentStreak = 0,
    DateTime? lastLoginDate,
    this.points = 0,
    this.progress = const {},
    this.emailVerified = false,
  }) : lastLoginDate = lastLoginDate ?? DateTime.now();

  // From JSON constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      department: json['department'] as String,
      selectedSubjects: (json['selectedSubjects'] is Iterable) 
          ? List<String>.from(json['selectedSubjects'] as Iterable) 
          : <String>[],
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastLoginDate: json['lastLoginDate'] != null 
          ? (json['lastLoginDate'] as Timestamp).toDate() 
          : DateTime.now(),
      points: json['points'] as int? ?? 0,
      progress: json['progress'] as Map<String, dynamic>? ?? {},
      emailVerified: json['emailVerified'] as bool? ?? false,
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'department': department,
      'selectedSubjects': selectedSubjects,
      'currentStreak': currentStreak,
      'lastLoginDate': lastLoginDate,
      'points': points,
      'progress': progress,
      'emailVerified': emailVerified,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? department,
    List<String>? selectedSubjects,
    int? currentStreak,
    DateTime? lastLoginDate,
    int? points,
    Map<String, dynamic>? progress,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      points: points ?? this.points,
      progress: progress ?? this.progress,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
} 