import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';

class FeedbackCard extends StatefulWidget {
  final FeedbackModel feedback;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showAdminActions;
  final bool showUserActions;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.showAdminActions = false,
    this.showUserActions = false,
  });

  @override
  State<FeedbackCard> createState() => _FeedbackCardState();
}

class _FeedbackCardState extends State<FeedbackCard>
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
    final isTablet = context.isTablet;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: ResponsiveHelper.getResponsiveMargin(
              context,
              mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              color: _glowAnimation.value,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.1),
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
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(20),
                      tablet: const EdgeInsets.all(24),
                      desktop: const EdgeInsets.all(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with category and status
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.feedback.categoryDisplayName,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  if (widget.feedback.name != null &&
                                      widget.feedback.name!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.feedback.name!,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusChip(theme),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Rating stars
                        _buildRatingStars(theme),

                        const SizedBox(height: 12),

                        // Comments
                        if (widget.feedback.comments.isNotEmpty) ...[
                          Text(
                            widget.feedback.comments,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Category and date row
                        Row(
                          children: [
                            _buildCategoryChip(theme),
                            const Spacer(),
                            _buildDateText(theme),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Footer row with user info and action buttons
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'By: ${widget.feedback.userName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textDisabled,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.showAdminActions) ...[
                              _buildAdminActionButtons(theme),
                            ],
                            if (widget.showUserActions) ...[
                              _buildUserActionButtons(theme),
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
          colors: [_getStatusColor(), _getStatusColor().withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        widget.feedback.statusDisplayName.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_getCategoryColor(), _getCategoryColor().withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getCategoryColor().withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        widget.feedback.categoryDisplayName.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRatingStars(ThemeData theme) {
    return Row(
      children: List.generate(5, (index) {
        final isFilled = index < widget.feedback.rating;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: isFilled ? AppTheme.statusPending : AppTheme.textDisabled,
          size: 20,
        );
      }),
    );
  }

  Widget _buildDateText(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        widget.feedback.formattedCreatedAt.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAdminActionButtons(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.feedback.status == FeedbackStatus.pending) ...[
          GestureDetector(
            onTap: widget.onApprove,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusCompleted.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.statusCompleted.withOpacity(0.3),
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: AppTheme.statusCompleted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onReject,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.statusOverdue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.statusOverdue.withOpacity(0.3),
                ),
              ),
              child: Icon(Icons.close, size: 16, color: AppTheme.statusOverdue),
            ),
          ),
        ],
        if (widget.onDelete != null) ...[
          const SizedBox(width: 8),
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

  Widget _buildUserActionButtons(ThemeData theme) {
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

  Color _getStatusColor() {
    switch (widget.feedback.status) {
      case FeedbackStatus.pending:
        return AppTheme.statusPending;
      case FeedbackStatus.approved:
        return AppTheme.statusCompleted;
      case FeedbackStatus.rejected:
        return AppTheme.statusOverdue;
    }
  }

  Color _getCategoryColor() {
    switch (widget.feedback.category) {
      case FeedbackCategory.course:
        return AppTheme.statusInProgress;
      case FeedbackCategory.internship:
        return const Color(0xFFAB47BC); // Purple
      case FeedbackCategory.company:
        return const Color(0xFF26A69A); // Teal
      case FeedbackCategory.experience:
        return AppTheme.statusPending;
    }
  }
}
