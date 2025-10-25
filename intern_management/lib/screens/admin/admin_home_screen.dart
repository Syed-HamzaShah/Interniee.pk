import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/shimmer_widget.dart';
import 'task_management_screen.dart';
import 'intern_management_screen.dart';
import 'performance_reports_screen.dart';
import '../profile_screen.dart';
import '../../utils/app_theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Task Management', 'Interns'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
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
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(taskProvider),
          _buildTaskManagementTab(),
          _buildInternsTab(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToTaskManagement(),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.assignment),
          label: const Text(
            'Manage Tasks',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(TaskProvider taskProvider) {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(taskProvider),

          const SizedBox(height: AppTheme.spacingLarge),

          Text('Recent Tasks', style: AppTheme.getHeadingStyle(fontSize: 20)),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildRecentTasks(taskProvider),
        ],
      ),
    );
  }

  Widget _buildQuickStats(TaskProvider taskProvider) {
    return Container(
      padding: AppTheme.getCardPadding(context),
      decoration: AppTheme.getGradientCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Statistics',
            style: AppTheme.getHeadingStyle(fontSize: 20),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  taskProvider.totalTasks.toString(),
                  Icons.assignment,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  taskProvider.completedTasks.toString(),
                  Icons.check_circle,
                  AppTheme.statusCompleted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  taskProvider.inProgressTasks.toString(),
                  Icons.hourglass_empty,
                  AppTheme.statusInProgress,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  taskProvider.overdueTasks.toString(),
                  Icons.warning,
                  AppTheme.statusOverdue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: AppTheme.getStatusCardDecoration(color),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            value,
            style: AppTheme.getHeadingStyle(fontSize: 18, color: color),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(
            title,
            style: AppTheme.getCaptionStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(TaskProvider taskProvider) {
    return StreamBuilder<List<dynamic>>(
      stream: taskProvider.getTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                isLoading: true,
                child: const ShimmerTaskCard(),
              );
            },
          );
        }

        final tasks = snapshot.data ?? [];
        final recentTasks = tasks.take(5).toList();

        if (recentTasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment, size: 48, color: AppTheme.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentTasks.length,
          itemBuilder: (context, index) {
            final task = recentTasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getTaskStatusColor(task.status),
                  child: Icon(
                    _getTaskStatusIcon(task.status),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(task.title),
                subtitle: Text(
                  '${task.priorityDisplayName} • ${task.formattedDeadline}',
                ),
                trailing: Chip(
                  label: Text(
                    task.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getTaskStatusColor(task.status),
                ),
                onTap: () => _showTaskDetails(task),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskManagementTab() {
    return const TaskManagementScreen();
  }

  Widget _buildInternsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intern Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildReportCard(
            'Manage Interns',
            'View and manage intern profiles and performance',
            Icons.people,
            () => _navigateToInternManagement(),
          ),

          const SizedBox(height: AppTheme.spacingMedium),

          _buildReportCard(
            'Performance Reports',
            'View intern performance and progress reports',
            Icons.assessment,
            () => _navigateToPerformanceReports(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
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

  void _navigateToTaskManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TaskManagementScreen()),
    );
  }

  void _navigateToInternManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const InternManagementScreen()),
    );
  }

  void _navigateToPerformanceReports() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PerformanceReportsScreen()),
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

  Color _getTaskStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'TaskStatus.notStarted':
        return AppTheme.textDisabled;
      case 'TaskStatus.inProgress':
        return AppTheme.statusInProgress;
      case 'TaskStatus.completed':
        return AppTheme.statusCompleted;
      case 'TaskStatus.overdue':
        return AppTheme.statusOverdue;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getTaskStatusIcon(dynamic status) {
    switch (status.toString()) {
      case 'TaskStatus.notStarted':
        return Icons.play_circle_outline;
      case 'TaskStatus.inProgress':
        return Icons.hourglass_empty;
      case 'TaskStatus.completed':
        return Icons.check_circle;
      case 'TaskStatus.overdue':
        return Icons.warning;
      default:
        return Icons.assignment;
    }
  }

  void _showTaskDetails(dynamic task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Description', task.description),
              _buildDetailRow('Status', task.statusDisplayName),
              _buildDetailRow('Priority', task.priorityDisplayName),
              _buildDetailRow('Deadline', task.formattedDeadline),
              _buildDetailRow('Created', task.formattedCreatedAt),
              if (task.notes != null && task.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(task.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
              const SizedBox(width: AppTheme.spacingMedium),
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
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: List.generate(
              5,
              (index) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.textDisabled.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
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
