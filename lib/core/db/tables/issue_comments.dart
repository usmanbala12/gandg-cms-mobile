import 'package:drift/drift.dart';

class IssueComments extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get issueLocalId => text()(); // FK to Issues.id
  TextColumn get authorId => text()();
  TextColumn get body => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  // Server-side fields
  TextColumn get serverId => text().nullable()();
  IntColumn get serverCreatedAt => integer().nullable()(); // epoch ms
  IntColumn get serverUpdatedAt => integer().nullable()(); // epoch ms

  // Sync status
  TextColumn get status =>
      text().withDefault(const Constant('PENDING'))(); // PENDING/SYNCED/ERROR

  @override
  Set<Column> get primaryKey => {id};
}
