import 'package:drift/drift.dart';

// Queue entry to drive sync. Project-scoped.
class SyncQueue extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get projectId => text()();
  TextColumn get entityType => text()(); // report/issue/media/etc.
  TextColumn get entityId => text()(); // local entity id
  TextColumn get action => text()(); // create/update/delete
  TextColumn get payload => text().nullable()(); // JSON as TEXT

  // Higher number = higher priority
  IntColumn get priority => integer().withDefault(const Constant(0))();

  // PENDING/IN_PROGRESS/FAILED/DONE/CONFLICT
  TextColumn get status => text().withDefault(const Constant('PENDING'))();

  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get lastAttemptAt => integer().nullable()(); // epoch ms
  TextColumn get errorMessage => text().nullable()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
