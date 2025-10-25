import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/intern_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';
import 'create_task_screen.dart';

class InternDetailsScreen extends StatefulWidget {
  final InternModel intern;

  const InternDetailsScreen({super.key, required this.intern});

  @override
  State<InternDetailsScreen> createState() => _InternDetailsScreenState();
}

class _InternDetailsScreenState extends State<InternDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Tasks', 'Performance', 'Timeline'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(
        context,
        listen: false,
      ).loadUserTasks(widget.intern.id);
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
        title: Text(widget.intern.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleAction,
            itemBuilder: (context) => [
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
                value: 'edit_profile',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'send_message',
                child: Row(
                  children: [
                    Icon(Icons.message, size: 20),
                    SizedBox(width: 8),
                    Text('Send Message'),
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
          _buildOverviewTab(),
          _buildTasksTab(),
          _buildPerformanceTab(),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final internTasks = taskProvider.userTasks;
        final stats = _calculateInternStats(widget.intern, internTasks);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildStatsCard(stats),
              const SizedBox(height: 16),
              _buildSkillsCard(),
              const SizedBox(height: 16),
              _buildRecentActivityCard(internTasks),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (taskProvider.errorMessage != null) {
          return _buildErrorWidget(taskProvider.errorMessage!);
        }

        final tasks = taskProvider.userTasks;

        if (tasks.isEmpty) {
          return _buildEmptyTasksWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _buildTaskCard(task);
          },
        );
      },
    );
  }

  Widget _buildPerformanceTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.userTasks;
        final performanceData = _calculatePerformanceData(widget.intern, tasks);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPerformanceOverviewCard(performanceData),
              const SizedBox(height: 16),
              _buildTaskStatusList(tasks),
              const SizedBox(height: 16),
              _buildProductivityList(tasks),
              const SizedBox(height: 16),
              _buildEvaluationCard(performanceData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineTab() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.userTasks;
        final timelineEvents = _buildTimelineEvents(tasks);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: timelineEvents.length,
          itemBuilder: (context, index) {
            final event = timelineEvents[index];
            return _buildTimelineEvent(event);
          },
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                  child: Text(
                    widget.intern.name.isNotEmpty
                        ? widget.intern.name[0].toUpperCase()
                        : 'I',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.intern.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.intern.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.intern.isActive
                              ? AppTheme.statusCompleted.withOpacity(0.2)
                              : AppTheme.textDisabled.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.intern.isActive ? 'Active' : 'Inactive',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: widget.intern.isActive
                                    ? AppTheme.statusCompleted
                                    : AppTheme.textDisabled,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Department',
              widget.intern.department ?? 'Not specified',
            ),
            _buildDetailRow(
              'University',
              widget.intern.university ?? 'Not specified',
            ),
            _buildDetailRow('Course', widget.intern.course ?? 'Not specified'),
            _buildDetailRow('Start Date', widget.intern.formattedStartDate),
            _buildDetailRow('End Date', widget.intern.formattedEndDate),
            _buildDetailRow(
              'Duration',
              '${widget.intern.internshipDurationInDays} days',
            ),
            if (widget.intern.bio != null) ...[
              const SizedBox(height: 12),
              Text(
                'Bio',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.intern.bio!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(InternStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Tasks',
                    stats.totalTasks.toString(),
                    Icons.assignment,
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
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
                  child: _buildStatItem(
                    'In Progress',
                    stats.inProgressTasks.toString(),
                    Icons.hourglass_empty,
                    AppTheme.statusInProgress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Overdue',
                    stats.overdueTasks.toString(),
                    Icons.warning,
                    AppTheme.statusOverdue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Completion Rate',
                    '${stats.completionRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    _getPerformanceColor(stats.completionRate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Avg. Time',
                    '${stats.averageCompletionTime.toStringAsFixed(1)} days',
                    Icons.schedule,
                    AppTheme.statusInProgress,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    if (widget.intern.skills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skills',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.intern.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(List<TaskModel> tasks) {
    final recentTasks = tasks.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (recentTasks.isEmpty)
              Text(
                'No recent activity',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...recentTasks.map((task) => _buildActivityItem(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(TaskModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Text(
            _getStatusText(task.status),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getStatusColor(task.status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(task.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(task.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Due: ${task.formattedDeadline}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _getPriorityIcon(task.priority),
                  size: 16,
                  color: _getPriorityColor(task.priority),
                ),
                const SizedBox(width: 4),
                Text(
                  task.priority.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverviewCard(PerformanceData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'Productivity Score',
                    '${data.productivityScore.toStringAsFixed(1)}/100',
                    Icons.speed,
                    _getPerformanceColor(data.productivityScore),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Quality Rating',
                    '${data.qualityRating.toStringAsFixed(1)}/5',
                    Icons.star,
                    AppTheme.statusInProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    'On-Time Delivery',
                    '${data.onTimeDelivery.toStringAsFixed(1)}%',
                    Icons.timer,
                    data.onTimeDelivery >= 80
                        ? AppTheme.statusCompleted
                        : AppTheme.statusOverdue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceMetric(
                    'Task Efficiency',
                    '${data.taskEfficiency.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusList(List<TaskModel> tasks) {
    final statusCounts = {
      'Completed': tasks
          .where((task) => task.status == TaskStatus.completed)
          .length,
      'In Progress': tasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length,
      'Not Started': tasks
          .where((task) => task.status == TaskStatus.notStarted)
          .length,
      'Overdue': tasks.where((task) => task.isOverdue).length,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Status Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              Color color;
              IconData icon;
              switch (entry.key) {
                case 'Completed':
                  color = AppTheme.statusCompleted;
                  icon = Icons.check_circle;
                  break;
                case 'In Progress':
                  color = AppTheme.statusInProgress;
                  icon = Icons.hourglass_empty;
                  break;
                case 'Not Started':
                  color = AppTheme.statusPending;
                  icon = Icons.assignment;
                  break;
                case 'Overdue':
                  color = AppTheme.statusOverdue;
                  icon = Icons.warning;
                  break;
                default:
                  color = AppTheme.textSecondary;
                  icon = Icons.help;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityList(List<TaskModel> tasks) {
    final monthlyData = <String, int>{};
    for (final task in tasks) {
      final month = '${task.createdAt.month}/${task.createdAt.year}';
      monthlyData[month] = (monthlyData[month] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Productivity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (monthlyData.isEmpty)
              Text(
                'No productivity data available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDisabled,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...monthlyData.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textPrimary),
                        ),
                      ),
                      Text(
                        '${entry.value} tasks',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(PerformanceData data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evaluation Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildEvaluationItem('Task Completion', data.completionRate, 100),
            _buildEvaluationItem('Quality of Work', data.qualityRating, 5),
            _buildEvaluationItem('Timeliness', data.onTimeDelivery, 100),
            _buildEvaluationItem('Communication', data.communicationRating, 5),
            _buildEvaluationItem('Initiative', data.initiativeRating, 5),
            _buildEvaluationItem('Teamwork', data.teamworkRating, 5),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationItem(String label, double value, double maxValue) {
    final percentage = (value / maxValue) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
              ),
              Text(
                '${value.toStringAsFixed(1)}/${maxValue.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.textDisabled.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPerformanceColor(percentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(TimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: event.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.formattedDate,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppTheme.textDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading tasks...'),
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
              'Error loading tasks',
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTasksWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppTheme.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks assigned',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textDisabled),
            ),
            const SizedBox(height: 8),
            Text(
              'This intern has not been assigned any tasks yet.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _assignTask(),
              icon: const Icon(Icons.add),
              label: const Text('Assign Task'),
            ),
          ],
        ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

    double averageCompletionTime = 0.0;
    if (completedTasks > 0) {
      final completedTaskList = tasks
          .where((task) => task.status == TaskStatus.completed)
          .toList();
      final totalDays = completedTaskList.fold<int>(0, (sum, task) {
        if (task.completedAt != null) {
          return sum + task.completedAt!.difference(task.createdAt).inDays;
        }
        return sum;
      });
      averageCompletionTime = totalDays / completedTasks;
    }

    return InternStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      overdueTasks: overdueTasks,
      completionRate: completionRate,
      averageCompletionTime: averageCompletionTime,
    );
  }

  PerformanceData _calculatePerformanceData(
    InternModel intern,
    List<TaskModel> tasks,
  ) {
    final stats = _calculateInternStats(intern, tasks);

    final productivityScore =
        (stats.completionRate * 0.7) +
        (stats.completedTasks * 2).clamp(0, 30).toDouble();

    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();
    final onTimeTasks = completedTasks.where((task) {
      if (task.completedAt == null) return false;
      return !task.completedAt!.isAfter(task.deadline);
    }).length;
    final onTimeDelivery = completedTasks.isEmpty
        ? 0.0
        : (onTimeTasks / completedTasks.length) * 100;

    final taskEfficiency = stats.averageCompletionTime > 0
        ? (7 / stats.averageCompletionTime) * 100
        : 0.0;

    return PerformanceData(
      completionRate: stats.completionRate,
      productivityScore: productivityScore.clamp(0, 100),
      qualityRating: intern.averageRating,
      onTimeDelivery: onTimeDelivery,
      taskEfficiency: taskEfficiency,
      communicationRating: 4.0, // Placeholder - would come from feedback
      initiativeRating: 4.0, // Placeholder - would come from feedback
      teamworkRating: 4.0, // Placeholder - would come from feedback
    );
  }

  List<TimelineEvent> _buildTimelineEvents(List<TaskModel> tasks) {
    final events = <TimelineEvent>[];

    for (final task in tasks) {
      events.add(
        TimelineEvent(
          title: 'Task: ${task.title}',
          description: 'Status: ${_getStatusText(task.status)}',
          date: task.createdAt,
          color: _getStatusColor(task.status),
        ),
      );

      if (task.completedAt != null) {
        events.add(
          TimelineEvent(
            title: 'Task Completed: ${task.title}',
            description: 'Completed on time',
            date: task.completedAt!,
            color: AppTheme.statusCompleted,
          ),
        );
      }
    }

    events.add(
      TimelineEvent(
        title: 'Internship Started',
        description: 'Joined the internship program',
        date: widget.intern.startDate,
        color: AppTheme.primaryGreen,
      ),
    );

    events.sort((a, b) => b.date.compareTo(a.date));

    return events;
  }

  Color _getStatusColor(TaskStatus status) {
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

  String _getStatusText(TaskStatus status) {
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

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.statusCompleted;
      case TaskPriority.medium:
        return AppTheme.statusInProgress;
      case TaskPriority.high:
        return AppTheme.statusOverdue;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  Color _getPerformanceColor(double value) {
    if (value >= 90) return AppTheme.statusCompleted;
    if (value >= 70) return AppTheme.primaryGreen;
    if (value >= 50) return AppTheme.statusInProgress;
    return AppTheme.statusOverdue;
  }

  void _assignTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CreateTaskScreen(preSelectedInternId: widget.intern.id),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'assign_task':
        _assignTask();
        break;
      case 'edit_profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit profile - Coming soon')),
        );
        break;
      case 'send_message':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Send message - Coming soon')),
        );
        break;
    }
  }
}

class InternStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int overdueTasks;
  final double completionRate;
  final double averageCompletionTime;

  InternStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.averageCompletionTime,
  });
}

class PerformanceData {
  final double completionRate;
  final double productivityScore;
  final double qualityRating;
  final double onTimeDelivery;
  final double taskEfficiency;
  final double communicationRating;
  final double initiativeRating;
  final double teamworkRating;

  PerformanceData({
    required this.completionRate,
    required this.productivityScore,
    required this.qualityRating,
    required this.onTimeDelivery,
    required this.taskEfficiency,
    required this.communicationRating,
    required this.initiativeRating,
    required this.teamworkRating,
  });
}

class TimelineEvent {
  final String title;
  final String description;
  final DateTime date;
  final Color color;

  TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
