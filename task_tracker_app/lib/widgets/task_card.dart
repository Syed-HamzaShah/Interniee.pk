import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showCompleteButton;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onEdit,
    this.onDelete,
    this.showCompleteButton = true,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation =
        ColorTween(
          begin: AppTheme.darkCard,
          end: AppTheme.primaryGreen.withOpacity(0.1),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _glowAnimation.value,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getStatusColor(
                    widget.task.status.name,
                  ).withOpacity(0.1),
                  blurRadius: _elevationAnimation.value,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.getStatusColor(
                        widget.task.status.name,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with title and status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.task.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusChip(theme),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Description
                        if (widget.task.description.isNotEmpty) ...[
                          Text(
                            widget.task.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Priority and due date row
                        Row(
                          children: [
                            _buildPriorityChip(theme),
                            const Spacer(),
                            _buildDueDateText(theme),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Footer row with assignee and complete button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Assigned by: ${widget.task.assignedByName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textDisabled,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.showCompleteButton &&
                                widget.task.status != TaskStatus.completed) ...[
                              const SizedBox(width: 12),
                              _buildCompleteButton(theme),
                            ],

                            // Admin action buttons (Edit/Delete)
                            if (widget.onEdit != null ||
                                widget.onDelete != null) ...[
                              const SizedBox(width: 12),
                              _buildAdminActionButtons(theme),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getStatusColor(widget.task.status.name),
            AppTheme.getStatusColor(widget.task.status.name).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getStatusColor(
              widget.task.status.name,
            ).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        widget.task.status.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.getPriorityColor(widget.task.priority.name),
            AppTheme.getPriorityColor(
              widget.task.priority.name,
            ).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPriorityColor(
              widget.task.priority.name,
            ).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        widget.task.priority.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDueDateText(ThemeData theme) {
    final now = DateTime.now();
    final isOverdue = widget.task.isOverdue;
    final isToday =
        widget.task.dueDate.day == now.day &&
        widget.task.dueDate.month == now.month &&
        widget.task.dueDate.year == now.year;
    final isTomorrow =
        widget.task.dueDate.day == now.add(const Duration(days: 1)).day &&
        widget.task.dueDate.month == now.add(const Duration(days: 1)).month &&
        widget.task.dueDate.year == now.add(const Duration(days: 1)).year;

    String dueText;
    Color dueColor;

    if (isOverdue) {
      dueText = 'OVERDUE';
      dueColor = AppTheme.statusOverdue;
    } else if (isToday) {
      dueText = 'DUE TODAY';
      dueColor = AppTheme.statusPending;
    } else if (isTomorrow) {
      dueText = 'DUE TOMORROW';
      dueColor = AppTheme.statusInProgress;
    } else {
      final daysUntilDue = widget.task.dueDate.difference(now).inDays;
      dueText = 'DUE IN $daysUntilDue DAYS';
      dueColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dueColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        dueText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: dueColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCompleteButton(ThemeData theme) {
    return GestureDetector(
      onTap: widget.onComplete,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen,
              AppTheme.primaryGreen.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'COMPLETE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButtons(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onEdit != null) ...[
          GestureDetector(
            onTap: widget.onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusInProgress.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.statusInProgress.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: AppTheme.statusInProgress,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.onDelete != null) ...[
          GestureDetector(
            onTap: widget.onDelete,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusOverdue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.statusOverdue.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.delete,
                size: 16,
                color: AppTheme.statusOverdue,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
