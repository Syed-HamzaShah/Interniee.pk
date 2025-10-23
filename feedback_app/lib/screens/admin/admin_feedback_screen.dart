import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback_model.dart';
import '../../widgets/feedback_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../utils/app_theme.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<FeedbackStatus> _statusTabs = [
    FeedbackStatus.pending,
    FeedbackStatus.approved,
    FeedbackStatus.rejected,
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
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Manage Feedback'),
        backgroundColor: AppTheme.darkSurface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,

        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _statusTabs
              .map(
                (status) => Tab(
                  text: _getStatusDisplayName(status),
                  icon: Icon(_getStatusIcon(status)),
                ),
              )
              .toList(),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildStatsOverview(feedbackProvider)),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _statusTabs
              .map((status) => _buildFeedbackList(status, feedbackProvider))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(FeedbackProvider feedbackProvider) {
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
            'Feedback Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
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
                    feedbackProvider.totalFeedbacks.toString(),
                    Icons.feedback,
                    AppTheme.primaryGreen,
                  ),
                  _buildStatItem(
                    'Pending',
                    feedbackProvider.pendingFeedbacks.toString(),
                    Icons.pending_actions,
                    AppTheme.statusPending,
                  ),
                  _buildStatItem(
                    'Approved',
                    feedbackProvider.approvedFeedbacks.toString(),
                    Icons.check_circle,
                    AppTheme.statusCompleted,
                  ),
                  _buildStatItem(
                    'Rejected',
                    feedbackProvider.rejectedFeedbacks.toString(),
                    Icons.cancel,
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

  Widget _buildFeedbackList(
    FeedbackStatus status,
    FeedbackProvider feedbackProvider,
  ) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: feedbackProvider.getFeedbacksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                isLoading: true,
                child: const ShimmerFeedbackCard(),
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
                  'Error loading feedback',
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
                  onPressed: () => feedbackProvider.refreshFeedbacks(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final allFeedbacks = snapshot.data ?? [];
        final statusFeedbacks = allFeedbacks
            .where((feedback) => feedback.status == status)
            .toList();

        if (statusFeedbacks.isEmpty) {
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
                  'No ${_getStatusDisplayName(status).toLowerCase()} feedback',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status == FeedbackStatus.pending
                      ? 'No feedback awaiting review'
                      : status == FeedbackStatus.approved
                      ? 'No approved feedback'
                      : 'No rejected feedback',
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
          onRefresh: () => feedbackProvider.refreshFeedbacks(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: statusFeedbacks.length,
            itemBuilder: (context, index) {
              final feedback = statusFeedbacks[index];
              return FeedbackCard(
                feedback: feedback,
                onTap: () => _showFeedbackDetails(feedback),
                onApprove: status == FeedbackStatus.pending
                    ? () => _approveFeedback(feedback)
                    : null,
                onReject: status == FeedbackStatus.pending
                    ? () => _rejectFeedback(feedback)
                    : null,
                onDelete: () => _deleteFeedback(feedback),
                showAdminActions: true,
              );
            },
          ),
        );
      },
    );
  }

  String _getStatusDisplayName(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return 'Pending';
      case FeedbackStatus.approved:
        return 'Approved';
      case FeedbackStatus.rejected:
        return 'Rejected';
    }
  }

  IconData _getStatusIcon(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return Icons.pending;
      case FeedbackStatus.approved:
        return Icons.check_circle;
      case FeedbackStatus.rejected:
        return Icons.cancel;
    }
  }

  void _showFeedbackDetails(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feedback.categoryDisplayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('User', feedback.userName),
              _buildDetailRow('Email', feedback.userEmail),
              if (feedback.name != null) ...[
                _buildDetailRow('Name', feedback.name!),
              ],
              _buildDetailRow('Category', feedback.categoryDisplayName),
              _buildDetailRow('Rating', feedback.ratingStars),
              _buildDetailRow('Status', feedback.statusDisplayName),
              _buildDetailRow('Submitted', feedback.formattedCreatedAt),
              const SizedBox(height: 16),
              Text('Comments:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(feedback.comments),
              if (feedback.adminNotes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Admin Notes:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(feedback.adminNotes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (feedback.status == FeedbackStatus.pending) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _approveFeedback(feedback);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCompleted,
              ),
              child: const Text('Approve'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _rejectFeedback(feedback);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusOverdue,
              ),
              child: const Text('Reject'),
            ),
          ],
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

  void _approveFeedback(FeedbackModel feedback) {
    _updateFeedbackStatus(
      feedback,
      FeedbackStatus.approved,
      'Feedback approved',
    );
  }

  void _rejectFeedback(FeedbackModel feedback) {
    _showRejectDialog(feedback);
  }

  void _showRejectDialog(FeedbackModel feedback) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject this feedback?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Rejection Notes (Optional)',
                hintText: 'Add notes about why this feedback was rejected...',
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
              Navigator.of(context).pop();
              await _updateFeedbackStatus(
                feedback,
                FeedbackStatus.rejected,
                'Feedback rejected',
                adminNotes: notesController.text.trim().isNotEmpty
                    ? notesController.text.trim()
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFeedbackStatus(
    FeedbackModel feedback,
    FeedbackStatus status,
    String successMessage, {
    String? adminNotes,
  }) async {
    final feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );

    final success = await feedbackProvider.updateFeedbackStatus(
      feedbackId: feedback.id,
      status: status,
      adminNotes: adminNotes,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? successMessage : 'Failed to update feedback'),
          backgroundColor: success
              ? AppTheme.primaryGreen
              : AppTheme.statusOverdue,
        ),
      );
    }
  }

  void _deleteFeedback(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: Text(
          'Are you sure you want to delete this feedback? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final feedbackProvider = Provider.of<FeedbackProvider>(
                context,
                listen: false,
              );
              final success = await feedbackProvider.deleteFeedback(
                feedback.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Feedback deleted successfully!'
                          : 'Failed to delete feedback',
                    ),
                    backgroundColor: success
                        ? AppTheme.primaryGreen
                        : AppTheme.statusOverdue,
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
}

// Shimmer widget for feedback card
class ShimmerFeedbackCard extends StatelessWidget {
  const ShimmerFeedbackCard({super.key});

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
              const SizedBox(width: 12),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.textDisabled.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
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
