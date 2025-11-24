import 'package:drift/drift.dart';

class Projects extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  // Optional text fields (JSON as TEXT)
  TextColumn get location => text().nullable()();
  TextColumn get metadata => text().nullable()();

  // Epoch milliseconds
  IntColumn get lastSynced => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
