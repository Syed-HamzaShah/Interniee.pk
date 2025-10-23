import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';

class AdminProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  final ProgressService _progressService = ProgressService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<TaskModel>> getAllTasks() {
    return _taskService.getAllTasks();
  }

  Stream<List<TaskModel>> getRecentTasks() {
    return _taskService.getAllTasks().map((tasks) => tasks.take(10).toList());
  }

  Stream<List<UserModel>> getAllUsers() {
    return _authService.getAllUsers();
  }

  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _authService.getUsersByRole(role);
  }

  Stream<Map<String, int>> getOverallStats() {
    return getAllTasks().asyncMap((tasks) async {
      final users = await getAllUsers().first;

      final totalTasks = tasks.length;
      final completedTasks = tasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final pendingTasks = tasks
          .where((task) => task.status == TaskStatus.pending)
          .length;
      final overdueTasks = tasks.where((task) => task.isOverdue).length;
      final totalUsers = users.length;

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'pendingTasks': pendingTasks,
        'overdueTasks': overdueTasks,
        'totalUsers': totalUsers,
      };
    });
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String assignedToId,
    required String assignedByName,
    required DateTime dueDate,
    required TaskPriority priority,
    List<String> tags = const [],
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final task = TaskModel(
        id: '', // Will be set by the service
        title: title,
        description: description,
        assignedToId: assignedToId,
        assignedByName: assignedByName,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        status: TaskStatus.pending,
        priority: priority,
        tags: tags,
        notes: notes,
      );

      await _taskService.createTask(task);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to create task: $e');
      _setLoading(false);
    }
  }

  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    String? assignedToId,
    String? assignedByName,
    DateTime? dueDate,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (assignedToId != null) updates['assignedToId'] = assignedToId;
      if (assignedByName != null) updates['assignedByName'] = assignedByName;
      if (dueDate != null) updates['dueDate'] = dueDate;
      if (status != null) updates['status'] = status.name;
      if (priority != null) updates['priority'] = priority.name;
      if (tags != null) updates['tags'] = tags;
      if (notes != null) updates['notes'] = notes;

      await _taskService.updateTask(taskId, updates);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update task: $e');
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.deleteTask(taskId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to delete task: $e');
      _setLoading(false);
    }
  }

  Future<void> assignTask(
    String taskId,
    String assignedToId,
    String assignedByName,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.assignTask(taskId, assignedToId, assignedByName);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to assign task: $e');
      _setLoading(false);
    }
  }

  Stream<List<TaskModel>> getUserTasks(String userId) {
    return _taskService.getUserTasks(userId);
  }

  Future<Map<String, int>> getUserTaskStats(String userId) async {
    try {
      return await _taskService.getUserTaskStats(userId);
    } catch (e) {
      _setError('Failed to get user task statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'inProgress': 0,
        'completed': 0,
        'overdue': 0,
      };
    }
  }

  Stream<List<ProgressModel>> getUserProgressForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _progressService.getProgressForDateRange(userId, startDate, endDate);
  }

  Future<Map<String, dynamic>> getUserWeeklyProgressSummary(
    String userId,
  ) async {
    try {
      return await _progressService.getWeeklyProgressSummary(userId);
    } catch (e) {
      _setError('Failed to get weekly progress summary: $e');
      return {
        'averageCompletionRate': 0.0,
        'totalTasks': 0,
        'completedTasks': 0,
        'performanceGrade': 'N/A',
        'daysActive': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getUserMonthlyProgressSummary(
    String userId,
  ) async {
    try {
      return await _progressService.getMonthlyProgressSummary(userId);
    } catch (e) {
      _setError('Failed to get monthly progress summary: $e');
      return {
        'averageCompletionRate': 0.0,
        'totalTasks': 0,
        'completedTasks': 0,
        'performanceGrade': 'N/A',
        'daysActive': 0,
      };
    }
  }

  Future<void> updateUserProgress(String userId) async {
    try {
      await _progressService.updateDailyProgress(userId);
    } catch (e) {
      _setError('Failed to update user progress: $e');
    }
  }

  Future<void> refreshData() async {
    _setLoading(true);
    _clearError();

    try {
      _setLoading(false);
    } catch (e) {
      _setError('Failed to refresh data: $e');
      _setLoading(false);
    }
  }

  Stream<List<TaskModel>> searchTasks(String query) {
    return getAllTasks().map(
      (tasks) => tasks
          .where(
            (task) =>
                task.title.toLowerCase().contains(query.toLowerCase()) ||
                task.description.toLowerCase().contains(query.toLowerCase()) ||
                task.assignedByName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList(),
    );
  }

  Stream<List<UserModel>> searchUsers(String query) {
    return getAllUsers().map(
      (users) => users
          .where(
            (user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList(),
    );
  }

  Stream<List<TaskModel>> getAllOverdueTasks() {
    return getAllTasks().map(
      (tasks) => tasks.where((task) => task.isOverdue).toList(),
    );
  }

  Stream<List<TaskModel>> getAllTasksByPriority(TaskPriority priority) {
    return getAllTasks().map(
      (tasks) => tasks.where((task) => task.priority == priority).toList(),
    );
  }

  Stream<List<TaskModel>> getAllTasksByStatus(TaskStatus status) {
    return getAllTasks().map(
      (tasks) => tasks.where((task) => task.status == status).toList(),
    );
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

  void clearError() {
    _clearError();
  }
}
