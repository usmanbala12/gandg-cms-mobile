import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:logger/logger.dart';

import 'package:field_link/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_link/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:field_link/features/reports/domain/entities/report_entity.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/report_dao.dart';
import 'package:field_link/core/db/daos/media_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/network/network_info.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

class MockReportDao extends Mock implements ReportDao {}

class MockMediaDao extends Mock implements MediaDao {}

class MockMetaDao extends Mock implements MetaDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockReportRemoteDataSource extends Mock
    implements ReportRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockLogger extends Mock implements Logger {}

void main() {
  late ReportRepositoryImpl repository;
  late MockAppDatabase mockDb;
  late MockReportDao mockReportDao;
  late MockMediaDao mockMediaDao;
  late MockMetaDao mockMetaDao;
  late MockSyncQueueDao mockSyncQueueDao;
  late MockReportRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockLogger mockLogger;

  setUp(() {
    mockDb = MockAppDatabase();
    mockReportDao = MockReportDao();
    mockMediaDao = MockMediaDao();
    mockMetaDao = MockMetaDao();
    mockSyncQueueDao = MockSyncQueueDao();
    mockRemoteDataSource = MockReportRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockLogger = MockLogger();

    // Mock networkInfo to return true (online) by default
    when(() => mockNetworkInfo.isOnline()).thenAnswer((_) async => true);

    repository = ReportRepositoryImpl(
      db: mockDb,
      reportDao: mockReportDao,
      mediaDao: mockMediaDao,
      metaDao: mockMetaDao,
      syncQueueDao: mockSyncQueueDao,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
      logger: mockLogger,
    );

    registerFallbackValue(ReportsCompanion());
    registerFallbackValue(SyncQueueCompanion());
  });

  group('createReport', () {
    final tReport = ReportEntity(
      id: '1',
      projectId: 'proj1',
      reportDate: 1234567890,
      createdAt: 1234567890,
      updatedAt: 1234567890,
      status: 'PENDING',
    );

    test('should insert report and enqueue sync item in transaction', () async {
      // Arrange
      when(() => mockDb.transaction(any())).thenAnswer((invocation) async {
        final action =
            invocation.positionalArguments[0] as Future<void> Function();
        return await action();
      });
      when(() => mockReportDao.insertReport(any())).thenAnswer((_) async {});
      when(() => mockSyncQueueDao.enqueue(any())).thenAnswer((_) async {});

      // Act
      await repository.createReport(tReport);

      // Assert
      verify(() => mockDb.transaction<void>(any())).called(1);
      verify(() => mockReportDao.insertReport(any())).called(1);
      verify(() => mockSyncQueueDao.enqueue(any())).called(1);
    });
  });

  group('getReports', () {
    final tReportRow = Report(
      id: '1',
      projectId: 'proj1',
      reportDate: 1234567890,
      createdAt: 1234567890,
      updatedAt: 1234567890,
      status: 'PENDING',
      submissionData: '{}',
      mediaIds: '[]',
    );

    test('should return reports from local db', () async {
      // Arrange
      when(
        () => mockReportDao.getReports(
          projectId: any(named: 'projectId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tReportRow]);
      when(() => mockMetaDao.getValue(any())).thenAnswer((_) async => null);

      // Act
      final result = await repository.getReports(projectId: 'proj1');

      // Assert
      expect(result.data.length, 1);
      expect(result.data.first.id, '1');
      verify(
        () => mockReportDao.getReports(
          projectId: any(named: 'projectId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });

    test(
      'should fetch from remote and update local db when forceRemote is true',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.fetchProjectReports('proj1'),
        ).thenAnswer(
          (_) async => [
            {
              'id': '1',
              'project_id': 'proj1',
              'report_date': 1234567890,
              'status': 'SYNCED',
              'created_at': 1234567890,
              'updated_at': 1234567890,
              'submission_data': <String, dynamic>{},
              'media_ids': <String>[],
            },
          ],
        );
        when(() => mockMetaDao.getValue(any())).thenAnswer((_) async => null);
        when(() => mockDb.transaction(any())).thenAnswer((invocation) async {
          final action = invocation.positionalArguments[0] as Function;
          await action();
          return Future.value();
        });
        when(() => mockReportDao.insertReport(any())).thenAnswer((_) async {});
        when(() => mockMetaDao.setValue(any(), any())).thenAnswer((_) async {});
        when(
          () => mockReportDao.getReports(
            projectId: 'proj1',
            limit: 50,
            offset: 0,
          ),
        ).thenAnswer((_) async => [tReportRow]);

        // Act
        final result = await repository.getReports(
          projectId: 'proj1',
          forceRemote: true,
        );

        // Assert
        verify(
          () => mockRemoteDataSource.fetchProjectReports('proj1'),
        ).called(1);
        verify(() => mockReportDao.insertReport(any())).called(1);
        expect(result.data.length, 1);
        expect(result.data.first.id, '1');
      },
    );
  });
}
