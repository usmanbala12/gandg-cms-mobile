# Offline-First Database Layer and Backend Sync Integration

## Overview

This document describes the complete implementation of the offline-first data layer for the Field Link Flutter application. The system uses Drift (SQLite) for local storage, Dio for API communication, and a robust SyncManager for handling background synchronization with conflict resolution.

## Architecture

### Core Components

1. **Database Layer (Drift)**
   - Local SQLite database with typed DAOs
   - Project-scoped data model
   - Transactional operations for atomicity

2. **API Client (Dio)**
   - Typed methods for all sync endpoints
   - Automatic retry and error handling
   - Logging interceptor for debugging

3. **Repositories**
   - Atomic insert + enqueue operations
   - Cache-aware fetching with TTL
   - Domain object mapping

4. **SyncManager**
   - Outgoing batch processing with claimBatch
   - Download and apply with conflict handling
   - Exponential backoff retry policy

5. **Media Management**
   - Multipart upload support
   - Storage cap enforcement
   - Cleanup service for old files

## File Structure

```
lib/core/
├── db/
│   ├── app_database.dart              # Main database class
│   ├── db_utils.dart                  # Constants and utilities
│   ├── README.md                      # Database documentation
│   ├── tables/                        # Table definitions
│   │   ├── projects.dart
│   │   ├── project_analytics.dart
│   │   ├── reports.dart
│   │   ├── issues.dart
│   │   ├── media.dart
│   │   ├── sync_queue.dart
│   │   ├── sync_conflicts.dart
│   │   └── meta.dart
│   ├── daos/                          # Data Access Objects
│   │   ├── project_dao.dart
│   │   ├── analytics_dao.dart
│   │   ├── report_dao.dart
│   │   ├── issue_dao.dart
│   │   ├── media_dao.dart
│   │   ├── sync_queue_dao.dart
│   │   ├── conflict_dao.dart
│   │   └── meta_dao.dart
│   ├── repositories/                  # High-level repositories
│   │   ├── dashboard_repository.dart
│   │   ├── report_repository.dart
│   │   └── media_repository.dart
│   ├── migrations/                    # Schema migrations
│   │   └── migrations.dart
│   └── debug/                         # Debug utilities
│       └── db_inspector_page.dart
├── network/
│   ├── api_client.dart                # Typed API client
│   ├── dio_client.dart                # Dio configuration
│   └── auth_interceptor.dart          # Auth handling
├── storage/
│   └── media_cleanup_service.dart     # Media storage management
├── sync/
│   └── sync_manager.dart              # Sync orchestration
└── di/
    └── injection_container.dart       # Dependency injection

test/
├── db/
│   ├── dao_tests.dart                 # DAO unit tests
│   └── migration_tests.dart           # Migration tests
└── sync/
    └── sync_manager_tests.dart        # SyncManager tests
```

## Key Features

### 1. Transactional ClaimBatch

The SyncQueue uses a transactional `claimBatch(limit)` method to safely claim pending items:

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

**Guarantees:**
- No duplicate claims across concurrent callers
- Automatic attempt counter increment
- Atomic status transition to IN_PROGRESS

### 2. Atomic Insert + Enqueue

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

**Benefits:**
- Ensures no orphaned queue items
- Maintains data consistency
- Enables reliable retry logic

### 3. Cache-Aware Fetching

Repositories implement TTL-based caching:

```dart
// Try local cache first
if (!forceRefresh) {
  final local = await analyticsDao.getAnalyticsForProject(projectId);
  if (local != null) {
    final age = now() - (local.lastSynced ?? 0);
    if (age < CacheTTL.analyticsTTL) {
      return local; // Return cached data
    }
  }
}

// Fetch from API if cache is stale
final remote = await apiClient.fetchProjectAnalytics(projectId);
await analyticsDao.upsertAnalytics(...);
return remote;
```

**TTL Values:**
- Reports: 30 days
- Analytics: 7 days
- Issues: 1 day

### 4. Conflict Resolution

When conflicts are detected (409 responses), they are stored and can be resolved:

