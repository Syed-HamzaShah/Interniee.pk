import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'custom_button.dart';

class AssignTaskDialog extends StatefulWidget {
  final UserModel user;
  final AdminProvider adminProvider;
  final VoidCallback onTaskAssigned;

  const AssignTaskDialog({
    super.key,
    required this.user,
    required this.adminProvider,
    required this.onTaskAssigned,
  });

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxDialogHeight = media.size.height * 0.85;
    return Dialog(
      backgroundColor: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: media.size.width * 0.95,
        constraints: BoxConstraints(maxWidth: 500, maxHeight: maxDialogHeight),
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreen.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign Task',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Create task for ${widget.user.name}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Form Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Assigned User Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primaryGreen,
                                  child: Text(
                                    widget.user.name.isNotEmpty
                                        ? widget.user.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.user.name,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.user.email,
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.statusInProgress,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'INTERN',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Title Field
                          _buildSectionTitle('Task Title', Icons.title),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _titleController,
                            hintText: 'Enter task title',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Task title is required';
                              }
                              if (value.trim().length < 3) {
                                return 'Title must be at least 3 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Description Field
                          _buildSectionTitle('Description', Icons.description),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _descriptionController,
                            hintText: 'Enter task description',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Task description is required';
                              }
                              if (value.trim().length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Priority and Due Date Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle(
                                      'Priority',
                                      Icons.priority_high,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPrioritySelector(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle(
                                      'Due Date',
                                      Icons.calendar_today,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDateSelector(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Tags Field
                          _buildSectionTitle(
                            'Tags (Optional)',
                            Icons.label_outline,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _tagsController,
                            hintText: 'Enter tags separated by commas',
                            suffixIcon: Icons.info_outline,
                          ),

                          const SizedBox(height: 20),

                          // Notes Field
                          _buildSectionTitle(
                            'Notes (Optional)',
                            Icons.note_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _notesController,
                            hintText: 'Additional notes or instructions',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Cancel',
                                  type: ButtonType.outline,
                                  onPressed: () => Navigator.of(context).pop(),
                                  backgroundColor: AppTheme.darkBorder,
                                  textColor: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: CustomButton(
                                  text: 'Assign Task',
                                  type: ButtonType.primary,
                                  isLoading: _isLoading,
                                  onPressed: _assignTask,
                                  icon: Icons.assignment_turned_in,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.darkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.statusOverdue),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.statusOverdue, width: 2),
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppTheme.textSecondary, size: 20)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<TaskPriority>(
      value: _selectedPriority,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.darkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: TaskPriority.values.map((priority) {
        Color priorityColor;
        IconData priorityIcon;

        switch (priority) {
          case TaskPriority.low:
            priorityColor = AppTheme.statusCompleted;
            priorityIcon = Icons.keyboard_arrow_down;
            break;
          case TaskPriority.medium:
            priorityColor = AppTheme.statusPending;
            priorityIcon = Icons.remove;
            break;
          case TaskPriority.high:
            priorityColor = AppTheme.statusInProgress;
            priorityIcon = Icons.keyboard_arrow_up;
            break;
          case TaskPriority.urgent:
            priorityColor = AppTheme.statusOverdue;
            priorityIcon = Icons.priority_high;
            break;
        }

        return DropdownMenuItem<TaskPriority>(
          value: priority,
          child: Row(
            children: [
              Icon(priorityIcon, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Text(
                priority.name.toUpperCase(),
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (priority) {
        setState(() {
          _selectedPriority = priority!;
        });
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatDate(_selectedDueDate),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: AppTheme.darkCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _assignTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.userModel;

      if (currentUser == null) {
        throw Exception('Current user not found');
      }

      // Parse tags
      List<String> tags = [];
      if (_tagsController.text.trim().isNotEmpty) {
        tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      await widget.adminProvider.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedToId: widget.user.id,
        assignedByName: currentUser.name,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        tags: tags,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      Navigator.of(context).pop();
      widget.onTaskAssigned();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign task: $e'),
          backgroundColor: AppTheme.statusOverdue,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
