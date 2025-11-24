import 'package:drift/drift.dart';

class Issues extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get projectId => text()(); // FK to Projects.id
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text().nullable()(); // LOW/MEDIUM/HIGH/CRITICAL
  TextColumn get assigneeId => text().nullable()();
  TextColumn get status => text().nullable()(); // OPEN/IN_PROGRESS/CLOSED/etc.
  TextColumn get category => text().nullable()();
  TextColumn get location => text().nullable()(); // JSON as TEXT
  IntColumn get dueDate => integer().nullable()(); // epoch ms

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // Server-side fields
  TextColumn get serverId => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}
