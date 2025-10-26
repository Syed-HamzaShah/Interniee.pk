import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/learning_progress_model.dart';

class LearningService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _coursesCollection = 'courses';
  static const String _lessonsCollection = 'lessons';
  static const String _quizzesCollection = 'quizzes';
  static const String _progressCollection = 'learning_progress';
  static const String _courseProgressCollection = 'course_progress';
  static const String _quizAttemptsCollection = 'quiz_attempts';

  // Course Management
  static Future<List<CourseModel>> getCourses({
    String? category,
    String? difficulty,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_coursesCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CourseModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  static Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore
          .collection(_coursesCollection)
          .doc(courseId)
          .get();
      if (doc.exists) {
        return CourseModel.fromMap({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching course: $e');
    }
  }

  static Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_coursesCollection)
          .where('isPublished', isEqualTo: true)
          .get();

      final courses = snapshot.docs.map((doc) {
        final data = doc.data();
        return CourseModel.fromMap({...data, 'id': doc.id});
      }).toList();

      // Filter courses by search query
      return courses.where((course) {
        final searchLower = query.toLowerCase();
        return course.title.toLowerCase().contains(searchLower) ||
            course.description.toLowerCase().contains(searchLower) ||
            course.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      throw Exception('Error searching courses: $e');
    }
  }

  // Lesson Management
  static Future<List<LessonModel>> getCourseLessons(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_lessonsCollection)
          .where('courseId', isEqualTo: courseId)
          .where('isPublished', isEqualTo: true)
          .orderBy('order')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LessonModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  static Future<LessonModel?> getLessonById(String lessonId) async {
    try {
      final doc = await _firestore
          .collection(_lessonsCollection)
          .doc(lessonId)
          .get();
      if (doc.exists) {
        return LessonModel.fromMap({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }

  // Quiz Management
  static Future<List<QuizModel>> getQuizzes({
    String? courseId,
    String? lessonId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_quizzesCollection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      if (lessonId != null) {
        query = query.where('lessonId', isEqualTo: lessonId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return QuizModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching quizzes: $e');
    }
  }

  static Future<QuizModel?> getQuizById(String quizId) async {
    try {
      print('Fetching quiz with ID: $quizId');
      final doc = await _firestore
          .collection(_quizzesCollection)
          .doc(quizId)
          .get();

      print('Document exists: ${doc.exists}');
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('Quiz data keys: ${data.keys}');

        // Try to fetch questions from subcollection
        List<Map<String, dynamic>> questions = [];

        // Check if questions exist in the document array
        if (data['questions'] is List &&
            (data['questions'] as List).isNotEmpty) {
          print('Questions found in document array');
          questions = (data['questions'] as List)
              .where((q) => q is Map<String, dynamic>)
              .map((q) => q as Map<String, dynamic>)
              .toList();
        } else {
          // Try fetching from subcollection
          print('Fetching questions from subcollection...');
          final questionsSnapshot = await _firestore
              .collection(_quizzesCollection)
              .doc(quizId)
              .collection('questions')
              .orderBy('order')
              .get();

          print(
            'Questions from subcollection: ${questionsSnapshot.docs.length}',
          );
          questions = questionsSnapshot.docs.map((qDoc) {
            final qData = qDoc.data();
            qData['id'] = qDoc.id;
            return qData;
          }).toList();

          // If still no questions, try 'questions' collection at same level
          // Note: This query requires an index, so we'll only fetch questions without orderBy
          if (questions.isEmpty) {
            print('Trying alternative questions collection...');
            try {
              final altSnapshot = await _firestore
                  .collection('questions')
                  .where('quizId', isEqualTo: quizId)
                  .get(); // Removed orderBy to avoid index requirement

              print(
                'Alternative questions collection: ${altSnapshot.docs.length}',
              );
              questions = altSnapshot.docs.map((qDoc) {
                final qData = qDoc.data();
                qData['id'] = qDoc.id;
                return qData;
              }).toList();

              // Sort manually by order field if it exists
              questions.sort((a, b) {
                final orderA = a['order'] ?? 0;
                final orderB = b['order'] ?? 0;
                return (orderA as int).compareTo(orderB as int);
              });
            } catch (e) {
              print(
                'Failed to fetch from alternative questions collection: $e',
              );
              // Continue without questions from this source
            }
          }
        }

        print('Total questions found: ${questions.length}');
        if (questions.isNotEmpty) {
          print('First question keys: ${questions[0].keys}');
        }

        try {
          // Replace the questions array in data
          final quizData = {...data, 'questions': questions, 'id': doc.id};
          final quiz = QuizModel.fromMap(quizData);
          print('Quiz parsed successfully: ${quiz.title}');
          print('Questions in parsed quiz: ${quiz.questions.length}');

          // Debug: Print parsed questions
          for (int i = 0; i < quiz.questions.length && i < 2; i++) {
            print('Question ${i + 1}: ${quiz.questions[i].question}');
            print('  Type: ${quiz.questions[i].type}');
            print('  Options count: ${quiz.questions[i].options.length}');
          }

          return quiz;
        } catch (parseError, stackTrace) {
          print('Error parsing quiz: $parseError');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }
      print('Quiz document does not exist');
      return null;
    } catch (e, stackTrace) {
      print('Error fetching quiz: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error fetching quiz: $e');
    }
  }

  static Future<String> saveQuizAttempt(QuizAttemptModel attempt) async {
    try {
      final docRef = await _firestore
          .collection(_quizAttemptsCollection)
          .add(attempt.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error saving quiz attempt: $e');
    }
  }

  static Future<List<QuizAttemptModel>> getUserQuizAttempts({
    required String userId,
    String? quizId,
    String? courseId,
  }) async {
    try {
      Query query = _firestore
          .collection(_quizAttemptsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('startedAt', descending: true);

      if (quizId != null) {
        query = query.where('quizId', isEqualTo: quizId);
      }
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return QuizAttemptModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching quiz attempts: $e');
    }
  }

  // Progress Tracking
  static Future<void> updateLessonProgress({
    required String userId,
    required String courseId,
    required String lessonId,
    required double progress,
    required int timeSpent,
    bool isCompleted = false,
  }) async {
    try {
      final progressId = '${userId}_${lessonId}';
      final progressData = LearningProgressModel(
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

      await _firestore
          .collection(_progressCollection)
          .doc(progressId)
          .set(progressData.toMap(), SetOptions(merge: true));

      // Update course progress
      await _updateCourseProgress(userId, courseId);
    } catch (e) {
      throw Exception('Error updating lesson progress: $e');
    }
  }

  static Future<LearningProgressModel?> getLessonProgress({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final progressId = '${userId}_${lessonId}';
      final doc = await _firestore
          .collection(_progressCollection)
          .doc(progressId)
          .get();

      if (doc.exists) {
        return LearningProgressModel.fromMap({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching lesson progress: $e');
    }
  }

  static Future<CourseProgressModel?> getCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final progressId = '${userId}_${courseId}';
      final doc = await _firestore
          .collection(_courseProgressCollection)
          .doc(progressId)
          .get();

      if (doc.exists) {
        return CourseProgressModel.fromMap({
          ...(doc.data() as Map<String, dynamic>),
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching course progress: $e');
    }
  }

  static Future<List<LearningProgressModel>> getUserProgress({
    required String userId,
    String? courseId,
  }) async {
    try {
      Query query = _firestore
          .collection(_progressCollection)
          .where('userId', isEqualTo: userId);

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LearningProgressModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching user progress: $e');
    }
  }

  // Helper method to update course progress
  static Future<void> _updateCourseProgress(
    String userId,
    String courseId,
  ) async {
    try {
      // Get all lessons for the course
      final lessons = await getCourseLessons(courseId);

      // Get all progress for this course
      final progressList = await getUserProgress(
        userId: userId,
        courseId: courseId,
      );

      // Calculate course progress
      final completedLessons = progressList.where((p) => p.isCompleted).length;
      final totalLessons = lessons.length;
      final overallProgress = totalLessons > 0
          ? completedLessons / totalLessons
          : 0.0;
      final totalTimeSpent = progressList.fold(
        0,
        (sum, p) => sum + p.timeSpent,
      );

      // Create lesson progress map
      final lessonProgress = <String, double>{};
      for (final progress in progressList) {
        lessonProgress[progress.lessonId] = progress.progress;
      }

      final courseProgress = CourseProgressModel(
        id: '${userId}_${courseId}',
        userId: userId,
        courseId: courseId,
        totalLessons: totalLessons,
        completedLessons: completedLessons,
        overallProgress: overallProgress,
        totalTimeSpent: totalTimeSpent,
        enrolledAt: DateTime.now(), // This should be set when user enrolls
        completedAt: overallProgress >= 1.0 ? DateTime.now() : null,
        isCompleted: overallProgress >= 1.0,
        lessonProgress: lessonProgress,
      );

      await _firestore
          .collection(_courseProgressCollection)
          .doc('${userId}_${courseId}')
          .set(courseProgress.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating course progress: $e');
    }
  }

  // Enroll user in course
  static Future<void> enrollInCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      final courseProgress = CourseProgressModel(
        id: '${userId}_${courseId}',
        userId: userId,
        courseId: courseId,
        totalLessons: 0,
        completedLessons: 0,
        overallProgress: 0.0,
        totalTimeSpent: 0,
        enrolledAt: DateTime.now(),
        isCompleted: false,
        lessonProgress: {},
      );

      await _firestore
          .collection(_courseProgressCollection)
          .doc('${userId}_${courseId}')
          .set(courseProgress.toMap());
    } catch (e) {
      throw Exception('Error enrolling in course: $e');
    }
  }

  // Check if user is enrolled in course
  static Future<bool> isEnrolledInCourse({
    required String userId,
    required String courseId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_courseProgressCollection)
          .doc('${userId}_${courseId}')
          .get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error checking enrollment: $e');
    }
  }

  // Get user's enrolled courses
  static Future<List<CourseProgressModel>> getUserEnrolledCourses(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_courseProgressCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('enrolledAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CourseProgressModel.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Error fetching enrolled courses: $e');
    }
  }
}
