import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/intern_provider.dart';
import '../../models/task_model.dart';
import '../../models/intern_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shimmer_widget.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';
import 'task_details_screen.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Tasks', 'By Status', 'By Intern', 'Overdue'];

  String _searchQuery = '';
  TaskStatus? _statusFilter;
  String? _internFilter;
  TaskPriority? _priorityFilter;
  bool _showOverdueOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
      Provider.of<InternProvider>(context, listen: false).loadInterns();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        toolbarHeight: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTasksTab(),
                _buildStatusTab(),
                _buildInternTab(),
                _buildOverdueTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTask(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Task'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.darkCard,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_statusFilter != null)
            _buildFilterChip(
              label: 'Status: ${_statusFilter!.name}',
              onDeleted: () => setState(() => _statusFilter = null),
            ),
          if (_internFilter != null)
            _buildFilterChip(
              label: 'Intern: ${_getInternName(_internFilter!)}',
              onDeleted: () => setState(() => _internFilter = null),
            ),
          if (_priorityFilter != null)
            _buildFilterChip(
              label: 'Priority: ${_priorityFilter!.name}',
              onDeleted: () => setState(() => _priorityFilter = null),
            ),
          if (_showOverdueOnly)
            _buildFilterChip(
              label: 'Overdue Only',
              onDeleted: () => setState(() => _showOverdueOnly = false),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
        labelStyle: const TextStyle(color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildAllTasksTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const ShimmerWidget(child: ShimmerTaskCard(), isLoading: true);
        }

        final filteredTasks = _getFilteredTasks(taskProvider.tasks);

        if (filteredTasks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => taskProvider.loadAllTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _buildTaskCard(task);
            },
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildStatusTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const ShimmerWidget(child: ShimmerTaskCard(), isLoading: true);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: TaskStatus.values.map((status) {
              final tasks = taskProvider.getTasksByStatus(status);
              return _buildStatusSection(status, tasks);
            }).toList(),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildInternTab() {
    return Consumer2<TaskProvider, InternProvider>(
      builder: (context, taskProvider, internProvider, child) {
        if (taskProvider.isLoading || internProvider.isLoading) {
          return const ShimmerWidget(child: ShimmerTaskCard(), isLoading: true);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: internProvider.interns.length,
          itemBuilder: (context, index) {
            final intern = internProvider.interns[index];
            final internTasks = taskProvider.tasks
                .where((task) => task.assignedTo == intern.id)
                .toList();

            return _buildInternTaskSection(intern, internTasks);
          },
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildOverdueTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const ShimmerWidget(child: ShimmerTaskCard(), isLoading: true);
        }

        final overdueTasks = taskProvider.getOverdueTasks();

        if (overdueTasks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.check_circle,
            title: 'No Overdue Tasks',
            subtitle: 'All tasks are up to date!',
          );
        }

        return RefreshIndicator(
          onRefresh: () => taskProvider.loadAllTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: overdueTasks.length,
            itemBuilder: (context, index) {
              final task = overdueTasks[index];
              return _buildTaskCard(task, isOverdue: true);
            },
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildTaskCard(TaskModel task, {bool isOverdue = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.darkCard,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTaskStatusColor(task.status),
          child: Icon(
            _getTaskStatusIcon(task.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    task.priorityDisplayName,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getPriorityColor(
                    task.priority,
                  ).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getPriorityColor(task.priority),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    task.statusDisplayName,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getTaskStatusColor(
                    task.status,
                  ).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getTaskStatusColor(task.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              task.formattedDeadline,
              style: TextStyle(
                color: isOverdue
                    ? AppTheme.statusOverdue
                    : AppTheme.textSecondary,
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleTaskAction(value, task),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppTheme.primaryGreen),
                  SizedBox(width: 8),
                  Text('Edit Task'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.statusOverdue),
                  SizedBox(width: 8),
                  Text('Delete Task'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToTaskDetails(task),
      ),
    );
  }

  Widget _buildStatusSection(TaskStatus status, List<TaskModel> tasks) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.darkCard,
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getTaskStatusColor(status),
              radius: 12,
              child: Icon(
                _getTaskStatusIcon(status),
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${status.name.toUpperCase()} (${tasks.length})',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: tasks.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tasks in this status',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ]
            : tasks.map((task) => _buildTaskCard(task)).toList(),
      ),
    );
  }

  Widget _buildInternTaskSection(InternModel intern, List<TaskModel> tasks) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.darkCard,
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: intern.profileImageUrl != null
                  ? NetworkImage(intern.profileImageUrl!)
                  : null,
              child: intern.profileImageUrl == null
                  ? Text(intern.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    intern.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${tasks.length} tasks assigned',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: tasks.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tasks assigned to this intern',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ]
            : tasks.map((task) => _buildTaskCard(task)).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    IconData icon = Icons.assignment,
    String title = 'No Tasks Found',
    String subtitle = 'Create your first task to get started',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateTask,
            icon: const Icon(Icons.add),
            label: const Text('Create Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    return tasks.where((task) {
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            task.title.toLowerCase().contains(_searchQuery) ||
            task.description.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      if (_statusFilter != null && task.status != _statusFilter) {
        return false;
      }

      if (_internFilter != null && task.assignedTo != _internFilter) {
        return false;
      }

      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }

      if (_showOverdueOnly && !task.isOverdue) {
        return false;
      }

      return true;
    }).toList();
  }

  String _getInternName(String internId) {
    final internProvider = Provider.of<InternProvider>(context, listen: false);
    final intern = internProvider.interns.firstWhere(
      (intern) => intern.id == internId,
      orElse: () => InternModel(
        id: internId,
        name: 'Unknown',
        email: '',
        department: '',
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        profileImageUrl: null,
      ),
    );
    return intern.name;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TaskStatus?>(
              initialValue: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...TaskStatus.values.map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status.name)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<TaskPriority?>(
              initialValue: _priorityFilter,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...TaskPriority.values.map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _priorityFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),

            CheckboxListTile(
              title: const Text('Show overdue only'),
              value: _showOverdueOnly,
              onChanged: (value) {
                setState(() {
                  _showOverdueOnly = value ?? false;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _statusFilter = null;
                _priorityFilter = null;
                _showOverdueOnly = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTaskAction(String action, TaskModel task) {
    switch (action) {
      case 'view':
        _navigateToTaskDetails(task);
        break;
      case 'edit':
        _navigateToEditTask(task);
        break;
      case 'delete':
        _showDeleteConfirmation(task);
        break;
    }
  }

  void _navigateToCreateTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );
  }

  void _navigateToEditTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );
  }

  void _navigateToTaskDetails(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
  }

  void _showDeleteConfirmation(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<TaskProvider>(
                context,
                listen: false,
              ).deleteTask(task.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted successfully'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.statusOverdue),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return AppTheme.statusNotStarted;
      case TaskStatus.inProgress:
        return AppTheme.statusInProgress;
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
      case TaskStatus.overdue:
        return AppTheme.statusOverdue;
    }
  }

  IconData _getTaskStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.radio_button_checked;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.overdue:
        return Icons.warning;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.priorityLow;
      case TaskPriority.medium:
        return AppTheme.priorityMedium;
      case TaskPriority.high:
        return AppTheme.priorityHigh;
      case TaskPriority.urgent:
        return AppTheme.priorityUrgent;
    }
  }
}
