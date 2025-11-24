import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_queue.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue(SyncQueueCompanion entry) async {
    await into(syncQueue).insert(entry);
  }

  Future<int> pendingCount() async {
    final query = selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()])
      ..where(syncQueue.status.equals('PENDING'));
    final result = await query
        .map((row) => row.read(syncQueue.id.count()))
        .getSingle();
    return result ?? 0;
  }

  Future<List<SyncQueueData>> getPending(int limit) {
    final query =
        (select(syncQueue)
              ..where((t) => t.status.equals('PENDING'))
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.priority,
                  mode: OrderingMode.desc,
                ),
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.asc,
                ),
              ])
              ..limit(limit))
            .get();
    return query;
  }

  // Transactional claimBatch implementation.
  // 1) Select rows in order with limit N where status=PENDING
  // 2) Update them to IN_PROGRESS, set last_attempt_at=now, attempts=attempts+1
  // 3) Return the claimed rows
  Future<List<SyncQueueData>> claimBatch(int limit) async {
    if (limit <= 0) return <SyncQueueData>[];

    return transaction(() async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final rows = await customSelect(
        '''
WITH candidates AS (
  SELECT id FROM sync_queue
  WHERE status = ?
  ORDER BY priority DESC, created_at ASC
  LIMIT ?
)
UPDATE sync_queue
SET status = ?,
    last_attempt_at = ?,
    attempts = attempts + 1
WHERE id IN (SELECT id FROM candidates)
  AND status = ?
RETURNING *;
''',
        variables: [
          const Variable<String>('PENDING'),
          Variable.withInt(limit),
          const Variable<String>('IN_PROGRESS'),
          Variable.withInt(nowMs),
          const Variable<String>('PENDING'),
        ],
        readsFrom: {syncQueue},
      ).map((row) => syncQueue.map(row.data)).get();

      // Ensure ordering consistency when returning rows to callers.
      rows.sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.createdAt.compareTo(b.createdAt);
      });

      return rows;
    });
  }

  Future<void> markDone(String id) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      const SyncQueueCompanion(status: Value('DONE')),
    );
  }

  Future<void> markFailed(String id, String error) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('FAILED'),
        errorMessage: Value(error),
      ),
    );
  }

  Future<void> markConflict(String id, {String? error}) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('CONFLICT'),
        errorMessage: error == null ? const Value.absent() : Value(error),
      ),
    );
  }

  Future<void> reenqueue(String id) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      const SyncQueueCompanion(status: Value('PENDING')),
    );
  }
}
