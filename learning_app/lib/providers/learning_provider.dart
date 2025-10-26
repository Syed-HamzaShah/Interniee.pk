import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/learning_progress_model.dart';
import '../services/lms_api_service.dart';
import '../services/learning_service.dart';

class LearningProvider with ChangeNotifier {
  // State variables
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  List<LessonModel> _lessons = [];
  List<QuizModel> _quizzes = [];
  List<CourseProgressModel> _enrolledCourses = [];
  Map<String, LearningProgressModel> _lessonProgress = {};
  Map<String, CourseProgressModel> _courseProgress = {};
  List<QuizAttemptModel> _quizAttempts = [];

  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedDifficulty;
  String _searchQuery = '';

  // Getters
  List<CourseModel> get courses => _filteredCourses;
  List<CourseModel> get allCourses => _courses;
  List<LessonModel> get lessons => _lessons;
  List<QuizModel> get quizzes => _quizzes;
  List<CourseProgressModel> get enrolledCourses => _enrolledCourses;
  Map<String, LearningProgressModel> get lessonProgress => _lessonProgress;
  Map<String, CourseProgressModel> get courseProgress => _courseProgress;
  List<QuizAttemptModel> get quizAttempts => _quizAttempts;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  String? get selectedDifficulty => _selectedDifficulty;
  String get searchQuery => _searchQuery;

  // Initialize provider
  Future<void> initialize(String userId) async {
    await loadCourses();
    await loadEnrolledCourses(userId);
  }

