# Database Schema & Drift Setup Guide

**Framework**: Drift (SQLite)  
**Purpose**: Local offline-first data storage with automatic sync queue management

---

## Overview

Drift is a type-safe, reactive database library for Flutter. It provides:
- Type-safe SQL queries
- Automatic code generation
- Reactive streams for real-time updates
- Migration support
- Transaction support

---

## Project Structure for Database

```
lib/
├── core/
│   └── database/
│       ├── app_database.dart          # Main database class
│       ├── tables/
│       │   ├── users_table.dart
│       │   ├── projects_table.dart
│       │   ├── reports_table.dart
│       │   ├── issues_table.dart
│       │   ├── requests_table.dart
│       │   ├── media_table.dart
│       │   ├── notifications_table.dart
│       │   └── sync_queue_table.dart
│       └── daos/
│           ├── user_dao.dart
│           ├── project_dao.dart
│           ├── report_dao.dart
│           ├── issue_dao.dart
│           ├── request_dao.dart
│           ├── media_dao.dart
│           ├── notification_dao.dart
│           └── sync_queue_dao.dart
```

---

## Step 1: Create Database Tables

### 1.1 Users Table

**File**: `lib/core/database/tables/users_table.dart`

```dart
import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 1.2 Projects Table

**File**: `lib/core/database/tables/projects_table.dart`

```dart
import 'package:drift/drift.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()(); // active, completed, archived
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 1.3 User Projects Table (Many-to-Many)

**File**: `lib/core/database/tables/user_projects_table.dart`

```dart
import 'package:drift/drift.dart';

class UserProjects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get projectId => text()();
  TextColumn get role => text()(); // admin, manager, member
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, projectId},
  ];

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [userId],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [projectId],
      foreignTable: 'projects',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.4 Reports Table

**File**: `lib/core/database/tables/reports_table.dart`

```dart
import 'package:drift/drift.dart';

class Reports extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()(); // draft, submitted, approved, rejected
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))(); // synced, pending, failed

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [projectId],
      foreignTable: 'projects',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [createdBy],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.5 Issues Table

**File**: `lib/core/database/tables/issues_table.dart`

```dart
import 'package:drift/drift.dart';

class Issues extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text()(); // open, in_progress, closed, resolved
  TextColumn get priority => text()(); // low, medium, high, critical
  TextColumn get assignedTo => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [projectId],
      foreignTable: 'projects',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [assignedTo],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [createdBy],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.6 Requests Table

**File**: `lib/core/database/tables/requests_table.dart`

```dart
import 'package:drift/drift.dart';

class Requests extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // fund, material, equipment, other
  TextColumn get status => text()(); // pending, approved, rejected
  TextColumn get requestedBy => text()();
  TextColumn get approvedBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [projectId],
      foreignTable: 'projects',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [requestedBy],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
    ForeignKeyConstraint(
      columns: [approvedBy],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.7 Media Table

**File**: `lib/core/database/tables/media_table.dart`

```dart
import 'package:drift/drift.dart';

class Media extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().nullable()();
  TextColumn get mimeType => text().nullable()();
  TextColumn get uploadedBy => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [uploadedBy],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.8 Media Associations Table

**File**: `lib/core/database/tables/media_associations_table.dart`

```dart
import 'package:drift/drift.dart';

class MediaAssociations extends Table {
  TextColumn get id => text()();
  TextColumn get mediaId => text()();
  TextColumn get entityType => text()(); // report, issue, request
  TextColumn get entityId => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mediaId, entityType, entityId},
  ];

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [mediaId],
      foreignTable: 'media',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.9 Notifications Table

**File**: `lib/core/database/tables/notifications_table.dart`

