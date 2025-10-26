import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

class LMSApiService {
  static const String baseUrl = 'https://learn.internee.pk/api';
  static const Duration timeout = Duration(seconds: 30);

  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Fetch all courses
  static Future<List<CourseModel>> fetchCourses({
    String? category,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (difficulty != null) queryParams['difficulty'] = difficulty;

      final uri = Uri.parse(
        '$baseUrl/courses',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coursesData = data['data'] as List<dynamic>? ?? [];

        return coursesData
            .map(
              (course) => CourseModel.fromMap(course as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courses: $e');
    }
  }

  // Fetch course by ID
  static Future<CourseModel?> fetchCourseById(String courseId) async {
    try {
      final uri = Uri.parse('$baseUrl/courses/$courseId');
      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CourseModel.fromMap(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch course: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course: $e');
    }
  }

  // Fetch lessons for a course
  static Future<List<LessonModel>> fetchCourseLessons(String courseId) async {
    try {
      final uri = Uri.parse('$baseUrl/courses/$courseId/lessons');
      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lessonsData = data['data'] as List<dynamic>? ?? [];

        return lessonsData
            .map(
              (lesson) => LessonModel.fromMap(lesson as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch lessons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lessons: $e');
    }
  }

  // Fetch lesson by ID
  static Future<LessonModel?> fetchLessonById(String lessonId) async {
    try {
      final uri = Uri.parse('$baseUrl/lessons/$lessonId');
      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LessonModel.fromMap(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch lesson: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lesson: $e');
    }
  }

  // Fetch quiz by ID
  static Future<QuizModel?> fetchQuizById(String quizId) async {
    try {
      final uri = Uri.parse('$baseUrl/quizzes/$quizId');
      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuizModel.fromMap(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch quiz: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching quiz: $e');
    }
  }

  // Submit quiz attempt
  static Future<QuizAttemptModel> submitQuizAttempt({
    required String quizId,
    required String userId,
    required List<AnswerModel> answers,
    required int timeSpent,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/quizzes/$quizId/attempts');
      final body = json.encode({
        'userId': userId,
        'answers': answers.map((a) => a.toMap()).toList(),
        'timeSpent': timeSpent,
      });

      final response = await http
          .post(uri, headers: _headers, body: body)
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return QuizAttemptModel.fromMap(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to submit quiz attempt: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error submitting quiz attempt: $e');
    }
  }

  // Get user's quiz attempts
  static Future<List<QuizAttemptModel>> getUserQuizAttempts({
    required String userId,
    String? quizId,
    String? courseId,
  }) async {
    try {
      final queryParams = <String, String>{'userId': userId};

      if (quizId != null) queryParams['quizId'] = quizId;
      if (courseId != null) queryParams['courseId'] = courseId;

      final uri = Uri.parse(
        '$baseUrl/quiz-attempts',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final attemptsData = data['data'] as List<dynamic>? ?? [];

        return attemptsData
            .map(
              (attempt) =>
                  QuizAttemptModel.fromMap(attempt as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch quiz attempts: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching quiz attempts: $e');
    }
  }

  // Search courses
  static Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/courses/search',
      ).replace(queryParameters: {'q': query});

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coursesData = data['data'] as List<dynamic>? ?? [];

        return coursesData
            .map(
              (course) => CourseModel.fromMap(course as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to search courses: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching courses: $e');
    }
  }

  // Get course categories
  static Future<List<String>> getCourseCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/courses/categories');
      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['data'] as List<dynamic>? ?? [];
        return categories.cast<String>();
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  // Mock data for development/testing
  static Future<List<CourseModel>> getMockCourses() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    return [
      CourseModel(
        id: '1',
        title: 'Flutter Development Fundamentals',
        description:
            'Learn the basics of Flutter development including widgets, state management, and navigation.',
        instructor: 'John Doe',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/4CAF50/FFFFFF?text=Flutter+Course',
        category: 'Mobile Development',
        duration: 120,
        totalLessons: 15,
        rating: 4.8,
        enrolledCount: 1250,
        difficulty: 'beginner',
        tags: ['Flutter', 'Dart', 'Mobile', 'UI/UX'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        isPublished: true,
        externalId: 'flutter-fundamentals',
      ),
      CourseModel(
        id: '2',
        title: 'Advanced React Patterns',
        description:
            'Master advanced React patterns including hooks, context, and performance optimization.',
        instructor: 'Jane Smith',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/2196F3/FFFFFF?text=React+Course',
        category: 'Web Development',
        duration: 180,
        totalLessons: 20,
        rating: 4.9,
        enrolledCount: 2100,
        difficulty: 'intermediate',
        tags: ['React', 'JavaScript', 'Web', 'Hooks'],
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        isPublished: true,
        externalId: 'react-advanced',
      ),
      CourseModel(
        id: '3',
        title: 'Python Data Science',
        description:
            'Complete guide to data science with Python including pandas, numpy, and machine learning.',
        instructor: 'Dr. Alex Johnson',
        thumbnailUrl:
            'https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Python+Course',
        category: 'Data Science',
        duration: 240,
        totalLessons: 25,
        rating: 4.7,
        enrolledCount: 3200,
        difficulty: 'intermediate',
        tags: ['Python', 'Data Science', 'Machine Learning', 'Pandas'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
        isPublished: true,
        externalId: 'python-data-science',
      ),
    ];
  }

  static Future<List<LessonModel>> getMockLessons(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      LessonModel(
        id: '${courseId}_1',
        courseId: courseId,
        title: 'Introduction to the Course',
        description:
            'Welcome to the course! Learn about what you\'ll be building.',
        type: LessonType.video,
        order: 1,
        duration: 10,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        attachments: [],
        isPublished: true,
        isFree: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        externalId: 'intro_lesson',
      ),
      LessonModel(
        id: '${courseId}_2',
        courseId: courseId,
        title: 'Setting Up Your Development Environment',
        description:
            'Learn how to set up your development environment properly.',
        type: LessonType.video,
        order: 2,
        duration: 15,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        attachments: ['https://example.com/setup-guide.pdf'],
        isPublished: true,
        isFree: false,
        createdAt: DateTime.now().subtract(const Duration(days: 29)),
        updatedAt: DateTime.now(),
        externalId: 'setup_lesson',
      ),
      LessonModel(
        id: '${courseId}_3',
        courseId: courseId,
        title: 'Understanding the Basics',
        description: 'Get familiar with the fundamental concepts.',
        type: LessonType.text,
        order: 3,
        duration: 20,
        content:
            'This is a comprehensive text lesson covering all the basic concepts...',
        attachments: [],
        isPublished: true,
        isFree: false,
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now(),
        externalId: 'basics_lesson',
      ),
      LessonModel(
        id: '${courseId}_4',
        courseId: courseId,
        title: 'Quiz: Test Your Knowledge',
        description: 'Test what you\'ve learned so far with this quiz.',
        type: LessonType.quiz,
        order: 4,
        duration: 10,
        quizId: '${courseId}_quiz_1',
        attachments: [],
        isPublished: true,
        isFree: false,
        createdAt: DateTime.now().subtract(const Duration(days: 27)),
        updatedAt: DateTime.now(),
        externalId: 'quiz_lesson',
      ),
    ];
  }

  static Future<QuizModel?> getMockQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return QuizModel(
      id: quizId,
      courseId: '1',
      lessonId: '1_4',
      title: 'Quiz: Test Your Knowledge',
      description: 'Test what you\'ve learned so far with this quiz.',
      questions: [
        QuestionModel(
          id: 'q1',
          question: 'What is Flutter?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(
              id: 'a1',
              text: 'A mobile development framework',
              isCorrect: true,
              order: 1,
            ),
            OptionModel(
              id: 'a2',
              text: 'A web browser',
              isCorrect: false,
              order: 2,
            ),
            OptionModel(
              id: 'a3',
              text: 'A database',
              isCorrect: false,
              order: 3,
            ),
            OptionModel(
              id: 'a4',
              text: 'A programming language',
              isCorrect: false,
              order: 4,
            ),
          ],
          points: 1,
          order: 1,
        ),
        QuestionModel(
          id: 'q2',
          question: 'Flutter uses Dart programming language.',
          type: QuestionType.trueFalse,
          options: [
            OptionModel(id: 'a1', text: 'True', isCorrect: true, order: 1),
            OptionModel(id: 'a2', text: 'False', isCorrect: false, order: 2),
          ],
          points: 1,
          order: 2,
        ),
        QuestionModel(
          id: 'q3',
          question: 'What does "hot reload" do in Flutter?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(
              id: 'a1',
              text: 'Restarts the app completely',
              isCorrect: false,
              order: 1,
            ),
            OptionModel(
              id: 'a2',
              text: 'Updates the UI instantly without losing state',
              isCorrect: true,
              order: 2,
            ),
            OptionModel(
              id: 'a3',
              text: 'Compiles the app for production',
              isCorrect: false,
              order: 3,
            ),
            OptionModel(
              id: 'a4',
              text: 'Saves the project files',
              isCorrect: false,
              order: 4,
            ),
          ],
          points: 2,
          order: 3,
        ),
      ],
      timeLimit: 10,
      passingScore: 70,
      maxAttempts: 3,
      isPublished: true,
      createdAt: DateTime.now().subtract(const Duration(days: 27)),
      updatedAt: DateTime.now(),
      externalId: 'flutter_quiz_1',
    );
  }
}
