import 'package:drift/drift.dart';

class Requests extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get projectId => text()(); // FK to Projects.id
  TextColumn get requestType => text().nullable()(); // Category/type of request
  TextColumn get title => text()();
  TextColumn get shortSummary => text().nullable()();
  TextColumn get description => text().nullable()();

  // PENDING/APPROVED/REJECTED/COMPLETED/CANCELLED
  TextColumn get status => text().withDefault(const Constant('PENDING'))();

  TextColumn get createdBy => text()(); // User ID
  TextColumn get assigneeId => text().nullable()();
  TextColumn get priority => text().nullable()(); // LOW/MEDIUM/HIGH/CRITICAL

  TextColumn get location => text().nullable()();
  IntColumn get dueDate => integer().nullable()(); // epoch ms

  IntColumn get createdAt => integer()(); // epoch ms
  IntColumn get updatedAt => integer()();

  // Server-side fields
  TextColumn get serverId => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()(); // epoch ms

  // Additional metadata as JSON
  TextColumn get meta => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
