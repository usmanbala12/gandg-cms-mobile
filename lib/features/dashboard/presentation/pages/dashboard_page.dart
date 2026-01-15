import 'dart:math' as math;

import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/dashboard_cubit.dart';
import '../widgets/analytics_card.dart';
import '../widgets/project_selector.dart';
import '../widgets/recent_activity_tile.dart';
import '../widgets/sync_status_widget.dart';

import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_event.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
    // Trigger initialization when dashboard becomes visible
    // The guard in init() prevents double initialization
    context.read<DashboardCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: const ProjectSelector(),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SyncStatusWidget(),
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        buildWhen: (previous, current) =>
            previous.analytics != current.analytics ||
            previous.loading != current.loading ||
            previous.error != current.error ||
            previous.offline != current.offline ||
            previous.requiresReauthentication != current.requiresReauthentication,
        builder: (context, state) {
          if (state.requiresReauthentication) {
            return const _LoginPrompt();
          }

          final analytics =
              state.analytics ??
              (state.selectedProjectId != null
                  ? AnalyticsEntity.empty(state.selectedProjectId!)
                  : null);

          return RefreshIndicator(
            onRefresh: () => context.read<DashboardCubit>().refresh(),
            color: Theme.of(context).primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (state.loading) const LinearProgressIndicator(minHeight: 2),
                if (state.error != null) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(message: state.error!, offline: state.offline),
                ],
                const SizedBox(height: 16),
                if (analytics != null)
                  _AnalyticsGrid(analytics: analytics)
                else
                  const _EmptyPlaceholder('Select a project to view analytics'),
                const SizedBox(height: 24),
                if (analytics != null)
                  _ChartsSection(analytics: analytics)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 24),
                if (analytics != null)
                  _RecentActivitySection(analytics: analytics)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Authentication Required',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session has expired or you are not logged in. Please sign in to view your dashboard.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsGrid extends StatelessWidget {
  const _AnalyticsGrid({required this.analytics});

  final AnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern();
    final isStale = analytics.isStale || analytics.isExpired;
    final metricCards = [
      AnalyticsCard(
        title: 'Reports',
        value: numberFormat.format(analytics.reportsCount),
        icon: Icons.description_outlined,
        subtitle: analytics.lastSyncedAt != null
            ? 'Updated ${DateFormat('MMM d').format(analytics.lastSyncedAt!.toLocal())}'
            : 'No sync yet',
      ),
      AnalyticsCard(
        title: 'Pending Requests',
        value: numberFormat.format(analytics.pendingRequests),
        icon: Icons.hourglass_top_outlined,
        subtitle: isStale ? 'Stale data' : 'Current',
      ),
      AnalyticsCard(
        title: 'Open Issues',
        value: numberFormat.format(analytics.openIssues),
        icon: Icons.warning_amber_outlined,
        subtitle: analytics.openIssues > 0 ? 'Needs attention' : 'All clear',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth > 900) {
          return Row(
            children: [
              for (var i = 0; i < metricCards.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == metricCards.length - 1 ? 0 : 16,
                    ),
                    child: metricCards[i],
                  ),
                ),
            ],
          );
        }

        if (maxWidth > 600) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: metricCards[0],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: metricCards[1],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              metricCards[2],
            ],
          );
        }

        return Column(
          children: metricCards
              .map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.analytics});

  final AnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Insights',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reports trend', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: analytics.reportTrend.isNotEmpty
                    ? RepaintBoundary(
                        child: CustomPaint(
                          painter: _LineChartPainter(
                            analytics.reportTrend,
                            color,
                          ),
                        ),
                      )
                    : const _EmptyPlaceholder('No timeseries data available'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request status distribution',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: analytics.statusBreakdown.isNotEmpty
                    ? RepaintBoundary(
                        child: CustomPaint(
                          painter: _BarChartPainter(
                            analytics.statusBreakdown,
                            color,
                          ),
                        ),
                      )
                    : const _EmptyPlaceholder('No status data available'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({required this.analytics});

  final AnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (analytics.recentActivity.isEmpty)
          const _EmptyPlaceholder('No activity captured in the last sync')
        else
          Column(
            children: [
              for (var i = 0; i < analytics.recentActivity.length; i++) ...[
                RecentActivityTile(activity: analytics.recentActivity[i]),
                if (i != analytics.recentActivity.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(List<TimeSeriesPoint> points, this.color)
      : sortedPoints = List<TimeSeriesPoint>.from(points)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
        _linePaint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true,
        _axisPaint = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 1,
        _dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  final List<TimeSeriesPoint> sortedPoints;
  final Color color;
  final Paint _linePaint;
  final Paint _axisPaint;
  final Paint _dotPaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (sortedPoints.isEmpty) return;

    final minX = sortedPoints.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxX = sortedPoints.last.timestamp.millisecondsSinceEpoch.toDouble();
    final maxY = sortedPoints
        .map((p) => p.count)
        .reduce(math.max)
        .toDouble()
        .clamp(1, double.infinity);

    final path = Path();
    for (var i = 0; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      final x = maxX == minX
          ? size.width * (sortedPoints.length == 1 ? 0.5 : i / (sortedPoints.length - 1))
          : ((point.timestamp.millisecondsSinceEpoch - minX) / (maxX - minX)) *
                size.width;
      final normalizedY = point.count / maxY;
      final y = size.height - (normalizedY * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      _axisPaint,
    );
    canvas.drawPath(path, _linePaint);

    for (var i = 0; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      final x = maxX == minX
          ? size.width * (sortedPoints.length == 1 ? 0.5 : i / (sortedPoints.length - 1))
          : ((point.timestamp.millisecondsSinceEpoch - minX) / (maxX - minX)) *
                size.width;
      final normalizedY = point.count / maxY;
      final y = size.height - (normalizedY * size.height);
      canvas.drawCircle(Offset(x, y), 3, _dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.sortedPoints != sortedPoints || oldDelegate.color != color;
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter(this.segments, this.color)
      : _barPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        _axisPaint = Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 1,
        _maxValue = segments.isEmpty
            ? 1.0
            : segments
                .map((s) => s.count)
                .reduce(math.max)
                .toDouble()
                .clamp(1, double.infinity);

  final List<StatusSegment> segments;
  final Color color;
  final Paint _barPaint;
  final Paint _axisPaint;
  final double _maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final barWidth = size.width / (segments.length * 2);

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      _axisPaint,
    );

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final barHeight = (segment.count / _maxValue) * (size.height - 16);
      final left = (i * 2 + 0.5) * barWidth;
      final rect = Rect.fromLTWH(
        left,
        size.height - barHeight,
        barWidth,
        barHeight,
      );
      canvas.drawRect(rect, _barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.color != color;
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.offline});

  final String message;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(offline ? Icons.wifi_off : Icons.error_outline, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.4)
        : Colors.black.withOpacity(0.4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