```dart
import 'package:drift/drift.dart';

class Notifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get body => text().nullable()();
  TextColumn get type => text()(); // issue_assigned, report_approved, request_status_changed
  TextColumn get entityType => text().nullable()();
  TextColumn get entityId => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<ForeignKeyConstraint> get foreignKeys => [
    ForeignKeyConstraint(
      columns: [userId],
      foreignTable: 'users',
      foreignColumns: ['id'],
    ),
  ];
}
```

### 1.10 Sync Queue Table

**File**: `lib/core/database/tables/sync_queue_table.dart`

```dart
import 'package:drift/drift.dart';

class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // report, issue, request, media
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON payload
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 1.11 Sync History Table

**File**: `lib/core/database/tables/sync_history_table.dart`

```dart
import 'package:drift/drift.dart';

class SyncHistory extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get status => text()(); // success, failed
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## Step 2: Create Main Database Class

**File**: `lib/core/database/app_database.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/users_table.dart';
import 'tables/projects_table.dart';
import 'tables/user_projects_table.dart';
import 'tables/reports_table.dart';
import 'tables/issues_table.dart';
import 'tables/requests_table.dart';
import 'tables/media_table.dart';
import 'tables/media_associations_table.dart';
import 'tables/notifications_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/sync_history_table.dart';
import 'daos/user_dao.dart';
import 'daos/project_dao.dart';
import 'daos/report_dao.dart';
import 'daos/issue_dao.dart';
import 'daos/request_dao.dart';
import 'daos/media_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Projects,
    UserProjects,
    Reports,
    Issues,
    Requests,
    Media,
    MediaAssociations,
    Notifications,
    SyncQueue,
    SyncHistory,
  ],
  daos: [
    UserDao,
    ProjectDao,
    ReportDao,
    IssueDao,
    RequestDao,
    MediaDao,
    NotificationDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) {
        return m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'field_link_db');
  }
}
```

---

## Step 3: Create DAOs (Data Access Objects)

### 3.1 User DAO

**File**: `lib/core/database/daos/user_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/users_table.dart';
import '../app_database.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> {
  UserDao(AppDatabase db) : super(db);

  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<void> updateUser(UsersCompanion user) {
    return update(users).replace(user);
  }

  Future<void> deleteUser(String id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }
}
```

### 3.2 Project DAO

**File**: `lib/core/database/daos/project_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/projects_table.dart';
import '../app_database.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> {
  ProjectDao(AppDatabase db) : super(db);

  Future<Project?> getProjectById(String id) {
    return (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<List<Project>> getAllProjects() {
    return select(projects).get();
  }

  Future<void> insertProject(ProjectsCompanion project) {
    return into(projects).insert(project);
  }

  Future<void> updateProject(ProjectsCompanion project) {
    return update(projects).replace(project);
  }

  Future<void> deleteProject(String id) {
    return (delete(projects)..where((p) => p.id.equals(id))).go();
  }
}
```

### 3.3 Report DAO

**File**: `lib/core/database/daos/report_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/reports_table.dart';
import '../app_database.dart';

part 'report_dao.g.dart';

@DriftAccessor(tables: [Reports])
class ReportDao extends DatabaseAccessor<AppDatabase> {
  ReportDao(AppDatabase db) : super(db);

  Future<Report?> getReportById(String id) {
    return (select(reports)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<List<Report>> getReportsByProject(String projectId) {
    return (select(reports)..where((r) => r.projectId.equals(projectId))).get();
  }

  Future<List<Report>> getPendingSyncReports() {
    return (select(reports)..where((r) => r.syncStatus.equals('pending'))).get();
  }

  Future<void> insertReport(ReportsCompanion report) {
    return into(reports).insert(report);
  }

  Future<void> updateReport(ReportsCompanion report) {
    return update(reports).replace(report);
  }

  Future<void> deleteReport(String id) {
    return (delete(reports)..where((r) => r.id.equals(id))).go();
  }
}
```

### 3.4 Issue DAO

