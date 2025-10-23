import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../providers/admin_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'custom_button.dart';

class CreateTaskDialog extends StatefulWidget {
  final AdminProvider adminProvider;
  final VoidCallback onTaskCreated;

  const CreateTaskDialog({
    super.key,
    required this.adminProvider,
    required this.onTaskCreated,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  UserModel? _selectedUser;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;
  List<UserModel> _internUsers = const [];
  bool _isLoadingUsers = true;
  String? _userLoadError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInternUsersOnce();
  }

  Future<void> _loadInternUsersOnce() async {
    try {
      setState(() {
        _isLoadingUsers = true;
        _userLoadError = null;
      });
      final users = await widget.adminProvider
          .getUsersByRole(UserRole.intern)
          .first;
      setState(() {
        _internUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _userLoadError = 'Failed to load users';
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxDialogHeight =
        (media.size.height - media.viewInsets.bottom) * 0.85;
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
            child: SizedBox(
              height: maxDialogHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
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
                            Icons.add_task,
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
                                'Create New Task',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Assign a task to a team member',
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            _buildSectionTitle(
                              'Description',
                              Icons.description,
                            ),
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

                            // User Assignment
                            _buildSectionTitle('Assign To', Icons.person),
                            const SizedBox(height: 8),
                            _buildUserSelector(),

                            const SizedBox(height: 20),

                            // Priority and Due Date stacked
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Priority',
                                  Icons.priority_high,
                                ),
                                const SizedBox(height: 8),
                                _buildPrioritySelector(),
                                const SizedBox(height: 16),
                                _buildSectionTitle(
                                  'Due Date',
                                  Icons.calendar_today,
                                ),
                                const SizedBox(height: 8),
                                _buildDateSelector(),
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

                            // Action Button
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Create Task',
                                    type: ButtonType.primary,
                                    isLoading: _isLoading,
                                    onPressed: _createTask,
                                    icon: Icons.add_task,
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

  Widget _buildUserSelector() {
    if (_isLoadingUsers) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Loading users...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_userLoadError != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.statusOverdue,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _userLoadError!,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: _loadInternUsersOnce,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_internUsers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: const Text(
          'No users available',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return DropdownButtonFormField<UserModel>(
      value: _selectedUser,
      isExpanded: true,
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
      hint: const Text(
        'Select a user',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
      items: _internUsers.map((user) {
        return DropdownMenuItem<UserModel>(
          value: user,
          child: Row(
            children: [
              CircleAvatar(
                radius: 10, // keep item height within tight constraints
                backgroundColor: AppTheme.primaryGreen,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.email.isNotEmpty
                      ? '${user.name} (${user.email})'
                      : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (user) {
        setState(() {
          _selectedUser = user;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a user';
        }
        return null;
      },
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a user to assign the task to'),
          backgroundColor: AppTheme.statusOverdue,
        ),
      );
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
        assignedToId: _selectedUser!.id,
        assignedByName: currentUser.name,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        tags: tags,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      Navigator.of(context).pop();
      widget.onTaskCreated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: $e'),
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
