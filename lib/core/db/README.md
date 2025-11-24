# Database Layer (Drift)

This directory contains the offline-first database implementation using Drift (SQLite).

## Structure

- **app_database.dart**: Main database class with schema definition and migrations.
- **tables/**: Table definitions (Projects, Reports, Issues, Media, SyncQueue, etc.).
- **daos/**: Data Access Objects for each table.
- **db_utils.dart**: Utility functions and constants (uuid, now, statuses, TTLs, media cap).
- **repositories/**: High-level repository layer (atomic insert + enqueue operations).
- **migrations/**: Migration scripts for schema changes.
- **debug/**: Debug UI for inspecting database state (kDebugMode only).

## Getting Started

### 1. Initialize Database in main.dart

```dart
import 'package:field_link/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI with database and sync manager
  await initDependencies(baseUrl: 'http://72.61.19.130:8081');
  
  runApp(const MyApp());
}
```

### 2. Generate Drift Code

After modifying tables or DAOs, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `app_database.g.dart`
- `*_dao.g.dart` files for each DAO

### 3. Run Tests

```bash
flutter test
```

Tests are located in `test/db/dao_tests.dart` and validate:
- Basic CRUD operations
- Transactional claimBatch concurrency
- Analytics, reports, media, and conflict operations

## Key Concepts

### Transactional claimBatch

The SyncQueue uses a transactional `claimBatch(limit)` method to safely claim pending items for processing:

```dart
// Claim up to 10 pending items atomically
final claimed = await syncQueueDao.claimBatch(10);

// Process each claimed item
for (final item in claimed) {
  try {
    await processQueueItem(item);
    await syncQueueDao.markDone(item.id);
  } catch (e) {
    await syncQueueDao.markFailed(item.id, e.toString());
  }
}
```

This ensures:
- No duplicate claims across concurrent callers
- Automatic increment of attempt counter
- Atomic status transition to IN_PROGRESS

### Atomic Insert + Enqueue

Repositories use transactions to atomically insert entities and enqueue sync items:

```dart
await db.transaction(() async {
  // Insert report
  await reportDao.insertReport(reportCompanion);
  
  // Enqueue sync item
  await syncQueueDao.enqueue(SyncQueueCompanion.insert(
    id: uuid(),
    projectId: projectId,
    entityType: 'report',
    entityId: reportId,
    action: 'create',
    payload: jsonEncode(reportData),
    createdAt: now(),
  ));
});
```

### JSON Storage

JSON fields are stored as TEXT in the database:
- `metadata` (Projects)
- `submissionData` (Reports)
- `location` (Reports, Issues)
- `mediaIds` (Reports)
- `reportsTimeseries`, `requestsByStatus`, `recentActivity` (ProjectAnalytics)

Parse JSON in the repository layer when mapping to domain objects.

### Timestamps

All timestamps are stored as epoch milliseconds (int):

```dart
import 'package:field_link/core/db/db_utils.dart';

final timestamp = now(); // Current time in epoch ms
```

### Cache TTL

Default cache TTLs are defined in `db_utils.dart`:

```dart
import 'package:field_link/core/db/db_utils.dart';

// 30 days for reports
final reportsTTL = CacheTTL.defaultReportsTTL;

// 7 days for analytics
final analyticsTTL = CacheTTL.analyticsTTL;
```

### Media Storage Cap

Default media cap is ~500MB:

```dart
import 'package:field_link/core/db/db_utils.dart';

final cap = MediaStorage.defaultMediaCapBytes; // 500MB
```

## Debug UI

To enable the debug database inspector (only in debug builds):

```dart
import 'package:field_link/core/db/debug/db_inspector_page.dart';

// In your debug menu or settings
if (kDebugMode) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DbInspectorPage()),
  );
}
```

The inspector shows:
- Project count
- Pending queue items
- Unresolved conflicts
- Buttons to force claim queue, truncate cache, export DB

## Configuration

### Changing Base URL

Update the base URL in `lib/core/di/injection_container.dart`:

```dart
await initDependencies(baseUrl: 'http://your-api-url:port');
```

## Migrations

When modifying the schema:

1. Update the table definition in `tables/`.
2. Increment `schemaVersion` in `app_database.dart`.
3. Add migration logic in `MigrationStrategy.onUpgrade()`.
4. Add a migration test in `test/db/migration_tests.dart`.

Example migration (v1 -> v2):

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
  },
  onUpgrade: (m, from, to) async {
    if (from == 1) {
      // Add thumbnail_path column to media table
      await m.addColumn(mediaFiles, mediaFiles.thumbnailPath);
    }
  },
);
```

## Constants and Utilities

### Status Constants

```dart
import 'package:field_link/core/db/db_utils.dart';

// Entity statuses
ReportStatus.draft
ReportStatus.submitted
ReportStatus.synced
ReportStatus.error

// Media upload statuses
MediaUploadStatus.pending
MediaUploadStatus.syncing
MediaUploadStatus.synced
MediaUploadStatus.error

// SyncQueue statuses
SyncQueueStatus.pending
SyncQueueStatus.inProgress
SyncQueueStatus.failed
SyncQueueStatus.done
SyncQueueStatus.conflict
```

### Helper Functions

```dart
import 'package:field_link/core/db/db_utils.dart';

// Generate UUID
final id = uuid();

// Current time in epoch ms
final timestamp = now();
```

## Troubleshooting

### Codegen Issues

If you see "missing part" errors:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Locked

If you encounter "database is locked" errors:
- Ensure only one instance of AppDatabase is created (use GetIt singleton).
- Close the database properly in cleanup code.

### Test Failures

For in-memory test database issues:
- Ensure `AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()))` is used.
- Check that all DAOs are properly initialized in test setUp.

## References

- [Drift Documentation](https://drift.simonbinder.eu/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Offline-First Architecture](https://offlinefirst.org/)
