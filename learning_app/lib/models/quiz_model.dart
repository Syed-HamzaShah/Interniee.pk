import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType { multipleChoice, trueFalse, fillInTheBlank, shortAnswer }

class QuizModel {
  final String id;
  final String courseId;
  final String lessonId;
  final String title;
  final String description;
  final List<QuestionModel> questions;
  final int timeLimit; // in minutes, 0 means no time limit
  final int passingScore; // percentage
  final int maxAttempts; // 0 means unlimited
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? externalId; // ID from learn.internee.pk

  QuizModel({
    required this.id,
    required this.courseId,
    required this.lessonId,
    required this.title,
    required this.description,
    required this.questions,
    required this.timeLimit,
    required this.passingScore,
    required this.maxAttempts,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    this.externalId,
  });

  factory QuizModel.fromMap(Map<String, dynamic> map) {
    return QuizModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions:
          (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeLimit: map['timeLimit'] ?? 0,
      passingScore: map['passingScore'] ?? 70,
      maxAttempts: map['maxAttempts'] ?? 0,
      isPublished: map['isPublished'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      externalId: map['externalId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'lessonId': lessonId,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'maxAttempts': maxAttempts,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'externalId': externalId,
    };
  }

  @override
  String toString() {
    return 'QuizModel(id: $id, title: $title, questionsCount: ${questions.length})';
  }
}

class QuestionModel {
  final String id;
  final String question;
  final QuestionType type;
  final List<OptionModel> options; // for multiple choice and true/false
  final String? correctAnswer; // for fill in the blank and short answer
  final List<String>? correctAnswers; // for multiple correct answers
  final int points;
  final String? explanation;
  final int order;

  QuestionModel({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.correctAnswer,
    this.correctAnswers,
    required this.points,
    this.explanation,
    required this.order,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    try {
      // Parse question type with flexible matching
      QuestionType questionType = QuestionType.multipleChoice;
      final typeString = map['type']
          ?.toString()
          .toLowerCase()
          .replaceAll('_', '')
          .replaceAll('-', '')
          .trim();
      if (typeString != null && typeString.isNotEmpty) {
        print('Parsing question type: $typeString');
        // Handle both full enum name and just the type name
        if (typeString.contains('multiplechoice')) {
          questionType = QuestionType.multipleChoice;
        } else if (typeString.contains('truefalse') ||
            typeString == 'true' ||
            typeString == 'false') {
          questionType = QuestionType.trueFalse;
        } else if (typeString.contains('fillintheblank') ||
            typeString.contains('blank')) {
          questionType = QuestionType.fillInTheBlank;
        } else if (typeString.contains('shortanswer') ||
            typeString.contains('short')) {
          questionType = QuestionType.shortAnswer;
        } else {
          // Try exact match with enum values
          try {
            questionType = QuestionType.values.firstWhere((e) {
              final enumName = e
                  .toString()
                  .split('.')
                  .last
                  .toLowerCase()
                  .replaceAll('_', '')
                  .replaceAll('-', '')
                  .trim();
              return enumName == typeString ||
                  enumName.contains(typeString) ||
                  typeString.contains(enumName);
            }, orElse: () => QuestionType.multipleChoice);
          } catch (e) {
            print(
              'Warning: Could not parse question type: $typeString, defaulting to multipleChoice',
            );
          }
        }
      }
      print('Parsed question type: $questionType');

      // Parse options - handle both List and Map formats
      List<OptionModel> options = [];
      if (map['options'] != null) {
        if (map['options'] is List) {
          options = (map['options'] as List)
              .where((o) => o is Map<String, dynamic>)
              .map((o) {
                try {
                  return OptionModel.fromMap(o as Map<String, dynamic>);
                } catch (e) {
                  print('Error parsing option: $e');
                  return null;
                }
              })
              .whereType<OptionModel>()
              .toList();
        } else if (map['options'] is Map) {
          // Handle map of options
          final optionsMap = map['options'] as Map<String, dynamic>;
          options = optionsMap.values
              .whereType<Map<String, dynamic>>()
              .map((o) {
                try {
                  return OptionModel.fromMap(o);
                } catch (e) {
                  print('Error parsing option: $e');
                  return null;
                }
              })
              .whereType<OptionModel>()
              .toList();
        }
      }

      return QuestionModel(
        id: map['id']?.toString() ?? map['questionId']?.toString() ?? '',
        question: map['question']?.toString() ?? map['text']?.toString() ?? '',
        type: questionType,
        options: options,
        correctAnswer: map['correctAnswer']?.toString(),
        correctAnswers: map['correctAnswers'] != null
            ? List<String>.from(map['correctAnswers'])
            : null,
        points: map['points'] is int
            ? map['points']
            : (map['points'] is num ? (map['points'] as num).toInt() : 1),
        explanation: map['explanation']?.toString(),
        order: map['order'] is int
            ? map['order']
            : (map['order'] is num ? (map['order'] as num).toInt() : 0),
      );
    } catch (e, stackTrace) {
      print('Error creating QuestionModel: $e');
      print('Map data: $map');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type.toString().split('.').last,
      'options': options.map((o) => o.toMap()).toList(),
      'correctAnswer': correctAnswer,
      'correctAnswers': correctAnswers,
      'points': points,
      'explanation': explanation,
      'order': order,
    };
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, type: $type)';
  }
}

class OptionModel {
  final String id;
  final String text;
  final bool isCorrect;
  final int order;

  OptionModel({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.order,
  });

  factory OptionModel.fromMap(Map<String, dynamic> map) {
    try {
      return OptionModel(
        id: map['id']?.toString() ?? map['optionId']?.toString() ?? '',
        text:
            map['text']?.toString() ??
            map['option']?.toString() ??
            map['label']?.toString() ??
            '',
        isCorrect:
            map['isCorrect'] == true ||
            map['isCorrect'] == 'true' ||
            map['isCorrect'] == 1,
        order: map['order'] is int
            ? map['order']
            : (map['order'] is num ? (map['order'] as num).toInt() : 0),
      );
    } catch (e, stackTrace) {
      print('Error creating OptionModel: $e');
      print('Map data: $map');
      print('Stack trace: $stackTrace');
      // Return a default option instead of crashing
      return OptionModel(
        id: map['id']?.toString() ?? '',
        text: 'Invalid option',
        isCorrect: false,
        order: 0,
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'isCorrect': isCorrect, 'order': order};
  }

  @override
  String toString() {
    return 'OptionModel(id: $id, text: $text, isCorrect: $isCorrect)';
  }
}

class QuizAttemptModel {
  final String id;
  final String userId;
  final String quizId;
  final String courseId;
  final String lessonId;
  final List<AnswerModel> answers;
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int timeSpent; // in seconds
  final DateTime startedAt;
  final DateTime? completedAt;
  final int attemptNumber;

  QuizAttemptModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.courseId,
    required this.lessonId,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passed,
    required this.timeSpent,
    required this.startedAt,
    this.completedAt,
    required this.attemptNumber,
  });

  factory QuizAttemptModel.fromMap(Map<String, dynamic> map) {
    return QuizAttemptModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      quizId: map['quizId'] ?? '',
      courseId: map['courseId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      answers:
          (map['answers'] as List<dynamic>?)
              ?.map((a) => AnswerModel.fromMap(a as Map<String, dynamic>))
              .toList() ??
          [],
      score: map['score'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      passed: map['passed'] ?? false,
      timeSpent: map['timeSpent'] ?? 0,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      attemptNumber: map['attemptNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'courseId': courseId,
      'lessonId': lessonId,
      'answers': answers.map((a) => a.toMap()).toList(),
      'score': score,
      'totalPoints': totalPoints,
      'percentage': percentage,
      'passed': passed,
      'timeSpent': timeSpent,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'attemptNumber': attemptNumber,
    };
  }

  @override
  String toString() {
    return 'QuizAttemptModel(id: $id, score: $score, percentage: $percentage, passed: $passed)';
  }
}

class AnswerModel {
  final String questionId;
  String? selectedOptionId; // for multiple choice
  String? textAnswer; // for text-based answers
  List<String>? selectedOptionIds; // for multiple correct answers
  bool isCorrect;
  int pointsEarned;

  AnswerModel({
    required this.questionId,
    this.selectedOptionId,
    this.textAnswer,
    this.selectedOptionIds,
    required this.isCorrect,
    required this.pointsEarned,
  });

  factory AnswerModel.fromMap(Map<String, dynamic> map) {
    return AnswerModel(
      questionId: map['questionId'] ?? '',
      selectedOptionId: map['selectedOptionId'],
      textAnswer: map['textAnswer'],
      selectedOptionIds: map['selectedOptionIds'] != null
          ? List<String>.from(map['selectedOptionIds'])
          : null,
      isCorrect: map['isCorrect'] ?? false,
      pointsEarned: map['pointsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedOptionId': selectedOptionId,
      'textAnswer': textAnswer,
      'selectedOptionIds': selectedOptionIds,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
    };
  }

  @override
  String toString() {
    return 'AnswerModel(questionId: $questionId, isCorrect: $isCorrect, pointsEarned: $pointsEarned)';
  }
}