**File**: `lib/core/database/daos/issue_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/issues_table.dart';
import '../app_database.dart';

part 'issue_dao.g.dart';

@DriftAccessor(tables: [Issues])
class IssueDao extends DatabaseAccessor<AppDatabase> {
  IssueDao(AppDatabase db) : super(db);

  Future<Issue?> getIssueById(String id) {
    return (select(issues)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  Future<List<Issue>> getIssuesByProject(String projectId) {
    return (select(issues)..where((i) => i.projectId.equals(projectId))).get();
  }

  Future<List<Issue>> getIssuesByStatus(String projectId, String status) {
    return (select(issues)
          ..where((i) => i.projectId.equals(projectId) & i.status.equals(status)))
        .get();
  }

  Future<void> insertIssue(IssuesCompanion issue) {
    return into(issues).insert(issue);
  }

  Future<void> updateIssue(IssuesCompanion issue) {
    return update(issues).replace(issue);
  }

  Future<void> deleteIssue(String id) {
    return (delete(issues)..where((i) => i.id.equals(id))).go();
  }
}
```

### 3.5 Request DAO

**File**: `lib/core/database/daos/request_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/requests_table.dart';
import '../app_database.dart';

part 'request_dao.g.dart';

@DriftAccessor(tables: [Requests])
class RequestDao extends DatabaseAccessor<AppDatabase> {
  RequestDao(AppDatabase db) : super(db);

  Future<Request?> getRequestById(String id) {
    return (select(requests)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<List<Request>> getRequestsByProject(String projectId) {
    return (select(requests)..where((r) => r.projectId.equals(projectId))).get();
  }

  Future<List<Request>> getPendingRequests(String projectId) {
    return (select(requests)
          ..where((r) => r.projectId.equals(projectId) & r.status.equals('pending')))
        .get();
  }

  Future<void> insertRequest(RequestsCompanion request) {
    return into(requests).insert(request);
  }

  Future<void> updateRequest(RequestsCompanion request) {
    return update(requests).replace(request);
  }

  Future<void> deleteRequest(String id) {
    return (delete(requests)..where((r) => r.id.equals(id))).go();
  }
}
```

### 3.6 Media DAO

**File**: `lib/core/database/daos/media_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/media_table.dart';
import '../app_database.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> {
  MediaDao(AppDatabase db) : super(db);

  Future<Medium?> getMediaById(String id) {
    return (select(media)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  Future<List<Medium>> getAllMedia() {
    return select(media).get();
  }

  Future<List<Medium>> getPendingSyncMedia() {
    return (select(media)..where((m) => m.syncStatus.equals('pending'))).get();
  }

  Future<void> insertMedia(MediaCompanion mediaItem) {
    return into(media).insert(mediaItem);
  }

  Future<void> updateMedia(MediaCompanion mediaItem) {
    return update(media).replace(mediaItem);
  }

  Future<void> deleteMedia(String id) {
    return (delete(media)..where((m) => m.id.equals(id))).go();
  }
}
```

### 3.7 Notification DAO

**File**: `lib/core/database/daos/notification_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/notifications_table.dart';
import '../app_database.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase> {
  NotificationDao(AppDatabase db) : super(db);

  Future<Notification?> getNotificationById(String id) {
    return (select(notifications)..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  Future<List<Notification>> getNotificationsByUser(String userId) {
    return (select(notifications)..where((n) => n.userId.equals(userId))).get();
  }

  Future<List<Notification>> getUnreadNotifications(String userId) {
    return (select(notifications)
          ..where((n) => n.userId.equals(userId) & n.isRead.equals(false)))
        .get();
  }

  Future<void> insertNotification(NotificationsCompanion notification) {
    return into(notifications).insert(notification);
  }

  Future<void> markAsRead(String id) {
    return (update(notifications)..where((n) => n.id.equals(id)))
        .write(const NotificationsCompanion(isRead: Value(true)));
  }

  Future<void> deleteNotification(String id) {
    return (delete(notifications)..where((n) => n.id.equals(id))).go();
  }
}
```

