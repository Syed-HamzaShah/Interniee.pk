import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final Function(TaskStatus)? onStatusUpdate;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(task.status),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                task.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: _getDeadlineColor()),
                  const SizedBox(width: 4),
                  Text(
                    task.formattedDeadline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getDeadlineColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Icon(Icons.flag, size: 16, color: _getPriorityColor()),
                  const SizedBox(width: 4),
                  Text(
                    task.priorityDisplayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  if (task.status == TaskStatus.inProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.statusInProgress.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.statusInProgress.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'In Progress',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.statusInProgress,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),

              if (onStatusUpdate != null && task.status != TaskStatus.completed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      if (task.status == TaskStatus.notStarted)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                onStatusUpdate!(TaskStatus.inProgress),
                            icon: const Icon(Icons.play_arrow, size: 16),
                            label: const Text('Start Task'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusInProgress,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      if (task.status == TaskStatus.inProgress) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                onStatusUpdate!(TaskStatus.notStarted),
                            icon: const Icon(Icons.pause, size: 16),
                            label: const Text('Pause'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                onStatusUpdate!(TaskStatus.completed),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.statusCompleted,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case TaskStatus.notStarted:
        backgroundColor = AppTheme.textDisabled.withOpacity(0.1);
        textColor = AppTheme.textDisabled;
        text = 'Not Started';
        break;
      case TaskStatus.inProgress:
        backgroundColor = AppTheme.statusInProgress.withOpacity(0.1);
        textColor = AppTheme.statusInProgress;
        text = 'In Progress';
        break;
      case TaskStatus.completed:
        backgroundColor = AppTheme.statusCompleted.withOpacity(0.1);
        textColor = AppTheme.statusCompleted;
        text = 'Completed';
        break;
      case TaskStatus.overdue:
        backgroundColor = AppTheme.statusOverdue.withOpacity(0.1);
        textColor = AppTheme.statusOverdue;
        text = 'Overdue';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDeadlineColor() {
    if (task.isOverdue) {
      return AppTheme.statusOverdue;
    } else if (task.deadline.difference(DateTime.now()).inDays <= 1) {
      return AppTheme.statusPending;
    } else {
      return AppTheme.textSecondary;
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
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
