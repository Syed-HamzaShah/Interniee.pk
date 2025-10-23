import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_theme.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  DateTime _selectedWeek = DateTime.now();
  bool _isLoading = false;
  Map<String, dynamic> _reportData = {};

  @override
  void initState() {
    super.initState();
    _generateWeeklyReport();
  }

  Future<void> _generateWeeklyReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Get all users
      final users = await adminProvider.getAllUsers().first;
      final tasks = await adminProvider.getAllTasks().first;

      // Filter tasks for this week
      final weeklyTasks = tasks.where((task) {
        return task.createdAt.isAfter(
              startOfWeek.subtract(const Duration(days: 1)),
            ) &&
            task.createdAt.isBefore(endOfWeek.add(const Duration(days: 1)));
      }).toList();

      // Calculate statistics
      final totalTasks = weeklyTasks.length;
      final completedTasks = weeklyTasks
          .where((task) => task.status == TaskStatus.completed)
          .length;
      final pendingTasks = weeklyTasks
          .where((task) => task.status == TaskStatus.pending)
          .length;
      final inProgressTasks = weeklyTasks
          .where((task) => task.status == TaskStatus.inProgress)
          .length;
      final overdueTasks = weeklyTasks.where((task) => task.isOverdue).length;

      // Calculate completion rate
      final completionRate = totalTasks > 0
          ? (completedTasks / totalTasks * 100)
          : 0.0;

      // Get user performance
      final userPerformance = <String, Map<String, dynamic>>{};

      for (final user in users.where((u) => u.role == UserRole.intern)) {
        final userTasks = weeklyTasks
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
        };
      }

      setState(() {
        _reportData = {
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'pendingTasks': pendingTasks,
          'inProgressTasks': inProgressTasks,
          'overdueTasks': overdueTasks,
          'completionRate': completionRate,
          'userPerformance': userPerformance,
          'startDate': startOfWeek,
          'endDate': endOfWeek,
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
        title: const Text('Weekly Report'),
        backgroundColor: AppTheme.darkCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateWeeklyReport,
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
                  // Week selector
                  _buildWeekSelector(),

                  const SizedBox(height: 24),

                  // Overall statistics
                  _buildOverallStats(),

                  const SizedBox(height: 24),

                  // User performance
                  _buildUserPerformance(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppTheme.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Week of',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                Text(
                  _formatDateRange(
                    _reportData['startDate'],
                    _reportData['endDate'],
                  ),
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
            onPressed: _selectWeek,
            icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
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
          const Text(
            'Overall Performance',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
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

  String _formatDateRange(DateTime start, DateTime end) {
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  Future<void> _selectWeek() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedWeek,
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
        _selectedWeek = selectedDate;
      });
      _generateWeeklyReport();
    }
  }
}
