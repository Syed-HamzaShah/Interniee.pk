import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _generateMonthlyReport();
  }

  Future<void> _generateMonthlyReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final startOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1,
      );
      final endOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      );

      // Get all users
      final users = await adminProvider.getAllUsers().first;
      final tasks = await adminProvider.getAllTasks().first;

      // Filter tasks for this month
      final monthlyTasks = tasks.where((task) {
        return task.createdAt.isAfter(
              startOfMonth.subtract(const Duration(days: 1)),
            ) &&
            task.createdAt.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).toList();

      // Calculate statistics
      final totalTasks = monthlyTasks.length;
      final completedTasks = monthlyTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final pendingTasks = monthlyTasks
          .where((task) => task.status == TaskStatus.pending)
          .length;
      final inProgressTasks = monthlyTasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length;
      final overdueTasks = monthlyTasks.where((task) => task.isOverdue).length;

      // Calculate completion rate
      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks * 100)
          : 0.0;

      // Calculate weekly breakdown
      final weeklyBreakdown = <String, Map<String, int>>{};
      for (int i = 0; i < 4; i++) {
        final weekStart = startOfMonth.add(Duration(days: i * 7));
        final weekEnd = weekStart.add(const Duration(days: 6));
        if (weekEnd.isAfter(endOfMonth)) break;

        final weekTasks = monthlyTasks.where((task) {
          return task.createdAt.isAfter(
                weekStart.subtract(const Duration(days: 1)),
              ) &&
              task.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
        }).toList();

        weeklyBreakdown['Week ${i + 1}'] = {
          'total': weekTasks.length,
          'completed': weekTasks
              .where((task) => task.status == TaskStatus.completed)
              .length,
          'pending': weekTasks
              .where((task) => task.status == TaskStatus.pending)
              .length,
          'inProgress': weekTasks
              .where((task) => task.status == TaskStatus.inProgress)
              .length,
        };
      }

      // Get user performance
      final userPerformance = <String, Map<String, dynamic>>{};

      for (final user in users.where((u) => u.role == UserRole.intern)) {
        final userTasks = monthlyTasks
            .where((task) => task.assignedToId == user.id)
            .toList();
        final userCompleted = userTasks
            .where((task) => task.status == TaskStatus.completed)
            .length;
        final userCompletionRate = userTasks.isNotEmpty
            ? (userCompleted / userTasks.length * 100)
            : 0.0;

        userPerformance[user.id] = {
          'user': user,
          'totalTasks': userTasks.length,
          'completedTasks': userCompleted,
          'completionRate': userCompletionRate,
          'performanceGrade': _calculateGrade(userCompletionRate),
          'avgTasksPerWeek': userTasks.length / 4,
        };
      }

      // Calculate trends (compare with previous month)
      final prevMonthStart = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      final prevMonthEnd = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        0,
      );

      final prevMonthTasks = tasks.where((task) {
        return task.createdAt.isAfter(
              prevMonthStart.subtract(const Duration(days: 1)),
            ) &&
            task.createdAt.isBefore(prevMonthEnd.add(const Duration(days: 1)));
      }).toList();

      final prevMonthCompleted = prevMonthTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final prevMonthCompletionRate = prevMonthTasks.isNotEmpty
          ? (prevMonthCompleted / prevMonthTasks.length * 100)
          : 0.0;

      final completionTrend = completionRate - prevMonthCompletionRate;

      setState(() {
        _reportData = {
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'pendingTasks': pendingTasks,
          'inProgressTasks': inProgressTasks,
          'overdueTasks': overdueTasks,
          'completionRate': completionRate,
          'completionTrend': completionTrend,
          'userPerformance': userPerformance,
          'weeklyBreakdown': weeklyBreakdown,
          'startDate': startOfMonth,
          'endDate': endOfMonth,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppTheme.statusOverdue,
          ),
        );
      }
    }
  }

  String _calculateGrade(double completionRate) {
    if (completionRate >= 90) return 'A';
    if (completionRate >= 80) return 'B';
    if (completionRate >= 70) return 'C';
    if (completionRate >= 60) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Monthly Report'),
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateMonthlyReport,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment,
                    size: 64,
                    color: AppTheme.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _buildMonthSelector(),

                  const SizedBox(height: 24),

                  // Overall statistics
                  _buildOverallStats(),

                  const SizedBox(height: 24),

                  // Weekly breakdown
                  _buildWeeklyBreakdown(),

                  const SizedBox(height: 24),

                  // User performance
                  _buildUserPerformance(),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Month',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                Text(
                  '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _selectMonth,
            icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    final trend = _reportData['completionTrend'] as double;
    final isPositive = trend >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.darkCard, AppTheme.darkCard.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Overall Performance',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(
                    0.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Completion rate
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '${_reportData['completionRate'].toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Completion Rate',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Task statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Tasks',
                  _reportData['totalTasks'].toString(),
                  Icons.task,
                  AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _reportData['completedTasks'].toString(),
                  Icons.check_circle,
                  AppTheme.statusCompleted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'In Progress',
                  _reportData['inProgressTasks'].toString(),
                  Icons.play_circle,
                  AppTheme.statusInProgress,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Overdue',
                  _reportData['overdueTasks'].toString(),
                  Icons.warning,
                  AppTheme.statusOverdue,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    final weeklyBreakdown =
        _reportData['weeklyBreakdown'] as Map<String, Map<String, int>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Breakdown',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...weeklyBreakdown.entries.map<Widget>((entry) {
          final weekName = entry.key;
          final data = entry.value;
          final completionRate = data['total']! > 0
              ? (data['completed']! / data['total']! * 100)
              : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      weekName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMiniStat(
                        'Total',
                        data['total']!.toString(),
                        Icons.task,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniStat(
                        'Completed',
                        data['completed']!.toString(),
                        Icons.check_circle,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniStat(
                        'In Progress',
                        data['inProgress']!.toString(),
                        Icons.play_circle,
                      ),
                    ),
                    Expanded(
                      child: _buildMiniStat(
                        'Pending',
                        data['pending']!.toString(),
                        Icons.pending,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPerformance() {
    final userPerformance =
        _reportData['userPerformance'] as Map<String, dynamic>;

    if (userPerformance.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.people, size: 48, color: AppTheme.textDisabled),
            const SizedBox(height: 16),
            Text(
              'No user performance data',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textDisabled),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Performance',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ...userPerformance.values.map<Widget>((performance) {
          final user = performance['user'] as UserModel;
          final completionRate = performance['completionRate'] as double;
          final grade = performance['performanceGrade'] as String;
          final avgTasksPerWeek = performance['avgTasksPerWeek'] as double;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${performance['completedTasks']}/${performance['totalTasks']} tasks completed',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${avgTasksPerWeek.toStringAsFixed(1)} tasks/week average',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(grade).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getGradeColor(grade)),
                      ),
                      child: Text(
                        'Grade: $grade',
                        style: TextStyle(
                          color: _getGradeColor(grade),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<void> _selectMonth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedMonth = selectedDate;
      });
      _generateMonthlyReport();
    }
  }
}
