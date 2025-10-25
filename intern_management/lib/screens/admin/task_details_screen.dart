import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/intern_provider.dart';
import '../../models/task_model.dart';
import '../../models/intern_model.dart';
import '../../utils/app_theme.dart';
import 'edit_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternProvider>(context, listen: false).loadInterns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(value),
            itemBuilder: (context) => [
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTaskHeader(),

            const SizedBox(height: 24),

            _buildTaskInformation(),

            const SizedBox(height: 24),

            _buildAssignmentInformation(),

            const SizedBox(height: 24),

            _buildStatusAndProgress(),

            const SizedBox(height: 24),

            if (widget.task.notes != null && widget.task.notes!.isNotEmpty)
              _buildNotesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditTask(),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Task'),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getTaskStatusColor(widget.task.status),
                  radius: 20,
                  child: Icon(
                    _getTaskStatusIcon(widget.task.status),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.task.statusDisplayName,
                        style: TextStyle(
                          color: _getTaskStatusColor(widget.task.status),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.task.description,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInformation() {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Information',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.flag,
              label: 'Priority',
              value: widget.task.priorityDisplayName,
              valueColor: _getPriorityColor(widget.task.priority),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Deadline',
              value: widget.task.formattedDeadline,
              valueColor: widget.task.isOverdue
                  ? AppTheme.statusOverdue
                  : AppTheme.textPrimary,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Created',
              value: widget.task.formattedCreatedAt,
            ),
            if (widget.task.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.check_circle,
                label: 'Completed',
                value: _formatDate(widget.task.completedAt!),
                valueColor: AppTheme.statusCompleted,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInformation() {
    return Consumer<InternProvider>(
      builder: (context, internProvider, child) {
        final assignedIntern = internProvider.interns.firstWhere(
          (intern) => intern.id == widget.task.assignedTo,
          orElse: () => InternModel(
            id: widget.task.assignedTo,
            name: 'Unknown Intern',
            email: '',
            department: '',
            startDate: DateTime.now(),
            createdAt: DateTime.now(),
            profileImageUrl: null,
          ),
        );

        return Card(
          color: AppTheme.darkCard,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assignment Information',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: assignedIntern.profileImageUrl != null
                          ? NetworkImage(assignedIntern.profileImageUrl!)
                          : null,
                      child: assignedIntern.profileImageUrl == null
                          ? Text(assignedIntern.name[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignedIntern.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignedIntern.email,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (assignedIntern.department != null &&
                              assignedIntern.department!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              assignedIntern.department!,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  Widget _buildStatusAndProgress() {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status & Progress',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(widget.task.progressPercentage * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: widget.task.progressPercentage,
                  backgroundColor: AppTheme.darkBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTaskStatusColor(widget.task.status),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (widget.task.status != TaskStatus.completed)
              _buildStatusChangeButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChangeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (widget.task.status == TaskStatus.notStarted)
              _buildStatusButton(
                'Start Task',
                TaskStatus.inProgress,
                Icons.play_arrow,
                AppTheme.statusInProgress,
              ),
            if (widget.task.status == TaskStatus.inProgress)
              _buildStatusButton(
                'Mark Complete',
                TaskStatus.completed,
                Icons.check_circle,
                AppTheme.statusCompleted,
              ),
            if (widget.task.status == TaskStatus.inProgress)
              _buildStatusButton(
                'Mark Overdue',
                TaskStatus.overdue,
                Icons.warning,
                AppTheme.statusOverdue,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    String label,
    TaskStatus status,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () => _updateTaskStatus(status),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      color: AppTheme.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Text(
                widget.task.notes!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEditTask();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _navigateToEditTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: widget.task),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${widget.task.title}"?',
        ),
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
              ).deleteTask(widget.task.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted successfully'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
                Navigator.of(context).pop();
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

  Future<void> _updateTaskStatus(TaskStatus status) async {
    final success = await Provider.of<TaskProvider>(
      context,
      listen: false,
    ).updateTaskStatus(widget.task.id, status);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task status updated to ${status.name}'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      setState(() {});
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
