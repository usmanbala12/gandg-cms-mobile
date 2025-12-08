import 'package:drift/drift.dart';

/// Notifications table - provision for future implementation
/// This table is created in the database but DAO/repository/UI will be implemented later
class Notifications extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get userId => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  // INFO/WARNING/ERROR/SUCCESS
  TextColumn get type => text().withDefault(const Constant('INFO'))();

  IntColumn get isRead =>
      integer().withDefault(const Constant(0))(); // 0 = unread, 1 = read
  IntColumn get createdAt => integer()(); // epoch ms

  // Server-side fields
  TextColumn get serverId => text().nullable()();

  // Additional metadata as JSON (e.g., deep link data)
  TextColumn get meta => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