  // Load courses
  Future<void> loadCourses({bool useMockData = false}) async {
    _setLoading(true);
    try {
      if (useMockData) {
        _courses = await LMSApiService.getMockCourses();
      } else {
        _courses = await LearningService.getCourses();
      }
      _applyFilters();
      _clearError();
    } catch (e) {
      _setError('Failed to load courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load enrolled courses
  Future<void> loadEnrolledCourses(String userId) async {
    try {
      _enrolledCourses = await LearningService.getUserEnrolledCourses(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load enrolled courses: $e');
    }
  }

  // Load lessons for a course
  Future<void> loadCourseLessons(
    String courseId, {
    bool useMockData = false,
  }) async {
    _setLoading(true);
    try {
      if (useMockData) {
        _lessons = await LMSApiService.getMockLessons(courseId);
      } else {
        _lessons = await LearningService.getCourseLessons(courseId);
      }
      _clearError();
    } catch (e) {
      _setError('Failed to load lessons: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load quizzes
  Future<void> loadQuizzes({String? courseId, String? lessonId}) async {
    _setLoading(true);
    try {
      _quizzes = await LearningService.getQuizzes(
        courseId: courseId,
        lessonId: lessonId,
      );
      _clearError();
    } catch (e) {
      _setError('Failed to load quizzes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load lesson progress
  Future<void> loadLessonProgress(String userId, String courseId) async {
    try {
      final progressList = await LearningService.getUserProgress(
        userId: userId,
        courseId: courseId,
      );

      _lessonProgress.clear();
      for (final progress in progressList) {
        _lessonProgress[progress.lessonId] = progress;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load lesson progress: $e');
    }
  }

  // Load course progress
  Future<void> loadCourseProgress(String userId, String courseId) async {
    try {
      final progress = await LearningService.getCourseProgress(
        userId: userId,
        courseId: courseId,
      );

      if (progress != null) {
        _courseProgress[courseId] = progress;
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to load course progress: $e');
    }
  }

  // Search courses
  Future<void> searchCourses(String query) async {
    _searchQuery = query;
    _setLoading(true);
    try {
      if (query.isEmpty) {
        _applyFilters();
      } else {
        if (kDebugMode) {
          // Use mock data for development
          _filteredCourses = _courses.where((course) {
            final searchLower = query.toLowerCase();
            return course.title.toLowerCase().contains(searchLower) ||
                course.description.toLowerCase().contains(searchLower) ||
                course.tags.any(
                  (tag) => tag.toLowerCase().contains(searchLower),
                );
          }).toList();
        } else {
          _courses = await LMSApiService.searchCourses(query);
          _applyFilters();
        }
      }
      _clearError();
    } catch (e) {
      _setError('Failed to search courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Filter courses
  void filterCourses({String? category, String? difficulty}) {
    _selectedCategory = category;
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredCourses = _courses.where((course) {
      bool matchesCategory =
          _selectedCategory == null || course.category == _selectedCategory;
      bool matchesDifficulty =
          _selectedDifficulty == null ||
          course.difficulty == _selectedDifficulty;
      return matchesCategory && matchesDifficulty;
    }).toList();
    notifyListeners();
  }

  // Enroll in course
  Future<bool> enrollInCourse(String userId, String courseId) async {
    try {
      await LearningService.enrollInCourse(userId: userId, courseId: courseId);
      await loadEnrolledCourses(userId);
      return true;
    } catch (e) {
      _setError('Failed to enroll in course: $e');
      return false;
    }
  }

  // Update lesson progress
  Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required double progress,
    required int timeSpent,
    bool isCompleted = false,
  }) async {
    try {
      await LearningService.updateLessonProgress(
        userId: userId,
        courseId: courseId,
        lessonId: lessonId,
        progress: progress,
        timeSpent: timeSpent,
        isCompleted: isCompleted,
      );

      // Update local state
      final progressId = '${userId}_${lessonId}';
      _lessonProgress[lessonId] = LearningProgressModel(
        id: progressId,
        userId: userId,
        courseId: courseId,
        lessonId: lessonId,
        isCompleted: isCompleted,
        timeSpent: timeSpent,
        progress: progress,
        lastAccessed: DateTime.now(),
        completedAt: isCompleted ? DateTime.now() : null,
        metadata: {},
      );

      // Reload course progress
      await loadCourseProgress(userId, courseId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update lesson progress: $e');
    }
  }

  // Submit quiz attempt
  Future<QuizAttemptModel?> submitQuizAttempt({
    required String userId,
    required String quizId,
    required List<AnswerModel> answers,
    required int timeSpent,
  }) async {
    try {
      final attempt = await LMSApiService.submitQuizAttempt(
        quizId: quizId,
        userId: userId,
        answers: answers,
        timeSpent: timeSpent,
      );

      // Save to Firebase
      await LearningService.saveQuizAttempt(attempt);

      // Add to local state
      _quizAttempts.add(attempt);
      notifyListeners();

      return attempt;
    } catch (e) {
      _setError('Failed to submit quiz: $e');
      return null;
    }
  }

  // Load quiz attempts
  Future<void> loadQuizAttempts({
    required String userId,
    String? quizId,
    String? courseId,
  }) async {
    try {
      _quizAttempts = await LearningService.getUserQuizAttempts(
        userId: userId,
        quizId: quizId,
        courseId: courseId,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load quiz attempts: $e');
    }
  }

  // Get lesson progress
  LearningProgressModel? getLessonProgress(String lessonId) {
    return _lessonProgress[lessonId];
  }

  // Get course progress
  CourseProgressModel? getCourseProgress(String courseId) {
    return _courseProgress[courseId];
  }

  // Check if user is enrolled
  bool isEnrolledInCourse(String courseId) {
    return _enrolledCourses.any((course) => course.courseId == courseId);
  }

  // Get course by ID
  CourseModel? getCourseById(String courseId) {
    try {
      return _courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Get lesson by ID
  LessonModel? getLessonById(String lessonId) {
    try {
      return _lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  // Get quiz by ID
  QuizModel? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedDifficulty = null;
    _applyFilters();
  }

  // Clear error
  void _clearError() {
    _error = null;
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _courses.clear();
    _filteredCourses.clear();
    _lessons.clear();
    _quizzes.clear();
    _enrolledCourses.clear();
    _lessonProgress.clear();
    _courseProgress.clear();
    _quizAttempts.clear();
    _isLoading = false;
    _error = null;
    _selectedCategory = null;
    _selectedDifficulty = null;
    _searchQuery = '';
    notifyListeners();
  }
}
