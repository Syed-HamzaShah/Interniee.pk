import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../models/quiz_model.dart';
import '../../services/learning_service.dart';

class QuizScreen extends StatefulWidget {
  final LessonModel lesson;

  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizModel? _quiz;
  List<AnswerModel> _answers = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _quizCompleted = false;
  QuizAttemptModel? _quizResult;
  String? _error;
  DateTime _startTime = DateTime.now();
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      print('=== QUIZ LOADING DEBUG ===');
      print('Loading quiz for lesson: ${widget.lesson.title}');
      print('Lesson ID: ${widget.lesson.id}');
      print('Quiz ID: ${widget.lesson.quizId}');
      print('Lesson Type: ${widget.lesson.type}');

      if (widget.lesson.quizId == null || widget.lesson.quizId!.isEmpty) {
        setState(() {
          _error =
              'Quiz not configured for this lesson. Please contact the course administrator.';
          _isLoading = false;
        });
        print('Error: Quiz ID is null or empty');
        return;
      }

      print('Fetching quiz from Firebase...');
      // Fetch quiz from Firebase
      _quiz = await LearningService.getQuizById(widget.lesson.quizId!);

      if (_quiz == null) {
        setState(() {
          _error =
              'Quiz "${widget.lesson.quizId}" not found in database. The quiz data may not be seeded yet. Please run the data seed script or contact the administrator.';
          _isLoading = false;
        });
        print('Error: Quiz is null - not found in Firestore');
        return;
      }

      print('Quiz loaded successfully: ${_quiz!.title}');
      print('Number of questions: ${_quiz!.questions.length}');

      if (_quiz!.questions.isEmpty) {
        setState(() {
          _error =
              'Quiz has no questions. The quiz data may be incomplete. Please check the database or reseed the quiz data.';
          _isLoading = false;
        });
        print('Error: Quiz has no questions');
        print('Quiz data: $_quiz');
        return;
      }

      // Initialize answers
      _answers = List.generate(
        _quiz!.questions.length,
        (index) => AnswerModel(
          questionId: _quiz!.questions[index].id,
          isCorrect: false,
          pointsEarned: 0,
        ),
      );

      // Set time limit
      if (_quiz!.timeLimit > 0) {
        _timeRemaining = Duration(minutes: _quiz!.timeLimit);
        _startTimer();
      }

