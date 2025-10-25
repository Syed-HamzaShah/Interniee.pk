import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/intern_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/intern_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';
import 'intern_details_screen.dart';

class PerformanceReportsScreen extends StatefulWidget {
  const PerformanceReportsScreen({super.key});

  @override
  State<PerformanceReportsScreen> createState() =>
      _PerformanceReportsScreenState();
}

class _PerformanceReportsScreenState extends State<PerformanceReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Overview', 'Individual', 'Comparison'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final internProvider = Provider.of<InternProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await Future.wait([
      internProvider.loadInterns(),
      taskProvider.loadAllTasks(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Performance Reports'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
          PopupMenuButton<String>(
            onSelected: _handleExportAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, size: 20),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Export as Excel'),
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
          _buildOverviewTab(),
          _buildIndividualTab(),
          _buildComparisonTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<InternProvider, TaskProvider>(
      builder: (context, internProvider, taskProvider, child) {
        if (internProvider.isLoading || taskProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null ||
            taskProvider.errorMessage != null) {
          return _buildErrorWidget(
            internProvider.errorMessage ?? taskProvider.errorMessage!,
          );
        }

        final interns = internProvider.interns;
        final tasks = taskProvider.tasks;

        if (interns.isEmpty) {
          return _buildEmptyWidget();
        }

        final overallStats = _calculateOverallStats(interns, tasks);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallStatsCard(overallStats),
              const SizedBox(height: 16),
              _buildPerformanceList(interns, tasks),
              const SizedBox(height: 16),
              _buildTopPerformersCard(interns, tasks),
              const SizedBox(height: 16),
              _buildTaskDistributionList(tasks),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndividualTab() {
    return Consumer2<InternProvider, TaskProvider>(
      builder: (context, internProvider, taskProvider, child) {
        if (internProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null) {
          return _buildErrorWidget(internProvider.errorMessage!);
        }

        if (internProvider.interns.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: internProvider.interns.length,
          itemBuilder: (context, index) {
            final intern = internProvider.interns[index];
            final internTasks = taskProvider.tasks
                .where((task) => task.assignedTo == intern.id)
                .toList();
            return _buildIndividualPerformanceCard(intern, internTasks);
          },
        );
      },
    );
  }

  Widget _buildComparisonTab() {
    return Consumer2<InternProvider, TaskProvider>(
      builder: (context, internProvider, taskProvider, child) {
        if (internProvider.isLoading) {
          return _buildLoadingWidget();
        }

        if (internProvider.errorMessage != null) {
          return _buildErrorWidget(internProvider.errorMessage!);
        }

        if (internProvider.interns.isEmpty) {
          return _buildEmptyWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComparisonChart(internProvider.interns, taskProvider.tasks),
              const SizedBox(height: 16),
              _buildRankingTable(internProvider.interns, taskProvider.tasks),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading performance data...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.statusOverdue),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.statusOverdue),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: AppTheme.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              'No performance data available',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textDisabled),
            ),
            const SizedBox(height: 8),
            Text(
              'No interns or tasks found to generate reports.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(OverallStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Interns',
                    stats.totalInterns.toString(),
                    Icons.people,
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Total Tasks',
                    stats.totalTasks.toString(),
                    Icons.assignment,
                    AppTheme.statusInProgress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Completion Rate',
                    '${stats.overallCompletionRate.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    AppTheme.statusCompleted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Avg. Rating',
                    stats.averageRating.toStringAsFixed(1),
                    Icons.star,
                    AppTheme.statusInProgress,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceList(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Rates by Intern',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...interns.map((intern) {
              final internTasks = tasks
                  .where((task) => task.assignedTo == intern.id)
                  .toList();
              final completedTasks = internTasks
                  .where((task) => task.status == TaskStatus.completed)
                  .length;
              final completionRate = internTasks.isEmpty
                  ? 0.0
                  : (completedTasks / internTasks.length) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        intern.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${completionRate.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getPerformanceColor(completionRate),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        backgroundColor: AppTheme.textDisabled.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPerformanceColor(completionRate),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersCard(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    final performers = _getTopPerformers(interns, tasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...performers.asMap().entries.map((entry) {
              final index = entry.key;
              final performer = entry.value;
              return _buildPerformerItem(index + 1, performer);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerItem(int rank, PerformerData performer) {
    Color rankColor;
    IconData rankIcon;

    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankIcon = Icons.emoji_events;
        break;
      case 3:
        rankColor = Colors.orange[300]!;
        rankIcon = Icons.emoji_events;
        break;
      default:
        rankColor = AppTheme.textSecondary;
        rankIcon = Icons.person;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(rankIcon, color: rankColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performer.intern.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${performer.completionRate.toStringAsFixed(1)}% completion rate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${performer.totalTasks} tasks',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDistributionList(List<TaskModel> tasks) {
    final statusCounts = {
      'Completed': tasks
          .where((task) => task.status == TaskStatus.completed)
          .length,
      'In Progress': tasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length,
      'Not Started': tasks
          .where((task) => task.status == TaskStatus.notStarted)
          .length,
      'Overdue': tasks.where((task) => task.isOverdue).length,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...statusCounts.entries.map((entry) {
              Color color;
              IconData icon;
              switch (entry.key) {
                case 'Completed':
                  color = AppTheme.statusCompleted;
                  icon = Icons.check_circle;
                  break;
                case 'In Progress':
                  color = AppTheme.statusInProgress;
                  icon = Icons.hourglass_empty;
                  break;
                case 'Not Started':
                  color = AppTheme.statusPending;
                  icon = Icons.assignment;
                  break;
                case 'Overdue':
                  color = AppTheme.statusOverdue;
                  icon = Icons.warning;
                  break;
                default:
                  color = AppTheme.textSecondary;
                  icon = Icons.help;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualPerformanceCard(
    InternModel intern,
    List<TaskModel> tasks,
  ) {
    final stats = _calculateInternStats(intern, tasks);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToInternDetails(intern),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                    child: Text(
                      intern.name.isNotEmpty
                          ? intern.name[0].toUpperCase()
                          : 'I',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          intern.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          intern.email,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPerformanceColor(
                        stats.completionRate,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPerformanceStatus(stats.completionRate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getPerformanceColor(stats.completionRate),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Tasks',
                      stats.totalTasks.toString(),
                      Icons.assignment,
                      AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Completed',
                      stats.completedTasks.toString(),
                      Icons.check_circle,
                      AppTheme.statusCompleted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPerformanceMetric(
                      'Rate',
                      '${stats.completionRate.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      _getPerformanceColor(stats.completionRate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: stats.completionRate / 100,
                backgroundColor: AppTheme.textDisabled.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getPerformanceColor(stats.completionRate),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Comparison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Comparison chart implementation coming soon'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTable(List<InternModel> interns, List<TaskModel> tasks) {
    final rankings = _getRankings(interns, tasks);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Rankings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Rank')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Tasks')),
                  DataColumn(label: Text('Completed')),
                  DataColumn(label: Text('Rate')),
                  DataColumn(label: Text('Rating')),
                ],
                rows: rankings.map((ranking) {
                  return DataRow(
                    cells: [
                      DataCell(Text(ranking.rank.toString())),
                      DataCell(Text(ranking.intern.name)),
                      DataCell(Text(ranking.totalTasks.toString())),
                      DataCell(Text(ranking.completedTasks.toString())),
                      DataCell(
                        Text('${ranking.completionRate.toStringAsFixed(1)}%'),
                      ),
                      DataCell(Text(ranking.averageRating.toStringAsFixed(1))),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(List<InternModel> interns, List<TaskModel> tasks) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Trends chart implementation coming soon'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyPerformanceCard(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Monthly performance data coming soon')),
          ],
        ),
      ),
    );
  }

  OverallStats _calculateOverallStats(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    final totalInterns = interns.length;
    final totalTasks = tasks.length;
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final overallCompletionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100
        : 0.0;

    double totalRating = 0.0;
    int ratingCount = 0;
    for (final intern in interns) {
      if (intern.averageRating > 0) {
        totalRating += intern.averageRating;
        ratingCount++;
      }
    }
    final averageRating = ratingCount > 0 ? totalRating / ratingCount : 0.0;

    return OverallStats(
      totalInterns: totalInterns,
      totalTasks: totalTasks,
      overallCompletionRate: overallCompletionRate,
      averageRating: averageRating,
    );
  }

  List<PerformerData> _getTopPerformers(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    final performers = <PerformerData>[];

    for (final intern in interns) {
      final internTasks = tasks
          .where((task) => task.assignedTo == intern.id)
          .toList();
      final completedTasks = internTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final completionRate = internTasks.isEmpty
          ? 0.0
          : (completedTasks / internTasks.length) * 100;

      performers.add(
        PerformerData(
          intern: intern,
          totalTasks: internTasks.length,
          completedTasks: completedTasks,
          completionRate: completionRate,
        ),
      );
    }

    performers.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return performers.take(5).toList();
  }

  List<RankingData> _getRankings(
    List<InternModel> interns,
    List<TaskModel> tasks,
  ) {
    final rankings = <RankingData>[];

    for (int i = 0; i < interns.length; i++) {
      final intern = interns[i];
      final internTasks = tasks
          .where((task) => task.assignedTo == intern.id)
          .toList();
      final completedTasks = internTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final completionRate = internTasks.isEmpty
          ? 0.0
          : (completedTasks / internTasks.length) * 100;

      rankings.add(
        RankingData(
          rank: i + 1,
          intern: intern,
          totalTasks: internTasks.length,
          completedTasks: completedTasks,
          completionRate: completionRate,
          averageRating: intern.averageRating,
        ),
      );
    }

    rankings.sort((a, b) => b.completionRate.compareTo(a.completionRate));

    for (int i = 0; i < rankings.length; i++) {
      rankings[i] = rankings[i].copyWith(rank: i + 1);
    }

    return rankings;
  }

  InternStats _calculateInternStats(InternModel intern, List<TaskModel> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks) * 100
        : 0.0;

    return InternStats(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      completionRate: completionRate,
    );
  }

  Color _getPerformanceColor(double completionRate) {
    if (completionRate >= 90) return AppTheme.statusCompleted;
    if (completionRate >= 70) return AppTheme.primaryGreen;
    if (completionRate >= 50) return AppTheme.statusInProgress;
    return AppTheme.statusOverdue;
  }

  String _getPerformanceStatus(double completionRate) {
    if (completionRate >= 90) return 'Excellent';
    if (completionRate >= 70) return 'Good';
    if (completionRate >= 50) return 'Average';
    return 'Needs Improvement';
  }

  void _navigateToInternDetails(InternModel intern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InternDetailsScreen(intern: intern),
      ),
    );
  }

  void _handleExportAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Export as ${action.split('_')[1].toUpperCase()} - Coming soon',
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }
}

class OverallStats {
  final int totalInterns;
  final int totalTasks;
  final double overallCompletionRate;
  final double averageRating;

  OverallStats({
    required this.totalInterns,
    required this.totalTasks,
    required this.overallCompletionRate,
    required this.averageRating,
  });
}

class PerformerData {
  final InternModel intern;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;

  PerformerData({
    required this.intern,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
  });
}

class RankingData {
  final int rank;
  final InternModel intern;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final double averageRating;

  RankingData({
    required this.rank,
    required this.intern,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.averageRating,
  });

  RankingData copyWith({
    int? rank,
    InternModel? intern,
    int? totalTasks,
    int? completedTasks,
    double? completionRate,
    double? averageRating,
  }) {
    return RankingData(
      rank: rank ?? this.rank,
      intern: intern ?? this.intern,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      completionRate: completionRate ?? this.completionRate,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

class InternStats {
  final int totalTasks;
  final int completedTasks;
  final double completionRate;

  InternStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
  });
}
