import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../utils/app_theme.dart';
import 'task_details_screen.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Not Started', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      if (authProvider.userModel != null) {
        taskProvider.loadUserTasks(authProvider.userModel!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Column(
        children: [
          _buildModernAppBar(context, taskProvider, authProvider),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTasksList(taskProvider, authProvider, null),
                _buildTasksList(
                  taskProvider,
                  authProvider,
                  TaskStatus.notStarted,
                ),
                _buildTasksList(
                  taskProvider,
                  authProvider,
                  TaskStatus.inProgress,
                ),
                _buildTasksList(
                  taskProvider,
                  authProvider,
                  TaskStatus.completed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(
    BuildContext context,
    TaskProvider taskProvider,
    AuthProvider authProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.darkSurface,
            AppTheme.darkCard,
            AppTheme.darkSurface.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTaskStatistics(taskProvider, authProvider)],
            ),
          ),
          _buildModernTabBar(),
        ],
      ),
    );
  }

  Widget _buildTaskStatsBadge(
    TaskProvider taskProvider,
    AuthProvider authProvider,
  ) {
    return StreamBuilder<List<TaskModel>>(
      stream: taskProvider.getUserTasksStream(authProvider.userModel?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final tasks = snapshot.data ?? [];
          final completedTasks = tasks
              .where((task) => task.status == TaskStatus.completed)
              .length;
          final totalTasks = tasks.length;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedTasks/$totalTasks',
                  style: AppTheme.getLabelStyle(
                    fontSize: 12,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTaskStatistics(
    TaskProvider taskProvider,
    AuthProvider authProvider,
  ) {
    return StreamBuilder<List<TaskModel>>(
      stream: taskProvider.getUserTasksStream(authProvider.userModel?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final tasks = snapshot.data ?? [];
          final notStarted = tasks
              .where((task) => task.status == TaskStatus.notStarted)
              .length;
          final inProgress = tasks
              .where((task) => task.status == TaskStatus.inProgress)
              .length;
          final completed = tasks
              .where((task) => task.status == TaskStatus.completed)
              .length;

          return Row(
            children: [
              _buildStatCard(
                'Not Started',
                notStarted,
                Icons.play_circle_outline,
                AppTheme.statusPending,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'In Progress',
                inProgress,
                Icons.hourglass_empty,
                AppTheme.statusInProgress,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                'Completed',
                completed,
                Icons.check_circle,
                AppTheme.statusCompleted,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count.toString(),
                    style: AppTheme.getHeadingStyle(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTheme.getCaptionStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: [
          _buildTab('All', Icons.list_alt_rounded, 0),
          _buildTab('Not Started', Icons.play_circle_outline, 1),
          _buildTab('In Progress', Icons.hourglass_empty, 2),
          _buildTab('Completed', Icons.check_circle, 3),
        ],
        labelColor: AppTheme.textPrimary,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: AppTheme.getLabelStyle(fontSize: 12),
        unselectedLabelStyle: AppTheme.getLabelStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(
    TaskProvider taskProvider,
    AuthProvider authProvider,
    TaskStatus? status,
  ) {
    return StreamBuilder<List<TaskModel>>(
      stream: taskProvider.getUserTasksStream(authProvider.userModel?.id ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                isLoading: true,
                child: const ShimmerTaskCard(),
              );
            },
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.statusOverdue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading tasks',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => taskProvider.refreshUserTasks(
                    authProvider.userModel?.id ?? '',
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allTasks = snapshot.data ?? [];
        final filteredTasks = status != null
            ? allTasks.where((task) => task.status == status).toList()
            : allTasks;

        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyStateIcon(status),
                  size: 64,
                  color: AppTheme.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyStateTitle(status),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyStateMessage(status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              taskProvider.refreshUserTasks(authProvider.userModel?.id ?? ''),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return TaskCard(
                task: task,
                onTap: () => _showTaskDetails(task),
                onStatusUpdate: (newStatus) =>
                    _updateTaskStatus(task, newStatus),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getEmptyStateIcon(TaskStatus? status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Icons.play_circle_outline;
      case TaskStatus.inProgress:
        return Icons.hourglass_empty;
      case TaskStatus.completed:
        return Icons.check_circle_outline;
      default:
        return Icons.assignment;
    }
  }

  String _getEmptyStateTitle(TaskStatus? status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'No tasks to start';
      case TaskStatus.inProgress:
        return 'No tasks in progress';
      case TaskStatus.completed:
        return 'No completed tasks';
      default:
        return 'No tasks assigned';
    }
  }

  String _getEmptyStateMessage(TaskStatus? status) {
    switch (status) {
      case TaskStatus.notStarted:
        return 'All your tasks are either in progress or completed';
      case TaskStatus.inProgress:
        return 'You don\'t have any tasks in progress right now';
      case TaskStatus.completed:
        return 'You haven\'t completed any tasks yet';
      default:
        return 'Your admin will assign tasks to you soon';
    }
  }

  void _showTaskDetails(TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
  }

  Future<void> _updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.updateTaskStatus(task.id, newStatus);
  }
}

class ShimmerTaskCard extends StatelessWidget {
  const ShimmerTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.textDisabled.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.textDisabled.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
