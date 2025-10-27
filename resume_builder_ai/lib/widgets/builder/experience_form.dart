import 'package:flutter/material.dart';
import '../../models/resume_model.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/responsive_layout.dart';

class ExperienceForm extends StatefulWidget {
  final WorkExperience? experience;
  final Function(WorkExperience) onSave;

  const ExperienceForm({super.key, this.experience, required this.onSave});

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentJob = false;
  List<String> _responsibilities = [];

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      _jobTitleController.text = widget.experience!.jobTitle;
      _companyController.text = widget.experience!.company;
      _locationController.text = widget.experience!.location;
      _startDate = widget.experience!.startDate;
      _endDate = widget.experience!.endDate;
      _isCurrentJob = widget.experience!.isCurrentJob;
      _responsibilities = List.from(widget.experience!.responsibilities);
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
                      widget.experience == null
                          ? 'Add Experience'
                          : 'Edit Experience',
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
                  controller: _jobTitleController,
                  label: 'Job Title *',
                  hintText: 'Senior Software Engineer',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _companyController,
                  label: 'Company *',
                  hintText: 'Tech Corp',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'San Francisco, CA',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        'Start Date',
                        _startDate,
                        (date) => setState(() => _startDate = date),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _isCurrentJob
                          ? Container(
                              height: 56,
                              alignment: Alignment.center,
                              child: const Text('Present'),
                            )
                          : _buildDateField(
                              'End Date',
                              _endDate,
                              (date) => setState(() => _endDate = date),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _isCurrentJob,
                  onChanged: (value) {
                    setState(() {
                      _isCurrentJob = value ?? false;
                      if (_isCurrentJob) _endDate = null;
                    });
                  },
                  title: const Text('I currently work here'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Text(
                  'Responsibilities',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ..._responsibilities.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(entry.value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _responsibilities.removeAt(entry.key);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _responsibilitiesController,
                  label: 'Add Responsibility',
                  hintText: 'Describe your achievement or responsibility',
                  maxLines: 3,
                  onSubmitted: (_) => _addResponsibility(),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addResponsibility,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Responsibility'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: ResponsiveLayout.getButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save Experience'),
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
          lastDate: DateTime.now(),
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

  void _addResponsibility() {
    if (_responsibilitiesController.text.isNotEmpty) {
      setState(() {
        _responsibilities.add(_responsibilitiesController.text);
        _responsibilitiesController.clear();
      });
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        WorkExperience(
          jobTitle: _jobTitleController.text,
          company: _companyController.text,
          location: _locationController.text,
          startDate: _startDate,
          endDate: _endDate,
          isCurrentJob: _isCurrentJob,
          responsibilities: _responsibilities,
        ),
      );
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _responsibilitiesController.dispose();
    super.dispose();
  }
}
