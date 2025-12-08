import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:matcher/matcher.dart' as matcher;
import 'package:mocktail/mocktail.dart';

import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/conflict_dao.dart';
import 'package:field_link/core/db/daos/issue_dao.dart';
import 'package:field_link/core/db/daos/issue_comment_dao.dart';
import 'package:field_link/core/db/db_utils.dart';
import 'package:field_link/core/network/api_client.dart';
import 'package:field_link/core/db/repositories/report_repository.dart';
import 'package:field_link/core/db/repositories/media_repository.dart';
import 'package:field_link/features/issues/domain/repositories/issue_repository.dart';
import 'package:field_link/features/requests/domain/repositories/request_repository.dart';
import 'package:field_link/core/sync/sync_manager.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

class MockReportRepository extends Mock implements ReportRepository {}

class MockMediaRepository extends Mock implements MediaRepository {}

class MockRequestRepository extends Mock implements RequestRepository {}

class MockIssueRepository extends Mock implements IssueRepository {}

class MockIssueDao extends Mock implements IssueDao {}

class MockIssueCommentDao extends Mock implements IssueCommentDao {}

void main() {
  group('SyncManager', () {
    late AppDatabase db;
    late SyncQueueDao syncQueueDao;
    late MetaDao metaDao;
    late ConflictDao conflictDao;
    late MockApiClient mockApiClient;
    late MockReportRepository mockReportRepository;
    late MockMediaRepository mockMediaRepository;
    late MockRequestRepository mockRequestRepository;
    late MockIssueRepository mockIssueRepository;
    late MockIssueDao mockIssueDao;
    late MockIssueCommentDao mockIssueCommentDao;
    late SyncManager syncManager;

    setUp(() async {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
      syncQueueDao = SyncQueueDao(db);
      metaDao = MetaDao(db);
      conflictDao = ConflictDao(db);
      mockApiClient = MockApiClient();
      mockReportRepository = MockReportRepository();
      mockMediaRepository = MockMediaRepository();
      mockRequestRepository = MockRequestRepository();
      mockIssueRepository = MockIssueRepository();
      mockIssueDao = MockIssueDao();
      mockIssueCommentDao = MockIssueCommentDao();

      syncManager = SyncManager(
        db: db,
        syncQueueDao: syncQueueDao,
        metaDao: metaDao,
        conflictDao: conflictDao,
        apiClient: mockApiClient,
        reportRepository: mockReportRepository,
        mediaRepository: mockMediaRepository,
        requestRepository: mockRequestRepository,
        issueRepository: mockIssueRepository,
        issueDao: mockIssueDao,
        issueCommentDao: mockIssueCommentDao,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('_processOutgoing marks items as DONE on success', () async {
      final nowTs = now();

      // Enqueue a report creation item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'q1',
          projectId: 'p1',
          entityType: 'report',
          entityId: 'r1',
          action: SyncQueueAction.create,
          payload: Value(jsonEncode({'title': 'Test Report'})),
          priority: const Value(1),
          status: const Value(SyncQueueStatus.pending),
          attempts: const Value(0),
          lastAttemptAt: const Value(null),
          errorMessage: const Value(null),
          createdAt: nowTs,
        ),
      );

      // Mock the report repository to succeed
      when(
        () => mockReportRepository.processSyncQueueItem(
          'p1',
          'r1',
          SyncQueueAction.create,
          any(),
        ),
      ).thenAnswer((_) async {});

      // Process outgoing
      await syncManager.processOutgoingForTesting(batchSize: 10);

      // Verify the item was marked as DONE
      final pending = await syncQueueDao.getPending(10);
      expect(pending.isEmpty, true);

      // Verify it's in the database with DONE status
      final allItems = await db.select(db.syncQueue).get();
      expect(allItems.length, 1);
      expect(allItems.first.status, SyncQueueStatus.done);
    });

    test('_processOutgoing marks items as FAILED on error', () async {
      final nowTs = now();

      // Enqueue a report creation item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'q1',
          projectId: 'p1',
          entityType: 'report',
          entityId: 'r1',
          action: SyncQueueAction.create,
          payload: Value(jsonEncode({'title': 'Test Report'})),
          priority: const Value(1),
          status: const Value(SyncQueueStatus.pending),
          attempts: const Value(SyncConstants.maxRetries),
          lastAttemptAt: const Value(null),
          errorMessage: const Value(null),
          createdAt: nowTs,
        ),
      );

      // Mock the report repository to fail
      when(
        () => mockReportRepository.processSyncQueueItem(
          'p1',
          'r1',
          SyncQueueAction.create,
          any(),
        ),
      ).thenThrow(Exception('Network error'));

      // Process outgoing
      await syncManager.processOutgoingForTesting(batchSize: 10);

      // Verify the item was marked as FAILED
      final allItems = await db.select(db.syncQueue).get();
      expect(allItems.length, 1);
      expect(allItems.first.status, SyncQueueStatus.failed);
    });

    test('_downloadAndApply updates meta last sync time', () async {
      // Mock the API to return empty changes
      when(() => mockApiClient.syncDownload('p1', any())).thenAnswer(
        (_) async => {
          'created': [],
          'updated': [],
          'deleted': [],
          'conflicts': [],
        },
      );

      // Run download and apply
      await syncManager.downloadAndApplyForTesting('p1');

      // Verify meta was updated
      final lastSyncStr = await metaDao.getValue('last_sync_p1');
      expect(lastSyncStr, matcher.isNotNull);
      final parsedTime = int.tryParse(lastSyncStr!);
      expect(parsedTime, matcher.isNotNull);
      expect(parsedTime! > 0, true);
    });

    test('_downloadAndApply inserts conflicts', () async {
      // Mock the API to return conflicts
      when(() => mockApiClient.syncDownload('p1', any())).thenAnswer(
        (_) async => {
          'created': [],
          'updated': [],
          'deleted': [],
          'conflicts': [
            {
              'entityType': 'report',
              'entityId': 'r1',
              'local': {'status': 'DRAFT'},
              'server': {'status': 'SYNCED'},
            },
          ],
        },
      );

      // Run download and apply
      await syncManager.downloadAndApplyForTesting('p1');

      // Verify conflict was inserted
      final conflicts = await conflictDao.getUnresolvedConflicts();
      expect(conflicts.length, 1);
      expect(conflicts.first.entityType, 'report');
      expect(conflicts.first.resolved, 0);
    });

    test('getPendingQueueCount returns correct count', () async {
      final nowTs = now();

      // Enqueue 3 items
      for (var i = 0; i < 3; i++) {
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: 'q$i',
            projectId: 'p1',
            entityType: 'report',
            entityId: 'r$i',
            action: SyncQueueAction.create,
            payload: const Value(null),
            priority: const Value(1),
            status: const Value(SyncQueueStatus.pending),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: nowTs,
          ),
        );
      }

      final count = await syncManager.getPendingQueueCount();
      expect(count, 3);
    });

    test('getUnresolvedConflictsCount returns correct count', () async {
      final nowTs = now();

      // Insert 2 unresolved conflicts
      for (var i = 0; i < 2; i++) {
        await conflictDao.insertConflict(
          SyncConflictsCompanion.insert(
            id: 'c$i',
            entityType: 'report',
            entityId: 'r$i',
            localPayload: '{}',
            serverPayload: '{}',
            detectedAt: nowTs,
            createdAt: nowTs,
          ),
        );
      }

      final count = await syncManager.getUnresolvedConflictsCount();
      expect(count, 2);
    });

    test('runSyncCycle processes outgoing and downloads', () async {
      final nowTs = now();

      // Enqueue an item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'q1',
          projectId: 'p1',
          entityType: 'report',
          entityId: 'r1',
          action: SyncQueueAction.create,
          payload: Value(jsonEncode({'title': 'Test'})),
          priority: const Value(1),
          status: const Value(SyncQueueStatus.pending),
          attempts: const Value(0),
          lastAttemptAt: const Value(null),
          errorMessage: const Value(null),
          createdAt: nowTs,
        ),
      );

      // Mock repositories and API
      when(
        () => mockReportRepository.processSyncQueueItem(
          'p1',
          'r1',
          SyncQueueAction.create,
          any(),
        ),
      ).thenAnswer((_) async {});

      when(() => mockApiClient.syncDownload('p1', any())).thenAnswer(
        (_) async => {
          'created': [],
          'updated': [],
          'deleted': [],
          'conflicts': [],
        },
      );

      // Run sync cycle
      await syncManager.runSyncCycle(projectId: 'p1');

      // Verify item was processed
      final pending = await syncQueueDao.getPending(10);
      expect(pending.isEmpty, true);

      // Verify meta was updated
      final lastSync = await metaDao.getValue('last_sync_p1');
      expect(lastSync, matcher.isNotNull);
      final parsedTime = int.tryParse(lastSync!);
      expect(parsedTime, matcher.isNotNull);
      expect(parsedTime! > 0, true);
    });
  });
}
