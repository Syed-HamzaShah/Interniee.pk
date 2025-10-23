import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/task_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../utils/app_theme.dart';
import '../profile_screen.dart';

class InternHomeScreen extends StatefulWidget {
  const InternHomeScreen({super.key});

  @override
  State<InternHomeScreen> createState() => _InternHomeScreenState();
}

class _InternHomeScreenState extends State<InternHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TaskStatus> _statusTabs = [
    TaskStatus.pending,
    TaskStatus.inProgress,
    TaskStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
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
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            // Show shorter title on smaller screens
            if (constraints.maxWidth < 400) {
              return Text(
                'Welcome, ${(authProvider.userModel?.name ?? 'Intern').split(' ').first}',
              );
            }
            return Text('Welcome, ${authProvider.userModel?.name ?? 'Intern'}');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskProvider.refreshTasks(),
            tooltip: 'Refresh Tasks',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allow horizontal scrolling on small screens
          tabs: _statusTabs
              .map(
                (status) => Tab(
                  text: _getTabText(status),
                  icon: Icon(_getStatusIcon(status)),
                ),
              )
              .toList(),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: _buildStatsOverview(taskProvider))];
        },
        body: TabBarView(
          controller: _tabController,
          children: _statusTabs
              .map((status) => _buildTasksList(status, taskProvider))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(TaskProvider taskProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Task Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          // Responsive grid layout for stats
          LayoutBuilder(
            builder: (context, constraints) {
              // For screens wider than 600px, show 4 columns
              // For screens between 400-600px, show 2 columns
              // For screens smaller than 400px, show 1 column
              int crossAxisCount;
              double childAspectRatio;

              if (constraints.maxWidth > 600) {
                crossAxisCount = 4;
                childAspectRatio = 1.2;
              } else if (constraints.maxWidth > 400) {
                crossAxisCount = 2;
                childAspectRatio = 1.5;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 3.0;
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatItem(
                    'Total',
                    taskProvider.totalTasks.toString(),
                    Icons.task_alt,
                    AppTheme.primaryGreen,
                  ),
                  _buildStatItem(
                    'Completed',
                    taskProvider.completedTasks.toString(),
                    Icons.check_circle,
                    AppTheme.statusCompleted,
                  ),
                  _buildStatItem(
                    'Pending',
                    taskProvider.pendingTasks.toString(),
                    Icons.pending_actions,
                    AppTheme.statusPending,
                  ),
                  _buildStatItem(
                    'Overdue',
                    taskProvider.overdueTasks.toString(),
                    Icons.warning_amber,
                    AppTheme.statusOverdue,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(TaskStatus status, TaskProvider taskProvider) {
    return StreamBuilder<List<TaskModel>>(
      stream: taskProvider.getTasksByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
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
                  onPressed: () => taskProvider.refreshTasks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 64,
                  color: AppTheme.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.name.toLowerCase()} tasks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == TaskStatus.pending
                      ? 'You have no pending tasks'
                      : status == TaskStatus.inProgress
                      ? 'You have no tasks in progress'
                      : 'You have no completed tasks',
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
          onRefresh: () => taskProvider.refreshTasks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            // Add physics to work with NestedScrollView
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onTap: () => _showTaskDetails(task),
                onComplete: status != TaskStatus.completed
                    ? () => _completeTask(task)
                    : null,
                showCompleteButton: status != TaskStatus.completed,
              );
            },
          ),
        );
      },
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.overdue:
        return Icons.warning;
    }
  }

  String _getTabText(TaskStatus status) {
    // Use MediaQuery to check screen width for responsive text
    final screenWidth = MediaQuery.of(context).size.width;

    // Show shorter text on very small screens
    if (screenWidth < 300) {
      switch (status) {
        case TaskStatus.pending:
          return 'PENDING';
        case TaskStatus.inProgress:
          return 'ACTIVE';
        case TaskStatus.completed:
          return 'DONE';
        case TaskStatus.overdue:
          return 'OVERDUE';
      }
    }
    return status.name.toUpperCase();
  }

  void _showTaskDetails(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.description.isNotEmpty) ...[
                Text(
                  'Description:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(task.description),
                const SizedBox(height: 16),
              ],
              _buildDetailRow('Priority', task.priority.name.toUpperCase()),
              _buildDetailRow('Status', task.status.name.toUpperCase()),
              _buildDetailRow('Due Date', _formatDate(task.dueDate)),
              _buildDetailRow('Assigned by', task.assignedByName),
              if (task.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(task.notes!),
              ],
              if (task.completedNotes != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Completion Notes:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(task.completedNotes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (task.status != TaskStatus.completed)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeTask(task);
              },
              child: const Text('Complete Task'),
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
            width: 80,
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

  void _completeTask(TaskModel task) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to mark "${task.title}" as completed?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Completion Notes (Optional)',
                hintText: 'Add any notes about the completion...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final taskProvider = Provider.of<TaskProvider>(
                context,
                listen: false,
              );
              await taskProvider.completeTask(
                task.id,
                completedNotes: notesController.text.trim().isNotEmpty
                    ? notesController.text.trim()
                    : null,
              );
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task completed successfully!'),
                    backgroundColor: AppTheme.statusCompleted,
                  ),
                );
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}
