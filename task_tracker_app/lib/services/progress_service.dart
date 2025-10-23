import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/progress_model.dart';
import '../models/task_model.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateDailyProgress(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final tasksSnapshot = await _firestore
          .collection('tasks')
          .where('assignedToId', isEqualTo: userId)
          .get();

      final tasks = tasksSnapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown User';

      final progress = ProgressModel.fromTasks(
        userId: userId,
        userName: userName,
        date: startOfDay,
        tasks: tasks,
      );

      final progressId = '${userId}_${startOfDay.millisecondsSinceEpoch}';
      await _firestore
          .collection('progress')
          .doc(progressId)
          .set(progress.toMap());
    } catch (e) {
      throw Exception('Failed to update daily progress: $e');
    }
  }

  Future<ProgressModel?> getProgressForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final progressId = '${userId}_${startOfDay.millisecondsSinceEpoch}';

      final doc = await _firestore.collection('progress').doc(progressId).get();
      if (doc.exists) {
        return ProgressModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get progress for date: $e');
    }
  }

  Stream<List<ProgressModel>> getProgressForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
    final endOfDay = DateTime(endDate.year, endDate.month, endDate.day);

    return _firestore
        .collection('progress')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProgressModel.fromDocument(doc))
              .toList(),
        );
  }

  Future<Map<String, dynamic>> getWeeklyProgressSummary(String userId) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final progressList = <ProgressModel>[];

      for (int i = 0; i < 7; i++) {
        final date = weekStart.add(Duration(days: i));
        final progress = await getProgressForDate(userId, date);
        if (progress != null) {
          progressList.add(progress);
        }
      }

      if (progressList.isEmpty) {
        return {
          'averageCompletionRate': 0.0,
          'totalTasks': 0,
          'completedTasks': 0,
          'performanceGrade': 'N/A',
          'daysActive': 0,
        };
      }

      final totalTasks = progressList.fold(
        0,
        (sum, progress) => sum + progress.totalTasks,
      );
      final completedTasks = progressList.fold(
        0,
        (sum, progress) => sum + progress.completedTasks,
      );
      final averageCompletionRate = totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0;
      final daysActive = progressList.length;

      return {
        'averageCompletionRate': averageCompletionRate,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'performanceGrade': _getPerformanceGrade(averageCompletionRate),
        'daysActive': daysActive,
      };
    } catch (e) {
      throw Exception('Failed to get weekly progress summary: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyProgressSummary(String userId) async {
    try {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final progressList = <ProgressModel>[];

      for (int i = 0; i < monthEnd.day; i++) {
        final date = monthStart.add(Duration(days: i));
        if (date.isBefore(now) || date.isAtSameMomentAs(now)) {
          final progress = await getProgressForDate(userId, date);
          if (progress != null) {
            progressList.add(progress);
          }
        }
      }

      if (progressList.isEmpty) {
        return {
          'averageCompletionRate': 0.0,
          'totalTasks': 0,
          'completedTasks': 0,
          'performanceGrade': 'N/A',
          'daysActive': 0,
        };
      }

      final totalTasks = progressList.fold(
        0,
        (sum, progress) => sum + progress.totalTasks,
      );
      final completedTasks = progressList.fold(
        0,
        (sum, progress) => sum + progress.completedTasks,
      );
      final averageCompletionRate = totalTasks > 0
          ? (completedTasks / totalTasks) * 100
          : 0.0;
      final daysActive = progressList.length;

      return {
        'averageCompletionRate': averageCompletionRate,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'performanceGrade': _getPerformanceGrade(averageCompletionRate),
        'daysActive': daysActive,
      };
    } catch (e) {
      throw Exception('Failed to get monthly progress summary: $e');
    }
  }

  Future<void> cleanupOldProgress({int daysToKeep = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final oldRecords = await _firestore
          .collection('progress')
          .where('date', isLessThan: cutoffDate)
          .get();

      final batch = _firestore.batch();
      for (final doc in oldRecords.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup old progress records: $e');
    }
  }

  String _getPerformanceGrade(double completionRate) {
    if (completionRate >= 90) return 'A+';
    if (completionRate >= 80) return 'A';
    if (completionRate >= 70) return 'B';
    if (completionRate >= 60) return 'C';
    if (completionRate >= 50) return 'D';
    return 'F';
  }
}
