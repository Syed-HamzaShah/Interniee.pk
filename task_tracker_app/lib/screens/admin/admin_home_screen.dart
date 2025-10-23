import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../widgets/task_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../widgets/create_task_dialog.dart';
import '../../widgets/edit_task_dialog.dart';
import '../../widgets/assign_task_dialog.dart';
import 'weekly_report_screen.dart';
import 'monthly_report_screen.dart';
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
  final List<String> _tabs = ['Overview', 'Tasks', 'Users', 'Reports'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminProvider.refreshData(),
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
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(adminProvider),
          _buildTasksTab(adminProvider),
          _buildUsersTab(adminProvider),
          _buildReportsTab(adminProvider),
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
          onPressed: () => _showCreateTaskDialog(),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_task),
          label: const Text(
            'Create Task',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick stats
          _buildQuickStats(adminProvider),

          const SizedBox(height: 24),

          // Recent tasks
          Text('Recent Tasks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          _buildRecentTasks(adminProvider),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AdminProvider adminProvider) {
    return StreamBuilder<Map<String, int>>(
      stream: adminProvider.getOverallStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats =
            snapshot.data ??
            {
              'totalTasks': 0,
              'completedTasks': 0,
              'pendingTasks': 0,
              'overdueTasks': 0,
              'totalUsers': 0,
            };

        return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Stats',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Tasks',
                      stats['totalTasks'].toString(),
                      Icons.task,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      stats['completedTasks'].toString(),
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
                    child: _buildStatCard(
                      'Pending',
                      stats['pendingTasks'].toString(),
                      Icons.pending,
                      AppTheme.statusPending,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Overdue',
                      stats['overdueTasks'].toString(),
                      Icons.warning,
                      AppTheme.statusOverdue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Users',
                      stats['totalUsers'].toString(),
                      Icons.people,
                      AppTheme.statusInProgress,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Completion Rate',
                      '${stats['totalTasks']! > 0 ? (stats['completedTasks']! / stats['totalTasks']! * 100).toStringAsFixed(1) : '0'}%',
                      Icons.trending_up,
                      AppTheme.accentGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(AdminProvider adminProvider) {
    return StreamBuilder<List<TaskModel>>(
      stream: adminProvider.getRecentTasks(),
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

        if (tasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.task_alt, size: 48, color: AppTheme.textDisabled),
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
          itemCount: tasks.take(5).length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onTap: () => _showTaskDetails(task),
              showCompleteButton: false,
              onEdit: () => _editTask(task),
              onDelete: () => _deleteTask(task),
            );
          },
        );
      },
    );
  }

  Widget _buildTasksTab(AdminProvider adminProvider) {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
            ),
          ),
        ),

        // Tasks List
        Expanded(
          child: StreamBuilder<List<TaskModel>>(
            stream: _searchQuery.isNotEmpty
                ? adminProvider.searchTasks(_searchQuery)
                : adminProvider.getAllTasks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                        Icons.task_alt,
                        size: 64,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first task to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => adminProvider.refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => _showTaskDetails(task),
                      showCompleteButton: false,
                      onEdit: () => _editTask(task),
                      onDelete: () => _deleteTask(task),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(AdminProvider adminProvider) {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.darkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
              ),
            ),
          ),
        ),

        // Users List
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _searchQuery.isNotEmpty
                ? adminProvider.searchUsers(_searchQuery)
                : adminProvider.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
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
                        'Error loading users',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final users = snapshot.data ?? [];

              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 64,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Users will appear here once they register',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textDisabled,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => adminProvider.refreshData(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(user.name),
                        subtitle: Text(user.email),
                        trailing: Chip(
                          label: Text(
                            user.role.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: user.role == UserRole.admin
                              ? AppTheme.primaryGreen
                              : AppTheme.statusInProgress,
                        ),
                        onTap: () => _showUserDetails(user),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab(AdminProvider adminProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Reports',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Weekly report
          _buildReportCard(
            'Weekly Report',
            'View this week\'s performance summary',
            Icons.calendar_view_week,
            () => _showWeeklyReport(adminProvider),
          ),

          const SizedBox(height: 12),

          // Monthly report
          _buildReportCard(
            'Monthly Report',
            'View this month\'s performance summary',
            Icons.calendar_month,
            () => _showMonthlyReport(adminProvider),
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

  void _showTaskDetails(TaskModel task) {
    // Implementation for showing task details
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
              _buildDetailRow('Assigned to', task.assignedToId),
              _buildDetailRow('Assigned by', task.assignedByName),
              if (task.notes != null) ...[
                const SizedBox(height: 8),
                Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
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
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editTask(task);
            },
            child: const Text('Edit Task'),
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

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Role', user.role.name.toUpperCase()),
            _buildDetailRow('Joined', _formatDate(user.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _assignTaskToUser(user);
            },
            child: const Text('Assign Task'),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        adminProvider: adminProvider,
        onTaskCreated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  void _editTask(TaskModel task) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        adminProvider: adminProvider,
        onTaskUpdated: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  void _assignTaskToUser(UserModel user) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AssignTaskDialog(
        user: user,
        adminProvider: adminProvider,
        onTaskAssigned: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task assigned to ${user.name} successfully!'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  void _showWeeklyReport(AdminProvider adminProvider) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const WeeklyReportScreen()));
  }

  void _showMonthlyReport(AdminProvider adminProvider) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MonthlyReportScreen()),
    );
  }

  void _deleteTask(TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Delete Task',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final adminProvider = Provider.of<AdminProvider>(
                context,
                listen: false,
              );

              try {
                await adminProvider.deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted successfully!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete task: $e'),
                    backgroundColor: AppTheme.statusOverdue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            child: const Text('Delete'),
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
