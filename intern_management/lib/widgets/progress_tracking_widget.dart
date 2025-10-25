import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

class ProgressTrackingWidget extends StatelessWidget {
  final List<TaskModel> tasks;
  final String title;

  const ProgressTrackingWidget({
    super.key,
    required this.tasks,
    this.title = 'Progress Overview',
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

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
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildOverallProgressBar(context, stats),

          const SizedBox(height: 24),

          _buildProgressStats(context, stats),

          const SizedBox(height: 20),

          _buildTaskStatusBreakdown(context, stats),
        ],
      ),
    );
  }

  Widget _buildOverallProgressBar(BuildContext context, ProgressStats stats) {
    final progressPercentage = stats.totalTasks > 0
        ? (stats.completedTasks / stats.totalTasks)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progressPercentage * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.darkBorder,
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(progressPercentage),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${stats.completedTasks} of ${stats.totalTasks} tasks completed',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProgressStats(BuildContext context, ProgressStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Completed',
            stats.completedTasks.toString(),
            Icons.check_circle,
            AppTheme.statusCompleted,
            stats.totalTasks > 0
                ? (stats.completedTasks / stats.totalTasks)
                : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            'In Progress',
            stats.inProgressTasks.toString(),
            Icons.hourglass_empty,
            AppTheme.statusInProgress,
            stats.totalTasks > 0
                ? (stats.inProgressTasks / stats.totalTasks)
                : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            context,
            'Pending',
            stats.notStartedTasks.toString(),
            Icons.play_circle_outline,
            AppTheme.statusPending,
            stats.totalTasks > 0
                ? (stats.notStartedTasks / stats.totalTasks)
                : 0.0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    double percentage,
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
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '      ${(percentage * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusBreakdown(BuildContext context, ProgressStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Status Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatusItem(
          context,
          'Completed Tasks',
          stats.completedTasks,
          stats.totalTasks,
          AppTheme.statusCompleted,
          Icons.check_circle,
        ),
        const SizedBox(height: 12),
        _buildStatusItem(
          context,
          'In Progress Tasks',
          stats.inProgressTasks,
          stats.totalTasks,
          AppTheme.statusInProgress,
          Icons.hourglass_empty,
        ),
        const SizedBox(height: 12),
        _buildStatusItem(
          context,
          'Not Started Tasks',
          stats.notStartedTasks,
          stats.totalTasks,
          AppTheme.statusPending,
          Icons.play_circle_outline,
        ),
        if (stats.overdueTasks > 0) ...[
          const SizedBox(height: 12),
          _buildStatusItem(
            context,
            'Overdue Tasks',
            stats.overdueTasks,
            stats.totalTasks,
            AppTheme.statusOverdue,
            Icons.warning,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
    IconData icon,
  ) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count tasks',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ProgressStats _calculateStats() {
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final inProgressTasks = tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .length;
    final notStartedTasks = tasks
        .where((task) => task.status == TaskStatus.notStarted)
        .length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;

    return ProgressStats(
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      notStartedTasks: notStartedTasks,
      overdueTasks: overdueTasks,
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.8) return AppTheme.statusCompleted;
    if (percentage >= 0.5) return AppTheme.statusInProgress;
    if (percentage >= 0.2) return AppTheme.statusPending;
    return AppTheme.statusOverdue;
  }
}

class ProgressStats {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int notStartedTasks;
  final int overdueTasks;

  ProgressStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.inProgressTasks,
    required this.notStartedTasks,
    required this.overdueTasks,
  });
}

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final String label;
  final Color color;
  final double size;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    required this.label,
    required this.color,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: AppTheme.darkBorder,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '          ${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class ProgressChartWidget extends StatelessWidget {
  final List<TaskModel> tasks;
  final String title;

  const ProgressChartWidget({
    super.key,
    required this.tasks,
    this.title = 'Progress Chart',
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

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
          Row(
            children: [
              Icon(Icons.pie_chart, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressWidget(
                progress: stats.totalTasks > 0
                    ? (stats.completedTasks / stats.totalTasks)
                    : 0.0,
                label: 'Completed',
                color: AppTheme.statusCompleted,
              ),
              CircularProgressWidget(
                progress: stats.totalTasks > 0
                    ? (stats.inProgressTasks / stats.totalTasks)
                    : 0.0,
                label: 'In Progress',
                color: AppTheme.statusInProgress,
              ),
              CircularProgressWidget(
                progress: stats.totalTasks > 0
                    ? (stats.notStartedTasks / stats.totalTasks)
                    : 0.0,
                label: 'Pending',
                color: AppTheme.statusPending,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ProgressStats _calculateStats() {
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final inProgressTasks = tasks
        .where((task) => task.status == TaskStatus.inProgress)
        .length;
    final notStartedTasks = tasks
        .where((task) => task.status == TaskStatus.notStarted)
        .length;
    final overdueTasks = tasks.where((task) => task.isOverdue).length;

    return ProgressStats(
      totalTasks: tasks.length,
      completedTasks: completedTasks,
      inProgressTasks: inProgressTasks,
      notStartedTasks: notStartedTasks,
      overdueTasks: overdueTasks,
    );
  }
}