```dart
// Detect conflict during sync
if (response.statusCode == 409) {
  throw ConflictException(
    message: 'Conflict detected',
    serverPayload: jsonEncode(response.data),
  );
}

// Conflict is stored in sync_conflicts table
// User can resolve via UI or automatic strategy
await conflictDao.markResolved(conflictId, resolution: 'server');
```

### 5. Media Upload with Storage Cap

Media files are uploaded with automatic storage cap enforcement:

```dart
// Save media and enqueue upload
final mediaId = await mediaRepository.saveLocalMediaAndEnqueue(
  projectId,
  filePath,
  'report',
  reportId,
);

// Check storage cap
final stats = await mediaCleanupService.getStorageStats(projectId);
if (stats.isOverCap) {
  await mediaCleanupService.enforceStorageCap(projectId);
}
```

**Default Cap:** ~500MB per project

## Database Schema

### Projects
- `id` (PK): UUID
- `name`: Text
- `location`: JSON (TEXT)
- `metadata`: JSON (TEXT)
- `lastSynced`: Epoch ms
- `createdAt`, `updatedAt`: Epoch ms

### SyncQueue
- `id` (PK): UUID
- `projectId`: FK to Projects
- `entityType`: report/issue/media/etc.
- `entityId`: Local entity ID
- `action`: create/update/delete
- `payload`: JSON (TEXT)
- `priority`: Integer (higher = higher priority)
- `status`: PENDING/IN_PROGRESS/FAILED/DONE/CONFLICT
- `attempts`: Integer (auto-incremented)
- `lastAttemptAt`: Epoch ms
- `errorMessage`: Text
- `createdAt`: Epoch ms

### Reports
- `id` (PK): UUID
- `projectId`: FK to Projects
- `formTemplateId`: Text
- `reportDate`: Epoch ms
- `submissionData`: JSON (TEXT)
- `location`: JSON (TEXT)
- `mediaIds`: JSON array (TEXT)
- `status`: DRAFT/SUBMITTED/SYNCED/ERROR
- `serverId`: Server-assigned ID
- `serverUpdatedAt`: Epoch ms
- `createdAt`, `updatedAt`: Epoch ms

### Media
- `id` (PK): UUID
- `localPath`: File path
- `projectId`: FK to Projects
- `parentType`: report/issue/etc.
- `parentId`: Local parent entity ID
- `uploadStatus`: PENDING/SYNCING/SYNCED/ERROR
- `mime`: MIME type
- `size`: Bytes
- `serverId`: Server-assigned ID
- `thumbnailPath`: Local thumbnail path
- `createdAt`: Epoch ms

### SyncConflicts
- `id` (PK): UUID
- `entityType`: report/issue/media/etc.
- `entityId`: Local entity ID
- `localPayload`: JSON (TEXT)
- `serverPayload`: JSON (TEXT)
- `resolved`: 0/1
- `resolution`: local/server/merged
- `detectedAt`, `createdAt`: Epoch ms

### Meta
- `key` (PK): Text (e.g., 'last_sync_projectId')
- `value`: Text

## API Endpoints

### Sync Endpoints
- `POST /api/v1/sync/batch` - Upload pending changes
- `GET /api/v1/sync/download` - Download server changes
- `GET /api/v1/sync/conflicts` - Fetch unresolved conflicts
- `POST /api/v1/sync/conflicts/{id}/resolve` - Resolve conflict

### Entity Endpoints
- `GET /api/v1/projects` - List projects
- `GET /api/v1/projects/{id}/analytics` - Get project analytics
- `POST /api/v1/projects/{id}/reports` - Create report
- `PUT /api/v1/projects/{id}/reports/{reportId}` - Update report
- `DELETE /api/v1/projects/{id}/reports/{reportId}` - Delete report
- `POST /api/v1/projects/{id}/media` - Upload media (multipart)
- `POST /api/v1/projects/{id}/issues` - Create issue
- `PUT /api/v1/projects/{id}/issues/{issueId}` - Update issue
- `DELETE /api/v1/projects/{id}/issues/{issueId}` - Delete issue

## Initialization

### In main.dart

```dart
import 'package:field_link/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI with database and sync manager
  await initDependencies(baseUrl: 'http://72.61.19.130:8081');
  
  runApp(const MyApp());
}
```

