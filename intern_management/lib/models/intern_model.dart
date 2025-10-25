import 'package:cloud_firestore/cloud_firestore.dart';

class InternModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? department;
  final String? university;
  final String? course;
  final DateTime startDate;
  final DateTime? endDate;
  final String? profileImageUrl;
  final String? bio;
  final List<String> skills;
  final Map<String, dynamic> performance; // Performance metrics
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  InternModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.department,
    this.university,
    this.course,
    required this.startDate,
    this.endDate,
    this.profileImageUrl,
    this.bio,
    this.skills = const [],
    this.performance = const {},
    this.isActive = true,
    required this.createdAt,
    this.lastActiveAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'university': university,
      'course': course,
      'startDate': startDate,
      'endDate': endDate,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'skills': skills,
      'performance': performance,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastActiveAt': lastActiveAt,
    };
  }

  factory InternModel.fromMap(Map<String, dynamic> map) {
    return InternModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      department: map['department'],
      university: map['university'],
      course: map['course'],
      startDate: map['startDate'] != null
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      skills: List<String>.from(map['skills'] ?? []),
      performance: Map<String, dynamic>.from(map['performance'] ?? {}),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastActiveAt: map['lastActiveAt'] != null
          ? (map['lastActiveAt'] as Timestamp).toDate()
          : null,
    );
  }

 snapshot
  factory InternModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InternModel.fromMap(data);
  }

  InternModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? university,
    String? course,
    DateTime? startDate,
    DateTime? endDate,
    String? profileImageUrl,
    String? bio,
    List<String>? skills,
    Map<String, dynamic>? performance,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return InternModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      university: university ?? this.university,
      course: course ?? this.course,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      performance: performance ?? this.performance,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return 'Ongoing';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get formattedLastActive {
    if (lastActiveAt == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${lastActiveAt!.day}/${lastActiveAt!.month}/${lastActiveAt!.year}';
    }
  }

  int get totalTasksAssigned {
    return performance['totalTasksAssigned'] ?? 0;
  }

  int get totalTasksCompleted {
    return performance['totalTasksCompleted'] ?? 0;
  }

  int get totalTasksOverdue {
    return performance['totalTasksOverdue'] ?? 0;
  }

  double get completionRate {
    if (totalTasksAssigned == 0) return 0.0;
    return (totalTasksCompleted / totalTasksAssigned) * 100;
  }

  double get averageRating {
    return (performance['averageRating'] ?? 0.0).toDouble();
  }

  String get performanceStatus {
    final rate = completionRate;
    if (rate >= 90) return 'Excellent';
    if (rate >= 70) return 'Good';
    if (rate >= 50) return 'Average';
    return 'Needs Improvement';
  }

  int get internshipDurationInDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  int get remainingDays {
    if (endDate == null) return -1; // Ongoing
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  bool get isInternshipCompleted {
    return endDate != null && DateTime.now().isAfter(endDate!);
  }

  bool get isInternshipActive {
    return isActive && !isInternshipCompleted;
  }
}
