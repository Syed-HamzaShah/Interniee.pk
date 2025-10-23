import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/shimmer_widget.dart';
import 'admin_feedback_screen.dart';
import 'firebase_data_screen.dart';
import '../profile_screen.dart';
import '../analytics/analytics_screen.dart';
import '../../utils/app_theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Feedback', 'Firebase Data'];

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
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(feedbackProvider),
          _buildFeedbackTab(),
          _buildFirebaseDataTab(),
        ],
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
          onPressed: () => _navigateToFeedbackManagement(),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.feedback),
          label: const Text(
            'Manage Feedback',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(FeedbackProvider feedbackProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(feedbackProvider),

          const SizedBox(height: 24),

          Text(
            'Recent Feedback',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildRecentFeedback(feedbackProvider),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FeedbackProvider feedbackProvider) {
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
          Text(
            'Feedback Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Feedback',
                  feedbackProvider.totalFeedbacks.toString(),
                  Icons.feedback,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  feedbackProvider.pendingFeedbacks.toString(),
                  Icons.pending,
                  AppTheme.statusPending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  feedbackProvider.approvedFeedbacks.toString(),
                  Icons.check_circle,
                  AppTheme.statusCompleted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Rating',
                  feedbackProvider.averageRating.toStringAsFixed(1),
                  Icons.star,
                  AppTheme.statusInProgress,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
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
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFeedback(FeedbackProvider feedbackProvider) {
    return StreamBuilder<List<dynamic>>(
      stream: feedbackProvider.getFeedbacksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
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
        }

        final feedbacks = snapshot.data ?? [];
        final recentFeedbacks = feedbacks.take(5).toList();

        if (recentFeedbacks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.feedback, size: 48, color: AppTheme.textDisabled),
                const SizedBox(height: 16),
                Text(
                  'No feedback yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textDisabled,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentFeedbacks.length,
          itemBuilder: (context, index) {
            final feedback = recentFeedbacks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getCategoryColor(feedback.category),
                  child: Icon(
                    _getCategoryIcon(feedback.category),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(feedback.categoryDisplayName),
                subtitle: Text(
                  '${feedback.ratingStars} • ${feedback.formattedCreatedAt}',
                ),
                trailing: Chip(
                  label: Text(
                    feedback.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(feedback.status),
                ),
                onTap: () => _showFeedbackDetails(feedback),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feedback Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildReportCard(
            'Manage Feedback',
            'Review, approve, and manage user feedback',
            Icons.feedback,
            () => _navigateToFeedbackManagement(),
          ),

          const SizedBox(height: 12),

          _buildReportCard(
            'Feedback Analytics',
            'View detailed analytics and insights',
            Icons.analytics,
            () => _navigateToAnalytics(),
          ),
        ],
      ),
    );
  }

  Widget _buildFirebaseDataTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Firebase Data Management',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _buildReportCard(
            'Firebase Data Management',
            'View, manage, and export all feedback data from Firebase',
            Icons.storage,
            () => _navigateToFirebaseData(),
          ),

          const SizedBox(height: 12),

          _buildReportCard(
            'Firebase Console',
            'Access Firebase Console directly for advanced data management',
            Icons.open_in_browser,
            () => _openFirebaseConsole(),
          ),

          const SizedBox(height: 12),

          _buildReportCard(
            'Export Data',
            'Export all feedback data to JSON format for backup',
            Icons.download,
            () => _exportAllData(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryGreen),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showFeedbackDetails(dynamic feedback) {
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
            width: 100,
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

  void _navigateToFeedbackManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AdminFeedbackScreen()),
    );
  }

  void _navigateToAnalytics() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
  }

  void _navigateToFirebaseData() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const FirebaseDataScreen()));
  }

  void _openFirebaseConsole() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Console'),
        content: const Text(
          'To access Firebase Console, open your browser and go to:\n\n'
          'https://console.firebase.google.com/project/interntasktracker-d127c/firestore',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please open the URL in your browser'),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _exportAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will export all feedback data to JSON format. '
          'Use the Firebase Data Management screen for detailed export options.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToFirebaseData();
            },
            child: const Text('Go to Export'),
          ),
        ],
      ),
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

  Color _getCategoryColor(dynamic category) {
    switch (category.toString()) {
      case 'FeedbackCategory.course':
        return AppTheme.statusInProgress;
      case 'FeedbackCategory.internship':
        return const Color(0xFFAB47BC);
      case 'FeedbackCategory.company':
        return const Color(0xFF26A69A);
      case 'FeedbackCategory.experience':
        return AppTheme.statusPending;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getCategoryIcon(dynamic category) {
    switch (category.toString()) {
      case 'FeedbackCategory.course':
        return Icons.school;
      case 'FeedbackCategory.internship':
        return Icons.work;
      case 'FeedbackCategory.company':
        return Icons.business;
      case 'FeedbackCategory.experience':
        return Icons.psychology;
      default:
        return Icons.feedback;
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'FeedbackStatus.pending':
        return AppTheme.statusPending;
      case 'FeedbackStatus.approved':
        return AppTheme.statusCompleted;
      case 'FeedbackStatus.rejected':
        return AppTheme.statusOverdue;
      default:
        return AppTheme.textSecondary;
    }
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
