import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reports.dart';

part 'report_dao.g.dart';

@DriftAccessor(tables: [Reports])
class ReportDao extends DatabaseAccessor<AppDatabase> with _$ReportDaoMixin {
  ReportDao(super.db);

  Future<void> insertReport(ReportsCompanion entity) async {
    await into(reports).insert(entity);
  }

  Future<void> updateReport(ReportsCompanion entity) async {
    await update(reports).replace(entity);
  }

  Future<void> updateReportServerFields(
    String localId,
    String serverId,
    int serverUpdatedAt,
  ) async {
    await (update(reports)..where((t) => t.id.equals(localId))).write(
      ReportsCompanion(
        serverId: Value(serverId),
        serverUpdatedAt: Value(serverUpdatedAt),
      ),
    );
  }

  Future<List<Report>> getReportsForProject(
    String projectId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (select(reports)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Report>> getPendingReports(String projectId) async {
    return (select(reports)..where(
          (t) => t.projectId.equals(projectId) & t.status.equals('DRAFT'),
        ))
        .get();
  }

  Stream<List<Report>> watchReportsForProject(String projectId) {
    return (select(reports)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> deleteReport(String id) async {
    return (delete(reports)..where((t) => t.id.equals(id))).go();
  }

  Future<Report?> getReportById(String id) async {
    return (select(reports)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