      setState(() {
        _isLoading = false;
      });
      print('Quiz loading complete - Ready to start!');
    } catch (e, stackTrace) {
      print('Error loading quiz: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error =
            'Failed to load quiz: ${e.toString()}\n\nPlease check if the quiz data is properly seeded in Firebase.';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_quizCompleted) {
        setState(() {
          if (_timeRemaining.inSeconds > 0) {
            _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
            _startTimer();
          } else {
            _submitQuiz();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          _quiz?.title ?? widget.lesson.title,
          style: AppTheme.getHeadingStyle(fontSize: 16),
        ),
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        actions: [
          if (_quiz?.timeLimit != null && _quiz!.timeLimit > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
                vertical: AppTheme.spacingXSmall,
              ),
              margin: const EdgeInsets.only(right: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: _timeRemaining.inMinutes < 2
                    ? AppTheme.statusOverdue
                    : AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Text(
                _formatDuration(_timeRemaining),
                style: AppTheme.getCaptionStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'Loading quiz...',
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_quizCompleted) {
      return _buildQuizResult();
    }

    return _buildQuizContent();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.statusOverdue),
            const SizedBox(height: AppTheme.spacingLarge),
            Text('Quiz Error', style: AppTheme.getHeadingStyle(fontSize: 24)),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              _error!,
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton(onPressed: _loadQuiz, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_quiz == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quiz!.questions.isEmpty) {
      return Center(
        child: Padding(
          padding: AppTheme.getScreenPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                'No Questions Available',
                style: AppTheme.getHeadingStyle(fontSize: 20),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'This quiz doesn\'t have any questions yet.',
                style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQuestionIndex >= _quiz!.questions.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = _quiz!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _quiz!.questions.length;

    return Column(
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_quiz!.questions.length}',
                    style: AppTheme.getBodyStyle(fontSize: 14),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTheme.getBodyStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppTheme.darkBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: AppTheme.getScreenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: AppTheme.getHeadingStyle(fontSize: 18),
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSmall,
                                vertical: AppTheme.spacingXSmall,
                              ),
                              decoration: BoxDecoration(
                                color: _getQuestionTypeColor(question.type),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall,
                                ),
                              ),
                              child: Text(
                                _getQuestionTypeText(question.type),
                                style: AppTheme.getCaptionStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSmall),
                            Text(
                              '${question.points} point${question.points > 1 ? 's' : ''}',
                              style: AppTheme.getCaptionStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                // Answer options
                _buildAnswerOptions(question),
              ],
            ),
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildAnswerOptions(QuestionModel question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceOptions(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseOptions(question);
      case QuestionType.fillInTheBlank:
        return _buildFillInTheBlankInput(question);
      case QuestionType.shortAnswer:
        return _buildShortAnswerInput(question);
    }
  }

  Widget _buildMultipleChoiceOptions(QuestionModel question) {
    return Column(
      children: question.options.map((option) {
        final isSelected =
            _answers[_currentQuestionIndex].selectedOptionId == option.id;
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
          child: Card(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : null,
            child: ListTile(
              title: Text(
                option.text,
                style: AppTheme.getBodyStyle(fontSize: 16),
              ),
              leading: Radio<String>(
                value: option.id,
                groupValue: _answers[_currentQuestionIndex].selectedOptionId,
                onChanged: (value) {
                  setState(() {
                    _answers[_currentQuestionIndex].selectedOptionId = value;
                  });
                },
                activeColor: AppTheme.primaryGreen,
              ),
              onTap: () {
                setState(() {
                  _answers[_currentQuestionIndex].selectedOptionId = option.id;
                });
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(QuestionModel question) {
    return Column(
      children: [
        _buildTrueFalseOption(question, 'True', true),
        const SizedBox(height: AppTheme.spacingSmall),
        _buildTrueFalseOption(question, 'False', false),
      ],
    );
  }

  Widget _buildTrueFalseOption(
    QuestionModel question,
    String text,
    bool value,
  ) {
    final isSelected =
        _answers[_currentQuestionIndex].selectedOptionId == value.toString();
    return Container(
      child: Card(
        color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : null,
        child: ListTile(
          title: Text(text, style: AppTheme.getBodyStyle(fontSize: 16)),
          leading: Radio<String>(
            value: value.toString(),
            groupValue: _answers[_currentQuestionIndex].selectedOptionId,
            onChanged: (selectedValue) {
              setState(() {
                _answers[_currentQuestionIndex].selectedOptionId =
                    selectedValue;
              });
            },
            activeColor: AppTheme.primaryGreen,
          ),
          onTap: () {
            setState(() {
              _answers[_currentQuestionIndex].selectedOptionId = value
                  .toString();
            });
          },
        ),
      ),
    );
  }

  Widget _buildFillInTheBlankInput(QuestionModel question) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _answers[_currentQuestionIndex].textAnswer = value;
        });
      },
    );
  }

  Widget _buildShortAnswerInput(QuestionModel question) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _answers[_currentQuestionIndex].textAnswer = value;
        });
      },
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: AppTheme.getScreenPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                child: const Text('Previous'),
              ),
            ),
          if (_currentQuestionIndex > 0)
            const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextQuestion,
              child: Text(
                _currentQuestionIndex == _quiz!.questions.length - 1
                    ? 'Submit Quiz'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResult() {
    if (_quizResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final passed = _quizResult!.passed;
    final percentage = _quizResult!.percentage;

    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Column(
        children: [
          // Result header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    size: 80,
                    color: passed
                        ? AppTheme.statusCompleted
                        : AppTheme.statusOverdue,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    passed ? 'Congratulations!' : 'Try Again',
                    style: AppTheme.getHeadingStyle(fontSize: 24),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    'You scored ${percentage.round()}%',
                    style: AppTheme.getBodyStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppTheme.darkBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      passed
                          ? AppTheme.statusCompleted
                          : AppTheme.statusOverdue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // Score details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quiz Details',
                    style: AppTheme.getSubheadingStyle(fontSize: 18),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildScoreRow(
                    'Score',
                    '${_quizResult!.score}/${_quizResult!.totalPoints}',
                  ),
                  _buildScoreRow('Percentage', '${percentage.round()}%'),
                  _buildScoreRow(
                    'Time Spent',
                    _formatDuration(Duration(seconds: _quizResult!.timeSpent)),
                  ),
                  _buildScoreRow('Status', passed ? 'Passed' : 'Failed'),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _retakeQuiz,
                  child: const Text('Retake Quiz'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: ElevatedButton(
                  onPressed: _continueLearning,
                  child: const Text('Continue Learning'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.getBodyStyle(fontSize: 14)),
          Text(
            value,
            style: AppTheme.getBodyStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return AppTheme.primaryGreen;
      case QuestionType.trueFalse:
        return AppTheme.statusInProgress;
      case QuestionType.fillInTheBlank:
        return AppTheme.statusPending;
      case QuestionType.shortAnswer:
        return AppTheme.statusOverdue;
    }
  }

  String _getQuestionTypeText(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'MULTIPLE CHOICE';
      case QuestionType.trueFalse:
        return 'TRUE/FALSE';
      case QuestionType.fillInTheBlank:
        return 'FILL IN THE BLANK';
      case QuestionType.shortAnswer:
        return 'SHORT ANSWER';
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex == _quiz!.questions.length - 1) {
      _submitQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final learningProvider = Provider.of<LearningProvider>(
        context,
        listen: false,
      );

      if (authProvider.userModel != null) {
        // Calculate scores
        int totalScore = 0;
        int totalPoints = _quiz!.questions.fold(0, (sum, q) => sum + q.points);

        for (int i = 0; i < _quiz!.questions.length; i++) {
          final question = _quiz!.questions[i];
          final answer = _answers[i];

          bool isCorrect = false;
          int pointsEarned = 0;

          switch (question.type) {
            case QuestionType.multipleChoice:
            case QuestionType.trueFalse:
              final selectedOption = question.options.firstWhere(
                (opt) => opt.id == answer.selectedOptionId,
                orElse: () =>
                    OptionModel(id: '', text: '', isCorrect: false, order: 0),
              );
              isCorrect = selectedOption.isCorrect;
              pointsEarned = isCorrect ? question.points : 0;
              break;
            case QuestionType.fillInTheBlank:
            case QuestionType.shortAnswer:
              // For text answers, we'll need server-side evaluation
              // For now, just check if answer is provided
              isCorrect = answer.textAnswer?.isNotEmpty ?? false;
              pointsEarned = isCorrect ? question.points : 0;
              break;
          }

          answer.isCorrect = isCorrect;
          answer.pointsEarned = pointsEarned;
          totalScore += pointsEarned;
        }

        final percentage = (totalScore / totalPoints) * 100;
        final passed = percentage >= _quiz!.passingScore;
        final timeSpent = DateTime.now().difference(_startTime).inSeconds;

        var quizAttempt = QuizAttemptModel(
          id: '',
          userId: authProvider.userModel!.id,
          quizId: _quiz!.id,
          courseId: _quiz!.courseId,
          lessonId: _quiz!.lessonId,
          answers: _answers,
          score: totalScore,
          totalPoints: totalPoints,
          percentage: percentage,
          passed: passed,
          timeSpent: timeSpent,
          startedAt: _startTime,
          completedAt: DateTime.now(),
          attemptNumber: 1, // TODO: Get actual attempt number
        );

        // Submit to provider (tries API first, falls back to Firebase only)
        QuizAttemptModel? result;
        try {
          result = await learningProvider.submitQuizAttempt(
            userId: authProvider.userModel!.id,
            quizId: _quiz!.id,
            answers: _answers,
            timeSpent: timeSpent,
          );
        } catch (e) {
          print('Failed to submit via API, saving to Firebase only: $e');
          // Save directly to Firebase
          try {
            final attemptId = await LearningService.saveQuizAttempt(
              quizAttempt,
            );
            quizAttempt = QuizAttemptModel(
              id: attemptId,
              userId: quizAttempt.userId,
              quizId: quizAttempt.quizId,
              courseId: quizAttempt.courseId,
              lessonId: quizAttempt.lessonId,
              answers: quizAttempt.answers,
              score: quizAttempt.score,
              totalPoints: quizAttempt.totalPoints,
              percentage: quizAttempt.percentage,
              passed: quizAttempt.passed,
              timeSpent: quizAttempt.timeSpent,
              startedAt: quizAttempt.startedAt,
              completedAt: quizAttempt.completedAt,
              attemptNumber: quizAttempt.attemptNumber,
            );
            result = quizAttempt;
          } catch (firebaseError) {
            print('Failed to save to Firebase: $firebaseError');
          }
        }

        setState(() {
          _quizResult = result ?? quizAttempt;
          _quizCompleted = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to submit quiz: $e';
      });
    }
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _quizCompleted = false;
      _quizResult = null;
      _answers = List.generate(
        _quiz!.questions.length,
        (index) => AnswerModel(
          questionId: _quiz!.questions[index].id,
          isCorrect: false,
          pointsEarned: 0,
        ),
      );
      _startTime = DateTime.now();
      if (_quiz!.timeLimit > 0) {
        _timeRemaining = Duration(minutes: _quiz!.timeLimit);
        _startTimer();
      }
    });
  }

  void _continueLearning() {
    Navigator.pop(context);
  }
}
