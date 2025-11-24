import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/projects.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Future<void> upsertProject(ProjectsCompanion entity) async {
    await into(projects).insertOnConflictUpdate(entity);
  }

  Future<List<Project>> getProjects() => select(projects).get();

  Stream<List<Project>> watchAllProjects() => select(projects).watch();

  Future<Project?> getProjectById(String id) async {
    return (select(
      projects,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> deleteProject(String id) async {
    return (delete(projects)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> clearAll() => delete(projects).go();
}
