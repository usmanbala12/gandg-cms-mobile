import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logger/logger.dart';

import 'package:field_link/features/issues/data/repositories/issue_repository_impl.dart';
import 'package:field_link/features/issues/data/datasources/issue_remote_datasource.dart';
import 'package:field_link/features/issues/domain/entities/data_source.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/issue_dao.dart';
import 'package:field_link/core/db/daos/issue_comment_dao.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/network/network_info.dart';

import 'package:field_link/core/db/daos/issue_history_dao.dart';
import 'package:field_link/core/db/daos/issue_media_dao.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockIssueDao extends Mock implements IssueDao {}

class MockIssueCommentDao extends Mock implements IssueCommentDao {}

class MockIssueHistoryDao extends Mock implements IssueHistoryDao {}

class MockIssueMediaDao extends Mock implements IssueMediaDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockMetaDao extends Mock implements MetaDao {}

class MockIssueRemoteDataSource extends Mock implements IssueRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLogger extends Mock implements Logger {}

void main() {
  late IssueRepositoryImpl repository;
  late MockAppDatabase mockDb;
  late MockIssueDao mockIssueDao;
  late MockIssueCommentDao mockIssueCommentDao;
  late MockIssueHistoryDao mockIssueHistoryDao;
  late MockIssueMediaDao mockIssueMediaDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockMetaDao mockMetaDao;
  late MockIssueRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockLogger mockLogger;

  setUp(() {
    mockDb = MockAppDatabase();
    mockIssueDao = MockIssueDao();
    mockIssueCommentDao = MockIssueCommentDao();
    mockIssueHistoryDao = MockIssueHistoryDao();
    mockIssueMediaDao = MockIssueMediaDao();
    mockSyncQueueDao = MockSyncQueueDao();
    mockMetaDao = MockMetaDao();
    mockRemoteDataSource = MockIssueRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockLogger = MockLogger();

    repository = IssueRepositoryImpl(
      db: mockDb,
      issueDao: mockIssueDao,
      issueCommentDao: mockIssueCommentDao,
      issueHistoryDao: mockIssueHistoryDao,
      issueMediaDao: mockIssueMediaDao,
      syncQueueDao: mockSyncQueueDao,
      metaDao: mockMetaDao,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
      logger: mockLogger,
    );

    registerFallbackValue(IssuesCompanion());
    registerFallbackValue(SyncQueueCompanion());
    registerFallbackValue(IssueCommentsCompanion());
    registerFallbackValue(() async {});

    when(() => mockDb.transaction(any())).thenAnswer((invocation) async {
      final action = invocation.positionalArguments[0] as Future Function();
      return await action();
    });
  });

  test('getIssues fetches from remote when online', () async {
    // Arrange
    final testIssue = Issue(
      id: '1',
      serverId: '1',
      projectId: 'proj1',
      title: 'Test Issue',
      description: 'Description',
      priority: 'HIGH',
      status: 'OPEN',
      assigneeId: null,
      category: null,
      location: null,
      dueDate: null,
      meta: null,
      createdAt: 1234567890,
      updatedAt: 1234567890,
      serverUpdatedAt: null,
      deletedAt: null,
      syncStatus: 'SYNCED',
    );

    when(() => mockNetworkInfo.isOnline()).thenAnswer((_) async => true);
    when(
      () => mockMetaDao.getValue('active_project_id'),
    ).thenAnswer((_) async => 'proj1');
    when(
      () => mockMetaDao.getValue('issues_last_synced_proj1'),
    ).thenAnswer((_) async => null);
    when(() => mockMetaDao.setValue(any(), any())).thenAnswer((_) async => {});
    when(
      () => mockRemoteDataSource.fetchProjectIssues(
        'proj1',
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filters: any(named: 'filters'),
      ),
    ).thenAnswer(
      (_) async => [
        {
          'id': '1',
          'project_id': 'proj1',
          'title': 'Test Issue',
          'description': 'Description',
          'priority': 'HIGH',
          'status': 'OPEN',
          'created_at': 1234567890,
          'updated_at': 1234567890,
        },
      ],
    );
    when(
      () => mockIssueDao.getIssueByServerId(any()),
    ).thenAnswer((_) async => null);
    when(() => mockIssueDao.insertIssue(any())).thenAnswer((_) async => 1);
    when(
      () => mockIssueDao.getIssuesForProject(
        any(),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [testIssue]);

    // Act
    final result = await repository.getIssues(projectId: 'proj1');

    // Assert
    verify(() => mockNetworkInfo.isOnline()).called(1);
    verify(
      () => mockRemoteDataSource.fetchProjectIssues(
        'proj1',
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
        filters: any(named: 'filters'),
      ),
    ).called(1);
    verify(() => mockIssueDao.insertIssue(any())).called(1);
    expect(result.issues.length, 1);
    expect(result.source, DataSource.remote);
    expect(result.isFresh, true);
  });

  test('deleteIssue performs soft delete and enqueues sync item', () async {
    // Arrange
    const issueId = 'issue-123';
    const projectId = 'proj-123';

    when(() => mockIssueDao.getIssueById(issueId)).thenAnswer(
      (_) async => Issue(
        id: issueId,
        projectId: projectId,
        title: 'Test',
        description: 'Desc',
        priority: 'MEDIUM',
        status: 'OPEN',
        assigneeId: null,
        category: null,
        location: null,
        dueDate: null,
        meta: null,
        createdAt: 1000,
        updatedAt: 1000,
        serverUpdatedAt: null,
        deletedAt: null,
        syncStatus: 'SYNCED',
        serverId: 'server-123',
      ),
    );

    when(() => mockIssueDao.deleteIssue(issueId)).thenAnswer((_) async => 1);
    when(() => mockSyncQueueDao.enqueue(any())).thenAnswer((_) async => 1);

    // Act
    await repository.deleteIssue(issueId);

    // Assert
    verify(() => mockIssueDao.deleteIssue(issueId)).called(1);
    verify(
      () => mockSyncQueueDao.enqueue(
        any(
          that: isA<SyncQueueCompanion>().having(
            (c) => c.action.value,
            'action',
            'delete',
          ),
        ),
      ),
    ).called(1);
  });
}
