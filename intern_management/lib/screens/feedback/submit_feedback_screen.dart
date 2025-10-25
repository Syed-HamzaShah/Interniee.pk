import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/feedback_model.dart';
import '../../widgets/custom_button.dart';
import '../../utils/app_theme.dart';

class SubmitFeedbackScreen extends StatefulWidget {
  const SubmitFeedbackScreen({super.key});

  @override
  State<SubmitFeedbackScreen> createState() => _SubmitFeedbackScreenState();
}

class _SubmitFeedbackScreenState extends State<SubmitFeedbackScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _commentsController = TextEditingController();

  FeedbackCategory _selectedCategory = FeedbackCategory.experience;
  int _selectedRating = 5;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final feedbackProvider = Provider.of<FeedbackProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Submit Feedback'),
        backgroundColor: AppTheme.darkSurface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppTheme.getScreenPadding(context),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),

              const SizedBox(height: AppTheme.spacingXLarge),

              _buildNameField(),

              const SizedBox(height: AppTheme.spacingLarge),

              _buildCategoryDropdown(),

              const SizedBox(height: AppTheme.spacingLarge),

              _buildRatingSection(),

              const SizedBox(height: AppTheme.spacingLarge),

              _buildCommentsField(),

              const SizedBox(height: AppTheme.spacingXLarge),

              if (feedbackProvider.errorMessage != null)
                _buildErrorMessage(feedbackProvider.errorMessage!),

              CustomButton(
                text: 'Submit Feedback',
                onPressed: _isSubmitting
                    ? null
                    : () => _submitFeedback(authProvider, feedbackProvider),
                isLoading: _isSubmitting,
                isFullWidth: true,
                icon: Icons.send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreenLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.feedback,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                Text(
                  'Share Your Feedback',
                  style: AppTheme.getHeadingStyle(fontSize: 22),
                ),

                const SizedBox(height: AppTheme.spacingSmall),

                Text(
                  'Help us improve by sharing your experience',
                  style: AppTheme.getBodyStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNameField() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: TextFormField(
              controller: _nameController,
              style: AppTheme.getBodyStyle(),
              decoration: InputDecoration(
                labelText: 'Your Name (Optional)',
                hintText: 'Enter your name',
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: DropdownButtonFormField<FeedbackCategory>(
              initialValue: _selectedCategory,
              style: AppTheme.getBodyStyle(),
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(
                  Icons.category_outlined,
                  color: AppTheme.primaryGreen,
                ),
              ),
              dropdownColor: AppTheme.darkCard,
              items: FeedbackCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryDisplayName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: AppTheme.getCardPadding(context),
              decoration: AppTheme.getCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating',
                    style: AppTheme.getSubheadingStyle(fontSize: 16),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      final isSelected = rating <= _selectedRating;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = rating;
                          });
                        },
                        child: AnimatedContainer(
                          duration: AppTheme.getShortAnimationDuration(),
                          padding: const EdgeInsets.all(AppTheme.spacingSmall),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryGreen.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusSmall,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryGreen
                                  : AppTheme.darkBorder,
                            ),
                          ),
                          child: Icon(
                            Icons.star,
                            color: isSelected
                                ? AppTheme.primaryGreen
                                : AppTheme.textDisabled,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Text(
                    _getRatingText(_selectedRating),
                    style: AppTheme.getBodyStyle(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsField() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: TextFormField(
              controller: _commentsController,
              style: AppTheme.getBodyStyle(),
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Comments *',
                hintText: 'Share your detailed feedback...',
                prefixIcon: const Icon(
                  Icons.comment_outlined,
                  color: AppTheme.primaryGreen,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide your feedback comments';
                }
                if (value.trim().length < 10) {
                  return 'Please provide more detailed feedback (at least 10 characters)';
                }
                return null;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.statusOverdue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.statusOverdue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.statusOverdue, size: 20),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              message,
              style: AppTheme.getBodyStyle(color: AppTheme.statusOverdue),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.course:
        return 'Course';
      case FeedbackCategory.internship:
        return 'Internship';
      case FeedbackCategory.company:
        return 'Company';
      case FeedbackCategory.experience:
        return 'Experience';
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  Future<void> _submitFeedback(
    AuthProvider authProvider,
    FeedbackProvider feedbackProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await feedbackProvider.submitFeedback(
      userName: authProvider.userModel?.name ?? 'Anonymous',
      userEmail: authProvider.userModel?.email ?? '',
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      category: _selectedCategory,
      rating: _selectedRating,
      comments: _commentsController.text.trim(),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      _nameController.clear();
      _commentsController.clear();
      _selectedCategory = FeedbackCategory.experience;
      _selectedRating = 5;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feedback submitted successfully!'),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
