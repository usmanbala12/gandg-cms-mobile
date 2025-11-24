import 'package:drift/drift.dart';

class SyncConflicts extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entityType => text()(); // report/issue/media/etc.
  TextColumn get entityId => text()(); // local entity id
  TextColumn get localPayload => text()(); // JSON as TEXT
  TextColumn get serverPayload => text()(); // JSON as TEXT
  IntColumn get detectedAt => integer()(); // epoch ms

  // 0 = unresolved, 1 = resolved
  IntColumn get resolved => integer().withDefault(const Constant(0))();

  // Resolution strategy or choice (e.g., 'local', 'server', 'merged')
  TextColumn get resolution => text().nullable()();

  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
