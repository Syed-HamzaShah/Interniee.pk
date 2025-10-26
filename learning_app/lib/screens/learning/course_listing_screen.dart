import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shimmer_widget.dart';
import '../../models/lesson_model.dart';
import 'course_detail_screen.dart';
import 'quiz_screen.dart';

class CourseListingScreen extends StatefulWidget {
  const CourseListingScreen({super.key});

  @override
  State<CourseListingScreen> createState() => _CourseListingScreenState();
}

class _CourseListingScreenState extends State<CourseListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  final List<String> _categories = [
    'All',
    'Mobile Development',
    'Web Development',
    'Data Science',
    'Machine Learning',
    'UI/UX Design',
    'Backend Development',
  ];
  final List<String> _difficulties = [
    'All',
    'beginner',
    'intermediate',
    'advanced',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final learningProvider = Provider.of<LearningProvider>(
        context,
        listen: false,
      );
      if (authProvider.userModel != null) {
        learningProvider.initialize(authProvider.userModel!.id);
        // Load quizzes as well
        learningProvider.loadQuizzes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Learning Center' : 'Quizzes'),
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        actions: [
          if (_selectedIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showSignOutDialog,
            ),
          ],
        ],
      ),
      body: _selectedIndex == 0 ? _buildCoursesTab() : _buildQuizzesTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.darkSurface,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizzes'),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, child) {
        if (learningProvider.isLoading) {
          return _buildLoadingState();
        }

        if (learningProvider.error != null) {
          return _buildErrorState(learningProvider.error!);
        }

        if (learningProvider.courses.isEmpty) {
          return _buildEmptyState();
        }

        return _buildCourseList(learningProvider);
      },
    );
  }

  Widget _buildQuizzesTab() {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, child) {
        if (learningProvider.isLoading) {
          return _buildLoadingState();
        }

        if (learningProvider.error != null) {
          return _buildErrorState(learningProvider.error!);
        }

        if (learningProvider.quizzes.isEmpty) {
          return _buildEmptyQuizState();
        }

        return _buildQuizList(learningProvider);
      },
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
            height: 200,
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
                learningProvider.loadCourses();
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
            Icon(
              Icons.school_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No courses available',
              style: AppTheme.getHeadingStyle(fontSize: 24),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Check back later for new courses',
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyQuizState() {
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

  Widget _buildCourseList(LearningProvider learningProvider) {
    return Column(
      children: [
        // Search and filter bar
        if (learningProvider.searchQuery.isNotEmpty ||
            learningProvider.selectedCategory != null ||
            learningProvider.selectedDifficulty != null)
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            color: AppTheme.darkSurface,
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppTheme.spacingSmall,
                    children: [
                      if (learningProvider.searchQuery.isNotEmpty)
                        Chip(
                          label: Text(
                            'Search: ${learningProvider.searchQuery}',
                          ),
                          onDeleted: () {
                            learningProvider.clearSearch();
                            _searchController.clear();
                          },
                        ),
                      if (learningProvider.selectedCategory != null)
                        Chip(
                          label: Text(
                            'Category: ${learningProvider.selectedCategory}',
                          ),
                          onDeleted: () {
                            learningProvider.filterCourses(category: null);
                          },
                        ),
                      if (learningProvider.selectedDifficulty != null)
                        Chip(
                          label: Text(
                            'Level: ${learningProvider.selectedDifficulty}',
                          ),
                          onDeleted: () {
                            learningProvider.filterCourses(difficulty: null);
                          },
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    learningProvider.clearFilters();
                    learningProvider.clearSearch();
                    _searchController.clear();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

        // Course list
        Expanded(
          child: ListView.builder(
            padding: AppTheme.getScreenPadding(context),
            itemCount: learningProvider.courses.length,
            itemBuilder: (context, index) {
              final course = learningProvider.courses[index];
              return _buildCourseCard(course, learningProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(course, LearningProvider learningProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Card(
        child: InkWell(
          onTap: () => _navigateToCourseDetail(course),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusMedium),
                  topRight: Radius.circular(AppTheme.borderRadiusMedium),
                ),
                child: CachedNetworkImage(
                  imageUrl: course.thumbnailUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: AppTheme.darkCard,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: AppTheme.darkCard,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              // Course content
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title and difficulty
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.title,
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
                            color: AppTheme.getPriorityColor(course.difficulty),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                          ),
                          child: Text(
                            course.difficulty.toUpperCase(),
                            style: AppTheme.getCaptionStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingSmall),

                    // Instructor
                    Text(
                      'by ${course.instructor}',
                      style: AppTheme.getBodyStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingSmall),

                    // Description
                    Text(
                      course.description,
                      style: AppTheme.getBodyStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: AppTheme.spacingMedium),

                    // Course stats
                    Row(
                      children: [
                        _buildStatItem(
                          Icons.play_lesson,
                          '${course.totalLessons} lessons',
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        _buildStatItem(
                          Icons.access_time,
                          '${course.duration} min',
                        ),
                        const SizedBox(width: AppTheme.spacingMedium),
                        _buildStatItem(Icons.star, course.rating.toString()),
                        const SizedBox(width: AppTheme.spacingMedium),
                        _buildStatItem(Icons.people, '${course.enrolledCount}'),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacingMedium),

                    // Category and tags
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
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
                            course.category,
                            style: AppTheme.getCaptionStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ...course.tags
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingSmall,
                                  vertical: AppTheme.spacingXSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBorder,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusSmall,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTheme.getCaptionStyle(fontSize: 12),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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

  void _navigateToCourseDetail(course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailScreen(course: course),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Courses'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter course name, instructor, or topic...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _searchController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final learningProvider = Provider.of<LearningProvider>(
                context,
                listen: false,
              );
              learningProvider.searchCourses(_searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
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

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusOverdue,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      // Navigate back to login screen or splash screen
      // The auth state change will automatically handle navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