### Code Generation

After modifying tables or DAOs:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `app_database.g.dart`
- `*_dao.g.dart` files for each DAO

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test Suite

```bash
# DAO tests
flutter test test/db/dao_tests.dart

# Migration tests
flutter test test/db/migration_tests.dart

# SyncManager tests
flutter test test/sync/sync_manager_tests.dart
```

### Test Coverage

- **DAO Tests**: CRUD operations, transactional claimBatch, concurrency
- **Migration Tests**: Schema creation, column additions, data preservation
- **SyncManager Tests**: Outgoing processing, download/apply, conflict handling

## Debug UI

To access the database inspector in debug builds:

```dart
import 'package:field_link/core/db/debug/db_inspector_page.dart';

// In your debug menu
if (kDebugMode) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DbInspectorPage()),
  );
}
```

**Features:**
- Project count
- Pending queue items
- Unresolved conflicts
- Force claim queue
- Truncate cache
- Export database

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

### TTL Constants

```dart
// 30 days for reports
final reportsTTL = CacheTTL.defaultReportsTTL;

// 7 days for analytics
final analyticsTTL = CacheTTL.analyticsTTL;

// 1 day for issues
final issuesTTL = CacheTTL.issuesTTL;
```

## Sync Workflow

### Outgoing Sync

1. User creates/updates/deletes entity locally
2. Repository atomically inserts entity and enqueues sync item
3. SyncManager claims batch of pending items
4. For each item:
   - Route to appropriate repository handler
   - Call API endpoint
   - Update local entity with server ID/timestamp
   - Mark queue item as DONE
5. On error: Mark as FAILED or CONFLICT, retry with backoff

### Incoming Sync

1. SyncManager calls `syncDownload` API
2. Server returns created/updated/deleted entities and conflicts
3. In a transaction:
   - Apply created entities
   - Apply updated entities
   - Apply deleted entities
   - Insert conflicts
   - Update last sync timestamp

### Conflict Resolution

1. Conflict detected during outgoing sync (409 response)
2. Conflict stored in `sync_conflicts` table
3. User notified via UI
4. User chooses resolution: local/server/merged
5. Conflict marked as resolved
6. Item requeued for sync

## Performance Considerations

### Indexes

- `sync_queue(status, priority DESC, created_at ASC)` - Optimizes claimBatch selection
- `reports(project_id)` - Optimizes project-scoped queries
- `reports(status)` - Optimizes status filtering
- `issues(project_id)` - Optimizes project-scoped queries
- `issues(status)` - Optimizes status filtering
- `media_files(project_id)` - Optimizes project-scoped queries
- `media_files(upload_status)` - Optimizes pending media queries
- `sync_conflicts(resolved)` - Optimizes conflict queries

### Batch Processing

- Default batch size: 10 items
- Configurable via `SyncConstants.defaultBatchSize`
- Prevents memory issues with large queues

### Caching

- 30-day TTL for reports
- 7-day TTL for analytics
- 1-day TTL for issues
- Configurable per repository

## Troubleshooting

### Codegen Issues

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Locked

- Ensure only one AppDatabase instance (use GetIt singleton)
- Close database properly in cleanup code

### Test Failures

- Use `AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()))`
- Ensure all DAOs are initialized in test setUp

### Sync Not Working

- Check pending queue count: `await syncManager.getPendingQueueCount()`
- Check unresolved conflicts: `await syncManager.getUnresolvedConflictsCount()`
- Review logs for API errors
- Verify base URL is correct

## Future Enhancements

- [ ] Background sync with WorkManager/BackgroundFetch
- [ ] Selective sync (sync only specific projects)
- [ ] Bandwidth-aware sync (pause on metered connections)
- [ ] Compression for large payloads
- [ ] Encryption for sensitive data
- [ ] Automatic conflict resolution strategies
- [ ] Sync progress UI
- [ ] Offline-first analytics

## References

- [Drift Documentation](https://drift.simonbinder.eu/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Offline-First Architecture](https://offlinefirst.org/)
- [Dio Documentation](https://pub.dev/packages/dio)
- [GetIt Documentation](https://pub.dev/packages/get_it)
