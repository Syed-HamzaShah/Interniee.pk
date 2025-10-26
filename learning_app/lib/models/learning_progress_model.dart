import 'package:cloud_firestore/cloud_firestore.dart';

class LearningProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final String lessonId;
  final bool isCompleted;
  final int timeSpent; // in seconds
  final double progress; // 0.0 to 1.0
  final DateTime lastAccessed;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata; // additional progress data

  LearningProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.lessonId,
    required this.isCompleted,
    required this.timeSpent,
    required this.progress,
    required this.lastAccessed,
    this.completedAt,
    required this.metadata,
  });

  factory LearningProgressModel.fromMap(Map<String, dynamic> map) {
    return LearningProgressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      timeSpent: map['timeSpent'] ?? 0,
      progress: (map['progress'] ?? 0.0).toDouble(),
      lastAccessed:
          (map['lastAccessed'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'lessonId': lessonId,
      'isCompleted': isCompleted,
      'timeSpent': timeSpent,
      'progress': progress,
      'lastAccessed': Timestamp.fromDate(lastAccessed),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'metadata': metadata,
    };
  }

  LearningProgressModel copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? lessonId,
    bool? isCompleted,
    int? timeSpent,
    double? progress,
    DateTime? lastAccessed,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return LearningProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      lessonId: lessonId ?? this.lessonId,
      isCompleted: isCompleted ?? this.isCompleted,
      timeSpent: timeSpent ?? this.timeSpent,
      progress: progress ?? this.progress,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'LearningProgressModel(id: $id, courseId: $courseId, lessonId: $lessonId, progress: $progress, isCompleted: $isCompleted)';
  }
}

class CourseProgressModel {
  final String id;
  final String userId;
  final String courseId;
  final int totalLessons;
  final int completedLessons;
  final double overallProgress; // 0.0 to 1.0
  final int totalTimeSpent; // in seconds
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final Map<String, double> lessonProgress; // lessonId -> progress

  CourseProgressModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.totalLessons,
    required this.completedLessons,
    required this.overallProgress,
    required this.totalTimeSpent,
    required this.enrolledAt,
    this.completedAt,
    required this.isCompleted,
    required this.lessonProgress,
  });

  factory CourseProgressModel.fromMap(Map<String, dynamic> map) {
    return CourseProgressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      overallProgress: (map['overallProgress'] ?? 0.0).toDouble(),
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      enrolledAt: (map['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      isCompleted: map['isCompleted'] ?? false,
      lessonProgress: Map<String, double>.from(
        (map['lessonProgress'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'overallProgress': overallProgress,
      'totalTimeSpent': totalTimeSpent,
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'isCompleted': isCompleted,
      'lessonProgress': lessonProgress,
    };
  }

  CourseProgressModel copyWith({
    String? id,
    String? userId,
    String? courseId,
    int? totalLessons,
    int? completedLessons,
    double? overallProgress,
    int? totalTimeSpent,
    DateTime? enrolledAt,
    DateTime? completedAt,
    bool? isCompleted,
    Map<String, double>? lessonProgress,
  }) {
    return CourseProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      overallProgress: overallProgress ?? this.overallProgress,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      lessonProgress: lessonProgress ?? this.lessonProgress,
    );
  }

  @override
  String toString() {
    return 'CourseProgressModel(id: $id, courseId: $courseId, overallProgress: $overallProgress, isCompleted: $isCompleted)';
  }
}
