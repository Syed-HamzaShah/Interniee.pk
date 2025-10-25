import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/feedback_card.dart';
import '../../widgets/shimmer_widget.dart';
import '../../utils/app_theme.dart';
import '../profile_screen.dart';
import 'submit_feedback_screen.dart';
import 'my_feedback_screen.dart';

class FeedbackHomeScreen extends StatefulWidget {
  const FeedbackHomeScreen({super.key});

  @override
  State<FeedbackHomeScreen> createState() => _FeedbackHomeScreenState();
}

class _FeedbackHomeScreenState extends State<FeedbackHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Dashboard', 'My Feedback'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isTablet = screenWidth > 768;

            if (screenWidth < 400) {
              return Text(
                'Welcome, ${(authProvider.userModel?.name ?? 'User').split(' ').first}',
                style: TextStyle(fontSize: isTablet ? 20 : 18),
              );
            }
            return Text(
              'Welcome, ${authProvider.userModel?.name ?? 'User'}',
              style: TextStyle(fontSize: isTablet ? 20 : 18),
            );
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDashboardTab(feedbackProvider), _buildMyFeedbackTab()],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToSubmitFeedback(),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add),
          label: const Text(
            'Submit Feedback',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTab(FeedbackProvider feedbackProvider) {
    return _buildRecentFeedback(feedbackProvider);
  }

  Widget _buildMyFeedbackTab() {
    return const MyFeedbackScreen();
  }

  Widget _buildRecentFeedback(FeedbackProvider feedbackProvider) {
    return StreamBuilder<List<dynamic>>(
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

        final feedbacks = snapshot.data ?? [];
        final recentFeedbacks = feedbacks.take(5).toList();

        if (recentFeedbacks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback, size: 64, color: AppTheme.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No feedback yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submit your first feedback to get started',
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
                itemCount: recentFeedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = recentFeedbacks[index];
                  return FeedbackCard(
                    feedback: feedback,
                    onTap: () => _showFeedbackDetails(feedback),
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

  void _showFeedbackDetails(dynamic feedback) {
    if (feedback == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feedback.categoryDisplayName ?? 'Feedback Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feedback.name != null && feedback.name!.isNotEmpty) ...[
                _buildDetailRow('Name', feedback.name!),
              ],
              _buildDetailRow(
                'Category',
                feedback.categoryDisplayName ?? 'Unknown',
              ),
              _buildDetailRow('Rating', feedback.ratingStars ?? 'No Rating'),
              _buildDetailRow(
                'Status',
                feedback.statusDisplayName ?? 'Unknown',
              ),
              _buildDetailRow(
                'Submitted',
                feedback.formattedCreatedAt ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              Text('Comments:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(feedback.comments ?? 'No comments provided'),
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

  void _navigateToSubmitFeedback() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SubmitFeedbackScreen()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            child: const Text('Logout'),
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
