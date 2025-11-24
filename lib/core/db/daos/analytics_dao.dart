import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/project_analytics.dart';

part 'analytics_dao.g.dart';

@DriftAccessor(tables: [ProjectAnalytics])
class AnalyticsDao extends DatabaseAccessor<AppDatabase>
    with _$AnalyticsDaoMixin {
  AnalyticsDao(super.db);

  Future<void> upsertAnalytics(ProjectAnalyticsCompanion entity) async {
    await into(projectAnalytics).insertOnConflictUpdate(entity);
  }

  Future<ProjectAnalytic?> getAnalyticsForProject(String projectId) async {
    return (select(
      projectAnalytics,
    )..where((tbl) => tbl.projectId.equals(projectId))).getSingleOrNull();
  }

  Stream<ProjectAnalytic?> watchAnalyticsForProject(String projectId) {
    return (select(
      projectAnalytics,
    )..where((tbl) => tbl.projectId.equals(projectId))).watchSingleOrNull();
  }

  Future<int> deleteAnalyticsForProject(String projectId) async {
    return (delete(
      projectAnalytics,
    )..where((tbl) => tbl.projectId.equals(projectId))).go();
  }
}
