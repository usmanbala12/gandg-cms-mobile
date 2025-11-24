import 'package:uuid/uuid.dart';

// UUID generation
String uuid() => const Uuid().v4();

// Current time in epoch milliseconds
int now() => DateTime.now().millisecondsSinceEpoch;

// Entity status constants
class EntityStatus {
  static const String draft = 'DRAFT';
  static const String submitted = 'SUBMITTED';
  static const String synced = 'SYNCED';
  static const String error = 'ERROR';
}

// Report status constants
class ReportStatus {
  static const String draft = 'DRAFT';
  static const String submitted = 'SUBMITTED';
  static const String synced = 'SYNCED';
  static const String error = 'ERROR';
}

// Issue status constants
class IssueStatus {
  static const String open = 'OPEN';
  static const String inProgress = 'IN_PROGRESS';
  static const String closed = 'CLOSED';
}

// Media upload status constants
class MediaUploadStatus {
  static const String pending = 'PENDING';
  static const String syncing = 'SYNCING';
  static const String synced = 'SYNCED';
  static const String error = 'ERROR';
}

// SyncQueue action constants
class SyncQueueAction {
  static const String create = 'create';
  static const String update = 'update';
  static const String delete = 'delete';
}

// SyncQueue status constants
class SyncQueueStatus {
  static const String pending = 'PENDING';
  static const String inProgress = 'IN_PROGRESS';
  static const String failed = 'FAILED';
  static const String done = 'DONE';
  static const String conflict = 'CONFLICT';
}

// Cache TTL constants (in milliseconds)
class CacheTTL {
  // 30 days for reports and analytics
  static const int defaultReportsTTL = 30 * 24 * 60 * 60 * 1000;
  // 30-day analytics cache requirement for parity with reports
  static const int analyticsTTL = 30 * 24 * 60 * 60 * 1000;
  // 1 day for issues
  static const int issuesTTL = 24 * 60 * 60 * 1000;
}

// Media storage constants
class MediaStorage {
  // Default media cap: ~500MB
  static const int defaultMediaCapBytes = 500 * 1024 * 1024;
}

// Sync constants
class SyncConstants {
  static const int defaultBatchSize = 10;
  static const int maxRetries = 3;
  static const int initialBackoffMs = 1000;
  static const double backoffMultiplier = 2.0;
}
