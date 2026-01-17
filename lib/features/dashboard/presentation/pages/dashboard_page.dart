import 'dart:math' as math;

import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/presentation/widgets/metric_tile.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_event.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:field_link/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_link/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:field_link/features/more/presentation/pages/notifications_page.dart';
import '../bloc/dashboard_cubit.dart';
import '../widgets/project_selector.dart';
import '../widgets/recent_activity_tile.dart';


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
    context.read<DashboardCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

          final analytics = state.analytics ??
              (state.selectedProjectId != null
                  ? AnalyticsEntity.empty(state.selectedProjectId!)
                  : null);

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<DashboardCubit>().refresh(),
              color: DesignSystem.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  const _DashboardHeader(),
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 32),
                  if (analytics != null)
                    _ChartsSection(analytics: analytics)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 32),
                  if (analytics != null)
                    _RecentActivitySection(analytics: analytics)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state.user?.fullName.split(' ').first ?? 'User';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: DesignSystem.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '$userName!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    BlocBuilder<DashboardCubit, DashboardState>(
                      buildWhen: (previous, current) =>
                          previous.offline != current.offline,
                      builder: (context, state) {
                        return Container(
                          decoration: BoxDecoration(
                            color: DesignSystem.surfaceLight,
                            shape: BoxShape.circle,
                            boxShadow: DesignSystem.shadowSm,
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            state.offline ? Icons.wifi_off : Icons.wifi,
                            color: state.offline 
                                ? DesignSystem.error 
                                : DesignSystem.textPrimaryLight,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    BlocBuilder<NotificationsCubit, NotificationsState>(
                      builder: (context, state) {
                        final unreadCount = state is NotificationsLoaded ? state.unreadCount : 0;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                final notificationsCubit = context.read<NotificationsCubit>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: notificationsCubit,
                                      child: const NotificationsPage(),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: DesignSystem.textPrimaryLight,
                                size: 28,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: DesignSystem.surfaceLight,
                                padding: const EdgeInsets.all(8),
                                shape: const CircleBorder(),
                              ),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: DesignSystem.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const ProjectSelector(),
          ],
        );
      },
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
            Icon(Icons.lock_outline, size: 64, color: DesignSystem.error),
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: 'Reports',
                value: numberFormat.format(analytics.reportsCount),
                icon: Icons.description_outlined,
                iconColor: DesignSystem.primary,
                trend: 12.5, // Dummy positive trend for demo
                trendLabel: 'vs last week',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricTile(
                title: 'Pending',
                value: numberFormat.format(analytics.pendingRequests),
                icon: Icons.hourglass_top_outlined,
                iconColor: DesignSystem.warning,
                trend: isStale ? null : -5.0,
                trendLabel: isStale ? 'Stale data' : 'vs last week',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MetricTile(
          title: 'Open Issues',
          value: numberFormat.format(analytics.openIssues),
          icon: Icons.warning_amber_outlined,
          iconColor: DesignSystem.error,
          trend: analytics.openIssues > 0 ? 2.0 : 0.0,
          trendLabel: analytics.openIssues > 0 ? 'Needs attention' : 'All clear',
        ),
      ],
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection({required this.analytics});

  final AnalyticsEntity analytics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = DesignSystem.primary;

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
        CustomCard(
          padding: const EdgeInsets.all(16),
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
                            primaryColor,
                          ),
                        ),
                      )
                    : const _EmptyPlaceholder('No timeseries data available'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const EdgeInsets.all(16),
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
                            primaryColor,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full list
              },
              child: const Text('View All'),
            ),
          ],
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
          ..strokeWidth = 3 // Thicker lines
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
        _axisPaint = Paint()
          ..color = color.withValues(alpha: 0.1)
          ..strokeWidth = 1,
        _dotPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
          
  final Paint _dotBorderPaint = Paint()
      ..color = DesignSystem.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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
      final y = size.height - (normalizedY * size.height * 0.8) - (size.height * 0.1); 
      // Scale to keep within bounds with padding
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Curve the line
        final prevPoint = sortedPoints[i - 1];
        final prevX = maxX == minX
            ? size.width * (sortedPoints.length == 1 ? 0.5 : (i - 1) / (sortedPoints.length - 1))
            : ((prevPoint.timestamp.millisecondsSinceEpoch - minX) / (maxX - minX)) *
                  size.width;
        final prevNormalizedY = prevPoint.count / maxY;
        final prevY = size.height - (prevNormalizedY * size.height * 0.8) - (size.height * 0.1);
        
        final controlX1 = prevX + (x - prevX) / 2;
        final controlX2 = prevX + (x - prevX) / 2;
        
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }
    }

    // Draw gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.0),
      ],
    );
    
    canvas.drawPath(
      fillPath, 
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
    );

    // Draw grid lines
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      _axisPaint,
    );

    canvas.drawPath(path, _linePaint);

    // Draw dots
    for (var i = 0; i < sortedPoints.length; i++) {
      final point = sortedPoints[i];
      final x = maxX == minX
          ? size.width * (sortedPoints.length == 1 ? 0.5 : i / (sortedPoints.length - 1))
          : ((point.timestamp.millisecondsSinceEpoch - minX) / (maxX - minX)) *
                size.width;
      final normalizedY = point.count / maxY;
      final y = size.height - (normalizedY * size.height * 0.8) - (size.height * 0.1);
      
      canvas.drawCircle(Offset(x, y), 4, _dotPaint);
      canvas.drawCircle(Offset(x, y), 4, _dotBorderPaint);
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
      Offset(0, size.height),
      Offset(size.width, size.height),
      _axisPaint,
    );

    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final barHeight = (segment.count / _maxValue) * (size.height - 20);
      final left = (i * 2 + 0.5) * barWidth;
      
      // Draw rounded bar
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(4),
      );
      
      canvas.drawRRect(rrect, _barPaint);
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystem.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignSystem.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(offline ? Icons.wifi_off : Icons.error_outline, color: DesignSystem.error),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: DesignSystem.error))),
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
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: DesignSystem.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
