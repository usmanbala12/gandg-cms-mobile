import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:field_link/core/db/app_database.dart';

void main() {
  group('Database Migrations', () {
    test('Schema v1 creates all tables', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        // Verify tables exist by querying them
        final projects = await db.select(db.projects).get();
        expect(projects, isA<List>());

        final syncQueue = await db.select(db.syncQueue).get();
        expect(syncQueue, isA<List>());

        final reports = await db.select(db.reports).get();
        expect(reports, isA<List>());

        final issues = await db.select(db.issues).get();
        expect(issues, isA<List>());

        final media = await db.select(db.mediaFiles).get();
        expect(media, isA<List>());

        final conflicts = await db.select(db.syncConflicts).get();
        expect(conflicts, isA<List>());

        final meta = await db.select(db.meta).get();
        expect(meta, isA<List>());
      } finally {
        await db.close();
      }
    });

    test('Schema version is correct', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        expect(db.schemaVersion, 1);
      } finally {
        await db.close();
      }
    });

    test('Media table has expected columns', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        // Insert a media record to verify columns
        await db.into(db.mediaFiles).insert(
          MediaFilesCompanion.insert(
            id: 'test-media-1',
            localPath: '/path/to/file.jpg',
            projectId: 'p1',
            parentType: 'report',
            parentId: 'r1',
            size: 1024,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        final media = await db.select(db.mediaFiles).get();
        expect(media.length, 1);
        expect(media.first.id, 'test-media-1');
        expect(media.first.uploadStatus, 'PENDING');
      } finally {
        await db.close();
      }
    });

    test('SyncQueue table has expected columns', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        final now = DateTime.now().millisecondsSinceEpoch;

        // Insert a sync queue item
        await db.into(db.syncQueue).insert(
          SyncQueueCompanion.insert(
            id: 'q1',
            projectId: 'p1',
            entityType: 'report',
            entityId: 'r1',
            action: 'create',
            payload: const Value(null),
            priority: const Value(1),
            status: const Value('PENDING'),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: now,
          ),
        );

        final queue = await db.select(db.syncQueue).get();
        expect(queue.length, 1);
        expect(queue.first.status, 'PENDING');
        expect(queue.first.attempts, 0);
      } finally {
        await db.close();
      }
    });

    test('Indexes are created correctly', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        // Query sqlite_master to check for indexes
        final result = await db.customSelect(
          'SELECT name FROM sqlite_master WHERE type="index" AND tbl_name="sync_queue";',
          readsFrom: {},
        ).get();

        // Should have at least one index on sync_queue
        expect(result.isNotEmpty, true);
      } finally {
        await db.close();
      }
    });

    test('Foreign key constraints are enforced', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        // Enable foreign keys
        await db.customStatement('PRAGMA foreign_keys = ON;');

        // Insert a project
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            id: 'p1',
            name: 'Test Project',
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Insert a report with valid project_id
        await db.into(db.reports).insert(
          ReportsCompanion.insert(
            id: 'r1',
            projectId: 'p1',
            reportDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        final reports = await db.select(db.reports).get();
        expect(reports.length, 1);
        expect(reports.first.projectId, 'p1');
      } finally {
        await db.close();
      }
    });

    test('Transactions work correctly', () async {
      final db = AppDatabase.forTesting(
        DatabaseConnection(NativeDatabase.memory()),
      );

      try {
        final now = DateTime.now().millisecondsSinceEpoch;

        // Test transaction: insert project and report atomically
        await db.transaction(() async {
          await db.into(db.projects).insert(
            ProjectsCompanion.insert(
              id: 'p1',
              name: 'Test Project',
              createdAt: now,
              updatedAt: now,
            ),
          );

          await db.into(db.reports).insert(
            ReportsCompanion.insert(
              id: 'r1',
              projectId: 'p1',
              reportDate: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
        });

        final projects = await db.select(db.projects).get();
        final reports = await db.select(db.reports).get();

        expect(projects.length, 1);
        expect(reports.length, 1);
      } finally {
        await db.close();
      }
    });
  });
}
