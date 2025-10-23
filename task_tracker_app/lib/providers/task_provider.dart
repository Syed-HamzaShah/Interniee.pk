import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  String? _currentUserId;
  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? get currentUserId => _currentUserId;
  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTasks => _allTasks.length;
  int get completedTasks =>
      _allTasks.where((task) => task.status == TaskStatus.completed).length;
  int get pendingTasks =>
      _allTasks.where((task) => task.status == TaskStatus.pending).length;
  int get inProgressTasks =>
      _allTasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get overdueTasks => _allTasks.where((task) => task.isOverdue).length;

  void setUserId(String userId) {
    _currentUserId = userId;
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _clearError();

    try {
      final tasks = await _taskService.getUserTasks(_currentUserId!).first;
      _allTasks = tasks;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load tasks: $e');
      _setLoading(false);
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }

  Stream<List<TaskModel>> getTasksByStatus(TaskStatus status) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _taskService.getTasksByStatus(_currentUserId!, status);
  }

  Stream<List<TaskModel>> getTasksByPriority(TaskPriority priority) {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _taskService.getTasksByPriority(_currentUserId!, priority);
  }

  Stream<List<TaskModel>> getOverdueTasks() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }
    return _taskService.getOverdueTasks(_currentUserId!);
  }

  Future<void> completeTask(String taskId, {String? completedNotes}) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.completeTask(taskId, completedNotes: completedNotes);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to complete task: $e');
      _setLoading(false);
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      await _taskService.updateTaskStatus(taskId, status);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update task status: $e');
      _setLoading(false);
    }
  }

  Stream<List<TaskModel>> searchTasks(String query) {
    if (_currentUserId == null || query.isEmpty) {
      return Stream.value([]);
    }
    return _taskService.searchTasks(_currentUserId!, query);
  }

  Future<Map<String, int>> getTaskStats() async {
    if (_currentUserId == null) {
      return {
        'total': 0,
        'pending': 0,
        'inProgress': 0,
        'completed': 0,
        'overdue': 0,
      };
    }

    try {
      return await _taskService.getUserTaskStats(_currentUserId!);
    } catch (e) {
      _setError('Failed to get task statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'inProgress': 0,
        'completed': 0,
        'overdue': 0,
      };
    }
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
