import 'package:drift/drift.dart';

class Reports extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get projectId => text()(); // FK to Projects.id
  TextColumn get formTemplateId => text().nullable()();
  IntColumn get reportDate => integer()(); // epoch ms
  TextColumn get submissionData => text().nullable()(); // JSON as TEXT
  TextColumn get location => text().nullable()(); // JSON as TEXT (lat/lng)
  TextColumn get mediaIds => text().nullable()(); // JSON array as TEXT

  // DRAFT/SUBMITTED/SYNCED/ERROR
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  // Server-side fields
  TextColumn get serverId => text().nullable()();
  IntColumn get serverUpdatedAt => integer().nullable()(); // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}
