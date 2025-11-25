# Reports Feature

This feature allows users to create, view, and sync reports for projects.

## Architecture

- **Domain Layer**: `ReportEntity`
- **Data Layer**: `ReportRepositoryImpl`, `ReportRemoteDataSource`, `ReportDao`, `MediaDao`
- **Presentation Layer**: `ReportsListPage`, `ReportCreatePage`, `ReportDetailPage`, `ConflictResolverPage`

## Key Components

### ReportRepository
Handles data operations for reports. It uses `ReportDao` for local storage and `ReportRemoteDataSource` for API calls. It implements an offline-first strategy where reports are created locally and then synced to the server.

### SyncManager
Orchestrates the sync process. It handles:
- Uploading pending reports and media.
- Downloading changes from the server.
- Detecting and resolving conflicts.

### Conflict Resolution
Conflicts are detected during sync (e.g., 409 Conflict response). Users can resolve conflicts via the `ConflictResolverPage`, choosing between the server version or the local version.

## Usage

1.  **View Reports**: Navigate to `ReportsListPage` with a `projectId`.
2.  **Create Report**: Click the "+" button to open `ReportCreatePage`. Select a template and attach media.
3.  **Sync**: Sync happens automatically in the background or can be triggered manually.
4.  **Resolve Conflicts**: If conflicts occur, they appear in the `ConflictResolverPage`.
