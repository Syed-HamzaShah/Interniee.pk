import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { pending, inProgress, completed, overdue }

enum TaskPriority { low, medium, high, urgent }

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String assignedToId;
  final String assignedByName;
  final DateTime createdAt;
  final DateTime dueDate;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> tags;
  final String? notes;
  final DateTime? completedAt;
  final String? completedNotes;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedToId,
    required this.assignedByName,
    required this.createdAt,
    required this.dueDate,
    required this.status,
    required this.priority,
    this.tags = const [],
    this.notes,
    this.completedAt,
    this.completedNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'assignedByName': assignedByName,
      'createdAt': createdAt,
      'dueDate': dueDate,
      'status': status.name,
      'priority': priority.name,
      'tags': tags,
      'notes': notes,
      'completedAt': completedAt,
      'completedNotes': completedNotes,
    };
  }

  // Create TaskModel from Firestore document
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      assignedToId: map['assignedToId'] ?? '',
      assignedByName: map['assignedByName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: TaskStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (priority) => priority.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      completedNotes: map['completedNotes'],
    );
  }

  factory TaskModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromMap(data);
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedToId,
    String? assignedByName,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? notes,
    DateTime? completedAt,
    String? completedNotes,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedByName: assignedByName ?? this.assignedByName,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      completedNotes: completedNotes ?? this.completedNotes,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != TaskStatus.completed;
  }

  String get statusColor {
    switch (status) {
      case TaskStatus.pending:
        return '#FFA726'; // Orange
      case TaskStatus.inProgress:
        return '#42A5F5';
      case TaskStatus.completed:
        return '#66BB6A'; // Green
      case TaskStatus.overdue:
        return '#EF5350'; // Red
    }
  }

  String get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return '#66BB6A'; // Green
      case TaskPriority.medium:
        return '#FFA726'; // Orange
      case TaskPriority.high:
        return '#FF7043';
      case TaskPriority.urgent:
        return '#EF5350'; // Red
    }
  }
}
