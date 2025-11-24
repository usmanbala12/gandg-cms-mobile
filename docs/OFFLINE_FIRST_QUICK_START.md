# Offline-First Implementation - Quick Start Guide

## 1. Setup

### Add Dependencies

Dependencies are already added to `pubspec.yaml`:
- `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`
- `uuid`, `json_annotation`
- `drift_dev`, `build_runner`, `mocktail`, `json_serializable` (dev)

### Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 2. Initialize in main.dart

```dart
import 'package:field_link/core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI with database and sync manager
  await initDependencies(baseUrl: 'http://72.61.19.130:8081');
  
  runApp(const MyApp());
}
```

## 3. Create a Report Locally

```dart
import 'package:field_link/core/db/repositories/report_repository.dart';
import 'package:get_it/get_it.dart';

final reportRepo = GetIt.instance<ReportRepository>();

// Create report and enqueue for sync
final reportId = await reportRepo.createReportLocallyAndEnqueue(
  'project-123',
  {
    'formTemplateId': 'template-1',
    'reportDate': DateTime.now().millisecondsSinceEpoch,
    'submissionData': {'field1': 'value1'},
    'location': {'lat': 10.5, 'lng': 20.5},
  },
);
```

## 4. Upload Media

```dart
import 'package:field_link/core/db/repositories/media_repository.dart';

final mediaRepo = GetIt.instance<MediaRepository>();

// Save media and enqueue for upload
final mediaId = await mediaRepo.saveLocalMediaAndEnqueue(
  'project-123',
  '/path/to/file.jpg',
  'report',
  reportId,
  mimeType: 'image/jpeg',
);
```

## 5. Run Sync Cycle

```dart
import 'package:field_link/core/sync/sync_manager.dart';

final syncManager = GetIt.instance<SyncManager>();

// Run complete sync cycle
await syncManager.runSyncCycle(projectId: 'project-123');
```

## 6. Monitor Sync Status

```dart
// Get pending queue count
final pendingCount = await syncManager.getPendingQueueCount();
print('Pending items: $pendingCount');

// Get unresolved conflicts
final conflictCount = await syncManager.getUnresolvedConflictsCount();
print('Unresolved conflicts: $conflictCount');
```

## 7. Access Database Inspector (Debug Only)

```dart
import 'package:flutter/foundation.dart';
import 'package:field_link/core/db/debug/db_inspector_page.dart';

if (kDebugMode) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DbInspectorPage()),
  );
}
```

## 8. Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/db/dao_tests.dart
flutter test test/sync/sync_manager_tests.dart
```

## Common Tasks

### Get Projects

```dart
import 'package:field_link/core/db/repositories/dashboard_repository.dart';

final dashboardRepo = GetIt.instance<DashboardRepository>();

// Get from cache or API
final projects = await dashboardRepo.getProjects();

// Force refresh from API
final projects = await dashboardRepo.getProjects(forceRemote: true);
```

### Get Project Analytics

```dart
// Get from cache (7-day TTL)
final analytics = await dashboardRepo.getProjectAnalytics('project-123');

// Force refresh
final analytics = await dashboardRepo.getProjectAnalytics(
  'project-123',
  forceRefresh: true,
);
```

### Watch Reports (Stream)

```dart
final reportRepo = GetIt.instance<ReportRepository>();

// Get stream of reports for a project
reportRepo.watchReportsForProject('project-123').listen((reports) {
  print('Reports updated: ${reports.length}');
});
```

### Check Media Storage

```dart
import 'package:field_link/core/storage/media_cleanup_service.dart';

final cleanupService = GetIt.instance<MediaCleanupService>();

// Get storage stats
final stats = await cleanupService.getStorageStats('project-123');
print('Storage: ${stats.totalMB}MB / ${stats.capMB}MB (${stats.percentUsed}%)');

// Enforce cap if needed
if (stats.isOverCap) {
  await cleanupService.enforceStorageCap('project-123');
}
```

### Resolve Conflicts

```dart
import 'package:field_link/core/db/daos/conflict_dao.dart';

final conflictDao = GetIt.instance<ConflictDao>();

// Get unresolved conflicts
final conflicts = await conflictDao.getUnresolvedConflicts();

// Resolve with server version
for (final conflict in conflicts) {
  await conflictDao.markResolved(
    conflict.id,
    resolution: 'server',
  );
}
```

## Architecture Overview

```
User Action (Create Report)
    ↓
Repository.createReportLocallyAndEnqueue()
    ↓
Transaction:
  - Insert Report into DB
  - Enqueue SyncQueue item
    ↓
SyncManager.runSyncCycle()
    ↓
_processOutgoing():
  - claimBatch(10)
  - For each item:
    - Call API endpoint
    - Update local entity with server ID
    - Mark as DONE
    ↓
_downloadAndApply():
  - Call syncDownload API
  - Apply created/updated/deleted
  - Insert conflicts
  - Update last sync time
```

## Key Concepts

### Transactional ClaimBatch
- Safely claims pending queue items without duplicates
- Automatically increments attempt counter
- Atomic status transition to IN_PROGRESS

### Atomic Insert + Enqueue
- Ensures no orphaned queue items
- Maintains data consistency
- Enables reliable retry logic

### Cache-Aware Fetching
- Uses TTL to determine cache freshness
- Automatically fetches from API if stale
- Reduces network traffic

### Conflict Resolution
- Detects conflicts (409 responses)
- Stores conflict details
- Allows user or automatic resolution

## Troubleshooting

### Codegen Not Working

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Database Locked Error

- Ensure only one AppDatabase instance (use GetIt singleton)
- Close database properly in cleanup

### Sync Not Processing

```dart
// Check pending count
final count = await syncManager.getPendingQueueCount();
print('Pending: $count');

// Check conflicts
final conflicts = await syncManager.getUnresolvedConflictsCount();
print('Conflicts: $conflicts');

// Run sync manually
await syncManager.runSyncCycle(projectId: 'project-123');
```

### API Errors

- Check base URL in `initDependencies(baseUrl: '...')`
- Verify API endpoints match backend contract
- Check logs for detailed error messages

## Next Steps

1. Integrate sync cycle into app lifecycle (e.g., on app resume)
2. Add connectivity listener to pause sync when offline
3. Implement background sync with WorkManager/BackgroundFetch
4. Add UI for conflict resolution
5. Add sync progress indicators
6. Implement selective sync for specific projects

## Documentation

- Full documentation: [OFFLINE_FIRST_IMPLEMENTATION.md](OFFLINE_FIRST_IMPLEMENTATION.md)
- Database layer: [lib/core/db/README.md](lib/core/db/README.md)
- API client: [lib/core/network/api_client.dart](lib/core/network/api_client.dart)
- SyncManager: [lib/core/sync/sync_manager.dart](lib/core/sync/sync_manager.dart)
