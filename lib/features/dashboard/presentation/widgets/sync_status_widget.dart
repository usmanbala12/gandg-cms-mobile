import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/dashboard_cubit.dart';

/// Displays the connectivity/sync indicator in the dashboard app bar.
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.loading != current.loading ||
          previous.offline != current.offline ||
          previous.lastSynced != current.lastSynced ||
          previous.analyticsStale != current.analyticsStale,
      builder: (context, state) {
        final status = _mapStatus(state);
        final detail = state.lastSynced != null
            ? DateFormat('MMM d, HH:mm').format(state.lastSynced!.toLocal())
            : 'No sync yet';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: foreground.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status.icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  _SyncStatus _mapStatus(DashboardState state) {
    if (state.loading == true) {
      return const _SyncStatus('Syncing', Icons.sync);
    }
    if (state.offline) {
      return const _SyncStatus('Offline', Icons.wifi_off);
    }
    if (state.analyticsStale) {
      return const _SyncStatus('Stale data', Icons.warning_amber_rounded);
    }
    return const _SyncStatus('Online', Icons.wifi);
  }
}

class _SyncStatus {
  const _SyncStatus(this.label, this.icon);
  final String label;
  final IconData icon;
}
