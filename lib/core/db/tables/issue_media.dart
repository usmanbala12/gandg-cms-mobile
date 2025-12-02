import 'package:drift/drift.dart';

class IssueMedia extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get issueId => text()(); // FK to Issues.id
  TextColumn get localPath => text()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();

  // Server fields
  TextColumn get serverId => text().nullable()();
  TextColumn get serverUrl => text().nullable()();

  // Sync status
  TextColumn get uploadStatus => text().withDefault(
    const Constant('PENDING'),
  )(); // PENDING, UPLOADING, DONE, ERROR

  @override
  Set<Column> get primaryKey => {id};
}
