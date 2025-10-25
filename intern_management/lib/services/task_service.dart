import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  Future<TaskModel?> createTask({
    required String title,
    required String description,
    required String assignedTo,
    required String assignedBy,
    required DateTime deadline,
    required TaskPriority priority,
    String? notes,
  }) async {
    try {
      final taskId = _firestore.collection(_collection).doc().id;

      final task = TaskModel(
        id: taskId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedBy: assignedBy,
        deadline: deadline,
        status: TaskStatus.notStarted,
        priority: priority,
        createdAt: DateTime.now(),
        notes: notes,
      );

      await _firestore.collection(_collection).doc(taskId).set(task.toMap());
      return task;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  Future<List<TaskModel>> getTasksByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user tasks: $e');
    }
  }

  Stream<List<TaskModel>> getTasksStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getUserTasksStream(String userId) {
    print('TaskService: Getting user tasks stream for userId: $userId');
    return _firestore
        .collection(_collection)
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(taskId).get();

      if (doc.exists) {
        return TaskModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updateData = {
        'status': status.name,
        'completedAt': status == TaskStatus.completed ? DateTime.now() : null,
      };

      await _firestore.collection(_collection).doc(taskId).update(updateData);
      return true;
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<bool> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (deadline != null) updateData['deadline'] = deadline;
      if (priority != null) updateData['priority'] = priority.name;
      if (notes != null) updateData['notes'] = notes;

      if (updateData.isNotEmpty) {
        await _firestore.collection(_collection).doc(taskId).update(updateData);
      }
      return true;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_collection).doc(taskId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks by status: $e');
    }
  }

  Future<List<TaskModel>> getUserTasksByStatus(
    String userId,
    TaskStatus status,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user tasks by status: $e');
    }
  }

  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where(
            'status',
            whereIn: [TaskStatus.notStarted.name, TaskStatus.inProgress.name],
          )
          .where('deadline', isLessThan: now)
          .orderBy('deadline', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get overdue tasks: $e');
    }
  }

  Future<List<TaskModel>> getUserOverdueTasks(String userId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .where(
            'status',
            whereIn: [TaskStatus.notStarted.name, TaskStatus.inProgress.name],
          )
          .where('deadline', isLessThan: now)
          .orderBy('deadline', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user overdue tasks: $e');
    }
  }

  Future<List<TaskModel>> getTasksDueSoon() async {
    try {
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where(
            'status',
            whereIn: [TaskStatus.notStarted.name, TaskStatus.inProgress.name],
          )
          .where('deadline', isGreaterThan: now)
          .where('deadline', isLessThan: threeDaysFromNow)
          .orderBy('deadline', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks due soon: $e');
    }
  }

  Future<List<TaskModel>> getUserTasksDueSoon(String userId) async {
    try {
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .where(
            'status',
            whereIn: [TaskStatus.notStarted.name, TaskStatus.inProgress.name],
          )
          .where('deadline', isGreaterThan: now)
          .where('deadline', isLessThan: threeDaysFromNow)
          .orderBy('deadline', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user tasks due soon: $e');
    }
  }

  Future<Map<String, int>> getTaskStatistics() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      int total = 0;
      int completed = 0;
      int inProgress = 0;
      int notStarted = 0;
      int overdue = 0;

      for (var doc in querySnapshot.docs) {
        final task = TaskModel.fromDocument(doc);
        total++;

        switch (task.status) {
          case TaskStatus.completed:
            completed++;
            break;
          case TaskStatus.inProgress:
            inProgress++;
            break;
          case TaskStatus.notStarted:
            notStarted++;
            break;
          case TaskStatus.overdue:
            overdue++;
            break;
        }

        if (task.isOverdue && task.status != TaskStatus.completed) {
          overdue++;
        }
      }

      return {
        'total': total,
        'completed': completed,
        'inProgress': inProgress,
        'notStarted': notStarted,
        'overdue': overdue,
      };
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }

  Future<Map<String, int>> getUserTaskStatistics(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .get();

      int total = 0;
      int completed = 0;
      int inProgress = 0;
      int notStarted = 0;
      int overdue = 0;

      for (var doc in querySnapshot.docs) {
        final task = TaskModel.fromDocument(doc);
        total++;

        switch (task.status) {
          case TaskStatus.completed:
            completed++;
            break;
          case TaskStatus.inProgress:
            inProgress++;
            break;
          case TaskStatus.notStarted:
            notStarted++;
            break;
          case TaskStatus.overdue:
            overdue++;
            break;
        }

        if (task.isOverdue && task.status != TaskStatus.completed) {
          overdue++;
        }
      }

      return {
        'total': total,
        'completed': completed,
        'inProgress': inProgress,
        'notStarted': notStarted,
        'overdue': overdue,
      };
    } catch (e) {
      throw Exception('Failed to get user task statistics: $e');
    }
  }

  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('priority', isEqualTo: priority.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks by priority: $e');
    }
  }

  Future<List<TaskModel>> getUserTasksByPriority(
    String userId,
    TaskPriority priority,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedTo', isEqualTo: userId)
          .where('priority', isEqualTo: priority.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user tasks by priority: $e');
    }
  }

  Future<List<TaskModel>> getTasksAssignedBy(String adminId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('assignedBy', isEqualTo: adminId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks assigned by admin: $e');
    }
  }

  Stream<List<TaskModel>> getTasksAssignedByStream(String adminId) {
    return _firestore
        .collection(_collection)
        .where('assignedBy', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<List<TaskModel>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (userId != null) {
        query = query.where('assignedTo', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      query = query
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tasks by date range: $e');
    }
  }

  Stream<List<TaskModel>> getTasksByDateRangeStream(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    try {
      Query query = _firestore.collection(_collection);

      if (userId != null) {
        query = query.where('assignedTo', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      query = query
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true);

      return query.snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
      );
    } catch (e) {
      return Stream.error('Failed to get tasks by date range stream: $e');
    }
  }

  Future<bool> batchUpdateTaskStatuses(
    List<String> taskIds,
    TaskStatus status,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final taskId in taskIds) {
        final taskRef = _firestore.collection(_collection).doc(taskId);
        batch.update(taskRef, {
          'status': status.name,
          'completedAt': status == TaskStatus.completed ? DateTime.now() : null,
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to batch update task statuses: $e');
    }
  }

  Future<List<TaskModel>> searchTasks(String searchQuery) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('title')
          .get();

      final allTasks = querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();

      return allTasks.where((task) {
        return task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            task.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  Future<Map<String, dynamic>> getTaskAnalytics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (userId != null) {
        query = query.where('assignedTo', isEqualTo: userId);
      }

      if (startDate != null && endDate != null) {
        query = query
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where(
              'createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate),
            );
      }

      final querySnapshot = await query.get();
      final tasks = querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();

      final totalTasks = tasks.length;
      final completedTasks = tasks
          .where((t) => t.status == TaskStatus.completed)
          .length;
      final inProgressTasks = tasks
          .where((t) => t.status == TaskStatus.inProgress)
          .length;
      final notStartedTasks = tasks
          .where((t) => t.status == TaskStatus.notStarted)
          .length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;

      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0;

      final priorityStats = <String, int>{};
      for (final priority in TaskPriority.values) {
        priorityStats[priority.name] = tasks
            .where((t) => t.priority == priority)
            .length;
      }

      double averageCompletionTime = 0.0;
      final completedTasksWithTime = tasks
          .where(
            (t) => t.status == TaskStatus.completed && t.completedAt != null,
          )
          .toList();

      if (completedTasksWithTime.isNotEmpty) {
        final totalCompletionTime = completedTasksWithTime
            .map((t) => t.completedAt!.difference(t.createdAt).inDays)
            .reduce((a, b) => a + b);
        averageCompletionTime =
            totalCompletionTime / completedTasksWithTime.length;
      }

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'inProgressTasks': inProgressTasks,
        'notStartedTasks': notStartedTasks,
        'overdueTasks': overdueTasks,
        'completionRate': completionRate,
        'priorityStats': priorityStats,
        'averageCompletionTime': averageCompletionTime,
      };
    } catch (e) {
      throw Exception('Failed to get task analytics: $e');
    }
  }
}
