import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:field_link/features/authentication/domain/entities/user.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_state.dart';

class _MockDashboardCubit extends Mock implements DashboardCubit {}

class _MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockDashboardCubit cubit;
  late _MockAuthBloc authBloc;
  late DashboardState state;
  late Project project;
  late AnalyticsEntity analytics;

  setUp(() {
    cubit = _MockDashboardCubit();
    authBloc = _MockAuthBloc();
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

    final user = User(id: '1', email: 'test@test.com', fullName: 'Test User');
    when(() => authBloc.state).thenReturn(AuthState.authenticated(user));
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => Stream.value(AuthState.authenticated(user)));
  });

  testWidgets('renders analytics cards, charts, and activity list', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DashboardCubit>.value(value: cubit),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: const DashboardPage(),
        ),
      ),
    );
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
