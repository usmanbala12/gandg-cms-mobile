import 'package:drift/drift.dart';

@DataClassName('UserTableData')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text()();
  TextColumn get role => text()();
  TextColumn get status => text()();
  BoolColumn get mfaEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
