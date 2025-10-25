import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/intern_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _tasksCollection = 'tasks';
  static const String _feedbacksCollection = 'feedbacks';

  final Map<String, StreamSubscription> _listeners = {};

  void dispose() {
    for (final subscription in _listeners.values) {
      subscription.cancel();
    }
    _listeners.clear();
  }


  Stream<List<UserModel>> getUsersStream() {
    return _firestore
        .collection(_usersCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<UserModel>> getUsersByRoleStream(UserRole role) {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: role.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList(),
        );
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
      return true;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }


  Stream<List<TaskModel>> getTasksStream() {
    return _firestore
        .collection(_tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getUserTasksStream(String userId) {
    return _firestore
        .collection(_tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getTasksByStatusStream(TaskStatus status) {
    return _firestore
        .collection(_tasksCollection)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Stream<List<TaskModel>> getTasksByPriorityStream(TaskPriority priority) {
    return _firestore
        .collection(_tasksCollection)
        .where('priority', isEqualTo: priority.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList(),
        );
  }

  Future<TaskModel?> createTask(TaskModel task) async {
    try {
      final docRef = await _firestore
          .collection(_tasksCollection)
          .add(task.toMap());
      return task.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<bool> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_tasksCollection).doc(taskId).update(data);
      return true;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_tasksCollection).doc(taskId).delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }


  Stream<List<InternModel>> getInternsStream() {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'intern')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Stream<List<InternModel>> getActiveInternsStream() {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'intern')
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Stream<List<InternModel>> getInternsByDepartmentStream(String department) {
    return _firestore
        .collection(_usersCollection)
        .where('role', isEqualTo: 'intern')
        .where('department', isEqualTo: department)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => InternModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<bool> updateInternProfile(
    String internId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(internId).update(data);
      return true;
    } catch (e) {
      throw Exception('Failed to update intern profile: $e');
    }
  }


  Stream<List<FeedbackModel>> getFeedbacksStream() {
    return _firestore
        .collection(_feedbacksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromDocument(doc))
              .toList(),
        );
  }

  Stream<List<FeedbackModel>> getUserFeedbacksStream(String userId) {
    return _firestore
        .collection(_feedbacksCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromDocument(doc))
              .toList(),
        );
  }

  Stream<List<FeedbackModel>> getFeedbacksByStatusStream(
    FeedbackStatus status,
  ) {
    return _firestore
        .collection(_feedbacksCollection)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FeedbackModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<FeedbackModel?> createFeedback(FeedbackModel feedback) async {
    try {
      final docRef = await _firestore
          .collection(_feedbacksCollection)
          .add(feedback.toMap());
      return feedback.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create feedback: $e');
    }
  }

  Future<bool> updateFeedback(
    String feedbackId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_feedbacksCollection)
          .doc(feedbackId)
          .update(data);
      return true;
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      await _firestore
          .collection(_feedbacksCollection)
          .doc(feedbackId)
          .delete();
      return true;
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }


  Future<Map<String, dynamic>> getTaskAnalytics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_tasksCollection);

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

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'inProgressTasks': inProgressTasks,
        'notStartedTasks': notStartedTasks,
        'overdueTasks': overdueTasks,
        'completionRate': completionRate,
        'priorityStats': priorityStats,
      };
    } catch (e) {
      throw Exception('Failed to get task analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getInternAnalytics() async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'intern')
          .get();

      final interns = querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();

      final totalInterns = interns.length;
      final activeInterns = interns.where((i) => i.isActive).length;
      final completedInterns = interns
          .where((i) => i.isInternshipCompleted)
          .length;
      final ongoingInterns = interns.where((i) => i.isInternshipActive).length;

      final departmentStats = <String, int>{};
      for (final intern in interns) {
        if (intern.department != null) {
          departmentStats[intern.department!] =
              (departmentStats[intern.department!] ?? 0) + 1;
        }
      }

      final performanceStats = <String, int>{};
      for (final intern in interns) {
        performanceStats[intern.performanceStatus] =
            (performanceStats[intern.performanceStatus] ?? 0) + 1;
      }

      return {
        'totalInterns': totalInterns,
        'activeInterns': activeInterns,
        'completedInterns': completedInterns,
        'ongoingInterns': ongoingInterns,
        'departmentStats': departmentStats,
        'performanceStats': performanceStats,
      };
    } catch (e) {
      throw Exception('Failed to get intern analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getFeedbackAnalytics() async {
    try {
      final querySnapshot = await _firestore
          .collection(_feedbacksCollection)
          .get();
      final feedbacks = querySnapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();

      final totalFeedbacks = feedbacks.length;
      final averageRating = feedbacks.isEmpty
          ? 0.0
          : feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
                feedbacks.length;

      final categoryStats = <String, int>{};
      final ratingDistribution = <int, int>{};
      final statusStats = <String, int>{};

      for (final feedback in feedbacks) {
        categoryStats[feedback.category.name] =
            (categoryStats[feedback.category.name] ?? 0) + 1;

        ratingDistribution[feedback.rating] =
            (ratingDistribution[feedback.rating] ?? 0) + 1;

        statusStats[feedback.status.name] =
            (statusStats[feedback.status.name] ?? 0) + 1;
      }

      return {
        'totalFeedbacks': totalFeedbacks,
        'averageRating': averageRating,
        'categoryStats': categoryStats,
        'ratingDistribution': ratingDistribution,
        'statusStats': statusStats,
      };
    } catch (e) {
      throw Exception('Failed to get feedback analytics: $e');
    }
  }


  Future<bool> batchUpdateTasks(
    List<String> taskIds,
    Map<String, dynamic> data,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final taskId in taskIds) {
        final taskRef = _firestore.collection(_tasksCollection).doc(taskId);
        batch.update(taskRef, data);
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to batch update tasks: $e');
    }
  }

  Future<bool> batchDelete(String collection, List<String> ids) async {
    try {
      final batch = _firestore.batch();

      for (final id in ids) {
        final docRef = _firestore.collection(collection).doc(id);
        batch.delete(docRef);
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw Exception('Failed to batch delete: $e');
    }
  }


  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_tasksCollection)
          .orderBy('title')
          .get();

      final allTasks = querySnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();

      return allTasks.where((task) {
        return task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  Future<List<InternModel>> searchInterns(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: 'intern')
          .orderBy('name')
          .get();

      final allInterns = querySnapshot.docs
          .map((doc) => InternModel.fromDocument(doc))
          .toList();

      return allInterns.where((intern) {
        return intern.name.toLowerCase().contains(query.toLowerCase()) ||
            intern.email.toLowerCase().contains(query.toLowerCase()) ||
            (intern.department?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search interns: $e');
    }
  }


  void startListening(
    String key,
    Stream stream,
    Function(dynamic) onData, {
    Function(dynamic)? onError,
  }) {
    _listeners[key]?.cancel();

    _listeners[key] = stream.listen(
      onData,
      onError: onError ?? (error) => {/* Error in stream $key: $error */},
    );
  }

  void stopListening(String key) {
    _listeners[key]?.cancel();
    _listeners.remove(key);
  }

  void stopAllListeners() {
    for (final subscription in _listeners.values) {
      subscription.cancel();
    }
    _listeners.clear();
  }
}
