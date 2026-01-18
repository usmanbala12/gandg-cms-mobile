import 'package:field_link/core/utils/theme/design_system.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.backgroundDark : DesignSystem.backgroundLight,
        // Optional: add a very subtle bottom border
        border: Border(
          bottom: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: 'Status',
              currentValue: selectedStatus,
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
              icon: Icons.adjust_rounded,
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              context,
              label: 'Priority',
              currentValue: selectedPriority,
              options: ['All', 'Low', 'Medium', 'High', 'Urgent', 'Critical'],
              onChanged: onPriorityChanged,
              icon: Icons.flag_rounded,
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              context,
              label: 'Category',
              currentValue: selectedCategory,
              options: [
                'All',
                'Maintenance',
                'Security',
                'Cleaning',
                'IT',
                'Other',
              ],
              onChanged: onCategoryChanged,
              icon: Icons.category_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = currentValue != 'All';

    return GestureDetector(
      onTap: () => _showOptionsSheet(context, label, currentValue, options, onChanged),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primary.withValues(alpha: 0.1)
              : (isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? DesignSystem.primary.withValues(alpha: 0.3)
                : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected ? null : DesignSystem.shadowSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? DesignSystem.primary : (isDark ? DesignSystem.textSecondaryDark : DesignSystem.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Text(
              isSelected ? currentValue : label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? DesignSystem.primary : (isDark ? DesignSystem.textPrimaryDark : DesignSystem.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? DesignSystem.primary : (isDark ? DesignSystem.textSecondaryDark : DesignSystem.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Grabber
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter by $title',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isOptionSelected = option == currentValue;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isOptionSelected ? DesignSystem.primary : null,
                          fontWeight: isOptionSelected ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: isOptionSelected
                          ? const Icon(Icons.check_circle_rounded, color: DesignSystem.primary)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        onChanged(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
