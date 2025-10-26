import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';

class DataSeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedSampleData() async {
    try {
      print('🌱 Starting to seed Firebase database...');

      // Seed courses
      await _seedCourses();

      // Seed lessons
      await _seedLessons();

      // Seed quizzes
      await _seedQuizzes();

      print('✅ Firebase database seeded successfully!');
    } catch (e) {
      print('❌ Error seeding database: $e');
      rethrow;
    }
  }

  static Future<void> _seedCourses() async {
    print('📚 Seeding courses...');

    final courses = [
      CourseModel(
        id: 'flutter_basics',
        title: 'Flutter Development Fundamentals',
        description:
            'Learn the basics of Flutter development from scratch. This comprehensive course covers widgets, state management, navigation, and more.',
        instructor: 'Dr. Sarah Ahmed',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=400',
        category: 'Mobile Development',
        duration: 480,
        totalLessons: 12,
        rating: 4.8,
        enrolledCount: 1250,
        difficulty: 'beginner',
        tags: ['Flutter', 'Dart', 'Mobile', 'Cross-platform'],
         createdAt: DateTime(2024, 1, 1),
         updatedAt: DateTime(2024, 1, 15),
        isPublished: true,
      ),
      CourseModel(
        id: 'react_advanced',
        title: 'Advanced React Patterns',
        description:
            'Master advanced React concepts including hooks, context, performance optimization, and modern development patterns.',
        instructor: 'Prof. Michael Johnson',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400',
        category: 'Web Development',
        duration: 600,
        totalLessons: 15,
        rating: 4.9,
        enrolledCount: 890,
        difficulty: 'intermediate',
        tags: ['React', 'JavaScript', 'Hooks', 'Performance'],
         createdAt: DateTime(2024, 1, 5),
         updatedAt: DateTime(2024, 1, 20),
        isPublished: true,
      ),
      CourseModel(
        id: 'python_ml',
        title: 'Machine Learning with Python',
        description:
            'Complete guide to machine learning using Python, covering algorithms, data preprocessing, model evaluation, and deployment.',
        instructor: 'Dr. Aisha Khan',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=400',
        category: 'Data Science',
        duration: 720,
        totalLessons: 18,
        rating: 4.7,
        enrolledCount: 2100,
        difficulty: 'intermediate',
        tags: ['Python', 'Machine Learning', 'Data Science', 'AI'],
         createdAt: DateTime(2024, 1, 10),
         updatedAt: DateTime(2024, 1, 25),
        isPublished: true,
      ),
      CourseModel(
        id: 'aws_cloud',
        title: 'AWS Cloud Architecture',
        description:
            'Learn to design and implement scalable cloud solutions using Amazon Web Services.',
        instructor: 'Eng. David Wilson',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=400',
        category: 'Cloud Computing',
        duration: 540,
        totalLessons: 14,
        rating: 4.6,
        enrolledCount: 750,
        difficulty: 'advanced',
        tags: ['AWS', 'Cloud', 'DevOps', 'Architecture'],
         createdAt: DateTime(2024, 1, 15),
         updatedAt: DateTime(2024, 1, 30),
        isPublished: true,
      ),
      CourseModel(
        id: 'ui_ux_design',
        title: 'UI/UX Design Principles',
        description:
            'Master the fundamentals of user interface and user experience design with practical projects.',
        instructor: 'Designer Lisa Chen',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1558655146-d09347e92766?w=400',
        category: 'Design',
        duration: 360,
        totalLessons: 10,
        rating: 4.5,
        enrolledCount: 980,
        difficulty: 'beginner',
        tags: ['UI Design', 'UX Design', 'Figma', 'Prototyping'],
         createdAt: DateTime(2024, 1, 20),
         updatedAt: DateTime(2024, 2, 1),
        isPublished: true,
      ),
    ];

    for (final course in courses) {
      await _firestore.collection('courses').doc(course.id).set(course.toMap());
      print('Added course: ${course.title}');
    }
  }

  static Future<void> _seedLessons() async {
    print('📖 Seeding lessons...');

    final lessons = [
      LessonModel(
        id: 'flutter_intro',
        courseId: 'flutter_basics',
        title: 'Introduction to Flutter',
        description:
            'Get started with Flutter development environment and understand the basics.',
        type: LessonType.video,
        order: 1,
        duration: 30,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        isPublished: true,
        isFree: true,
         createdAt: DateTime(2024, 1, 1),
         updatedAt: DateTime(2024, 1, 15),
        attachments: [],
      ),
      LessonModel(
        id: 'flutter_widgets',
        courseId: 'flutter_basics',
        title: 'Understanding Widgets',
        description:
            'Learn about Flutter widgets and how to use them effectively.',
        type: LessonType.video,
        order: 2,
        duration: 45,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        isPublished: true,
        isFree: false,
         createdAt: DateTime(2024, 1, 2),
         updatedAt: DateTime(2024, 1, 2),
        attachments: [],
      ),
      LessonModel(
        id: 'flutter_state',
        courseId: 'flutter_basics',
        title: 'State Management',
        description: 'Master state management in Flutter applications.',
        type: LessonType.video,
        order: 3,
        duration: 60,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_5mb.mp4',
        isPublished: true,
        isFree: false,
         createdAt: DateTime(2024, 1, 3),
         updatedAt: DateTime(2024, 1, 3),
        attachments: [],
      ),
      LessonModel(
        id: 'react_hooks',
        courseId: 'react_advanced',
        title: 'Advanced React Hooks',
        description: 'Deep dive into custom hooks and advanced hook patterns.',
        type: LessonType.video,
        order: 1,
        duration: 50,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_2mb.mp4',
        isPublished: true,
        isFree: true,
         createdAt: DateTime(2024, 1, 5),
         updatedAt: DateTime(2024, 1, 20),
        attachments: [],
      ),
      LessonModel(
        id: 'ml_intro',
        courseId: 'python_ml',
        title: 'Introduction to Machine Learning',
        description: 'Understanding the fundamentals of machine learning.',
        type: LessonType.video,
        order: 1,
        duration: 40,
        videoUrl:
            'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        isPublished: true,
        isFree: true,
         createdAt: DateTime(2024, 1, 10),
         updatedAt: DateTime(2024, 1, 25),
        attachments: [],
      ),
    ];

    for (final lesson in lessons) {
      await _firestore.collection('lessons').doc(lesson.id).set(lesson.toMap());
      print('Added lesson: ${lesson.title}');
    }
  }

  static Future<void> _seedQuizzes() async {
    print('🧠 Seeding quizzes...');

    final now = DateTime.now();
    
    // Flutter quiz
    final flutterQuiz = QuizModel(
      id: 'flutter_basics_quiz',
      courseId: 'flutter_basics',
      lessonId: 'flutter_intro',
      title: 'Flutter Development Fundamentals Quiz',
      description: 'Test your understanding of Flutter fundamentals.',
      questions: [
        QuestionModel(
          id: 'f1',
          question: 'What language is primarily used to write Flutter apps?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'f1a1', text: 'Java', isCorrect: false, order: 1),
            OptionModel(id: 'f1a2', text: 'Dart', isCorrect: true, order: 2),
            OptionModel(id: 'f1a3', text: 'Kotlin', isCorrect: false, order: 3),
            OptionModel(id: 'f1a4', text: 'Swift', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 1,
        ),
        QuestionModel(
          id: 'f2',
          question: 'Which widget is used for unidirectional scrolling in Flutter?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'f2a1', text: 'ListView', isCorrect: true, order: 1),
            OptionModel(id: 'f2a2', text: 'Column', isCorrect: false, order: 2),
            OptionModel(id: 'f2a3', text: 'Stack', isCorrect: false, order: 3),
            OptionModel(id: 'f2a4', text: 'Container', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 2,
        ),
        QuestionModel(
          id: 'f3',
          question: 'Which of the following is a Stateful widget in Flutter?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'f3a1', text: 'Text', isCorrect: false, order: 1),
            OptionModel(id: 'f3a2', text: 'Icon', isCorrect: false, order: 2),
            OptionModel(id: 'f3a3', text: 'Scaffold', isCorrect: false, order: 3),
            OptionModel(id: 'f3a4', text: 'Checkbox', isCorrect: true, order: 4),
          ],
          points: 10,
          order: 3,
        ),
        QuestionModel(
          id: 'f4',
          question: "What does the 'setState()' function do?",
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'f4a1', text: 'Destroys the widget', isCorrect: false, order: 1),
            OptionModel(id: 'f4a2', text: 'Renders UI frame', isCorrect: false, order: 2),
            OptionModel(id: 'f4a3', text: 'Updates the UI state', isCorrect: true, order: 3),
            OptionModel(id: 'f4a4', text: 'Builds routes', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 4,
        ),
        QuestionModel(
          id: 'f5',
          question: 'Which command is used to create a new Flutter project?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'f5a1', text: 'flutter new app', isCorrect: false, order: 1),
            OptionModel(id: 'f5a2', text: 'flutter create', isCorrect: true, order: 2),
            OptionModel(id: 'f5a3', text: 'flutter init', isCorrect: false, order: 3),
            OptionModel(id: 'f5a4', text: 'flutter start', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 5,
        ),
      ],
      timeLimit: 15,
      passingScore: 70,
      maxAttempts: 3,
      isPublished: true,
      createdAt: now,
      updatedAt: now,
    );

    // React quiz
    final reactQuiz = QuizModel(
      id: 'react_advanced_quiz',
      courseId: 'react_advanced',
      lessonId: 'react_hooks',
      title: 'Advanced React Patterns Quiz',
      description: 'Test your understanding of React concepts.',
      questions: [
        QuestionModel(
          id: 'r1',
          question: 'React is mainly used for building ____?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'r1a1', text: 'Databases', isCorrect: false, order: 1),
            OptionModel(id: 'r1a2', text: 'User Interfaces', isCorrect: true, order: 2),
            OptionModel(id: 'r1a3', text: 'Servers', isCorrect: false, order: 3),
            OptionModel(id: 'r1a4', text: 'Mobile Networks', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 1,
        ),
        QuestionModel(
          id: 'r2',
          question: 'What is JSX?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'r2a1', text: 'A Java extension', isCorrect: false, order: 1),
            OptionModel(id: 'r2a2', text: 'JavaScript XML', isCorrect: true, order: 2),
            OptionModel(id: 'r2a3', text: 'A CSS preprocessor', isCorrect: false, order: 3),
            OptionModel(id: 'r2a4', text: 'A database query language', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 2,
        ),
        QuestionModel(
          id: 'r3',
          question: 'Which hook is used to handle state in functional components?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'r3a1', text: 'useState', isCorrect: true, order: 1),
            OptionModel(id: 'r3a2', text: 'useRef', isCorrect: false, order: 2),
            OptionModel(id: 'r3a3', text: 'useEffect', isCorrect: false, order: 3),
            OptionModel(id: 'r3a4', text: 'useMemo', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 3,
        ),
        QuestionModel(
          id: 'r4',
          question: 'What is the virtual DOM?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'r4a1', text: 'A copy of the real DOM', isCorrect: true, order: 1),
            OptionModel(id: 'r4a2', text: 'A browser extension', isCorrect: false, order: 2),
            OptionModel(id: 'r4a3', text: 'A CSS model', isCorrect: false, order: 3),
            OptionModel(id: 'r4a4', text: 'React server', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 4,
        ),
        QuestionModel(
          id: 'r5',
          question: 'Which command creates a new React App?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'r5a1', text: 'npm react new', isCorrect: false, order: 1),
            OptionModel(id: 'r5a2', text: 'npx create-react-app', isCorrect: true, order: 2),
            OptionModel(id: 'r5a3', text: 'npm start-react', isCorrect: false, order: 3),
            OptionModel(id: 'r5a4', text: 'node create react', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 5,
        ),
      ],
      timeLimit: 15,
      passingScore: 70,
      maxAttempts: 3,
      isPublished: true,
      createdAt: now,
      updatedAt: now,
    );

    // UI/UX quiz
    final uiuxQuiz = QuizModel(
      id: 'ui_ux_design_quiz',
      courseId: 'ui_ux_design',
      lessonId: 'ui_ux_design',
      title: 'UI/UX Design Principles Quiz',
      description: 'Test your understanding of UI/UX design concepts.',
      questions: [
        QuestionModel(
          id: 'u1',
          question: 'What does UX stand for?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'u1a1', text: 'User Xperience', isCorrect: false, order: 1),
            OptionModel(id: 'u1a2', text: 'User Experience', isCorrect: true, order: 2),
            OptionModel(id: 'u1a3', text: 'User Execution', isCorrect: false, order: 3),
            OptionModel(id: 'u1a4', text: 'Ultimate Experience', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 1,
        ),
        QuestionModel(
          id: 'u2',
          question: 'Which of the following is a UI design tool?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'u2a1', text: 'Figma', isCorrect: true, order: 1),
            OptionModel(id: 'u2a2', text: 'GitHub', isCorrect: false, order: 2),
            OptionModel(id: 'u2a3', text: 'MongoDB', isCorrect: false, order: 3),
            OptionModel(id: 'u2a4', text: 'Postman', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 2,
        ),
        QuestionModel(
          id: 'u3',
          question: 'Which principle focuses on keeping the interface clean and straightforward?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'u3a1', text: 'Simplicity', isCorrect: true, order: 1),
            OptionModel(id: 'u3a2', text: 'Aesthetics', isCorrect: false, order: 2),
            OptionModel(id: 'u3a3', text: 'Branding', isCorrect: false, order: 3),
            OptionModel(id: 'u3a4', text: 'Storytelling', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 3,
        ),
        QuestionModel(
          id: 'u4',
          question: 'Which is a key UX deliverable?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'u4a1', text: 'Wireframe', isCorrect: true, order: 1),
            OptionModel(id: 'u4a2', text: 'Compiler', isCorrect: false, order: 2),
            OptionModel(id: 'u4a3', text: 'Database schema', isCorrect: false, order: 3),
            OptionModel(id: 'u4a4', text: 'Unit test', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 4,
        ),
        QuestionModel(
          id: 'u5',
          question: 'What does UI stand for?',
          type: QuestionType.multipleChoice,
          options: [
            OptionModel(id: 'u5a1', text: 'User Interaction', isCorrect: false, order: 1),
            OptionModel(id: 'u5a2', text: 'User Interface', isCorrect: true, order: 2),
            OptionModel(id: 'u5a3', text: 'Universal Input', isCorrect: false, order: 3),
            OptionModel(id: 'u5a4', text: 'Unified Internet', isCorrect: false, order: 4),
          ],
          points: 10,
          order: 5,
        ),
      ],
      timeLimit: 15,
      passingScore: 70,
      maxAttempts: 3,
      isPublished: true,
      createdAt: now,
      updatedAt: now,
    );

    final quizzes = [flutterQuiz, reactQuiz, uiuxQuiz];

    for (final quiz in quizzes) {
      await _firestore.collection('quizzes').doc(quiz.id).set(quiz.toMap());
      print('Added quiz: ${quiz.title}');
    }
  }
}
