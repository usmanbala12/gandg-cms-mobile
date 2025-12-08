// coverage:ignore-file

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/projects.dart';
import 'tables/sync_queue.dart';
import 'tables/project_analytics.dart';
import 'tables/reports.dart';
import 'tables/issues.dart';
import 'tables/issue_comments.dart';
import 'tables/media.dart';
import 'tables/sync_conflicts.dart';
import 'tables/meta.dart';
import 'tables/form_templates.dart';
import 'daos/project_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/analytics_dao.dart';
import 'daos/report_dao.dart';
import 'daos/issue_dao.dart';
import 'daos/issue_comment_dao.dart';
import 'daos/media_dao.dart';
import 'daos/conflict_dao.dart';
import 'daos/meta_dao.dart';

import 'tables/issue_history.dart';
import 'tables/issue_media.dart';
import 'daos/issue_history_dao.dart';
import 'daos/issue_media_dao.dart';
import 'tables/requests.dart';
import 'tables/notifications.dart';
import 'daos/request_dao.dart';
import 'daos/notification_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Projects,
    SyncQueue,
    ProjectAnalytics,
    Reports,
    Issues,
    IssueComments,
    IssueHistory,
    IssueMedia,
    MediaFiles,
    SyncConflicts,
    Meta,
    FormTemplates,
    Requests,
    Notifications,
  ],
  daos: [
    ProjectDao,
    SyncQueueDao,
    AnalyticsDao,
    ReportDao,
    IssueDao,
    IssueCommentDao,
    IssueHistoryDao,
    IssueMediaDao,
    MediaDao,
    ConflictDao,
    MetaDao,
    RequestDao,
    NotificationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing: create an in-memory database
  AppDatabase.forTesting(DatabaseConnection super.connection);

  // Increment this when making schema changes and add proper migrations.
  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Add migration steps when schemaVersion increases.
          // Example template:
          if (from < 2) {
            await m.createTable(formTemplates);
          }
          if (from < 3) {
            await m.createTable(issueComments);
          }
          if (from < 4) {
            await m.createTable(issueHistory);
            await m.createTable(issueMedia);
            await m.addColumn(issues, issues.deletedAt);
            await m.addColumn(issues, issues.syncStatus);
            await m.addColumn(issueComments, issueComments.updatedAt);
            await m.addColumn(issueComments, issueComments.serverUpdatedAt);
            await m.addColumn(issueComments, issueComments.deletedAt);
          }
          if (from < 5) {
            await m.createTable(requests);
            await m.createTable(notifications);
          }
          if (from < 6) {
            await m.addColumn(
                requests, requests.shortSummary as GeneratedColumn);
            await m.addColumn(requests, requests.location as GeneratedColumn);
            await m.addColumn(requests, requests.dueDate as GeneratedColumn);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _ensureIndexes();
        },
      );

  Future<void> closeDb() async {
    await close();
  }

  Future<void> _ensureIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_syncqueue_status_priority_created ON sync_queue(status, priority DESC, created_at ASC);',
      'CREATE INDEX IF NOT EXISTS idx_syncqueue_project_status ON sync_queue(project_id, status);',
      'CREATE INDEX IF NOT EXISTS idx_reports_project_id ON reports(project_id);',
      'CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);',
      'CREATE INDEX IF NOT EXISTS idx_reports_server_id ON reports(server_id);',
      'CREATE INDEX IF NOT EXISTS idx_issues_project_id ON issues(project_id);',
      'CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);',
      'CREATE INDEX IF NOT EXISTS idx_issues_server_id ON issues(server_id);',
      'CREATE INDEX IF NOT EXISTS idx_issue_comments_issue_id ON issue_comments(issue_local_id, created_at ASC);',
      'CREATE INDEX IF NOT EXISTS idx_media_project_id ON media_files(project_id);',
      'CREATE INDEX IF NOT EXISTS idx_media_upload_status ON media_files(upload_status);',
      'CREATE INDEX IF NOT EXISTS idx_media_parent_lookup ON media_files(parent_type, parent_id);',
      'CREATE INDEX IF NOT EXISTS idx_conflicts_resolved ON sync_conflicts(resolved);',
      'CREATE INDEX IF NOT EXISTS idx_requests_project_id ON requests(project_id);',
      'CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status);',
      'CREATE INDEX IF NOT EXISTS idx_requests_server_id ON requests(server_id);',
      'CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);',
      'CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);',
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
