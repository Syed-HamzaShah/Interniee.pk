import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../utils/app_theme.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (_task.status != TaskStatus.completed)
            PopupMenuButton<String>(
              onSelected: (value) {
                _handleStatusUpdate(
                  TaskStatus.values.firstWhere(
                    (status) => status.name == value,
                  ),
                );
              },
              itemBuilder: (context) {
                final menuItems = <PopupMenuEntry<String>>[];

                if (_task.status == TaskStatus.notStarted) {
                  menuItems.add(
                    const PopupMenuItem(
                      value: 'inProgress',
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: AppTheme.statusInProgress,
                          ),
                          SizedBox(width: 8),
                          Text('Start Task'),
                        ],
                      ),
                    ),
                  );
                } else if (_task.status == TaskStatus.inProgress) {
                  menuItems.addAll([
                    const PopupMenuItem(
                      value: 'notStarted',
                      child: Row(
                        children: [
                          Icon(Icons.pause, color: AppTheme.textSecondary),
                          SizedBox(width: 8),
                          Text('Pause Task'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Row(
                        children: [
                          Icon(Icons.check, color: AppTheme.statusCompleted),
                          SizedBox(width: 8),
                          Text('Mark Complete'),
                        ],
                      ),
                    ),
                  ]);
                }

                return menuItems;
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildStatusChip(_task.status),
                const SizedBox(width: 12),
                _buildPriorityChip(_task.priority),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection('Description', _task.description, Icons.description),

            const SizedBox(height: 24),

            _buildDetailsSection(),

            const SizedBox(height: 24),

            if (_task.notes != null && _task.notes!.isNotEmpty)
              _buildSection('Notes', _task.notes!, Icons.note),

            const SizedBox(height: 24),

            if (_task.attachments.isNotEmpty) _buildAttachmentsSection(),

            const SizedBox(height: 24),

            if (_task.status != TaskStatus.completed) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: [
              _buildDetailRow('Created', _task.formattedCreatedAt),
              _buildDetailRow('Deadline', _task.formattedDeadline),
              _buildDetailRow('Priority', _task.priorityDisplayName),
              if (_task.completedAt != null)
                _buildDetailRow('Completed', _formatDate(_task.completedAt!)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
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

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 8),
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            children: _task.attachments.map((attachment) {
              return ListTile(
                leading: const Icon(
                  Icons.file_download,
                  color: AppTheme.primaryGreen,
                ),
                title: Text(
                  attachment.split('/').last,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
                ),
                trailing: const Icon(
                  Icons.download,
                  color: AppTheme.primaryGreen,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('File download not implemented yet'),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_task.status == TaskStatus.notStarted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleStatusUpdate(TaskStatus.inProgress),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusInProgress,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (_task.status == TaskStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleStatusUpdate(TaskStatus.completed),
              icon: const Icon(Icons.check),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCompleted,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleStatusUpdate(TaskStatus.notStarted),
              icon: const Icon(Icons.pause),
              label: const Text('Pause Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color backgroundColor;
    Color textColor;

    switch (priority) {
      case TaskPriority.low:
        backgroundColor = AppTheme.priorityLow.withOpacity(0.1);
        textColor = AppTheme.priorityLow;
        break;
      case TaskPriority.medium:
        backgroundColor = AppTheme.priorityMedium.withOpacity(0.1);
        textColor = AppTheme.priorityMedium;
        break;
      case TaskPriority.high:
        backgroundColor = AppTheme.priorityHigh.withOpacity(0.1);
        textColor = AppTheme.priorityHigh;
        break;
      case TaskPriority.urgent:
        backgroundColor = AppTheme.priorityUrgent.withOpacity(0.1);
        textColor = AppTheme.priorityUrgent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            priority.name.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusUpdate(TaskStatus newStatus) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    try {
      await taskProvider.updateTaskStatus(_task.id, newStatus);

      setState(() {
        _task = _task.copyWith(
          status: newStatus,
          completedAt: newStatus == TaskStatus.completed
              ? DateTime.now()
              : null,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task status updated to ${_task.statusDisplayName}'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task status: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
