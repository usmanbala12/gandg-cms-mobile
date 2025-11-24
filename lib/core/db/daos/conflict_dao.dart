import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_conflicts.dart';

part 'conflict_dao.g.dart';

@DriftAccessor(tables: [SyncConflicts])
class ConflictDao extends DatabaseAccessor<AppDatabase>
    with _$ConflictDaoMixin {
  ConflictDao(super.db);

  Future<void> insertConflict(SyncConflictsCompanion entity) async {
    await into(syncConflicts).insert(entity);
  }

  Future<List<SyncConflict>> getUnresolvedConflicts() async {
    return (select(syncConflicts)
          ..where((t) => t.resolved.equals(0))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.detectedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Future<void> markResolved(
    String conflictId, {
    required String resolution,
  }) async {
    await (update(syncConflicts)..where((t) => t.id.equals(conflictId))).write(
      SyncConflictsCompanion(
        resolved: const Value(1),
        resolution: Value(resolution),
      ),
    );
  }

  Future<int> deleteConflict(String id) async {
    return (delete(syncConflicts)..where((t) => t.id.equals(id))).go();
  }

  Future<SyncConflict?> getConflictById(String id) async {
    return (select(
      syncConflicts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
