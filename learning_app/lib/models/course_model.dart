import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String thumbnailUrl;
  final String category;
  final int duration; // in minutes
  final int totalLessons;
  final double rating;
  final int enrolledCount;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final String? externalId; // ID from learn.internee.pk

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.category,
    required this.duration,
    required this.totalLessons,
    required this.rating,
    required this.enrolledCount,
    required this.difficulty,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    this.externalId,
  });

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      instructor: map['instructor'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      totalLessons: map['totalLessons'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      enrolledCount: map['enrolledCount'] ?? 0,
      difficulty: map['difficulty'] ?? 'beginner',
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: map['isPublished'] ?? false,
      externalId: map['externalId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'duration': duration,
      'totalLessons': totalLessons,
      'rating': rating,
      'enrolledCount': enrolledCount,
      'difficulty': difficulty,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'externalId': externalId,
    };
  }

  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? thumbnailUrl,
    String? category,
    int? duration,
    int? totalLessons,
    double? rating,
    int? enrolledCount,
    String? difficulty,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    String? externalId,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      totalLessons: totalLessons ?? this.totalLessons,
      rating: rating ?? this.rating,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, title: $title, instructor: $instructor, category: $category, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
