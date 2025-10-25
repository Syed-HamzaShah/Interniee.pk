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
      appBar: AppBar(
        title: const Text('My Feedback'),
        backgroundColor: AppTheme.darkSurface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
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
      body: TabBarView(
        controller: _tabController,
        children: _categoryTabs
            .map((category) => _buildFeedbackList(category, feedbackProvider))
            .toList(),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
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
