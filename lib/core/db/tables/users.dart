import 'package:drift/drift.dart';

@DataClassName('UserTableData')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text()();
  TextColumn get role => text()(); // internal role name (roleName)
  TextColumn get roleId => text().nullable()();
  TextColumn get roleDisplayName => text().nullable()();
  BoolColumn get admin => boolean().withDefault(const Constant(false))();
  TextColumn get status => text()();
  BoolColumn get mfaEnabled => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
