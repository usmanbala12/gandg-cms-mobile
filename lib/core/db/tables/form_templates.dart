import 'package:drift/drift.dart';

class FormTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get schema => text()(); // JSON string
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get lastSynced => integer()(); // Milliseconds since epoch

  @override
  Set<Column> get primaryKey => {id};
}
