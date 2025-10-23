import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_model.dart';

class ProgressModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionRate;
  final List<String> completedTaskIds;
  final List<String> pendingTaskIds;
  final List<String> overdueTaskIds;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionRate,
    this.completedTaskIds = const [],
    this.pendingTaskIds = const [],
    this.overdueTaskIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'date': date,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'completionRate': completionRate,
      'completedTaskIds': completedTaskIds,
      'pendingTaskIds': pendingTaskIds,
      'overdueTaskIds': overdueTaskIds,
    };
  }

  // Create ProgressModel from Firestore document
  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      totalTasks: map['totalTasks'] ?? 0,
      completedTasks: map['completedTasks'] ?? 0,
      pendingTasks: map['pendingTasks'] ?? 0,
      overdueTasks: map['overdueTasks'] ?? 0,
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      completedTaskIds: List<String>.from(map['completedTaskIds'] ?? []),
      pendingTaskIds: List<String>.from(map['pendingTaskIds'] ?? []),
      overdueTaskIds: List<String>.from(map['overdueTaskIds'] ?? []),
    );
  }

  factory ProgressModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel.fromMap(data);
  }

  factory ProgressModel.fromTasks({
    required String userId,
    required String userName,
    required DateTime date,
    required List<TaskModel> tasks,
  }) {
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();
    final pendingTasks = tasks
        .where(
          (task) =>
              task.status == TaskStatus.pending ||
              task.status == TaskStatus.inProgress,
        )
        .toList();
    final overdueTasks = tasks.where((task) => task.isOverdue).toList();

    final totalTasks = tasks.length;
    final completionRate = totalTasks > 0
        ? (completedTasks.length / totalTasks) * 100
        : 0.0;

    return ProgressModel(
      id: '${userId}_${date.millisecondsSinceEpoch}',
      userId: userId,
      userName: userName,
      date: date,
      totalTasks: totalTasks,
      completedTasks: completedTasks.length,
      pendingTasks: pendingTasks.length,
      overdueTasks: overdueTasks.length,
      completionRate: completionRate,
      completedTaskIds: completedTasks.map((task) => task.id).toList(),
      pendingTaskIds: pendingTasks.map((task) => task.id).toList(),
      overdueTaskIds: overdueTasks.map((task) => task.id).toList(),
    );
  }

  ProgressModel copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? date,
    int? totalTasks,
    int? completedTasks,
    int? pendingTasks,
    int? overdueTasks,
    double? completionRate,
    List<String>? completedTaskIds,
    List<String>? pendingTaskIds,
    List<String>? overdueTaskIds,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      date: date ?? this.date,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      completionRate: completionRate ?? this.completionRate,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
      pendingTaskIds: pendingTaskIds ?? this.pendingTaskIds,
      overdueTaskIds: overdueTaskIds ?? this.overdueTaskIds,
    );
  }

  String get performanceGrade {
    if (completionRate >= 90) return 'A+';
    if (completionRate >= 80) return 'A';
    if (completionRate >= 70) return 'B';
    if (completionRate >= 60) return 'C';
    if (completionRate >= 50) return 'D';
    return 'F';
  }

  String get performanceColor {
    if (completionRate >= 90) return '#66BB6A';
    if (completionRate >= 70) return '#42A5F5';
    if (completionRate >= 50) return '#FFA726';
    return '#EF5350';
  }
}
