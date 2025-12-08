import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:logger/logger.dart';

import 'package:field_link/features/requests/data/repositories/request_repository_impl.dart';
import 'package:field_link/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:field_link/features/requests/data/models/request_model.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/request_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/network/network_info.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockRequestDao extends Mock implements RequestDao {}

class MockMetaDao extends Mock implements MetaDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockRequestRemoteDataSource extends Mock
    implements RequestRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLogger extends Mock implements Logger {}

void main() {
  late RequestRepositoryImpl repository;
  late MockAppDatabase mockDb;
  late MockRequestDao mockRequestDao;
  late MockMetaDao mockMetaDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockRequestRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockLogger mockLogger;

  setUp(() {
    mockDb = MockAppDatabase();
    mockRequestDao = MockRequestDao();
    mockMetaDao = MockMetaDao();
    mockSyncQueueDao = MockSyncQueueDao();
    mockRemoteDataSource = MockRequestRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockLogger = MockLogger();

    when(() => mockNetworkInfo.isOnline()).thenAnswer((_) async => true);

    repository = RequestRepositoryImpl(
      db: mockDb,
      requestDao: mockRequestDao,
      metaDao: mockMetaDao,
      syncQueueDao: mockSyncQueueDao,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
      logger: mockLogger,
    );

    registerFallbackValue(RequestsCompanion());
    registerFallbackValue(SyncQueueCompanion());
  });

  group('createRequest', () {
    final tRequestModel = RequestModel(
      id: '1',
      projectId: 'proj1',
      requestNumber: 'REQ-001',
      type: 'FUNDS',
      description: 'Test Request',
      amount: 100.0,
      currency: 'USD',
      priority: 'HIGH',
      status: 'PENDING',
      createdBy: 'user1',
      createdAt: 1234567890,
      updatedAt: 1234567890,
      title: '',
    );

    test('should insert request and enqueue sync item in transaction',
        () async {
      // Arrange
      when(() => mockDb.transaction(any())).thenAnswer((invocation) async {
        final action =
            invocation.positionalArguments[0] as Future<void> Function();
        return await action();
      });
      when(() => mockRequestDao.insertRequest(any())).thenAnswer((_) async {});
      when(() => mockSyncQueueDao.enqueue(any())).thenAnswer((_) async {});

      // Act
      await repository.createRequest(tRequestModel);

      // Assert
      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(() => mockRequestDao.insertRequest(any())).called(1);
      verify(() => mockSyncQueueDao.enqueue(any())).called(1);
    });
  });

  group('getRequestsForUser', () {
    final tRequestRow = Request(
      id: '1',
      projectId: 'proj1',
      requestType: 'FUNDS',
      title: 'Test Request',
      description: 'Test Description',
      status: 'PENDING',
      createdBy: 'user1',
      priority: 'HIGH',
      createdAt: 1234567890,
      updatedAt: 1234567890,
      meta: '{}',
    );

    test('should return requests from local db', () async {
      // Arrange
      when(
        () => mockRequestDao.getRequestsForUser(
          any(), // projectId
          any(), // userId
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tRequestRow]);
      when(() => mockMetaDao.getValue(any())).thenAnswer((_) async => null);

      // Act
      final result =
          await repository.getMyRequests(projectId: 'proj1', userId: 'user1');

      // Assert
      expect(result.data.length, 1);
      expect(result.data.first.id, '1');
      verify(
        () => mockRequestDao.getRequestsForUser(
          any(),
          any(),
          status: any(named: 'status'),
        ),
      ).called(1);
    });

    test(
        'should fetch from remote and update local db when forceRemote is true',
        () async {
      // Arrange
      final tRequestModel = RequestModel(
        id: '1',
        projectId: 'proj1',
        requestNumber: 'REQ-001',
        type: 'FUNDS',
        description: 'Test Description',
        amount: 100.0,
        currency: 'USD',
        priority: 'HIGH',
        status: 'SYNCED',
        createdBy: 'user1',
        createdAt: 1234567890,
        updatedAt: 1234567890,
        title: '',
      );

      when(() => mockRemoteDataSource.fetchProjectRequests(
            any(), // projectId
            filters: any(named: 'filters'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenAnswer((_) async => [tRequestModel.toJson()]);

      when(() => mockMetaDao.getValue(any())).thenAnswer((_) async => null);
      when(() => mockDb.transaction(any())).thenAnswer((invocation) async {
        final action =
            invocation.positionalArguments[0] as Future<void> Function();
        return await action();
      });
      when(() => mockRequestDao.insertRequest(any())).thenAnswer((_) async {});
      when(() => mockMetaDao.setValue(any(), any())).thenAnswer((_) async {});
      when(() => mockRequestDao.getRequestsForUser(
            'proj1',
            'user1',
            status: any(named: 'status'),
          )).thenAnswer((_) async => [tRequestRow]);

      // Act
      final result = await repository.getMyRequests(
        projectId: 'proj1',
        userId: 'user1',
        forceRemote: true,
      );

      // Assert
      verify(() => mockRemoteDataSource.fetchProjectRequests(
            'proj1',
            filters: any(named: 'filters'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).called(1);
      verify(() => mockRequestDao.insertRequest(any())).called(1);
      expect(result.data.length, 1);
      expect(result.data.first.id, '1');
    });
  });
}
