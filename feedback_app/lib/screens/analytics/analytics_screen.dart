import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback_model.dart';
import '../../utils/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Categories', 'Ratings', 'Trends'];

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
        backgroundColor: AppTheme.darkSurface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        toolbarHeight: 10,

        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(feedbackProvider),
          _buildCategoriesTab(feedbackProvider),
          _buildRatingsTab(feedbackProvider),
          _buildTrendsTab(feedbackProvider),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(FeedbackProvider feedbackProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 768;
        final isDesktop = screenWidth > 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 32
                : isTablet
                ? 24
                : 16,
            vertical: isTablet ? 20 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecentActivity(feedbackProvider),

              SizedBox(height: isTablet ? 32 : 24),

              _buildQuickStats(feedbackProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(FeedbackProvider feedbackProvider) {
    final recentFeedbacks = feedbackProvider.recentFeedbacks.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recentFeedbacks.isEmpty)
            Center(
              child: Text(
                'No recent feedback',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textDisabled),
              ),
            )
          else
            ...recentFeedbacks.map((feedback) => _buildActivityItem(feedback)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(FeedbackModel feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getCategoryColor(feedback.category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.categoryDisplayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${feedback.ratingStars} • ${feedback.formattedCreatedAt}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(feedback.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(feedback.status).withOpacity(0.3),
              ),
            ),
            child: Text(
              feedback.statusDisplayName,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _getStatusColor(feedback.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(FeedbackProvider feedbackProvider) {
    final categoryStats = feedbackProvider.categoryStats;
    final ratingDistribution = feedbackProvider.ratingDistribution;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Category',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTopCategory(categoryStats),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Most Common Rating',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMostCommonRating(ratingDistribution),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(FeedbackProvider feedbackProvider) {
    final categoryStats = feedbackProvider.categoryStats;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Feedback by Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _buildCategorySections(categoryStats),
                      centerSpaceRadius: 35,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...categoryStats.entries.map(
                  (entry) => _buildCategoryItem(
                    entry.key,
                    entry.value,
                    categoryStats.values.reduce((a, b) => a + b),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsTab(FeedbackProvider feedbackProvider) {
    final ratingDistribution = feedbackProvider.ratingDistribution;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Rating Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: ratingDistribution.values.isEmpty
                          ? 10
                          : ratingDistribution.values
                                    .reduce((a, b) => a > b ? a : b)
                                    .toDouble() +
                                2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}★',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildRatingBars(ratingDistribution),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...ratingDistribution.entries.map(
                  (entry) => _buildRatingItem(
                    entry.key,
                    entry.value,
                    ratingDistribution.values.reduce((a, b) => a + b),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(FeedbackProvider feedbackProvider) {
    final monthlyCount = feedbackProvider.monthlyFeedbackCount;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 16,
      ),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: [
                Text(
                  'Monthly Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final months = monthlyCount.keys.toList()..sort();
                              if (value.toInt() < months.length) {
                                final monthKey = months[value.toInt()];
                                final parts = monthKey.split('-');
                                return Text(
                                  '${parts[1]}/${parts[0].substring(2)}',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 10,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: _buildTrendLines(monthlyCount),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildCategorySections(
    Map<FeedbackCategory, int> categoryStats,
  ) {
    final total = categoryStats.values.reduce((a, b) => a + b);
    if (total == 0) return [];

    return categoryStats.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildRatingBars(Map<int, int> ratingDistribution) {
    return ratingDistribution.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: _getRatingColor(entry.key),
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<LineChartBarData> _buildTrendLines(Map<String, int> monthlyCount) {
    final months = monthlyCount.keys.toList()..sort();
    final spots = months.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        monthlyCount[entry.value]!.toDouble(),
      );
    }).toList();

    return [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppTheme.primaryGreen,
        barWidth: 3,
        dotData: FlDotData(show: true),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.primaryGreen.withOpacity(0.1),
        ),
      ),
    ];
  }

  Widget _buildCategoryItem(FeedbackCategory category, int count, int total) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getCategoryDisplayName(category),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(int rating, int count, int total) {
    final percentage = total > 0 ? (count / total) * 100 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: index < rating
                    ? AppTheme.statusPending
                    : AppTheme.textDisabled,
                size: 16,
              );
            }),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$rating Star${rating > 1 ? 's' : ''}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
            ),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTopCategory(Map<FeedbackCategory, int> categoryStats) {
    if (categoryStats.isEmpty) return 'N/A';
    return _getCategoryDisplayName(
      categoryStats.entries.reduce((a, b) => a.value > b.value ? a : b).key,
    );
  }

  String _getMostCommonRating(Map<int, int> ratingDistribution) {
    if (ratingDistribution.isEmpty) return 'N/A';
    final mostCommon = ratingDistribution.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    return '${mostCommon.key} Star${mostCommon.key > 1 ? 's' : ''}';
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

  Color _getCategoryColor(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.course:
        return AppTheme.statusInProgress;
      case FeedbackCategory.internship:
        return const Color(0xFFAB47BC);
      case FeedbackCategory.company:
        return const Color(0xFF26A69A);
      case FeedbackCategory.experience:
        return AppTheme.statusPending;
    }
  }

  Color _getStatusColor(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.pending:
        return AppTheme.statusPending;
      case FeedbackStatus.approved:
        return AppTheme.statusCompleted;
      case FeedbackStatus.rejected:
        return AppTheme.statusOverdue;
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return AppTheme.statusOverdue;
      case 2:
        return const Color(0xFFFF7043);
      case 3:
        return AppTheme.statusPending;
      case 4:
        return AppTheme.statusInProgress;
      case 5:
        return AppTheme.statusCompleted;
      default:
        return AppTheme.textSecondary;
    }
  }
}
