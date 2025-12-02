import 'dart:convert';
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reports.dart';
import '../tables/form_templates.dart';

part 'report_dao.g.dart';

@DriftAccessor(tables: [Reports, FormTemplates])
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

  Future<void> updateReportMedia(String id, List<String> mediaIds) async {
    await (update(reports)..where((t) => t.id.equals(id))).write(
      ReportsCompanion(mediaIds: Value(jsonEncode(mediaIds))),
    );
  }

  Future<List<Report>> getReports({
    String? projectId,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = select(reports);
    if (projectId != null) {
      query.where((t) => t.projectId.equals(projectId));
    }
    query
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<List<Report>> getPendingReports(String projectId) async {
    return (select(reports)..where(
          (t) => t.projectId.equals(projectId) & t.status.equals('DRAFT'),
        ))
        .get();
  }

  Stream<List<Report>> watchReports({String? projectId}) {
    final query = select(reports);
    if (projectId != null) {
      query.where((t) => t.projectId.equals(projectId));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return query.watch();
  }

  Future<void> deleteReport(String id) async {
    await (delete(reports)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> upsertTemplates(List<FormTemplatesCompanion> templates) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(formTemplates, templates);
    });
  }

  Future<List<FormTemplate>> getTemplates() => select(formTemplates).get();

  Future<FormTemplate?> getTemplateById(String id) {
    return (select(
      formTemplates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Report?> getReportById(String id) async {
    return (select(reports)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
