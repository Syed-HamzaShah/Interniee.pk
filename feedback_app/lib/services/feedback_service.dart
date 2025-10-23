import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<String?> submitFeedback(FeedbackModel feedback) async {
    try {
      await _analytics.logEvent(
        name: 'feedback_submitted',
        parameters: {
          'category': feedback.category.name,
          'rating': feedback.rating,
          'user_id': feedback.userId,
        },
      );

      final docRef = await _firestore
          .collection('feedbacks')
          .add(feedback.toMap());

      await _analytics.logEvent(
        name: 'feedback_stored_successfully',
        parameters: {
          'feedback_id': docRef.id,
          'category': feedback.category.name,
        },
      );

      return docRef.id;
    } catch (e) {
      await _analytics.logEvent(
        name: 'feedback_submission_error',
        parameters: {'error': e.toString(), 'category': feedback.category.name},
      );
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getUserFeedbacks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user feedbacks: $e');
    }
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all feedbacks: $e');
    }
  }

  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus status,
    String? adminNotes,
  }) async {
    try {
      await _firestore.collection('feedbacks').doc(feedbackId).update({
        'status': status.name,
        'adminNotes': adminNotes,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update feedback status: $e');
    }
  }

  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedbacks').doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByCategory(
    FeedbackCategory category,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedbacks by category: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByRating(int rating) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('rating', isEqualTo: rating)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedbacks by rating: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByStatus(
    FeedbackStatus status,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedbacks by status: $e');
    }
  }

  Future<Map<String, dynamic>> getFeedbackStatistics() async {
    try {
      final snapshot = await _firestore.collection('feedbacks').get();
      final feedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();

      final totalFeedbacks = feedbacks.length;
      final averageRating = feedbacks.isEmpty
          ? 0.0
          : feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
                feedbacks.length;

      final categoryStats = <String, int>{};
      final ratingDistribution = <int, int>{};
      final statusStats = <String, int>{};

      for (final feedback in feedbacks) {
        categoryStats[feedback.category.name] =
            (categoryStats[feedback.category.name] ?? 0) + 1;

        ratingDistribution[feedback.rating] =
            (ratingDistribution[feedback.rating] ?? 0) + 1;

        statusStats[feedback.status.name] =
            (statusStats[feedback.status.name] ?? 0) + 1;
      }

      return {
        'totalFeedbacks': totalFeedbacks,
        'averageRating': averageRating,
        'categoryStats': categoryStats,
        'ratingDistribution': ratingDistribution,
        'statusStats': statusStats,
      };
    } catch (e) {
      throw Exception('Failed to get feedback statistics: $e');
    }
  }

  Future<Map<String, int>> getMonthlyFeedbackCount() async {
    try {
      final snapshot = await _firestore.collection('feedbacks').get();
      final feedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();

      final monthlyCount = <String, int>{};

      for (final feedback in feedbacks) {
        final monthKey =
            '${feedback.createdAt.year}-${feedback.createdAt.month.toString().padLeft(2, '0')}';
        monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
      }

      return monthlyCount;
    } catch (e) {
      throw Exception('Failed to get monthly feedback count: $e');
    }
  }

  Stream<List<FeedbackModel>> getFeedbacksStream({
    String? userId,
    FeedbackCategory? category,
    FeedbackStatus? status,
    int? rating,
  }) {
    try {
      Query query = _firestore.collection('feedbacks');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (rating != null) {
        query = query.where('rating', isEqualTo: rating);
      }

      query = query.orderBy('createdAt', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => FeedbackModel.fromDocument(doc))
            .toList();
      });
    } catch (e) {
      return Stream.error('Failed to get feedbacks stream: $e');
    }
  }

  Future<List<FeedbackModel>> getFeedbacksByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get feedbacks by date range: $e');
    }
  }

  Future<Map<String, dynamic>> exportFeedbacks() async {
    try {
      final snapshot = await _firestore.collection('feedbacks').get();
      final feedbacks = snapshot.docs
          .map((doc) => {'id': doc.id, 'data': doc.data()})
          .toList();

      final exportData = {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalFeedbacks': feedbacks.length,
        'feedbacks': feedbacks,
      };

      return exportData;
    } catch (e) {
      throw Exception('Failed to export feedbacks: $e');
    }
  }

  Future<int> getFeedbackCount({
    String? userId,
    FeedbackCategory? category,
    FeedbackStatus? status,
    int? rating,
  }) async {
    try {
      Query query = _firestore.collection('feedbacks');

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (rating != null) {
        query = query.where('rating', isEqualTo: rating);
      }

      final snapshot = await query.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get feedback count: $e');
    }
  }
}
