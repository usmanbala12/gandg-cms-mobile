import 'dart:async';

import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/domain/repository_result.dart';
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
    when(repository.getActiveProjectId).thenAnswer((_) async => null);

    cubit = DashboardCubit(repository: repository);
  });

  tearDown(() async {
    await projectStream.close();
    await analyticsStream.close();
    await cubit.close();
  });

  test(
    'init emits requiresReauthentication when getProjects throws DashboardAuthorizationException',
    () async {
      // Arrange
      when(
        () => repository.getProjects(forceRemote: false),
      ).thenThrow(DashboardAuthorizationException(message: 'Auth failed'));

      // Act
      await cubit.init();

      // Assert
      expect(cubit.state.requiresReauthentication, true);
      expect(cubit.state.error, 'Auth failed');
    },
  );

  test(
    'init attempts remote fetch when cache is empty and handles auth error',
    () async {
      // Arrange: Cache returns empty list wrapped in RepositoryResult
      when(
        () => repository.getProjects(forceRemote: false),
      ).thenAnswer((_) async => RepositoryResult.local([]));

      // Arrange: Remote fetch throws Auth Exception
      when(() => repository.getProjects(forceRemote: true)).thenThrow(
        DashboardAuthorizationException(message: 'Auth failed remote'),
      );

      // Act
      await cubit.init();

      // Assert
      // Verify that forceRemote: true was called
      verify(() => repository.getProjects(forceRemote: true)).called(1);

      expect(cubit.state.requiresReauthentication, true);
      expect(cubit.state.error, 'Auth failed remote');
    },
  );

  test(
    'init attempts remote fetch when cache is empty and handles success',
    () async {
      // Arrange: Cache returns empty list wrapped in RepositoryResult
      when(
        () => repository.getProjects(forceRemote: false),
      ).thenAnswer((_) async => RepositoryResult.local([]));

      final project = Project(
        id: 'p1',
        name: 'Test Project',
        lastSynced: 0,
        createdAt: 0,
        updatedAt: 0,
      );

      // Arrange: Remote fetch returns projects wrapped in RepositoryResult
      when(
        () => repository.getProjects(forceRemote: true),
      ).thenAnswer((_) async => RepositoryResult.remote([project]));

      when(
        () => repository.getProjectAnalytics(
          any(),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => RepositoryResult.remote(AnalyticsEntity.empty('p1')),
      );

      // Act
      await cubit.init();

      // Assert
      verify(() => repository.getProjects(forceRemote: true)).called(1);
      expect(cubit.state.requiresReauthentication, false);
      expect(cubit.state.error, null);
    },
  );
}
