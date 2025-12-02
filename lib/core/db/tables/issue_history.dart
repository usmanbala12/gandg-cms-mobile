import 'package:drift/drift.dart';

class IssueHistory extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get issueId => text()(); // FK to Issues.id
  TextColumn get action => text()(); // create, update, status, assign, comment
  TextColumn get field => text().nullable()(); // field name changed
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get authorId => text()();
  IntColumn get timestamp => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
