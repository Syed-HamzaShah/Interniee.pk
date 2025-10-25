import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/intern_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class RealtimeSyncService with ChangeNotifier {
  static final RealtimeSyncService _instance = RealtimeSyncService._internal();
  factory RealtimeSyncService() => _instance;
  RealtimeSyncService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final Map<String, StreamSubscription> _subscriptions = {};

  List<TaskModel> _tasks = [];
  List<InternModel> _interns = [];
  List<FeedbackModel> _feedbacks = [];
  List<UserModel> _users = [];

  bool _isLoading = false;
  String? _errorMessage;

  bool _isConnected = true;
  DateTime? _lastSyncTime;

  List<TaskModel> get tasks => _tasks;
  List<InternModel> get interns => _interns;
  List<FeedbackModel> get feedbacks => _feedbacks;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _isConnected;
  DateTime? get lastSyncTime => _lastSyncTime;


  Future<void> initializeSync() async {
    _setLoading(true);
    _clearError();

    try {
      await _startTasksSync();
      await _startInternsSync();
      await _startFeedbacksSync();
      await _startUsersSync();

      _lastSyncTime = DateTime.now();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize sync: $e');
      _setLoading(false);
    }
  }

  Future<void> initializeUserSync(String userId, UserRole role) async {
    _setLoading(true);
    _clearError();

    try {
      if (role == UserRole.admin) {
        await initializeSync();
      } else {
        await _startUserTasksSync(userId);
        await _startUserFeedbacksSync(userId);
      }

      _lastSyncTime = DateTime.now();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize user sync: $e');
      _setLoading(false);
    }
  }


  Future<void> _startTasksSync() async {
    _subscriptions['tasks'] = _databaseService.getTasksStream().listen(
      (tasks) {
        _tasks = tasks;
        _updateLastSyncTime();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to sync tasks: $error');
        _setConnectionStatus(false);
      },
    );
  }

  Future<void> _startUserTasksSync(String userId) async {
    _subscriptions['userTasks'] = _databaseService
        .getUserTasksStream(userId)
        .listen(
          (tasks) {
            _tasks = tasks;
            _updateLastSyncTime();
            notifyListeners();
          },
          onError: (error) {
            _setError('Failed to sync user tasks: $error');
            _setConnectionStatus(false);
          },
        );
  }


  Future<void> _startInternsSync() async {
    _subscriptions['interns'] = _databaseService.getInternsStream().listen(
      (interns) {
        _interns = interns;
        _updateLastSyncTime();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to sync interns: $error');
        _setConnectionStatus(false);
      },
    );
  }


  Future<void> _startFeedbacksSync() async {
    _subscriptions['feedbacks'] = _databaseService.getFeedbacksStream().listen(
      (feedbacks) {
        _feedbacks = feedbacks;
        _updateLastSyncTime();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to sync feedbacks: $error');
        _setConnectionStatus(false);
      },
    );
  }

  Future<void> _startUserFeedbacksSync(String userId) async {
    _subscriptions['userFeedbacks'] = _databaseService
        .getUserFeedbacksStream(userId)
        .listen(
          (feedbacks) {
            _feedbacks = feedbacks;
            _updateLastSyncTime();
            notifyListeners();
          },
          onError: (error) {
            _setError('Failed to sync user feedbacks: $error');
            _setConnectionStatus(false);
          },
        );
  }


  Future<void> _startUsersSync() async {
    _subscriptions['users'] = _databaseService.getUsersStream().listen(
      (users) {
        _users = users;
        _updateLastSyncTime();
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to sync users: $error');
        _setConnectionStatus(false);
      },
    );
  }


  Stream<List<TaskModel>> getTasksByStatusStream(TaskStatus status) {
    return _databaseService.getTasksByStatusStream(status);
  }

  Stream<List<TaskModel>> getTasksByPriorityStream(TaskPriority priority) {
    return _databaseService.getTasksByPriorityStream(priority);
  }

  Stream<List<InternModel>> getActiveInternsStream() {
    return _databaseService.getActiveInternsStream();
  }

  Stream<List<InternModel>> getInternsByDepartmentStream(String department) {
    return _databaseService.getInternsByDepartmentStream(department);
  }

  Stream<List<FeedbackModel>> getFeedbacksByStatusStream(
    FeedbackStatus status,
  ) {
    return _databaseService.getFeedbacksByStatusStream(status);
  }


  Future<bool> createTask(TaskModel task) async {
    try {
      final createdTask = await _databaseService.createTask(task);
      if (createdTask != null) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to create task: $e');
      return false;
    }
  }

  Future<bool> updateTask(String taskId, Map<String, dynamic> data) async {
    try {
      final success = await _databaseService.updateTask(taskId, data);
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final success = await _databaseService.deleteTask(taskId);
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete task: $e');
      return false;
    }
  }

  Future<bool> createFeedback(FeedbackModel feedback) async {
    try {
      final createdFeedback = await _databaseService.createFeedback(feedback);
      if (createdFeedback != null) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to create feedback: $e');
      return false;
    }
  }

  Future<bool> updateFeedback(
    String feedbackId,
    Map<String, dynamic> data,
  ) async {
    try {
      final success = await _databaseService.updateFeedback(feedbackId, data);
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update feedback: $e');
      return false;
    }
  }

  Future<bool> updateInternProfile(
    String internId,
    Map<String, dynamic> data,
  ) async {
    try {
      final success = await _databaseService.updateInternProfile(
        internId,
        data,
      );
      if (success) {
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update intern profile: $e');
      return false;
    }
  }


  Future<Map<String, dynamic>?> getTaskAnalytics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _databaseService.getTaskAnalytics(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('Failed to get task analytics: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInternAnalytics() async {
    try {
      return await _databaseService.getInternAnalytics();
    } catch (e) {
      _setError('Failed to get intern analytics: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFeedbackAnalytics() async {
    try {
      return await _databaseService.getFeedbackAnalytics();
    } catch (e) {
      _setError('Failed to get feedback analytics: $e');
      return null;
    }
  }


  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      return await _databaseService.searchTasks(query);
    } catch (e) {
      _setError('Failed to search tasks: $e');
      return [];
    }
  }

  Future<List<InternModel>> searchInterns(String query) async {
    try {
      return await _databaseService.searchInterns(query);
    } catch (e) {
      _setError('Failed to search interns: $e');
      return [];
    }
  }


  Future<bool> batchUpdateTasks(
    List<String> taskIds,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _databaseService.batchUpdateTasks(taskIds, data);
    } catch (e) {
      _setError('Failed to batch update tasks: $e');
      return false;
    }
  }

  Future<bool> batchDelete(String collection, List<String> ids) async {
    try {
      return await _databaseService.batchDelete(collection, ids);
    } catch (e) {
      _setError('Failed to batch delete: $e');
      return false;
    }
  }


  Future<void> checkConnection() async {
    try {
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      _setConnectionStatus(true);
    } catch (e) {
      _setConnectionStatus(false);
    }
  }

  Future<void> retryConnection() async {
    await checkConnection();
    if (_isConnected) {
      await initializeSync();
    }
  }


  List<TaskModel> getFilteredTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
    String? assignedBy,
  }) {
    return _tasks.where((task) {
      if (status != null && task.status != status) return false;
      if (priority != null && task.priority != priority) return false;
      if (assignedTo != null && task.assignedTo != assignedTo) return false;
      if (assignedBy != null && task.assignedBy != assignedBy) return false;
      return true;
    }).toList();
  }

  List<InternModel> getFilteredInterns({
    String? department,
    String? university,
    bool? isActive,
    String? performanceStatus,
  }) {
    return _interns.where((intern) {
      if (department != null && intern.department != department) return false;
      if (university != null && intern.university != university) return false;
      if (isActive != null && intern.isActive != isActive) return false;
      if (performanceStatus != null &&
          intern.performanceStatus != performanceStatus)
        return false;
      return true;
    }).toList();
  }

  List<FeedbackModel> getFilteredFeedbacks({
    FeedbackStatus? status,
    FeedbackCategory? category,
    int? rating,
    String? userId,
  }) {
    return _feedbacks.where((feedback) {
      if (status != null && feedback.status != status) return false;
      if (category != null && feedback.category != category) return false;
      if (rating != null && feedback.rating != rating) return false;
      if (userId != null && feedback.userId != userId) return false;
      return true;
    }).toList();
  }


  @override
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _databaseService.dispose();
    super.dispose();
  }


  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setConnectionStatus(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  void _updateLastSyncTime() {
    _lastSyncTime = DateTime.now();
  }
}
