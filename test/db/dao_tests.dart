import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull, isNull;
import 'package:path/path.dart' as p;

import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/project_dao.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/db/daos/analytics_dao.dart';
import 'package:field_link/core/db/daos/report_dao.dart';
import 'package:field_link/core/db/daos/media_dao.dart';
import 'package:field_link/core/db/daos/conflict_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';

import 'package:field_link/core/db/db_utils.dart';
import 'package:field_link/core/storage/media_cleanup_service.dart';

void main() {
  late AppDatabase db;
  late ProjectDao projectDao;
  late SyncQueueDao queueDao;
  late AnalyticsDao analyticsDao;
  late ReportDao reportDao;
  late MediaDao mediaDao;
  late ConflictDao conflictDao;
  late MetaDao metaDao;

  setUp(() async {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    projectDao = ProjectDao(db);
    queueDao = SyncQueueDao(db);
    analyticsDao = AnalyticsDao(db);
    reportDao = ReportDao(db);
    mediaDao = MediaDao(db);
    conflictDao = ConflictDao(db);
    metaDao = MetaDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Insert project -> read back', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await projectDao.upsertProject(
      ProjectsCompanion.insert(
        id: 'p1',
        name: 'Project One',
        createdAt: now,
        updatedAt: now,
      ),
    );

    final all = await projectDao.getProjects();
    expect(all.length, 1);
    expect(all.first.id, 'p1');
  });

  test('claimBatch concurrency yields unique claims', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // seed 3 items
    for (var i = 0; i < 3; i++) {
      await queueDao.enqueue(
        SyncQueueCompanion.insert(
          id: 'q$i',
          projectId: 'p1',
          entityType: 'report',
          entityId: 'r$i',
          action: 'create',
          payload: const Value(null),
          priority: Value(i),
          status: const Value('PENDING'),
          attempts: const Value(0),
          lastAttemptAt: const Value(null),
          errorMessage: const Value(null),
          createdAt: now + i,
        ),
      );
    }

    // Two concurrent claimers asking for 2 each
    final f1 = queueDao.claimBatch(2);
    final f2 = queueDao.claimBatch(2);

    final results = await Future.wait([f1, f2]);
    final claimed = {
      ...results[0].map((e) => e.id),
      ...results[1].map((e) => e.id),
    };

    // Should not exceed total 3 and no duplicates
    expect(claimed.length, 3);

    // All claimed items should now be marked in-progress and have attempt count incremented
    for (final batch in results) {
      for (final item in batch) {
        expect(item.status, 'IN_PROGRESS');
        expect(item.attempts, 1);
      }
    }

    // Ensure none remain pending
    final remainingPending = await queueDao.getPending(10);
    expect(remainingPending.isEmpty, true);
  });

  test('Insert analytics and read back', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await analyticsDao.upsertAnalytics(
      ProjectAnalyticsCompanion.insert(
        projectId: 'p1',
        reportsCount: const Value(5),
        requestsPending: const Value(2),
        openIssues: const Value(3),
        lastSynced: Value(now),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final analytics = await analyticsDao.getAnalyticsForProject('p1');
    expect(analytics, isNotNull);
    expect(analytics!.reportsCount, 5);
    expect(analytics.openIssues, 3);
  });

  test('Insert report and read back', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final reportId = uuid();
    await reportDao.insertReport(
      ReportsCompanion.insert(
        id: reportId,
        projectId: 'p1',
        reportDate: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final report = await reportDao.getReportById(reportId);
    expect(report, isNotNull);
    expect(report!.id, reportId);
    expect(report.status, 'DRAFT');
  });

  test('Insert media and check total size', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final mediaId1 = uuid();
    final mediaId2 = uuid();

    await mediaDao.insertMedia(
      MediaFilesCompanion.insert(
        id: mediaId1,
        localPath: '/path/to/file1.jpg',
        projectId: 'p1',
        parentType: 'report',
        parentId: 'r1',
        size: 1024 * 100, // 100KB
        createdAt: now,
      ),
    );

    await mediaDao.insertMedia(
      MediaFilesCompanion.insert(
        id: mediaId2,
        localPath: '/path/to/file2.jpg',
        projectId: 'p1',
        parentType: 'report',
        parentId: 'r1',
        size: 1024 * 200, // 200KB
        createdAt: now,
      ),
    );

    final totalSize = await mediaDao.totalMediaSizeForProject('p1');
    expect(totalSize, 1024 * 300); // 300KB total
  });

  test(
    'Media cleanup enforces storage cap and removes orphaned entries',
    () async {
      final cleanupService = MediaCleanupService(mediaDao: mediaDao);
      final tempDir = await Directory.systemTemp.createTemp(
        'media-cleanup-test',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final now = DateTime.now().millisecondsSinceEpoch;

      Future<String> createTempFile(String name, int size) async {
        final file = File(p.join(tempDir.path, name));
        await file.writeAsBytes(List<int>.filled(size, 1));
        return file.path;
      }

      final orphanPath = await createTempFile('orphan.jpg', 256);
      final syncedPath = await createTempFile('synced.jpg', 256);

      await mediaDao.insertMedia(
        MediaFilesCompanion.insert(
          id: 'media-orphan',
          localPath: orphanPath,
          projectId: 'project-cleanup',
          parentType: 'report',
          parentId: '',
          uploadStatus: const Value(MediaUploadStatus.error),
          size: 256,
          createdAt: now,
        ),
      );

      await mediaDao.insertMedia(
        MediaFilesCompanion.insert(
          id: 'media-synced',
          localPath: syncedPath,
          projectId: 'project-cleanup',
          parentType: 'report',
          parentId: 'report-1',
          uploadStatus: const Value(MediaUploadStatus.synced),
          size: 256,
          createdAt: now + 1,
        ),
      );

      final cleaned = await cleanupService.enforceStorageCap(
        'project-cleanup',
        capBytes: 256,
      );

      expect(cleaned, isTrue);
      final remainingSize = await mediaDao.totalMediaSizeForProject(
        'project-cleanup',
      );
      expect(remainingSize <= 256, isTrue);
    },
  );

  test('Insert conflict and mark resolved', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final conflictId = uuid();

    await conflictDao.insertConflict(
      SyncConflictsCompanion.insert(
        id: conflictId,
        entityType: 'report',
        entityId: 'r1',
        localPayload: '{"status":"DRAFT"}',
        serverPayload: '{"status":"SYNCED"}',
        detectedAt: now,
        createdAt: now,
      ),
    );

    var unresolved = await conflictDao.getUnresolvedConflicts();
    expect(unresolved.length, 1);

    await conflictDao.markResolved(conflictId, resolution: 'server');

    unresolved = await conflictDao.getUnresolvedConflicts();
    expect(unresolved.isEmpty, true);
  });

  test('Meta key-value operations', () async {
    await metaDao.setValue('last_sync_p1', '${now()}');
    final value = await metaDao.getValue('last_sync_p1');
    expect(value, isNotNull);

    await metaDao.deleteKey('last_sync_p1');
    final deletedValue = await metaDao.getValue('last_sync_p1');
    expect(deletedValue, isNull);
  });
}
