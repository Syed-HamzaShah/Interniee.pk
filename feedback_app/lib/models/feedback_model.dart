import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackCategory { course, internship, company, experience }

enum FeedbackStatus { pending, approved, rejected }

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? name;
  final FeedbackCategory category;
  final int rating;
  final String comments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final FeedbackStatus status;
  final String? adminNotes;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.name,
    required this.category,
    required this.rating,
    required this.comments,
    required this.createdAt,
    this.updatedAt,
    this.status = FeedbackStatus.pending,
    this.adminNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'name': name,
      'category': category.name,
      'rating': rating,
      'comments': comments,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status.name,
      'adminNotes': adminNotes,
    };
  }

  // Create FeedbackModel from Firestore document
  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    try {
      return FeedbackModel(
        id: map['id']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        userName: map['userName']?.toString() ?? 'Unknown User',
        userEmail: map['userEmail']?.toString() ?? '',
        name: map['name']?.toString(),
        category: FeedbackCategory.values.firstWhere(
          (category) => category.name == map['category'],
          orElse: () => FeedbackCategory.experience,
        ),
        rating: (map['rating'] is int) ? map['rating'] : 1,
        comments: map['comments']?.toString() ?? '',
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null && map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : null,
        status: FeedbackStatus.values.firstWhere(
          (status) => status.name == map['status'],
          orElse: () => FeedbackStatus.pending,
        ),
        adminNotes: map['adminNotes']?.toString(),
      );
    } catch (e) {
      return FeedbackModel(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'unknown',
        userName: 'Unknown User',
        userEmail: 'unknown@example.com',
        category: FeedbackCategory.experience,
        rating: 1,
        comments: 'Error loading feedback data',
        createdAt: DateTime.now(),
        status: FeedbackStatus.pending,
      );
    }
  }

  factory FeedbackModel.fromDocument(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Document data is null');
      }
      return FeedbackModel.fromMap(data);
    } catch (e) {
      return FeedbackModel(
        id: doc.id,
        userId: 'unknown',
        userName: 'Unknown User',
        userEmail: 'unknown@example.com',
        category: FeedbackCategory.experience,
        rating: 1,
        comments: 'Error loading feedback data',
        createdAt: DateTime.now(),
        status: FeedbackStatus.pending,
      );
    }
  }

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? name,
    FeedbackCategory? category,
    int? rating,
    String? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    FeedbackStatus? status,
    String? adminNotes,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case FeedbackCategory.course:
        return 'Course';
      case FeedbackCategory.internship:
        return 'Internship';
      case FeedbackCategory.company:
        return 'Company';
      case FeedbackCategory.experience:
        return 'Experience';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case FeedbackStatus.pending:
        return 'Pending';
      case FeedbackStatus.approved:
        return 'Approved';
      case FeedbackStatus.rejected:
        return 'Rejected';
    }
  }

  String get statusColor {
    switch (status) {
      case FeedbackStatus.pending:
        return '#FFA726'; // Orange
      case FeedbackStatus.approved:
        return '#66BB6A'; // Green
      case FeedbackStatus.rejected:
        return '#EF5350'; // Red
    }
  }

  String get categoryColor {
    switch (category) {
      case FeedbackCategory.course:
        return '#42A5F5'; // Blue
      case FeedbackCategory.internship:
        return '#AB47BC'; // Purple
      case FeedbackCategory.company:
        return '#26A69A'; // Teal
      case FeedbackCategory.experience:
        return '#FF7043'; // Deep Orange
    }
  }

  String get ratingStars {
    return '★' * rating + '☆' * (5 - rating);
  }

  bool get isRecent {
    return DateTime.now().difference(createdAt).inDays <= 7;
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
