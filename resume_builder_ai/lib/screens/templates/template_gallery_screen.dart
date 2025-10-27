import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/resume_provider.dart';
import '../../widgets/template/template_preview_card.dart';
import '../../models/resume_model.dart';
import '../../utils/responsive_layout.dart';

class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({super.key});

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  String _selectedTemplateId = 'modern';
  String _selectedColor = 'blue';

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'modern',
      'name': 'Modern',
      'description': 'Perfect for tech and creative roles',
      'icon': Icons.auto_awesome,
    },
    {
      'id': 'professional',
      'name': 'Professional',
      'description': 'Classic design for corporate positions',
      'icon': Icons.business_center,
    },
    {
      'id': 'minimalist',
      'name': 'Minimalist',
      'description': 'Clean and simple layout',
      'icon': Icons.minimize,
    },
    {
      'id': 'academic',
      'name': 'Academic',
      'description': 'Ideal for research and education',
      'icon': Icons.school,
    },
    {
      'id': 'technical',
      'name': 'Technical',
      'description': 'Designed for engineering roles',
      'icon': Icons.code,
    },
  ];

  final List<Map<String, dynamic>> _colors = [
    {'id': 'blue', 'color': const Color(0xFF3B82F6), 'name': 'Blue'},
    {'id': 'green', 'color': const Color(0xFF10B981), 'name': 'Green'},
    {'id': 'purple', 'color': const Color(0xFF8B5CF6), 'name': 'Purple'},
    {'id': 'red', 'color': const Color(0xFFEF4444), 'name': 'Red'},
    {'id': 'orange', 'color': const Color(0xFFF59E0B), 'name': 'Orange'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final resume = Provider.of<ResumeProvider>(
      context,
      listen: false,
    ).currentResume;
    if (resume != null) {
      setState(() {
        _selectedTemplateId = resume.settings.templateId;
        _selectedColor = resume.settings.colorScheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Templates & Styles')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Template',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Select a professional template that matches your style',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.isMobileLayout(context)
                      ? 2
                      : 3,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final template = _templates[index];
                  return TemplatePreviewCard(
                        templateId: template['id'],
                        name: template['name'],
                        description: template['description'],
                        icon: template['icon'],
                        isSelected: _selectedTemplateId == template['id'],
                        onTap: () {
                          setState(() {
                            _selectedTemplateId = template['id'];
                          });
                        },
                      )
                      .animate()
                      .fadeIn(delay: (200 + index * 100).ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Color Scheme',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                'Pick a color that represents your professional brand',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _colors.map((colorData) {
                  final isSelected = _selectedColor == colorData['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorData['id'];
                      });
                    },
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorData['color']
                              : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorData['color'].withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorData['color'],
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            colorData['name'],
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: ResponsiveLayout.getButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _applySettings,
                  child: const Text(
                    'Apply Changes',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 900.ms).scale(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _applySettings() {
    final provider = Provider.of<ResumeProvider>(context, listen: false);
    provider.updateSettings(
      ResumeSettings(
        templateId: _selectedTemplateId,
        colorScheme: _selectedColor,
        fontFamily: 'Inter',
        layout: 'single',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template and color updated successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Navigator.pop(context);
  }
}