### 3.8 Sync Queue DAO

**File**: `lib/core/database/daos/sync_queue_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../tables/sync_queue_table.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase> {
  SyncQueueDao(AppDatabase db) : super(db);

  Future<SyncQueueData?> getQueueItemById(String id) {
    return (select(syncQueue)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<SyncQueueData>> getAllQueueItems() {
    return select(syncQueue).get();
  }

  Future<List<SyncQueueData>> getQueueItemsByEntity(String entityType, String entityId) {
    return (select(syncQueue)
          ..where((s) => s.entityType.equals(entityType) & s.entityId.equals(entityId)))
        .get();
  }

  Future<void> addToQueue(SyncQueueCompanion item) {
    return into(syncQueue).insert(item);
  }

  Future<void> updateQueueItem(SyncQueueCompanion item) {
    return update(syncQueue).replace(item);
  }

  Future<void> removeFromQueue(String id) {
    return (delete(syncQueue)..where((s) => s.id.equals(id))).go();
  }

  Future<void> incrementRetryCount(String id) {
    return (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value((select(syncQueue)..where((s) => s.id.equals(id)))
            .map((s) => s.retryCount)
            .first),
      ),
    );
  }
}
```

---

## Step 4: Generate Drift Code

After creating all tables and DAOs, run:

```bash
flutter pub run build_runner build
```

This generates:
- `app_database.g.dart` - Main database implementation
- `*_dao.g.dart` - DAO implementations
- Type-safe query builders

---

## Step 5: Register Database in DI Container

**File**: `lib/core/di/injection_container.dart` (Update)

```dart
import 'package:field_link/core/database/app_database.dart';

Future<void> init() async {
  // ... existing code ...

  // Database
  final database = AppDatabase();
  sl.registerSingleton<AppDatabase>(database);

  // DAOs
  sl.registerSingleton(database.userDao);
  sl.registerSingleton(database.projectDao);
  sl.registerSingleton(database.reportDao);
  sl.registerSingleton(database.issueDao);
  sl.registerSingleton(database.requestDao);
  sl.registerSingleton(database.mediaDao);
  sl.registerSingleton(database.notificationDao);
  sl.registerSingleton(database.syncQueueDao);
}
```

---

## Usage Examples

### Insert User

```dart
final userDao = sl<UserDao>();
await userDao.insertUser(
  UsersCompanion(
    id: const Value('user_123'),
    email: const Value('user@example.com'),
    name: const Value('John Doe'),
  ),
);
```

### Query Reports by Project

```dart
final reportDao = sl<ReportDao>();
final reports = await reportDao.getReportsByProject('project_123');
```

### Watch for Changes (Reactive)

```dart
final reportDao = sl<ReportDao>();
reportDao.getReportsByProject('project_123').watch().listen((reports) {
  // UI updates automatically when data changes
});
```

### Add to Sync Queue

```dart
final syncQueueDao = sl<SyncQueueDao>();
await syncQueueDao.addToQueue(
  SyncQueueCompanion(
    id: const Value('sync_123'),
    entityType: const Value('report'),
    entityId: const Value('report_456'),
    operation: const Value('create'),
    payload: const Value('{"title": "New Report"}'),
  ),
);
```

---

## Important Notes

- **Always use Value()** when inserting/updating to wrap values
- **Use watch()** for reactive queries that update UI automatically
- **Filter by project_id** in all queries to maintain project scoping
- **Handle sync_status** to track offline changes
- **Implement proper error handling** for database operations
- **Test migrations** thoroughly before deploying

---

## Next Steps

1. Run `flutter pub run build_runner build` to generate code
2. Create repository implementations that use DAOs
3. Implement sync logic to handle pending items
4. Add conflict resolution for sync conflicts
5. Create UI screens that display data from database

---

**Last Updated**: [Current Date]
**Status**: Ready for Implementation
