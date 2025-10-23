import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback_model.dart';
import '../../widgets/feedback_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../utils/app_theme.dart';

class MyFeedbackScreen extends StatefulWidget {
  const MyFeedbackScreen({super.key});

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<FeedbackCategory> _categoryTabs = [
    FeedbackCategory.course,
    FeedbackCategory.internship,
    FeedbackCategory.company,
    FeedbackCategory.experience,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categoryTabs.length, vsync: this);
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: AppTheme.darkSurface,
            foregroundColor: AppTheme.textPrimary,
            elevation: 0,
            floating: true,
            pinned: true,
            centerTitle: false,
            toolbarHeight: 0,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _categoryTabs
                  .map(
                    (category) => Tab(
                      text: _getCategoryDisplayName(category),
                      icon: Icon(_getCategoryIcon(category)),
                    ),
                  )
                  .toList(),
            ),
          ),
          SliverToBoxAdapter(child: _buildStatsOverview(feedbackProvider)),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _categoryTabs
              .map((category) => _buildFeedbackList(category, feedbackProvider))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(FeedbackProvider feedbackProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 768;
        final isDesktop = screenWidth > 1024;

        return Container(
          margin: EdgeInsets.all(isTablet ? 8 : 8),
          padding: EdgeInsets.all(isTablet ? 8 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                blurRadius: isTablet ? 24 : 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Feedback Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: isTablet ? 20 : 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 20 : 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;
                  double spacing;

                  if (isDesktop) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.1;
                    spacing = 16;
                  } else if (isTablet) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.3;
                    spacing = 14;
                  } else if (screenWidth > 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.4;
                    spacing = 12;
                  } else if (screenWidth > 400) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.6;
                    spacing = 10;
                  } else {
                    crossAxisCount = 2;
                    childAspectRatio = 1.8;
                    spacing = 8;
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      children: [
                        _buildStatItem(
                          'Total',
                          feedbackProvider.totalFeedbacks.toString(),
                          Icons.feedback,
                          AppTheme.primaryGreen,
                          isTablet: isTablet,
                        ),
                        _buildStatItem(
                          'Approved',
                          feedbackProvider.approvedFeedbacks.toString(),
                          Icons.check_circle,
                          AppTheme.statusCompleted,
                          isTablet: isTablet,
                        ),
                        _buildStatItem(
                          'Pending',
                          feedbackProvider.pendingFeedbacks.toString(),
                          Icons.pending_actions,
                          AppTheme.statusPending,
                          isTablet: isTablet,
                        ),
                        _buildStatItem(
                          'Avg Rating',
                          feedbackProvider.averageRating.toStringAsFixed(1),
                          Icons.star,
                          AppTheme.statusInProgress,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isTablet = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isTablet ? 32 : 28),
          SizedBox(height: isTablet ? 10 : 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isTablet ? 6 : 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: isTablet ? 13 : 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackList(
    FeedbackCategory category,
    FeedbackProvider feedbackProvider,
  ) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: feedbackProvider.getFeedbacksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isTablet = screenWidth > 768;

              return ListView.builder(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ShimmerWidget(
                    isLoading: true,
                    child: const ShimmerFeedbackCard(),
                  );
                },
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
        final categoryFeedbacks = allFeedbacks
            .where((feedback) => feedback.category == category)
            .toList();

        if (categoryFeedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 64,
                  color: AppTheme.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_getCategoryDisplayName(category).toLowerCase()} feedback',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share your ${_getCategoryDisplayName(category).toLowerCase()} experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Use the floating button below to submit feedback',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => feedbackProvider.refreshFeedbacks(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isTablet = screenWidth > 768;

              return ListView.builder(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categoryFeedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = categoryFeedbacks[index];
                  return FeedbackCard(
                    feedback: feedback,
                    onTap: () => _showFeedbackDetails(feedback),
                    onEdit: () => _editFeedback(feedback),
                    onDelete: () => _deleteFeedback(feedback),
                    showUserActions: true,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getCategoryDisplayName(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.course:
        return 'Course';
      case FeedbackCategory.internship:
        return 'Internship';
      case FeedbackCategory.company:
        return 'Company';
      case FeedbackCategory.experience:
        return 'Experience';
    }
  }

  IconData _getCategoryIcon(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.course:
        return Icons.school;
      case FeedbackCategory.internship:
        return Icons.work;
      case FeedbackCategory.company:
        return Icons.business;
      case FeedbackCategory.experience:
        return Icons.psychology;
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
              if (feedback.name != null && feedback.name!.isNotEmpty) ...[
                _buildDetailRow('Name', feedback.name!),
              ],
              _buildDetailRow('Category', feedback.categoryDisplayName),
              _buildDetailRow('Rating', feedback.ratingStars),
              _buildDetailRow('Status', feedback.statusDisplayName),
              _buildDetailRow('Submitted', feedback.formattedCreatedAt),
              const SizedBox(height: 16),
              Text('Comments:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                feedback.comments.isNotEmpty
                    ? feedback.comments
                    : 'No comments provided',
              ),
              if (feedback.adminNotes != null &&
                  feedback.adminNotes!.isNotEmpty) ...[
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

  void _editFeedback(FeedbackModel feedback) {
    // For now, show a message that editing is not available
    // In a real app, you might want to implement editing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Editing feedback is not available. Please submit a new feedback.',
        ),
        backgroundColor: AppTheme.statusPending,
      ),
    );
  }

  void _deleteFeedback(FeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: Text('Are you sure you want to delete this feedback?'),
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
