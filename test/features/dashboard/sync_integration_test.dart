import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/analytics_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/project_dao.dart';
import 'package:field_link/core/db/db_utils.dart';
import 'package:field_link/core/network/api_client.dart';
import 'package:field_link/core/network/network_info.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/sync/sync_manager.dart';
import 'package:field_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockSyncManager extends Mock implements SyncManager {}

class _MockTokenStorageService extends Mock implements TokenStorageService {}

class _MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AppDatabase db;
  late ProjectDao projectDao;
  late AnalyticsDao analyticsDao;
  late MetaDao metaDao;
  late _MockApiClient apiClient;
  late _MockSyncManager syncManager;
  late _MockTokenStorageService tokenStorageService;
  late _MockNetworkInfo networkInfo;
  late DashboardRepositoryImpl repository;
  const projectId = 'project-1';

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    projectDao = ProjectDao(db);
    analyticsDao = AnalyticsDao(db);
    metaDao = MetaDao(db);
    apiClient = _MockApiClient();
    syncManager = _MockSyncManager();
    tokenStorageService = _MockTokenStorageService();
    networkInfo = _MockNetworkInfo();

    // Mock the tokenStorageService to return true for isAuthenticated
    when(
      () => tokenStorageService.isAuthenticated(),
    ).thenAnswer((_) async => true);

    // Mock networkInfo to return true (online)
    when(() => networkInfo.isOnline()).thenAnswer((_) async => true);

    repository = DashboardRepositoryImpl(
      projectDao: projectDao,
      analyticsDao: analyticsDao,
      metaDao: metaDao,
      apiClient: apiClient,
      syncManager: syncManager,
      tokenStorageService: tokenStorageService,
      networkInfo: networkInfo,
    );

    final nowMs = now();
    await projectDao.upsertProject(
      ProjectsCompanion.insert(
        id: projectId,
        name: 'Integration Project',
        location: const Value(null),
        metadata: const Value(null),
        lastSynced: Value(nowMs),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('getProjectAnalytics caches and emits through watch stream', () async {
    final payload = {
      'reportsCount': 10,
      'pendingRequests': 2,
      'openIssues': 1,
      'reportsTimeseries': [
        {
          'timestamp': DateTime.utc(2024, 1, 1).millisecondsSinceEpoch,
          'count': 4,
        },
        {
          'timestamp': DateTime.utc(2024, 1, 2).millisecondsSinceEpoch,
          'count': 6,
        },
      ],
      'statusCounts': {'PENDING': 2, 'APPROVED': 8},
      'recentActivity': [
        {
          'type': 'report',
          'title': 'Report synced',
          'description': 'Daily report processed',
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      ],
    };

    when(
      () => apiClient.fetchProjectAnalytics(projectId),
    ).thenAnswer((_) async => payload);
    when(
      () => syncManager.runSyncCycle(projectId: projectId),
    ).thenAnswer((_) async {});

    final result = await repository.getProjectAnalytics(
      projectId,
      forceRefresh: true,
    );
    expect(result.data.reportsCount, 10);

    final emitted = await repository
        .watchAnalytics(projectId)
        .firstWhere((it) => it != null);
    expect(emitted?.pendingRequests, 2);

    verify(() => apiClient.fetchProjectAnalytics(projectId)).called(1);
  });

  test('cached analytics returned when within TTL', () async {
    final payload = {'reportsCount': 3, 'pendingRequests': 1, 'openIssues': 0};
    when(
      () => apiClient.fetchProjectAnalytics(projectId),
    ).thenAnswer((_) async => payload);
    when(
      () => syncManager.runSyncCycle(projectId: projectId),
    ).thenAnswer((_) async {});

    await repository.getProjectAnalytics(projectId, forceRefresh: true);

    final cached = await repository.getProjectAnalytics(projectId);
    expect(cached.data.reportsCount, 3);

    verify(() => apiClient.fetchProjectAnalytics(projectId)).called(1);
  });

  test('offline fetch falls back to stale cache', () async {
    final nowMs = now() - const Duration(days: 2).inMilliseconds;
    await analyticsDao.upsertAnalytics(
      ProjectAnalyticsCompanion.insert(
        projectId: projectId,
        reportsCount: const Value(5),
        requestsPending: const Value(2),
        openIssues: const Value(1),
        reportsTimeseries: const Value(null),
        requestsByStatus: const Value(null),
        recentActivity: const Value(null),
        lastSynced: Value(nowMs),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );

    when(() => apiClient.fetchProjectAnalytics(projectId)).thenThrow(
      DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/projects/$projectId/requests/analytics',
        ),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repository.getProjectAnalytics(
      projectId,
      forceRefresh: true,
    );
    expect(result.data.reportsCount, 5);
    expect(result.data.isStale, true);
    expect(result.isLocal, true);
  });
}
