import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDashboardCubit extends Mock implements DashboardCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockDashboardCubit cubit;
  late DashboardState state;
  late Project project;
  late AnalyticsEntity analytics;

  setUp(() {
    cubit = _MockDashboardCubit();
    final now = DateTime.now().millisecondsSinceEpoch;
    project = Project(
      id: 'project-1',
      name: 'Downtown Build',
      location: null,
      metadata: null,
      lastSynced: now,
      createdAt: now - 1000,
      updatedAt: now,
    );
    analytics = AnalyticsEntity(
      projectId: project.id,
      reportsCount: 15,
      pendingRequests: 3,
      openIssues: 1,
      reportTrend: [
        TimeSeriesPoint(DateTime.utc(2024, 1, 1), 2),
        TimeSeriesPoint(DateTime.utc(2024, 1, 2), 4),
      ],
      statusBreakdown: const [
        StatusSegment('PENDING', 3),
        StatusSegment('APPROVED', 6),
        StatusSegment('REJECTED', 2),
      ],
      recentActivity: [
        RecentActivityEntry(
          type: 'report',
          title: 'Report synced',
          description: 'QA report uploaded',
          timestamp: DateTime.utc(2024, 1, 2, 8, 30),
        ),
      ],
      lastSyncedAt: DateTime.now().toUtc(),
      isStale: false,
      isExpired: false,
    );
    state = DashboardState(
      projects: [project],
      selectedProjectId: project.id,
      analytics: analytics,
      loading: false,
      error: null,
      lastSynced: analytics.lastSyncedAt,
      offline: false,
      analyticsStale: false,
    );

    when(() => cubit.state).thenReturn(state);
    when(
      () => cubit.stream,
    ).thenAnswer((_) => Stream<DashboardState>.value(state));
    when(() => cubit.refresh()).thenAnswer((_) async {});
    when(cubit.close).thenAnswer((_) async {});
  });

  testWidgets('renders analytics cards, charts, and activity list', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: DashboardPage(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('15'), findsWidgets);
    expect(find.text('Pending Requests'), findsOneWidget);
    expect(find.text('Open Issues'), findsOneWidget);
    expect(find.text('Report synced'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('Online'), findsOneWidget);
  });
}
