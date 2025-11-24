import 'dart:async';

import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late _MockDashboardRepository repository;
  late DashboardCubit cubit;
  late StreamController<List<Project>> projectStream;
  late StreamController<AnalyticsEntity?> analyticsStream;
  late Project sampleProject;
  late AnalyticsEntity analytics;

  setUp(() {
    repository = _MockDashboardRepository();
    projectStream = StreamController<List<Project>>.broadcast();
    analyticsStream = StreamController<AnalyticsEntity?>.broadcast();

    when(repository.watchProjects).thenAnswer((_) => projectStream.stream);
    when(
      () => repository.watchAnalytics(any()),
    ).thenAnswer((_) => analyticsStream.stream);
    when(() => repository.setActiveProjectId(any())).thenAnswer((_) async {});
    when(() => repository.runSync(any())).thenAnswer((_) async {});

    final now = DateTime.now().millisecondsSinceEpoch;
    sampleProject = Project(
      id: 'project-1',
      name: 'Sample Project',
      location: null,
      metadata: null,
      lastSynced: now,
      createdAt: now,
      updatedAt: now,
    );

    analytics = AnalyticsEntity(
      projectId: sampleProject.id,
      reportsCount: 12,
      pendingRequests: 4,
      openIssues: 2,
      reportTrend: [
        TimeSeriesPoint(DateTime.utc(2024, 1, 1), 2),
        TimeSeriesPoint(DateTime.utc(2024, 1, 2), 4),
      ],
      statusBreakdown: const [
        StatusSegment('PENDING', 4),
        StatusSegment('APPROVED', 8),
      ],
      recentActivity: [
        RecentActivityEntry(
          type: 'report',
          title: 'Report submitted',
          description: 'Daily report uploaded',
          timestamp: DateTime.utc(2024, 1, 2, 9),
        ),
      ],
      lastSyncedAt: DateTime.now().toUtc(),
      isStale: false,
      isExpired: false,
    );

    when(
      () => repository.getProjects(forceRemote: any(named: 'forceRemote')),
    ).thenAnswer((_) async => [sampleProject]);
    when(
      repository.getActiveProjectId,
    ).thenAnswer((_) async => sampleProject.id);
    when(
      () => repository.getProjectAnalytics(
        any(),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => analytics);

    cubit = DashboardCubit(repository: repository);
  });

  tearDown(() async {
    await projectStream.close();
    await analyticsStream.close();
    await cubit.close();
  });

  test('init loads projects and analytics', () async {
    await cubit.init();
    projectStream.add([sampleProject]);
    analyticsStream.add(analytics);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.projects, [sampleProject]);
    expect(cubit.state.selectedProjectId, sampleProject.id);
    expect(cubit.state.analytics, analytics);
    expect(cubit.state.loading, false);
  });

  test('selectProject switches context and fetches analytics', () async {
    await cubit.init();

    final anotherProject = sampleProject.copyWith(
      id: 'project-2',
      name: 'Project Two',
    );
    when(
      () => repository.getProjects(forceRemote: any(named: 'forceRemote')),
    ).thenAnswer((_) async => [sampleProject, anotherProject]);
    when(
      repository.getActiveProjectId,
    ).thenAnswer((_) async => anotherProject.id);
    final otherAnalytics = AnalyticsEntity(
      projectId: anotherProject.id,
      reportsCount: analytics.reportsCount,
      pendingRequests: analytics.pendingRequests,
      openIssues: analytics.openIssues,
      reportTrend: analytics.reportTrend,
      statusBreakdown: analytics.statusBreakdown,
      recentActivity: analytics.recentActivity,
      lastSyncedAt: analytics.lastSyncedAt,
      isStale: analytics.isStale,
      isExpired: analytics.isExpired,
    );
    when(
      () => repository.getProjectAnalytics(
        anotherProject.id,
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => otherAnalytics);
    projectStream.add([sampleProject, anotherProject]);

    await cubit.selectProject(anotherProject.id);

    verify(() => repository.setActiveProjectId(anotherProject.id)).called(1);
    expect(cubit.state.selectedProjectId, anotherProject.id);
  });

  test('refresh triggers sync and force refresh', () async {
    await cubit.init();

    await cubit.refresh();

    verify(() => repository.runSync(sampleProject.id)).called(1);
    verify(
      () =>
          repository.getProjectAnalytics(sampleProject.id, forceRefresh: true),
    ).called(1);
  });
}
