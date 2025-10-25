import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/intern_model.dart';
import '../providers/intern_provider.dart';
import '../utils/app_theme.dart';

class InternSelectionWidget extends StatefulWidget {
  final String? selectedInternId;
  final Function(String?) onInternSelected;
  final String? Function(String?)? validator;

  const InternSelectionWidget({
    super.key,
    this.selectedInternId,
    required this.onInternSelected,
    this.validator,
  });

  @override
  State<InternSelectionWidget> createState() => _InternSelectionWidgetState();
}

class _InternSelectionWidgetState extends State<InternSelectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InternProvider>(context, listen: false).loadInterns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign to Intern',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Consumer<InternProvider>(
          builder: (context, internProvider, child) {
            if (internProvider.isLoading) {
              return _buildLoadingWidget();
            }

            if (internProvider.errorMessage != null) {
              return _buildErrorWidget(internProvider.errorMessage!);
            }

            if (internProvider.interns.isEmpty) {
              return _buildEmptyWidget();
            }

            return _buildInternDropdown(internProvider.interns);
          },
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading interns...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusOverdue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.statusOverdue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.statusOverdue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.statusOverdue),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<InternProvider>(context, listen: false).loadInterns();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: AppTheme.textDisabled, size: 20),
          const SizedBox(width: 12),
          Text(
            'No interns available',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _buildInternDropdown(List<InternModel> interns) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          initialValue: widget.selectedInternId,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          hint: Text(
            'Select an intern',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.person_off,
                    color: AppTheme.textDisabled,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'No assignment',
                    style: TextStyle(
                      color: AppTheme.textDisabled,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...interns.map((intern) {
              return DropdownMenuItem<String>(
                value: intern.id,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppTheme.primaryGreen.withOpacity(0.2),
                      child: Text(
                        intern.name.isNotEmpty
                            ? intern.name[0].toUpperCase()
                            : 'I',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            intern.email,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            widget.onInternSelected(value);
          },
          validator: widget.validator,
        ),
      ),
    );
  }
}
