import 'package:cloud_firestore/cloud_firestore.dart';

enum LessonType { video, text, quiz, assignment }

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final LessonType type;
  final int order;
  final int duration; // in minutes
  final String? videoUrl;
  final String? content; // for text lessons
  final String? quizId; // for quiz lessons
  final String? assignmentId; // for assignment lessons
  final List<String> attachments; // file URLs
  final bool isPublished;
  final bool isFree; // free preview lesson
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? externalId; // ID from learn.internee.pk

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    required this.duration,
    this.videoUrl,
    this.content,
    this.quizId,
    this.assignmentId,
    required this.attachments,
    required this.isPublished,
    required this.isFree,
    required this.createdAt,
    required this.updatedAt,
    this.externalId,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: LessonType.values.firstWhere(
        (e) => e.toString() == 'LessonType.${map['type']}',
        orElse: () => LessonType.video,
      ),
      order: map['order'] ?? 0,
      duration: map['duration'] ?? 0,
      videoUrl: map['videoUrl'],
      content: map['content'],
      quizId: map['quizId'],
      assignmentId: map['assignmentId'],
      attachments: List<String>.from(map['attachments'] ?? []),
      isPublished: map['isPublished'] ?? false,
      isFree: map['isFree'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      externalId: map['externalId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'order': order,
      'duration': duration,
      'videoUrl': videoUrl,
      'content': content,
      'quizId': quizId,
      'assignmentId': assignmentId,
      'attachments': attachments,
      'isPublished': isPublished,
      'isFree': isFree,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'externalId': externalId,
    };
  }

  LessonModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    LessonType? type,
    int? order,
    int? duration,
    String? videoUrl,
    String? content,
    String? quizId,
    String? assignmentId,
    List<String>? attachments,
    bool? isPublished,
    bool? isFree,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? externalId,
  }) {
    return LessonModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      order: order ?? this.order,
      duration: duration ?? this.duration,
      videoUrl: videoUrl ?? this.videoUrl,
      content: content ?? this.content,
      quizId: quizId ?? this.quizId,
      assignmentId: assignmentId ?? this.assignmentId,
      attachments: attachments ?? this.attachments,
      isPublished: isPublished ?? this.isPublished,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      externalId: externalId ?? this.externalId,
    );
  }

  @override
  String toString() {
    return 'LessonModel(id: $id, title: $title, type: $type, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
