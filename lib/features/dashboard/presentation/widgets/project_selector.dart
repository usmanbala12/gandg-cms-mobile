import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard_cubit.dart';

/// Dropdown control for selecting the active project.
/// Selection changes propagate to [DashboardCubit] which persists the value
/// via [MetaDao] and refreshes the scoped dashboard data.
class ProjectSelector extends StatelessWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white24
        : Colors.black12;

    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.projects != current.projects ||
          previous.selectedProjectId != current.selectedProjectId,
      builder: (context, state) {
        final items = state.projects
            .map(
              (project) => DropdownMenuItem<String>(
                value: project.id,
                child: Text(project.name, style: theme.textTheme.titleMedium),
              ),
            )
            .toList();

        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No projects synced',
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedProjectId ?? items.first.value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              items: items,
              onChanged: (value) {
                if (value == null) return;
                context.read<DashboardCubit>().selectProject(value);
              },
            ),
          ),
        );
      },
    );
  }
}
