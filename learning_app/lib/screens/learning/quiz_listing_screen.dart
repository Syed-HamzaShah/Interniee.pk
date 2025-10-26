import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/learning_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shimmer_widget.dart';
import '../../models/lesson_model.dart';
import 'quiz_screen.dart';

class QuizListingScreen extends StatefulWidget {
  final String? courseId;
  final String? lessonId;

  const QuizListingScreen({super.key, this.courseId, this.lessonId});

  @override
  State<QuizListingScreen> createState() => _QuizListingScreenState();
}

class _QuizListingScreenState extends State<QuizListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final learningProvider = Provider.of<LearningProvider>(
        context,
        listen: false,
      );
      learningProvider.loadQuizzes(
        courseId: widget.courseId,
        lessonId: widget.lessonId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(widget.courseId != null ? 'Course Quizzes' : 'All Quizzes'),
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
      ),
      body: Consumer<LearningProvider>(
        builder: (context, learningProvider, child) {
          if (learningProvider.isLoading) {
            return _buildLoadingState();
          }

          if (learningProvider.error != null) {
            return _buildErrorState(learningProvider.error!);
          }

          if (learningProvider.quizzes.isEmpty) {
            return _buildEmptyState();
          }

          return _buildQuizList(learningProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: AppTheme.getScreenPadding(context),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
        child: ShimmerWidget(
          isLoading: true,
          child: Container(
            height: 120,
            decoration: AppTheme.getCardDecoration(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.statusOverdue),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Something went wrong',
              style: AppTheme.getHeadingStyle(fontSize: 24),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              error,
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            ElevatedButton(
              onPressed: () {
                final learningProvider = Provider.of<LearningProvider>(
                  context,
                  listen: false,
                );
                learningProvider.loadQuizzes(
                  courseId: widget.courseId,
                  lessonId: widget.lessonId,
                );
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No quizzes available',
              style: AppTheme.getHeadingStyle(fontSize: 24),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Check back later for new quizzes',
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizList(LearningProvider learningProvider) {
    return ListView.builder(
      padding: AppTheme.getScreenPadding(context),
      itemCount: learningProvider.quizzes.length,
      itemBuilder: (context, index) {
        final quiz = learningProvider.quizzes[index];
        return _buildQuizCard(quiz, learningProvider);
      },
    );
  }

  Widget _buildQuizCard(quiz, LearningProvider learningProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Card(
        child: InkWell(
          onTap: () => _navigateToQuiz(quiz),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quiz title and difficulty
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: AppTheme.getHeadingStyle(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: Text(
                        'QUIZ',
                        style: AppTheme.getCaptionStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingSmall),

                // Description
                Text(
                  quiz.description,
                  style: AppTheme.getBodyStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.spacingMedium),

                // Quiz stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.quiz,
                      '${quiz.questions.length} questions',
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    if (quiz.timeLimit > 0)
                      _buildStatItem(
                        Icons.access_time,
                        '${quiz.timeLimit} min',
                      ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    _buildStatItem(Icons.star, '${quiz.passingScore}% to pass'),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingMedium),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToQuiz(quiz),
                    child: const Text('Start Quiz'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.spacingXSmall),
        Text(text, style: AppTheme.getCaptionStyle(fontSize: 12)),
      ],
    );
  }

  void _navigateToQuiz(quiz) {
    // For now, we'll create a mock lesson since QuizScreen expects a LessonModel
    // In a real app, you'd have a proper lesson associated with the quiz
    final mockLesson = LessonModel(
      id: quiz.lessonId,
      courseId: quiz.courseId,
      title: quiz.title,
      description: quiz.description,
      type: LessonType.quiz,
      order: 1,
      duration: quiz.timeLimit,
      isPublished: true,
      isFree: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      attachments: [],
      quizId: quiz.id,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(lesson: mockLesson)),
    );
  }
}
