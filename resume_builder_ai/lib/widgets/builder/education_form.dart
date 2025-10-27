import 'package:flutter/material.dart';
import '../../models/resume_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/responsive_layout.dart';

class EducationForm extends StatefulWidget {
  final Education? education;
  final Function(Education) onSave;

  const EducationForm({super.key, this.education, required this.onSave});

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  final _formKey = GlobalKey<FormState>();
  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _locationController = TextEditingController();
  final _fieldOfStudyController = TextEditingController();
  final _gpaController = TextEditingController();

  DateTime? _graduationDate;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      _degreeController.text = widget.education!.degree;
      _institutionController.text = widget.education!.institution;
      _locationController.text = widget.education!.location;
      _fieldOfStudyController.text = widget.education!.fieldOfStudy ?? '';
      _gpaController.text = widget.education!.gpa ?? '';
      _graduationDate = widget.education!.graduationDate;
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
                      widget.education == null
                          ? 'Add Education'
                          : 'Edit Education',
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
                  controller: _degreeController,
                  label: 'Degree *',
                  hintText: 'Bachelor of Science',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _fieldOfStudyController,
                  label: 'Field of Study',
                  hintText: 'Computer Science',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _institutionController,
                  label: 'Institution *',
                  hintText: 'University Name',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'Boston, MA',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        'Graduation Date',
                        _graduationDate,
                        (date) => setState(() => _graduationDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _gpaController,
                        label: 'GPA',
                        hintText: '3.8',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveLayout.getButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Education'),
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

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2050),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? '${date.month}/${date.year}' : label,
              style: TextStyle(
                color: date != null ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        Education(
          degree: _degreeController.text,
          institution: _institutionController.text,
          location: _locationController.text,
          graduationDate: _graduationDate,
          gpa: _gpaController.text.isEmpty ? null : _gpaController.text,
          fieldOfStudy: _fieldOfStudyController.text.isEmpty
              ? null
              : _fieldOfStudyController.text,
        ),
      );
    }
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _institutionController.dispose();
    _locationController.dispose();
    _fieldOfStudyController.dispose();
    _gpaController.dispose();
    super.dispose();
  }
}
