import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/resume_provider.dart';
import '../../services/pdf_service.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../utils/responsive_layout.dart';
import 'package:intl/intl.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  final _pdfService = PDFService();
  bool _isGeneratingPDF = false;

  @override
  Widget build(BuildContext context) {
    final resumeProvider = Provider.of<ResumeProvider>(context);
    final resume = resumeProvider.currentResume;

    if (resume == null) {
      return const Scaffold(body: Center(child: Text('No resume to preview')));
    }

    final primaryColor = _getColorFromScheme(resume.settings.colorScheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _exportPDF,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: ResponsiveLayout.getPadding(context),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(resume, primaryColor),
                      const SizedBox(height: 24),
                      const Divider(thickness: 2),
                      const SizedBox(height: 24),
                      if (resume.professionalSummary.isNotEmpty) ...[
                        _buildSection(
                          'Professional Summary',
                          primaryColor,
                          child: Text(
                            resume.professionalSummary,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (resume.experience.isNotEmpty) ...[
                        _buildSection(
                          'Experience',
                          primaryColor,
                          child: Column(
                            children: resume.experience
                                .map((exp) => _buildExperienceItem(exp))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (resume.education.isNotEmpty) ...[
                        _buildSection(
                          'Education',
                          primaryColor,
                          child: Column(
                            children: resume.education
                                .map((edu) => _buildEducationItem(edu))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (resume.skills.isNotEmpty) ...[
                        _buildSection(
                          'Skills',
                          primaryColor,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: resume.skills
                                .map(
                                  (skill) =>
                                      _buildSkillChip(skill, primaryColor),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (resume.projects.isNotEmpty) ...[
                        _buildSection(
                          'Projects',
                          primaryColor,
                          child: Column(
                            children: resume.projects
                                .map((proj) => _buildProjectItem(proj))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (resume.certifications.isNotEmpty) ...[
                        _buildSection(
                          'Certifications',
                          primaryColor,
                          child: Column(
                            children: resume.certifications
                                .map((cert) => _buildCertificationItem(cert))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                ),
              ),
            ),
          ),
          if (_isGeneratingPDF)
            LoadingOverlay(
              isLoading: _isGeneratingPDF,
              message: 'Generating PDF...',
              child: Container(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeader(resume, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resume.personalInfo.fullName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: -0.5,
          ),
        ),
        if (resume.personalInfo.headline.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            resume.personalInfo.headline,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            if (resume.personalInfo.email.isNotEmpty)
              _buildContactItem(
                Icons.email_outlined,
                resume.personalInfo.email,
              ),
            if (resume.personalInfo.phone.isNotEmpty)
              _buildContactItem(
                Icons.phone_outlined,
                resume.personalInfo.phone,
              ),
            if (resume.personalInfo.location.isNotEmpty)
              _buildContactItem(
                Icons.location_on_outlined,
                resume.personalInfo.location,
              ),
            if (resume.personalInfo.linkedIn != null)
              _buildContactItem(Icons.link, resume.personalInfo.linkedIn!),
            if (resume.personalInfo.github != null)
              _buildContactItem(Icons.code, resume.personalInfo.github!),
            if (resume.personalInfo.portfolio != null)
              _buildContactItem(Icons.language, resume.personalInfo.portfolio!),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildSection(
    String title,
    Color primaryColor, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildExperienceItem(experience) {
    final dateFormat = DateFormat('MMM yyyy');
    final startDate = experience.startDate != null
        ? dateFormat.format(experience.startDate)
        : '';
    final endDate = experience.isCurrentJob
        ? 'Present'
        : (experience.endDate != null
              ? dateFormat.format(experience.endDate)
              : '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience.jobTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${experience.company}${experience.location.isNotEmpty ? " • ${experience.location}" : ""}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (startDate.isNotEmpty || endDate.isNotEmpty)
                Text(
                  '$startDate - $endDate',
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
            ],
          ),
          if (experience.responsibilities.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...experience.responsibilities.map(
              (resp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        resp,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationItem(education) {
    final dateFormat = DateFormat('MMM yyyy');
    final gradDate = education.graduationDate != null
        ? dateFormat.format(education.graduationDate)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education.degree,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${education.institution}${education.location.isNotEmpty ? " • ${education.location}" : ""}',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                if (education.fieldOfStudy != null &&
                    education.fieldOfStudy!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    education.fieldOfStudy!,
                    style: const TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (gradDate.isNotEmpty)
                Text(
                  gradDate,
                  style: const TextStyle(fontSize: 13, color: Colors.black45),
                ),
              if (education.gpa != null && education.gpa!.isNotEmpty)
                Text(
                  'GPA: ${education.gpa}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(project) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            project.description,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          if (project.technologies.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Technologies: ${project.technologies.join(", ")}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificationItem(cert) {
    final dateFormat = DateFormat('MMM yyyy');
    final date = cert.dateObtained != null
        ? dateFormat.format(cert.dateObtained)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cert.issuer,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          if (date.isNotEmpty)
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Text(
        skill,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
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
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Resume'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _exportPDF,
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

  Future<void> _exportPDF() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final resume = Provider.of<ResumeProvider>(
        context,
        listen: false,
      ).currentResume;
      if (resume == null) return;

      final pdfFile = await _pdfService.generateResumePDF(resume);

      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF Generated'),
            content: const Text(
              'Your resume PDF has been generated successfully!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await _pdfService.sharePDF(pdfFile);
                  if (mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  Color _getColorFromScheme(String scheme) {
    switch (scheme) {
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'green':
        return const Color(0xFF10B981);
      case 'purple':
        return const Color(0xFF8B5CF6);
      case 'red':
        return const Color(0xFFEF4444);
      case 'orange':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF3B82F6);
    }
  }
}
