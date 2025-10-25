import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intern_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/intern_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';
import 'create_task_screen.dart';
import 'intern_details_screen.dart';

class InternManagementScreen extends StatefulWidget {
  const InternManagementScreen({super.key});

  @override
  State<InternManagementScreen> createState() => _InternManagementScreenState();
}

class _InternManagementScreenState extends State<InternManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Interns', 'Performance', 'Task Assignment'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
        title: const Text('Intern Management'),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<InternProvider>(context, listen: false).loadInterns();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllInternsTab(),
          _buildPerformanceTab(),
          _buildTaskAssignmentTab(),
        ],
      ),
    );
  }

  Widget _buildAllInternsTab() {
    return Consumer<InternProvider>(
      builder: (context, internProvider, child) {
        if (internProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null) {
          return _buildErrorWidget(internProvider.errorMessage!);
        }

        if (internProvider.interns.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: internProvider.interns.length,
          itemBuilder: (context, index) {
            final intern = internProvider.interns[index];
            return _buildInternCard(intern);
          },
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return Consumer<InternProvider>(
      builder: (context, internProvider, child) {
        if (internProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null) {
          return _buildErrorWidget(internProvider.errorMessage!);
        }

        if (internProvider.interns.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: internProvider.interns.length,
          itemBuilder: (context, index) {
            final intern = internProvider.interns[index];
            return _buildPerformanceCard(intern);
          },
        );
      },
    );
  }

  Widget _buildTaskAssignmentTab() {
    return Consumer2<InternProvider, TaskProvider>(
      builder: (context, internProvider, taskProvider, child) {
        if (internProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null) {
          return _buildErrorWidget(internProvider.errorMessage!);
        }

        if (internProvider.interns.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: internProvider.interns.length,
          itemBuilder: (context, index) {
            final intern = internProvider.interns[index];
            return _buildTaskAssignmentCard(intern);
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading interns...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.statusOverdue),
            const SizedBox(height: 16),
            Text(
              'Error loading interns',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.statusOverdue),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Provider.of<InternProvider>(
                  context,
                  listen: false,
                ).loadInterns();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No interns found',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textDisabled),
            ),
            const SizedBox(height: 8),
            Text(
              'No interns have been registered yet.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternCard(InternModel intern) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
          child: Text(
            intern.name.isNotEmpty ? intern.name[0].toUpperCase() : 'I',
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          intern.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              intern.email,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Joined: ${_formatDate(intern.createdAt)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textDisabled),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            _handleInternAction(value, intern);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('View Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'assign_task',
              child: Row(
                children: [
                  Icon(Icons.assignment, size: 20),
                  SizedBox(width: 8),
                  Text('Assign Task'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'view_tasks',
              child: Row(
                children: [
                  Icon(Icons.list, size: 20),
                  SizedBox(width: 8),
                  Text('View Tasks'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showInternDetails(intern),
      ),
    );
  }

  Widget _buildPerformanceCard(InternModel intern) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final internTasks = taskProvider.tasks
            .where((task) => task.assignedTo == intern.id)
            .toList();
        final stats = _calculateInternStats(intern, internTasks);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _navigateToInternDetails(intern),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                        child: Text(
                          intern.name.isNotEmpty
                              ? intern.name[0].toUpperCase()
                              : 'I',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              intern.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              intern.email,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPerformanceColor(
                            stats.completionRate,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPerformanceStatus(stats.completionRate),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _getPerformanceColor(
                                  stats.completionRate,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Tasks Assigned',
                          stats.totalTasks.toString(),
                          Icons.assignment,
                          AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Completed',
                          stats.completedTasks.toString(),
                          Icons.check_circle,
                          AppTheme.statusCompleted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPerformanceMetric(
                          'In Progress',
                          stats.inProgressTasks.toString(),
                          Icons.hourglass_empty,
                          AppTheme.statusInProgress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPerformanceMetric(
                          'Overdue',
                          stats.overdueTasks.toString(),
                          Icons.warning,
                          AppTheme.statusOverdue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: stats.completionRate / 100,
                    backgroundColor: AppTheme.textDisabled.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPerformanceColor(stats.completionRate),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completion Rate: ${stats.completionRate.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'Avg. Rating: ${intern.averageRating.toStringAsFixed(1)}/5',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskAssignmentCard(InternModel intern) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final internTasks = taskProvider.tasks
            .where((task) => task.assignedTo == intern.id)
            .toList();
        final recentTasks = internTasks.take(3).toList();
        final stats = _calculateInternStats(intern, internTasks);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                      child: Text(
                        intern.name.isNotEmpty
                            ? intern.name[0].toUpperCase()
                            : 'I',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            intern.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            intern.email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _assignTaskToIntern(intern),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Assign Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTaskStatItem(
                        'Total',
                        stats.totalTasks.toString(),
                        AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTaskStatItem(
                        'Completed',
                        stats.completedTasks.toString(),
                        AppTheme.statusCompleted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTaskStatItem(
                        'In Progress',
                        stats.inProgressTasks.toString(),
                        AppTheme.statusInProgress,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTaskStatItem(
                        'Overdue',
                        stats.overdueTasks.toString(),
                        AppTheme.statusOverdue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Recent Tasks:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (recentTasks.isEmpty)
                  Text(
                    'No tasks assigned yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textDisabled,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...recentTasks.map((task) => _buildRecentTaskItem(task)),
                if (internTasks.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: () => _viewInternTasks(intern),
                      child: Text(
                        'View all ${internTasks.length} tasks',
                        style: TextStyle(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleInternAction(String action, InternModel intern) {
    switch (action) {
      case 'view_profile':
        _showInternDetails(intern);
        break;
      case 'assign_task':
        _assignTaskToIntern(intern);
        break;
      case 'view_tasks':
        _viewInternTasks(intern);
        break;
    }
  }

  void _showInternDetails(InternModel intern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(intern.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email', intern.email),
              _buildDetailRow('Role', 'INTERN'),
              _buildDetailRow('Joined', _formatDate(intern.createdAt)),
              if (intern.profileImageUrl != null)
                _buildDetailRow('Profile Image', intern.profileImageUrl!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _assignTaskToIntern(intern);
            },
            child: const Text('Assign Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _assignTaskToIntern(InternModel intern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(preSelectedInternId: intern.id),
      ),
    );
  }

  void _viewInternTasks(InternModel intern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternDetailsScreen(intern: intern),
      ),
    );
  }

  void _navigateToInternDetails(InternModel intern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternDetailsScreen(intern: intern),
      ),
    );
  }

  InternStats _calculateInternStats(InternModel intern, List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final inProgressTasks = tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100
        : 0.0;

    return InternStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
    );
  }

  Color _getPerformanceColor(double completionRate) {
    if (completionRate >= 90) return AppTheme.statusCompleted;
    if (completionRate >= 70) return AppTheme.primaryGreen;
    if (completionRate >= 50) return AppTheme.statusInProgress;
    return AppTheme.statusOverdue;
  }

  String _getPerformanceStatus(double completionRate) {
    if (completionRate >= 90) return 'Excellent';
    if (completionRate >= 70) return 'Good';
    if (completionRate >= 50) return 'Average';
    return 'Needs Improvement';
  }

  Widget _buildTaskStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTaskItem(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getTaskStatusColor(task.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _getTaskStatusText(task.status),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getTaskStatusColor(task.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return AppTheme.statusCompleted;
      case TaskStatus.inProgress:
        return AppTheme.statusInProgress;
      case TaskStatus.notStarted:
        return AppTheme.statusPending;
      case TaskStatus.overdue:
        return AppTheme.statusOverdue;
    }
  }

  String _getTaskStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }
}

class InternStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final double completionRate;

  InternStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.completionRate,
  });
}
