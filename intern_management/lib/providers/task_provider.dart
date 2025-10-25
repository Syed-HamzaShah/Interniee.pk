import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  List<TaskModel> _userTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get userTasks => _userTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTasks => _tasks.length;
  int get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).length;
  int get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get notStartedTasks =>
      _tasks.where((task) => task.status == TaskStatus.notStarted).length;
  int get overdueTasks => _tasks.where((task) => task.isOverdue).length;

  int get userTotalTasks => _userTasks.length;
  int get userCompletedTasks =>
      _userTasks.where((task) => task.status == TaskStatus.completed).length;
  int get userInProgressTasks =>
      _userTasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get userNotStartedTasks =>
      _userTasks.where((task) => task.status == TaskStatus.notStarted).length;
  int get userOverdueTasks => _userTasks.where((task) => task.isOverdue).length;

  double get userCompletionRate {
    if (userTotalTasks == 0) return 0.0;
    return (userCompletedTasks / userTotalTasks) * 100;
  }

  Future<void> loadAllTasks() async {
    _setLoading(true);
    _clearError();

    try {
      _tasks = await _taskService.getAllTasks();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load tasks: $e');
      _setLoading(false);
    }
  }

  Future<void> loadUserTasks(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _userTasks = await _taskService.getTasksByUser(userId);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load user tasks: $e');
      _setLoading(false);
    }
  }

  Stream<List<TaskModel>> getTasksStream() {
    return _taskService.getTasksStream();
  }

  Stream<List<TaskModel>> getUserTasksStream(String userId) {
    return _taskService.getUserTasksStream(userId);
  }

  void listenToTasksStream() {
    getTasksStream().listen(
      (tasks) {
        _tasks = tasks;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to listen to tasks stream: $error');
      },
    );
  }

  void listenToUserTasksStream(String userId) {
    getUserTasksStream(userId).listen(
      (tasks) {
        _userTasks = tasks;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to listen to user tasks stream: $error');
      },
    );
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String assignedTo,
    required String assignedBy,
    required DateTime deadline,
    required TaskPriority priority,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final task = await _taskService.createTask(
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedBy: assignedBy,
        deadline: deadline,
        priority: priority,
        notes: notes,
      );

      if (task != null) {
        _tasks.add(task);
        if (assignedTo == _getCurrentUserId()) {
          _userTasks.add(task);
        }
        notifyListeners();
        _setLoading(false);
        return true;
      }

      _setError('Failed to create task');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to create task: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _taskService.updateTaskStatus(taskId, status);

      if (success) {
        _updateTaskInList(_tasks, taskId, status);
        _updateTaskInList(_userTasks, taskId, status);
        notifyListeners();
        _setLoading(false);
        return true;
      }

      _setError('Failed to update task status');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update task status: $e');
      _setLoading(false);
      return false;
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
    _setLoading(true);
    _clearError();

    try {
      final success = await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        deadline: deadline,
        priority: priority,
        notes: notes,
      );

      if (success) {
        await loadAllTasks();
        _setLoading(false);
        return true;
      }

      _setError('Failed to update task');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update task: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _taskService.deleteTask(taskId);

      if (success) {
        _tasks.removeWhere((task) => task.id == taskId);
        _userTasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
        _setLoading(false);
        return true;
      }

      _setError('Failed to delete task');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to delete task: $e');
      _setLoading(false);
      return false;
    }
  }

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<TaskModel> getUserTasksByStatus(TaskStatus status) {
    return _userTasks.where((task) => task.status == status).toList();
  }

  List<TaskModel> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<TaskModel> getUserOverdueTasks() {
    return _userTasks.where((task) => task.isOverdue).toList();
  }

  List<TaskModel> getTasksDueSoon() {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));

    return _tasks.where((task) {
      return task.status != TaskStatus.completed &&
          task.deadline.isAfter(now) &&
          task.deadline.isBefore(threeDaysFromNow);
    }).toList();
  }

  List<TaskModel> getUserTasksDueSoon() {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));

    return _userTasks.where((task) {
      return task.status != TaskStatus.completed &&
          task.deadline.isAfter(now) &&
          task.deadline.isBefore(threeDaysFromNow);
    }).toList();
  }

  Future<void> refreshTasks() async {
    await loadAllTasks();
  }

  Future<void> refreshUserTasks(String userId) async {
    await loadUserTasks(userId);
  }

  void _updateTaskInList(
    List<TaskModel> taskList,
    String taskId,
    TaskStatus status,
  ) {
    final index = taskList.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      taskList[index] = taskList[index].copyWith(
        status: status,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
      );
    }
  }

  String? _getCurrentUserId() {
    return null;
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

  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<TaskModel> getUserTasksByPriority(TaskPriority priority) {
    return _userTasks.where((task) => task.priority == priority).toList();
  }

  List<TaskModel> getTasksAssignedBy(String adminId) {
    return _tasks.where((task) => task.assignedBy == adminId).toList();
  }

  List<TaskModel> getTasksByDateRange(DateTime startDate, DateTime endDate) {
    return _tasks.where((task) {
      return task.createdAt.isAfter(startDate) &&
          task.createdAt.isBefore(endDate);
    }).toList();
  }

  List<TaskModel> getUserTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _userTasks.where((task) {
      return task.createdAt.isAfter(startDate) &&
          task.createdAt.isBefore(endDate);
    }).toList();
  }

  List<TaskModel> get recentTasks {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _tasks.where((task) => task.createdAt.isAfter(weekAgo)).toList();
  }

  List<TaskModel> get userRecentTasks {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _userTasks.where((task) => task.createdAt.isAfter(weekAgo)).toList();
  }

  List<TaskModel> get highPriorityTasks {
    return _tasks
        .where(
          (task) =>
              task.priority == TaskPriority.high ||
              task.priority == TaskPriority.urgent,
        )
        .toList();
  }

  List<TaskModel> get userHighPriorityTasks {
    return _userTasks
        .where(
          (task) =>
              task.priority == TaskPriority.high ||
              task.priority == TaskPriority.urgent,
        )
        .toList();
  }

  Map<String, dynamic> get taskAnalytics {
    final total = _tasks.length;
    final completed = completedTasks;
    final inProgress = inProgressTasks;
    final notStarted = notStartedTasks;
    final overdue = overdueTasks;
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    final priorityStats = <String, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority.name] = _tasks
          .where((t) => t.priority == priority)
          .length;
    }

    return {
      'total': total,
      'completed': completed,
      'inProgress': inProgress,
      'notStarted': notStarted,
      'overdue': overdue,
      'completionRate': completionRate,
      'priorityStats': priorityStats,
    };
  }

  Map<String, dynamic> get userTaskAnalytics {
    final total = _userTasks.length;
    final completed = userCompletedTasks;
    final inProgress = userInProgressTasks;
    final notStarted = userNotStartedTasks;
    final overdue = userOverdueTasks;
    final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

    final priorityStats = <String, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority.name] = _userTasks
          .where((t) => t.priority == priority)
          .length;
    }

    return {
      'total': total,
      'completed': completed,
      'inProgress': inProgress,
      'notStarted': notStarted,
      'overdue': overdue,
      'completionRate': completionRate,
      'priorityStats': priorityStats,
    };
  }

  List<TaskModel> searchTasks(String query) {
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<TaskModel> searchUserTasks(String query) {
    return _userTasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
