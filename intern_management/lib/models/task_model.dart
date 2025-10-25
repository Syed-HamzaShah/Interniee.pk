import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { notStarted, inProgress, completed, overdue }

enum TaskPriority { low, medium, high, urgent }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String assignedBy; // Admin User ID
  final DateTime deadline;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final List<String> attachments; // URLs to attachments

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.completedAt,
    this.notes,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'deadline': deadline,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'notes': notes,
      'attachments': attachments,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedTo: map['assignedTo'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : DateTime.now().add(Duration(days: 7)),
      status: TaskStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => TaskStatus.notStarted,
      ),
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
      attachments: List<String>.from(map['attachments'] ?? []),
    );
  }

 snapshot
  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromMap(data);
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedBy,
    DateTime? deadline,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
    List<String>? attachments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }

  String get statusDisplayName {
    switch (status) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  String get formattedDeadline {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue by ${(-difference)} days';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'Due in $difference days';
    }
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

  bool get isOverdue {
    return status != TaskStatus.completed && DateTime.now().isAfter(deadline);
  }

  double get progressPercentage {
    switch (status) {
      case TaskStatus.notStarted:
        return 0.0;
      case TaskStatus.inProgress:
        return 0.5;
      case TaskStatus.completed:
        return 1.0;
      case TaskStatus.overdue:
        return 0.0;
    }
  }
}
