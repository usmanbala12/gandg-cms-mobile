import 'package:drift/drift.dart';

class MediaFiles extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get localPath => text()(); // file path on device
  TextColumn get projectId => text()(); // FK to Projects.id
  TextColumn get parentType => text()(); // report/issue/etc.
  TextColumn get parentId => text()(); // local entity id

  // PENDING/SYNCING/SYNCED/ERROR
  TextColumn get uploadStatus =>
      text().withDefault(const Constant('PENDING'))();

  TextColumn get mime => text().nullable()(); // e.g., image/jpeg
  IntColumn get size => integer()(); // bytes
  IntColumn get createdAt => integer()();

  // Server-side fields
  TextColumn get serverId => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()(); // local thumbnail path

  @override
  Set<Column> get primaryKey => {id};
}
