import 'package:flutter/material.dart';
import '../../models/resume_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/responsive_layout.dart';

class ProjectForm extends StatefulWidget {
  final Project? project;
  final Function(Project) onSave;

  const ProjectForm({super.key, this.project, required this.onSave});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _technologyController = TextEditingController();

  final List<String> _technologies = [];

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _titleController.text = widget.project!.title;
      _descriptionController.text = widget.project!.description;
      _linkController.text = widget.project!.link ?? '';
      _technologies.addAll(widget.project!.technologies);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveLayout.getPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.project == null ? 'Add Project' : 'Edit Project',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _titleController,
                  label: 'Project Title *',
                  hintText: 'E-commerce Website',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description *',
                  hintText: 'Describe what you built and achieved...',
                  maxLines: 4,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _linkController,
                  label: 'Project Link',
                  hintText: 'https://github.com/username/project',
                ),
                const SizedBox(height: 16),
                Text(
                  'Technologies',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (_technologies.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _technologies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tech = entry.value;
                      return Chip(
                        label: Text(tech),
                        onDeleted: () {
                          setState(() {
                            _technologies.removeAt(index);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _technologyController,
                        hintText: 'Add technology',
                        onSubmitted: _addTechnology,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          _addTechnology(_technologyController.text),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveLayout.getButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Project'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addTechnology(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _technologies.add(text);
        _technologyController.clear();
      });
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        Project(
          title: _titleController.text,
          description: _descriptionController.text,
          link: _linkController.text.isEmpty ? null : _linkController.text,
          technologies: _technologies,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _technologyController.dispose();
    super.dispose();
  }
}
