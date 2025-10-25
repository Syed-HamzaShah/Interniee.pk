import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseInitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeDatabase() async {
    try {
      await _createSampleAdmin();

      await _createSampleInterns();

      await _createSampleTasks();

      await _createSampleFeedbacks();

    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createSampleAdmin() async {
    final adminId = 'admin_001';
    final adminData = {
      'id': adminId,
      'name': 'Admin User',
      'email': 'admin@internee.pk',
      'role': 'admin',
      'createdAt': Timestamp.now(),
      'profileImageUrl': null,
    };

    await _firestore.collection('users').doc(adminId).set(adminData);
  }

  Future<void> _createSampleInterns() async {
    final interns = [
      {
        'id': 'intern_001',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'role': 'intern',
        'phone': '+1234567890',
        'department': 'Software Development',
        'university': 'University of Technology',
        'course': 'Computer Science',
        'startDate': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 30)),
        ),
        'endDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 60)),
        ),
        'profileImageUrl': null,
        'bio':
            'Passionate about software development and learning new technologies.',
        'skills': ['Flutter', 'Dart', 'Firebase', 'Git'],
        'performance': {
          'totalTasksAssigned': 5,
          'totalTasksCompleted': 3,
          'totalTasksOverdue': 1,
          'averageRating': 4.2,
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      },
      {
        'id': 'intern_002',
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'role': 'intern',
        'phone': '+1234567891',
        'department': 'Marketing',
        'university': 'Business University',
        'course': 'Marketing Management',
        'startDate': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 15)),
        ),
        'endDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 75)),
        ),
        'profileImageUrl': null,
        'bio':
            'Creative marketer with a passion for digital marketing and social media.',
        'skills': [
          'Digital Marketing',
          'Social Media',
          'Content Creation',
          'Analytics',
        ],
        'performance': {
          'totalTasksAssigned': 3,
          'totalTasksCompleted': 2,
          'totalTasksOverdue': 0,
          'averageRating': 4.5,
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      },
      {
        'id': 'intern_003',
        'name': 'Mike Johnson',
        'email': 'mike.johnson@example.com',
        'role': 'intern',
        'phone': '+1234567892',
        'department': 'Data Science',
        'university': 'Data Science Institute',
        'course': 'Data Science',
        'startDate': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 45)),
        ),
        'endDate': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 45)),
        ),
        'profileImageUrl': null,
        'bio':
            'Data enthusiast with expertise in machine learning and statistical analysis.',
        'skills': ['Python', 'Machine Learning', 'Statistics', 'SQL'],
        'performance': {
          'totalTasksAssigned': 7,
          'totalTasksCompleted': 6,
          'totalTasksOverdue': 0,
          'averageRating': 4.8,
        },
        'isActive': true,
        'createdAt': Timestamp.now(),
        'lastActiveAt': Timestamp.now(),
      },
    ];

    for (final intern in interns) {
      await _firestore
          .collection('users')
          .doc(intern['id'] as String)
          .set(intern);
    }
  }

  Future<void> _createSampleTasks() async {
    final tasks = [
      {
        'id': 'task_001',
        'title': 'Develop Flutter Mobile App',
        'description':
            'Create a mobile application using Flutter framework with Firebase backend integration.',
        'assignedTo': 'intern_001',
        'assignedBy': 'admin_001',
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
        'status': 'inProgress',
        'priority': 'high',
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'notes': 'Focus on clean code and proper documentation.',
        'attachments': [],
      },
      {
        'id': 'task_002',
        'title': 'Social Media Campaign',
        'description':
            'Design and execute a social media marketing campaign for the new product launch.',
        'assignedTo': 'intern_002',
        'assignedBy': 'admin_001',
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 10)),
        ),
        'status': 'notStarted',
        'priority': 'medium',
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'notes': 'Include Instagram, Facebook, and Twitter strategies.',
        'attachments': [],
      },
      {
        'id': 'task_003',
        'title': 'Data Analysis Report',
        'description':
            'Analyze customer data and create comprehensive insights report.',
        'assignedTo': 'intern_003',
        'assignedBy': 'admin_001',
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 5)),
        ),
        'status': 'completed',
        'priority': 'urgent',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        'completedAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'notes': 'Excellent work on the analysis. Very detailed insights.',
        'attachments': ['report.pdf'],
      },
      {
        'id': 'task_004',
        'title': 'UI/UX Design Review',
        'description':
            'Review and improve the user interface design for better user experience.',
        'assignedTo': 'intern_001',
        'assignedBy': 'admin_001',
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
        'status': 'inProgress',
        'priority': 'medium',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'completedAt': null,
        'notes': 'Focus on accessibility and mobile responsiveness.',
        'attachments': [],
      },
      {
        'id': 'task_005',
        'title': 'Content Creation',
        'description':
            'Create engaging content for blog posts and social media platforms.',
        'assignedTo': 'intern_002',
        'assignedBy': 'admin_001',
        'deadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 4)),
        ),
        'status': 'notStarted',
        'priority': 'low',
        'createdAt': Timestamp.now(),
        'completedAt': null,
        'notes': 'Include SEO optimization and keyword research.',
        'attachments': [],
      },
    ];

    for (final task in tasks) {
      await _firestore.collection('tasks').doc(task['id'] as String).set(task);
    }
  }

  Future<void> _createSampleFeedbacks() async {
    final feedbacks = [
      {
        'id': 'feedback_001',
        'userId': 'intern_001',
        'userName': 'John Doe',
        'userEmail': 'john.doe@example.com',
        'name': 'Flutter Development Experience',
        'category': 'internship',
        'rating': 5,
        'comments':
            'The Flutter development internship has been amazing. I learned a lot about mobile app development and Firebase integration. The mentors are very supportive and the projects are challenging yet achievable.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'updatedAt': null,
        'status': 'approved',
        'adminNotes': 'Great feedback from a dedicated intern.',
      },
      {
        'id': 'feedback_002',
        'userId': 'intern_002',
        'userName': 'Jane Smith',
        'userEmail': 'jane.smith@example.com',
        'name': 'Marketing Department',
        'category': 'company',
        'rating': 4,
        'comments':
            'The marketing team is very professional and welcoming. I gained valuable experience in digital marketing and social media management. The work environment is collaborative and encouraging.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'updatedAt': null,
        'status': 'pending',
        'adminNotes': null,
      },
      {
        'id': 'feedback_003',
        'userId': 'intern_003',
        'userName': 'Mike Johnson',
        'userEmail': 'mike.johnson@example.com',
        'name': 'Data Science Program',
        'category': 'course',
        'rating': 5,
        'comments':
            'The data science program exceeded my expectations. The projects are real-world applicable and the learning curve is well-structured. I highly recommend this program to anyone interested in data science.',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 3)),
        ),
        'updatedAt': null,
        'status': 'approved',
        'adminNotes': 'Outstanding performance and feedback.',
      },
      {
        'id': 'feedback_004',
        'userId': 'intern_001',
        'userName': 'John Doe',
        'userEmail': 'john.doe@example.com',
        'name': 'Overall Experience',
        'category': 'experience',
        'rating': 4,
        'comments':
            'Overall, my internship experience has been very positive. The company culture is great, and I have learned a lot. The only suggestion would be to have more structured learning sessions.',
        'createdAt': Timestamp.now(),
        'updatedAt': null,
        'status': 'pending',
        'adminNotes': null,
      },
    ];

    for (final feedback in feedbacks) {
      await _firestore
          .collection('feedbacks')
          .doc(feedback['id'] as String)
          .set(feedback);
    }
  }

  Future<void> createIndexes() async {
  }

  Future<void> clearAllData() async {
    try {
      final collections = [
        'users',
        'tasks',
        'feedbacks',
        'reports',
        'notifications',
      ];

      for (final collection in collections) {
        final batch = _firestore.batch();
        final snapshot = await _firestore.collection(collection).get();

        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
      }

    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isDatabaseInitialized() async {
    try {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      return usersSnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getDatabaseStatistics() async {
    try {
      final stats = <String, int>{};

      final collections = ['users', 'tasks', 'feedbacks'];

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        stats[collection] = snapshot.docs.length;
      }

      return stats;
    } catch (e) {
      return {};
    }
  }
}
