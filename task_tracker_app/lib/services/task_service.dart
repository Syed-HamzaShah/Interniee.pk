import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTask(TaskModel task) async {
    try {
      final docRef = await _firestore.collection('tasks').add(task.toMap());
      await _firestore.collection('tasks').doc(docRef.id).update({
        'id': docRef.id,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _firestore.collection('tasks').doc(taskId).get();
      if (doc.exists) {
        return TaskModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Update task
  Future<void> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Stream<List<TaskModel>> getUserTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedToId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getAllTasks() {
    return _firestore
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getTasksByStatus(String userId, TaskStatus status) {
    return _firestore
        .collection('tasks')
        .where('assignedToId', isEqualTo: userId)
        .where('status', isEqualTo: status.name)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs
              .map((doc) => TaskModel.fromDocument(doc))
              .toList();
          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        });
  }

  Stream<List<TaskModel>> getTasksByPriority(
    String userId,
    TaskPriority priority,
  ) {
    return _firestore
        .collection('tasks')
        .where('assignedToId', isEqualTo: userId)
        .where('priority', isEqualTo: priority.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getOverdueTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedToId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'inProgress'])
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromDocument(doc))
              .where((task) => task.isOverdue)
              .toList(),
        );
  }

  Future<void> completeTask(String taskId, {String? completedNotes}) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': TaskStatus.completed.name,
        'completedAt': Timestamp.fromDate(DateTime.now()),
        'completedNotes': completedNotes,
      });
    } catch (e) {
      throw Exception('Failed to complete task: $e');
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final updates = <String, dynamic>{'status': status.name};
      if (status == TaskStatus.completed) {
        updates['completedAt'] = Timestamp.fromDate(DateTime.now());
      }
      await _firestore.collection('tasks').doc(taskId).update(updates);
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> assignTask(
    String taskId,
    String assignedToId,
    String assignedByName,
  ) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'assignedToId': assignedToId,
        'assignedByName': assignedByName,
      });
    } catch (e) {
      throw Exception('Failed to assign task: $e');
    }
  }

  Future<Map<String, int>> getUserTaskStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedToId', isEqualTo: userId)
          .get();

      int total = 0;
      int pending = 0;
      int inProgress = 0;
      int completed = 0;
      int overdue = 0;

      for (final doc in snapshot.docs) {
        final task = TaskModel.fromDocument(doc);
        total++;

        switch (task.status) {
          case TaskStatus.pending:
            pending++;
            break;
          case TaskStatus.inProgress:
            inProgress++;
            break;
          case TaskStatus.completed:
            completed++;
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
        'pending': pending,
        'inProgress': inProgress,
        'completed': completed,
        'overdue': overdue,
      };
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }

  Stream<List<TaskModel>> searchTasks(String userId, String query) {
    return _firestore
        .collection('tasks')
        .where('assignedToId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromDocument(doc))
              .where(
                (task) =>
                    task.title.toLowerCase().contains(query.toLowerCase()) ||
                    task.description.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList(),
        );
  }
}
