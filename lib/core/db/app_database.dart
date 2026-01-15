// coverage:ignore-file

import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/projects.dart';
import 'tables/sync_queue.dart';
import 'tables/meta.dart';
import 'tables/requests.dart';
import 'tables/users.dart';
import 'daos/project_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/meta_dao.dart';
import 'daos/request_dao.dart';
import 'daos/user_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    SyncQueue,
    Meta,
    Requests,
    Users,
  ],
  daos: [
    ProjectDao,
    SyncQueueDao,
    MetaDao,
    RequestDao,
    UserDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing: create an in-memory database
  AppDatabase.forTesting(DatabaseConnection super.connection);

  // Increment this when making schema changes and add proper migrations.
  @override
  int get schemaVersion => 9;

  // Track if indexes are being created to avoid duplicate work
  bool _indexCreationStarted = false;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Migration v9: Simplify offline capabilities
          // Drop unused tables (Reports, Issues, Notifications, etc.)
          if (from < 9) {
            // Drop tables that are no longer needed
            final tablesToDrop = [
              'reports',
              'issues',
              'issue_comments',
              'issue_history',
              'issue_media',
              'media_files',
              'sync_conflicts',
              'form_templates',
              'notifications',
              'project_analytics',
            ];

            for (final table in tablesToDrop) {
              try {
                await m.database.customStatement('DROP TABLE IF EXISTS $table');
              } catch (_) {
                // Table might not exist, ignore
              }
            }

            // Clean up any orphaned indexes
            final indexesToDrop = [
              'idx_reports_project_id',
              'idx_reports_status',
              'idx_reports_server_id',
              'idx_issues_project_id',
              'idx_issues_status',
              'idx_issues_server_id',
              'idx_issue_comments_issue_id',
              'idx_media_project_id',
              'idx_media_upload_status',
              'idx_media_parent_lookup',
              'idx_conflicts_resolved',
              'idx_notifications_user_id',
              'idx_notifications_is_read',
            ];

            for (final index in indexesToDrop) {
              try {
                await m.database.customStatement('DROP INDEX IF EXISTS $index');
              } catch (_) {
                // Index might not exist, ignore
              }
            }
          }

          // Keep previous migrations for users upgrading from older versions
          if (from < 5) {
            await m.createTable(requests);
          }
          if (from < 6) {
            try {
              await m.addColumn(
                  requests, requests.shortSummary as GeneratedColumn);
            } catch (_) {}
            try {
              await m.addColumn(requests, requests.location as GeneratedColumn);
            } catch (_) {}
            try {
              await m.addColumn(requests, requests.dueDate as GeneratedColumn);
            } catch (_) {}
          }
          if (from < 7) {
            await m.createTable(users);
          }
          if (from < 8) {
            await m.addColumn(users, users.roleId);
            await m.addColumn(users, users.roleDisplayName);
            await m.addColumn(users, users.admin);
            await m.addColumn(users, users.createdAt);
            await m.addColumn(users, users.updatedAt);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Schedule index creation for background execution
          unawaited(_ensureIndexesInBackground());
        },
      );

  Future<void> closeDb() async {
    await close();
  }

  /// Creates indexes in the background, checking if they're already done
  Future<void> _ensureIndexesInBackground() async {
    if (_indexCreationStarted) return;
    _indexCreationStarted = true;

    try {
      final existingVersion = await (select(meta)
            ..where((t) => t.key.equals('indexes_version')))
          .getSingleOrNull();

      // Current indexes version - increment when adding new indexes
      // v2: Simplified schema with only essential tables
      const currentIndexVersion = '2';

      if (existingVersion?.value == currentIndexVersion) {
        return;
      }

      await _createIndexes();

      await into(meta).insertOnConflictUpdate(
        MetaCompanion.insert(
          key: 'indexes_version',
          value: currentIndexVersion,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Warning: Index creation failed: $e');
    }
  }

  Future<void> _createIndexes() async {
    const statements = [
      // SyncQueue indexes for efficient queue processing
      'CREATE INDEX IF NOT EXISTS idx_syncqueue_status_priority_created ON sync_queue(status, priority DESC, created_at ASC);',
      'CREATE INDEX IF NOT EXISTS idx_syncqueue_project_status ON sync_queue(project_id, status);',
      // Requests indexes
      'CREATE INDEX IF NOT EXISTS idx_requests_project_id ON requests(project_id);',
      'CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status);',
      'CREATE INDEX IF NOT EXISTS idx_requests_server_id ON requests(server_id);',
      // Users index
      'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);',
    ];

    for (final statement in statements) {
      await customStatement(statement);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
