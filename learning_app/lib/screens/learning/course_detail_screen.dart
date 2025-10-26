import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/learning_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/shimmer_widget.dart';
import '../../models/course_model.dart';
import '../../models/lesson_model.dart';
import 'video_player_screen.dart';
import 'quiz_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkEnrollment();
    _loadCourseData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkEnrollment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );

    if (authProvider.userModel != null) {
      final isEnrolled = learningProvider.isEnrolledInCourse(widget.course.id);
      setState(() {
        _isEnrolled = isEnrolled;
      });
    }
  }

  Future<void> _loadCourseData() async {
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );
    await learningProvider.loadCourseLessons(widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildCourseHeader(),
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.darkSurface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.share), onPressed: _shareCourse),
        IconButton(
          icon: Icon(_isEnrolled ? Icons.bookmark : Icons.bookmark_border),
          onPressed: _toggleBookmark,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: widget.course.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.darkCard,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppTheme.darkCard,
            child: Icon(
              Icons.image_not_supported,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course title and difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.course.title,
                    style: AppTheme.getHeadingStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSmall,
                    vertical: AppTheme.spacingXSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getPriorityColor(widget.course.difficulty),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                  ),
                  child: Text(
                    widget.course.difficulty.toUpperCase(),
                    style: AppTheme.getCaptionStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingSmall),

            // Instructor and rating
            Row(
              children: [
                Text(
                  'by ${widget.course.instructor}',
                  style: AppTheme.getBodyStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.statusPending,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.spacingXSmall),
                    Text(
                      widget.course.rating.toString(),
                      style: AppTheme.getBodyStyle(fontSize: 14),
                    ),
                    const SizedBox(width: AppTheme.spacingXSmall),
                    Text(
                      '(${widget.course.enrolledCount} students)',
                      style: AppTheme.getCaptionStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            // Course stats
            Row(
              children: [
                _buildStatChip(
                  Icons.play_lesson,
                  '${widget.course.totalLessons} Lessons',
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                _buildStatChip(
                  Icons.access_time,
                  '${widget.course.duration} min',
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                _buildStatChip(Icons.category, widget.course.category),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            // Description
            Text(
              widget.course.description,
              style: AppTheme.getBodyStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: AppTheme.spacingMedium),

            // Tags
            Wrap(
              spacing: AppTheme.spacingSmall,
              runSpacing: AppTheme.spacingSmall,
              children: widget.course.tags
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
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingXSmall),
          Text(text, style: AppTheme.getCaptionStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: AppTheme.darkSurface,
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Lessons'),
            Tab(text: 'Overview'),
            Tab(text: 'Reviews'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [_buildLessonsTab(), _buildOverviewTab(), _buildReviewsTab()],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return Consumer<LearningProvider>(
      builder: (context, learningProvider, child) {
        if (learningProvider.isLoading) {
          return _buildLessonsLoadingState();
        }

        if (learningProvider.lessons.isEmpty) {
          return _buildEmptyLessonsState();
        }

        return ListView.builder(
          padding: AppTheme.getScreenPadding(context),
          itemCount: learningProvider.lessons.length,
          itemBuilder: (context, index) {
            final lesson = learningProvider.lessons[index];
            return _buildLessonCard(lesson, learningProvider);
          },
        );
      },
    );
  }

  Widget _buildLessonsLoadingState() {
    return ListView.builder(
      padding: AppTheme.getScreenPadding(context),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
        child: ShimmerWidget(
          isLoading: true,
          child: Container(
            height: 80,
            decoration: AppTheme.getCardDecoration(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLessonsState() {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_lesson_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No lessons available',
              style: AppTheme.getHeadingStyle(fontSize: 20),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Lessons will be added soon',
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(
    LessonModel lesson,
    LearningProvider learningProvider,
  ) {
    final progress = learningProvider.getLessonProgress(lesson.id);
    final isCompleted = progress?.isCompleted ?? false;
    final progressValue = progress?.progress ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppTheme.spacingMedium),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getLessonTypeColor(lesson.type),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              _getLessonTypeIcon(lesson.type),
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),
          title: Text(
            lesson.title,
            style: AppTheme.getSubheadingStyle(fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXSmall),
              Text(
                lesson.description,
                style: AppTheme.getBodyStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXSmall),
                  Text(
                    '${lesson.duration} min',
                    style: AppTheme.getCaptionStyle(fontSize: 12),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  if (lesson.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      child: Text(
                        'FREE',
                        style: AppTheme.getCaptionStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: AppTheme.darkBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted
                        ? AppTheme.statusCompleted
                        : AppTheme.primaryGreen,
                  ),
                ),
              ],
            ],
          ),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.play_circle_outline,
            color: isCompleted
                ? AppTheme.statusCompleted
                : AppTheme.primaryGreen,
          ),
          onTap: () => _navigateToLesson(lesson),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: AppTheme.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What you\'ll learn',
            style: AppTheme.getHeadingStyle(fontSize: 20),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildLearningOutcomes(),
          const SizedBox(height: AppTheme.spacingLarge),
          Text(
            'Course Requirements',
            style: AppTheme.getHeadingStyle(fontSize: 20),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildRequirements(),
        ],
      ),
    );
  }

  Widget _buildLearningOutcomes() {
    final outcomes = [
      'Master the fundamentals of ${widget.course.category.toLowerCase()}',
      'Build real-world projects and applications',
      'Understand best practices and industry standards',
      'Develop problem-solving skills',
      'Create a portfolio of work',
    ];

    return Column(
      children: outcomes
          .map(
            (outcome) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      outcome,
                      style: AppTheme.getBodyStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRequirements() {
    final requirements = [
      'Basic programming knowledge',
      'Computer with internet connection',
      'Willingness to learn and practice',
    ];

    return Column(
      children: requirements
          .map(
            (requirement) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.statusInProgress,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      requirement,
                      style: AppTheme.getBodyStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildReviewsTab() {
    return Center(
      child: Padding(
        padding: AppTheme.getScreenPadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_outline, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'No reviews yet',
              style: AppTheme.getHeadingStyle(fontSize: 20),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Be the first to review this course',
              style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: AppTheme.getScreenPadding(context),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enroll Now',
                    style: AppTheme.getBodyStyle(fontSize: 12),
                  ),
                  Text('Free', style: AppTheme.getHeadingStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isEnrolled ? _continueLearning : _enrollInCourse,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMedium,
                  ),
                ),
                child: Text(
                  _isEnrolled ? 'Continue Learning' : 'Enroll Now',
                  style: AppTheme.getButtonStyle(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return AppTheme.statusInProgress;
      case LessonType.text:
        return AppTheme.primaryGreen;
      case LessonType.quiz:
        return AppTheme.statusPending;
      case LessonType.assignment:
        return AppTheme.statusOverdue;
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_outline;
      case LessonType.text:
        return Icons.article_outlined;
      case LessonType.quiz:
        return Icons.quiz_outlined;
      case LessonType.assignment:
        return Icons.assignment_outlined;
    }
  }

  void _navigateToLesson(LessonModel lesson) {
    switch (lesson.type) {
      case LessonType.video:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(lesson: lesson),
          ),
        );
        break;
      case LessonType.quiz:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(lesson: lesson)),
        );
        break;
      case LessonType.text:
      case LessonType.assignment:
        // TODO: Implement text and assignment screens
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text and assignment lessons coming soon!'),
          ),
        );
        break;
    }
  }

  void _enrollInCourse() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );

    if (authProvider.userModel != null) {
      final success = await learningProvider.enrollInCourse(
        authProvider.userModel!.id,
        widget.course.id,
      );

      if (success) {
        setState(() {
          _isEnrolled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    }
  }

  void _continueLearning() {
    // Navigate to first incomplete lesson or last accessed lesson
    final learningProvider = Provider.of<LearningProvider>(
      context,
      listen: false,
    );
    final lessons = learningProvider.lessons;

    if (lessons.isNotEmpty) {
      // Find first incomplete lesson
      for (final lesson in lessons) {
        final progress = learningProvider.getLessonProgress(lesson.id);
        if (progress == null || !progress.isCompleted) {
          _navigateToLesson(lesson);
          return;
        }
      }

      // If all lessons completed, go to first lesson
      _navigateToLesson(lessons.first);
    }
  }

  void _shareCourse() {
    // TODO: Implement course sharing
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share feature coming soon!')));
  }

  void _toggleBookmark() {
    // TODO: Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark feature coming soon!')),
    );
  }
}
