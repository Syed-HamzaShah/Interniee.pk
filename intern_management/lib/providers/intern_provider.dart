import 'package:flutter/foundation.dart';
import '../models/intern_model.dart';
import '../services/intern_service.dart';

class InternProvider with ChangeNotifier {
  final InternService _internService = InternService();

  List<InternModel> _interns = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InternModel> get interns => _interns;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadInterns() async {
    _setLoading(true);
    _clearError();

    try {
      _interns = await _internService.getAllInterns();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load interns: $e');
      _setLoading(false);
    }
  }

  Stream<List<InternModel>> getInternsStream() {
    return _internService.getInternsStream();
  }

  Future<void> loadActiveInterns() async {
    _setLoading(true);
    _clearError();

    try {
      _interns = await _internService.getActiveInterns();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load active interns: $e');
      _setLoading(false);
    }
  }

  Stream<List<InternModel>> getActiveInternsStream() {
    return _internService.getActiveInternsStream();
  }

  void listenToInternsStream() {
    getInternsStream().listen(
      (interns) {
        _interns = interns;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to listen to interns stream: $error');
      },
    );
  }

  void listenToActiveInternsStream() {
    getActiveInternsStream().listen(
      (interns) {
        _interns = interns;
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to listen to active interns stream: $error');
      },
    );
  }

  Future<InternModel?> getInternById(String internId) async {
    try {
      return await _internService.getInternById(internId);
    } catch (e) {
      _setError('Failed to get intern: $e');
      return null;
    }
  }

  Future<bool> updateInternProfile({
    required String internId,
    String? name,
    String? phone,
    String? department,
    String? university,
    String? course,
    String? bio,
    List<String>? skills,
    String? profileImageUrl,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _internService.updateInternProfile(
        internId: internId,
        name: name,
        phone: phone,
        department: department,
        university: university,
        course: course,
        bio: bio,
        skills: skills,
        profileImageUrl: profileImageUrl,
      );

      if (success) {
        await loadInterns();
        _setLoading(false);
        return true;
      }

      _setError('Failed to update intern profile');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update intern profile: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateInternPerformance({
    required String internId,
    required Map<String, dynamic> performanceData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _internService.updateInternPerformance(
        internId: internId,
        performanceData: performanceData,
      );

      if (success) {
        await loadInterns();
        _setLoading(false);
        return true;
      }

      _setError('Failed to update intern performance');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to update intern performance: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getInternPerformanceAnalytics(
    String internId,
  ) async {
    try {
      return await _internService.getInternPerformanceAnalytics(internId);
    } catch (e) {
      _setError('Failed to get intern performance analytics: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllInternsPerformanceAnalytics() async {
    try {
      return await _internService.getAllInternsPerformanceAnalytics();
    } catch (e) {
      _setError('Failed to get all interns performance analytics: $e');
      return [];
    }
  }

  Future<List<InternModel>> getInternsByDepartment(String department) async {
    try {
      return await _internService.getInternsByDepartment(department);
    } catch (e) {
      _setError('Failed to get interns by department: $e');
      return [];
    }
  }

  Future<List<InternModel>> getInternsByUniversity(String university) async {
    try {
      return await _internService.getInternsByUniversity(university);
    } catch (e) {
      _setError('Failed to get interns by university: $e');
      return [];
    }
  }

  Future<List<InternModel>> getInternsBySkills(List<String> skills) async {
    try {
      return await _internService.getInternsBySkills(skills);
    } catch (e) {
      _setError('Failed to get interns by skills: $e');
      return [];
    }
  }

  Future<List<InternModel>> searchInterns(String searchQuery) async {
    try {
      return await _internService.searchInterns(searchQuery);
    } catch (e) {
      _setError('Failed to search interns: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getInternStatistics() async {
    try {
      return await _internService.getInternStatistics();
    } catch (e) {
      _setError('Failed to get intern statistics: $e');
      return null;
    }
  }

  Future<bool> deactivateIntern(String internId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _internService.deactivateIntern(internId);

      if (success) {
        await loadInterns();
        _setLoading(false);
        return true;
      }

      _setError('Failed to deactivate intern');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to deactivate intern: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> reactivateIntern(String internId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _internService.reactivateIntern(internId);

      if (success) {
        await loadInterns();
        _setLoading(false);
        return true;
      }

      _setError('Failed to reactivate intern');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to reactivate intern: $e');
      _setLoading(false);
      return false;
    }
  }

  List<InternModel> get activeInterns {
    return _interns.where((intern) => intern.isActive).toList();
  }

  List<InternModel> get completedInterns {
    return _interns.where((intern) => intern.isInternshipCompleted).toList();
  }

  List<InternModel> get ongoingInterns {
    return _interns.where((intern) => intern.isInternshipActive).toList();
  }

  List<InternModel> getInternsByPerformanceStatus(String status) {
    return _interns
        .where((intern) => intern.performanceStatus == status)
        .toList();
  }

  List<InternModel> get highPerformingInterns {
    return _interns.where((intern) => intern.completionRate >= 80).toList();
  }

  List<InternModel> get internsNeedingImprovement {
    return _interns.where((intern) => intern.completionRate < 50).toList();
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
