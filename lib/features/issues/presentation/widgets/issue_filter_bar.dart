import 'package:flutter/material.dart';

class IssueFilterBar extends StatelessWidget {
  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;

  const IssueFilterBar({
    super.key,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusChanged,
    required this.onPriorityChanged,
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
            options: ['All', 'Open', 'In Progress', 'Resolved', 'Closed'],
            onChanged: onStatusChanged,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            label: 'Priority',
            value: selectedPriority,
            options: ['All', 'Low', 'Medium', 'High', 'Critical'],
            onChanged: onPriorityChanged,
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
    final theme = Theme.of(context);
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
