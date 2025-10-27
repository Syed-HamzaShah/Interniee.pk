import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/builder/section_card.dart';
import '../../widgets/builder/ai_suggestion_panel.dart';
import '../../widgets/builder/experience_form.dart';
import '../../widgets/builder/education_form.dart';
import '../../widgets/builder/project_form.dart';
import '../../widgets/builder/skill_chip.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/responsive_layout.dart';
import '../../services/ai_service.dart';
import '../../models/resume_model.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _aiService = AIService();
  final _personalInfoKey = GlobalKey();
  final _summaryKey = GlobalKey();
  final _experienceKey = GlobalKey();
  final _educationKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _projectsKey = GlobalKey();

  bool _showAISuggestions = false;
  List<String> _aiSuggestions = [];
  bool _isLoadingAI = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _headlineController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadResumeData();
  }

  void _loadResumeData() {
    final resumeProvider = Provider.of<ResumeProvider>(context, listen: false);
    final resume = resumeProvider.currentResume;

    if (resume != null) {
      _fullNameController.text = resume.personalInfo.fullName;
      _emailController.text = resume.personalInfo.email;
      _phoneController.text = resume.personalInfo.phone;
      _locationController.text = resume.personalInfo.location;
      _headlineController.text = resume.personalInfo.headline;
      _linkedInController.text = resume.personalInfo.linkedIn ?? '';
      _githubController.text = resume.personalInfo.github ?? '';
      _portfolioController.text = resume.personalInfo.portfolio ?? '';
      _summaryController.text = resume.professionalSummary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumeProvider = Provider.of<ResumeProvider>(context);
    final resume = resumeProvider.currentResume;

    if (resume == null) {
      return const Scaffold(body: Center(child: Text('No resume selected')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(resume.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/templates');
            },
            tooltip: 'Templates',
          ),
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/preview');
            },
            tooltip: 'Preview',
          ),
          IconButton(
            icon: Icon(_showAISuggestions ? Icons.close : Icons.auto_awesome),
            onPressed: () {
              setState(() {
                _showAISuggestions = !_showAISuggestions;
              });
            },
            tooltip: 'AI Suggestions',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: _showAISuggestions
                ? AISuggestionPanel(
                    suggestions: _aiSuggestions,
                    isLoading: _isLoadingAI,
                    onClose: () {
                      setState(() {
                        _showAISuggestions = false;
                      });
                    },
                    onApplySuggestion: (suggestion) {
                      _summaryController.text = suggestion;
                      _savePersonalInfo();
                    },
                  ).animate().fadeIn()
                : SingleChildScrollView(
                    padding: ResponsiveLayout.getPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressIndicator(),
                        const SizedBox(height: 24),
                        _buildPersonalInfoSection(resume),
                        const SizedBox(height: 20),
                        _buildProfessionalSummarySection(resume),
                        const SizedBox(height: 20),
                        _buildExperienceSection(resume),
                        const SizedBox(height: 20),
                        _buildEducationSection(resume),
                        const SizedBox(height: 20),
                        _buildSkillsSection(resume),
                        const SizedBox(height: 20),
                        _buildProjectsSection(resume),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ).animate().fadeIn(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resume Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${_calculateProgress()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF6366F1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _calculateProgress() / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  double _calculateProgress() {
    final resume = Provider.of<ResumeProvider>(context).currentResume;
    if (resume == null) {
      return 0;
    }

    int completed = 0;
    const total = 6;

    if (resume.personalInfo.fullName.isNotEmpty &&
        resume.personalInfo.email.isNotEmpty) {
      completed++;
    }
    if (resume.professionalSummary.isNotEmpty) {
      completed++;
    }
    if (resume.experience.isNotEmpty) {
      completed++;
    }
    if (resume.education.isNotEmpty) {
      completed++;
    }
    if (resume.skills.isNotEmpty) {
      completed++;
    }
    if (resume.projects.isNotEmpty) {
      completed++;
    }

    return (completed / total * 100).roundToDouble();
  }

  Widget _buildPersonalInfoSection(ResumeModel resume) {
    return SectionCard(
      key: _personalInfoKey,
      title: 'Personal Information',
      icon: Icons.person_outline,
      iconColor: const Color(0xFF6366F1),
      isCompleted:
          resume.personalInfo.fullName.isNotEmpty &&
          resume.personalInfo.email.isNotEmpty,
      child: Column(
        children: [
          CustomTextField(
            controller: _fullNameController,
            label: 'Full Name *',
            hintText: 'John Doe',
            prefixIcon: Icons.person_outline,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            label: 'Email *',
            hintText: 'john.doe@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _phoneController,
            label: 'Phone',
            hintText: '+1 (555) 123-4567',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _locationController,
            label: 'Location',
            hintText: 'New York, NY',
            prefixIcon: Icons.location_on_outlined,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _headlineController,
            label: 'Professional Headline',
            hintText: 'Software Engineer | Full Stack Developer',
            prefixIcon: Icons.work_outline,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _linkedInController,
            label: 'LinkedIn',
            hintText: 'linkedin.com/in/johndoe',
            prefixIcon: Icons.link,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _githubController,
            label: 'GitHub',
            hintText: 'github.com/johndoe',
            prefixIcon: Icons.code,
            onChanged: (_) => _savePersonalInfo(),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _portfolioController,
            label: 'Portfolio',
            hintText: 'johndoe.com',
            prefixIcon: Icons.language,
            onChanged: (_) => _savePersonalInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSummarySection(ResumeModel resume) {
    return SectionCard(
      key: _summaryKey,
      title: 'Professional Summary',
      icon: Icons.description_outlined,
      iconColor: const Color(0xFF8B5CF6),
      isCompleted: resume.professionalSummary.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.auto_awesome),
        onPressed: _generateSummary,
        tooltip: 'Generate with AI',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _summaryController,
            label: 'Summary',
            hintText:
                'Write a compelling summary about your professional experience...',
            maxLines: 5,
            onChanged: (value) {
              final provider = Provider.of<ResumeProvider>(
                context,
                listen: false,
              );
              provider.updateProfessionalSummary(value);
            },
          ),
          const SizedBox(height: 12),
          Text(
            '${_summaryController.text.split(' ').length} words',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(ResumeModel resume) {
    return SectionCard(
      key: _experienceKey,
      title: 'Work Experience',
      icon: Icons.work_outline,
      iconColor: const Color(0xFF06B6D4),
      isCompleted: resume.experience.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _showExperienceForm(),
        tooltip: 'Add Experience',
      ),
      child: Column(
        children: [
          if (resume.experience.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No work experience added yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resume.experience.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              return _buildExperienceCard(exp, index);
            }),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(WorkExperience exp, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exp.jobTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exp.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showExperienceForm(index: index, experience: exp),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeExperience(index),
                  ),
                ],
              ),
            ],
          ),
          if (exp.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...exp.responsibilities.map(
              (resp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(resp)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationSection(ResumeModel resume) {
    return SectionCard(
      key: _educationKey,
      title: 'Education',
      icon: Icons.school_outlined,
      iconColor: const Color(0xFF10B981),
      isCompleted: resume.education.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _showEducationForm(),
        tooltip: 'Add Education',
      ),
      child: Column(
        children: [
          if (resume.education.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No education added yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resume.education.asMap().entries.map((entry) {
              final index = entry.key;
              final edu = entry.value;
              return _buildEducationCard(edu, index);
            }),
        ],
      ),
    );
  }

  Widget _buildEducationCard(Education edu, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.degree,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  edu.institution,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
                if (edu.fieldOfStudy != null &&
                    edu.fieldOfStudy!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    edu.fieldOfStudy!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () =>
                    _showEducationForm(index: index, education: edu),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () => _removeEducation(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(ResumeModel resume) {
    return SectionCard(
      key: _skillsKey,
      title: 'Skills',
      icon: Icons.stars_outlined,
      iconColor: const Color(0xFFF59E0B),
      isCompleted: resume.skills.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.auto_awesome),
        onPressed: _suggestSkills,
        tooltip: 'Suggest Skills',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _skillController,
                  hintText: 'Add a skill',
                  prefixIcon: Icons.add,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _addSkill(value);
                      _skillController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_skillController.text.isNotEmpty) {
                    _addSkill(_skillController.text);
                    _skillController.clear();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          if (resume.skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resume.skills.map((skill) {
                return SkillChip(
                  skill: skill,
                  onRemove: () => _removeSkill(skill),
                );
              }).toList(),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No skills added yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsSection(ResumeModel resume) {
    return SectionCard(
      key: _projectsKey,
      title: 'Projects',
      icon: Icons.folder_outlined,
      iconColor: const Color(0xFFEC4899),
      isCompleted: resume.projects.isNotEmpty,
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => _showProjectForm(),
        tooltip: 'Add Project',
      ),
      child: Column(
        children: [
          if (resume.projects.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No projects added yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...resume.projects.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return _buildProjectCard(project, index);
            }),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () =>
                        _showProjectForm(index: index, project: project),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red,
                    ),
                    onPressed: () => _removeProject(index),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    tech,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/preview');
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Preview'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/templates');
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePersonalInfo() {
    final resumeProvider = Provider.of<ResumeProvider>(context, listen: false);
    resumeProvider.updatePersonalInfo(
      PersonalInfo(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        headline: _headlineController.text,
        linkedIn: _linkedInController.text.isEmpty
            ? null
            : _linkedInController.text,
        github: _githubController.text.isEmpty ? null : _githubController.text,
        portfolio: _portfolioController.text.isEmpty
            ? null
            : _portfolioController.text,
      ),
    );
  }

  Future<void> _generateSummary() async {
    setState(() {
      _isLoadingAI = true;
      _showAISuggestions = true;
    });

    final resume = Provider.of<ResumeProvider>(
      context,
      listen: false,
    ).currentResume;
    final role = resume?.personalInfo.headline ?? 'Professional';
    final skills = resume?.skills ?? [];

    try {
      final suggestion = await _aiService.generateProfessionalSummary(
        role: role,
        experienceLevel: 'experienced',
        skills: skills.isEmpty
            ? ['Communication', 'Problem Solving']
            : skills.take(5).toList(),
      );

      setState(() {
        _aiSuggestions = [suggestion];
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() {
        _aiSuggestions = ['Failed to generate suggestion. Please try again.'];
        _isLoadingAI = false;
      });
    }
  }

  Future<void> _suggestSkills() async {
    setState(() {
      _isLoadingAI = true;
      _showAISuggestions = true;
    });

    final resume = Provider.of<ResumeProvider>(
      context,
      listen: false,
    ).currentResume;
    final jobTitle = resume?.personalInfo.headline ?? 'Professional';

    try {
      final suggestions = await _aiService.suggestSkills(jobTitle);

      setState(() {
        _aiSuggestions = suggestions;
        _isLoadingAI = false;
      });
    } catch (e) {
      setState(() {
        _aiSuggestions = ['Failed to generate suggestions. Please try again.'];
        _isLoadingAI = false;
      });
    }
  }

  void _showExperienceForm({int? index, WorkExperience? experience}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExperienceForm(
        experience: experience,
        onSave: (exp) {
          final provider = Provider.of<ResumeProvider>(context, listen: false);
          if (index != null) {
            provider.updateExperience(index, exp);
          } else {
            provider.addExperience(exp);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEducationForm({int? index, Education? education}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EducationForm(
        education: education,
        onSave: (edu) {
          final provider = Provider.of<ResumeProvider>(context, listen: false);
          if (index != null) {
            provider.updateEducation(index, edu);
          } else {
            provider.addEducation(edu);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showProjectForm({int? index, Project? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectForm(
        project: project,
        onSave: (proj) {
          final provider = Provider.of<ResumeProvider>(context, listen: false);
          if (index != null) {
            provider.updateProject(index, proj);
          } else {
            provider.addProject(proj);
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _addSkill(String skill) {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.addSkill(skill);
  }

  void _removeSkill(String skill) {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.removeSkill(skill);
  }

  void _removeExperience(int index) {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.removeExperience(index);
  }

  void _removeEducation(int index) {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.removeEducation(index);
  }

  void _removeProject(int index) {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.removeProject(index);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _headlineController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    super.dispose();
  }
}
