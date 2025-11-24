import 'package:drift/drift.dart';

class ProjectAnalytics extends Table {
  TextColumn get projectId => text()(); // FK to Projects.id
  IntColumn get lastSynced => integer().nullable()(); // epoch ms
  IntColumn get reportsCount => integer().withDefault(const Constant(0))();
  IntColumn get requestsPending => integer().withDefault(const Constant(0))();
  IntColumn get openIssues => integer().withDefault(const Constant(0))();

  // JSON as TEXT
  TextColumn get reportsTimeseries => text().nullable()();
  TextColumn get requestsByStatus => text().nullable()();
  TextColumn get recentActivity => text().nullable()();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {projectId};
}
