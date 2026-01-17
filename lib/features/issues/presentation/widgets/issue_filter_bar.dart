import 'package:flutter/material.dart';

class IssueFilterBar extends StatelessWidget {
  final String selectedStatus;
  final String selectedPriority;
  final String selectedCategory;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onCategoryChanged;

  const IssueFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedCategory,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            context,
            label: 'Status',
            value: selectedStatus,
            options: [
              'All',
              'Open',
              'In Progress',
              'On Hold',
              'Resolved',
              'Closed',
              'Reopened',
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Priority',
            value: selectedPriority,
            options: ['All', 'Low', 'Medium', 'High', 'Urgent', 'Critical'],
            onChanged: onPriorityChanged,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Category',
            value: selectedCategory,
            options: [
              'All',
              'Maintenance',
              'Security',
              'Cleaning',
              'IT',
              'Other',
            ],
            onChanged: onCategoryChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final isSelected = value != 'All';

    return InputChip(
      label: Text(isSelected ? '$label: $value' : label),
      selected: isSelected,
      onSelected: (selected) {
        _showOptionsSheet(context, label, options, onChanged);
      },
      deleteIcon: isSelected ? const Icon(Icons.close, size: 18) : null,
      onDeleted: isSelected ? () => onChanged('All') : null,
      avatar: isSelected ? null : const Icon(Icons.filter_list, size: 18),
      showCheckmark: false,
    );
  }

  void _showOptionsSheet(
    BuildContext context,
    String title,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select $title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  onChanged(option);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
