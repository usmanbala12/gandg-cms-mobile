import 'package:drift/drift.dart';

// Key-value store for app metadata (last sync times, active project, etc.)
class Meta extends Table {
  TextColumn get key => text()(); // e.g., 'last_sync_projectId', 'active_project_id'
  TextColumn get value => text()(); // JSON or plain text

  @override
  Set<Column> get primaryKey => {key};
}
