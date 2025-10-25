import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';

class FeedbackProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FeedbackModel> _feedbacks = [];
  List<FeedbackModel> _allFeedbacks = []; // For admin view
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  UserRole? _userRole;

  List<FeedbackModel> get feedbacks => _feedbacks;
  List<FeedbackModel> get allFeedbacks => _allFeedbacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userId => _userId;
  UserRole? get userRole => _userRole;

  int get totalFeedbacks =>
      _userRole == UserRole.admin ? _allFeedbacks.length : _feedbacks.length;
  int get pendingFeedbacks =>
      _getFeedbacksByStatus(FeedbackStatus.pending).length;
  int get approvedFeedbacks =>
      _getFeedbacksByStatus(FeedbackStatus.approved).length;
  int get rejectedFeedbacks =>
      _getFeedbacksByStatus(FeedbackStatus.rejected).length;

  double get averageRating {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    if (feedbacks.isEmpty) return 0.0;
    return feedbacks.map((f) => f.rating).reduce((a, b) => a + b) /
        feedbacks.length;
  }

  void setUserContext(String userId, UserRole role) {
    _userId = userId;
    _userRole = role;
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    if (_userId == null || _userId!.isEmpty) return;

    _setLoading(true);
    _clearError();

    try {
      if (_userRole == UserRole.admin) {
        await _loadAllFeedbacks();
      } else {
        await _loadUserFeedbacks();
      }
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load feedbacks: $e');
      _setLoading(false);
    }
  }

  Future<void> _loadUserFeedbacks() async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      _feedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();
    } catch (e) {
      _feedbacks = [];
    }

    notifyListeners();
  }

  Future<void> _loadAllFeedbacks() async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();

      _allFeedbacks = snapshot.docs
          .map((doc) => FeedbackModel.fromDocument(doc))
          .toList();

      _feedbacks = _allFeedbacks; // For admin, show all feedbacks
    } catch (e) {
      _allFeedbacks = [];
      _feedbacks = [];
    }

    notifyListeners();
  }

  Stream<List<FeedbackModel>> getFeedbacksStream() {
    if (_userId == null || _userId!.isEmpty) return Stream.value([]);

    try {
      if (_userRole == UserRole.admin) {
        return _firestore
            .collection('feedbacks')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              try {
                return snapshot.docs
                    .map((doc) => FeedbackModel.fromDocument(doc))
                    .toList();
              } catch (e) {
                return <FeedbackModel>[];
              }
            })
            .handleError((error) {
              return <FeedbackModel>[];
            });
      } else {
        return _firestore
            .collection('feedbacks')
            .where('userId', isEqualTo: _userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              try {
                return snapshot.docs
                    .map((doc) => FeedbackModel.fromDocument(doc))
                    .toList();
              } catch (e) {
                return <FeedbackModel>[];
              }
            })
            .handleError((error) {
              return <FeedbackModel>[];
            });
      }
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<bool> submitFeedback({
    required String userName,
    required String userEmail,
    String? name,
    required FeedbackCategory category,
    required int rating,
    required String comments,
  }) async {
    if (_userId == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final feedbackId = _firestore.collection('feedbacks').doc().id;
      final feedback = FeedbackModel(
        id: feedbackId,
        userId: _userId!,
        userName: userName,
        userEmail: userEmail,
        name: name,
        category: category,
        rating: rating,
        comments: comments,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('feedbacks')
          .doc(feedbackId)
          .set(feedback.toMap());

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to submit feedback: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateFeedbackStatus({
    required String feedbackId,
    required FeedbackStatus status,
    String? adminNotes,
  }) async {
    if (_userRole != UserRole.admin) return false;

    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('feedbacks').doc(feedbackId).update({
        'status': status.name,
        'adminNotes': adminNotes,
        'updatedAt': DateTime.now(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update feedback: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteFeedback(String feedbackId) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('feedbacks').doc(feedbackId).delete();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete feedback: $e');
      _setLoading(false);
      return false;
    }
  }

  List<FeedbackModel> getFeedbacksByCategory(FeedbackCategory category) {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    return feedbacks.where((f) => f.category == category).toList();
  }

  List<FeedbackModel> getFeedbacksByRating(int rating) {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    return feedbacks.where((f) => f.rating == rating).toList();
  }

  List<FeedbackModel> _getFeedbacksByStatus(FeedbackStatus status) {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    return feedbacks.where((f) => f.status == status).toList();
  }

  List<FeedbackModel> getFeedbacksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    return feedbacks
        .where(
          (f) =>
              f.createdAt.isAfter(startDate) && f.createdAt.isBefore(endDate),
        )
        .toList();
  }

  List<FeedbackModel> get recentFeedbacks {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return feedbacks.where((f) => f.createdAt.isAfter(weekAgo)).toList();
  }

  Map<FeedbackCategory, int> get categoryStats {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    final stats = <FeedbackCategory, int>{};

    for (final category in FeedbackCategory.values) {
      stats[category] = feedbacks.where((f) => f.category == category).length;
    }

    return stats;
  }

  Map<int, int> get ratingDistribution {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    final distribution = <int, int>{};

    for (int i = 1; i <= 5; i++) {
      distribution[i] = feedbacks.where((f) => f.rating == i).length;
    }

    return distribution;
  }

  Map<String, int> get monthlyFeedbackCount {
    final feedbacks = _userRole == UserRole.admin ? _allFeedbacks : _feedbacks;
    final monthlyCount = <String, int>{};

    for (final feedback in feedbacks) {
      final monthKey =
          '${feedback.createdAt.year}-${feedback.createdAt.month.toString().padLeft(2, '0')}';
      monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
    }

    return monthlyCount;
  }

  Future<void> refreshFeedbacks() async {
    await _loadFeedbacks();
  }

  void clearError() {
    _clearError();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
