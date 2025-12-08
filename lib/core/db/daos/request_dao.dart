import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/requests.dart';

part 'request_dao.g.dart';

@DriftAccessor(tables: [Requests])
class RequestDao extends DatabaseAccessor<AppDatabase> with _$RequestDaoMixin {
  RequestDao(super.db);

  /// Insert or update a request (upsert)
  Future<void> insertRequest(RequestsCompanion request) async {
    await into(requests).insertOnConflictUpdate(request);
  }

  /// Update an existing request
  Future<void> updateRequest(RequestsCompanion request) async {
    await update(requests).replace(request);
  }

  /// Get all requests for a project, optionally filtered by status
  Future<List<Request>> getRequestsForProject(
    String projectId, {
    String? status,
  }) async {
    final query = select(requests)
      ..where((tbl) => tbl.projectId.equals(projectId));

    if (status != null && status.isNotEmpty) {
      query.where((tbl) => tbl.status.equals(status));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.get();
  }

  /// Watch requests for a project (reactive stream)
  Stream<List<Request>> watchRequestsForProject(
    String projectId, {
    String? status,
  }) {
    final query = select(requests)
      ..where((tbl) => tbl.projectId.equals(projectId));

    if (status != null && status.isNotEmpty) {
      query.where((tbl) => tbl.status.equals(status));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch();
  }

  /// Get requests for a specific user in a project
  Future<List<Request>> getRequestsForUser(
    String projectId,
    String userId, {
    String? status,
  }) async {
    final query = select(requests)
      ..where(
        (tbl) => tbl.projectId.equals(projectId) & tbl.createdBy.equals(userId),
      );

    if (status != null && status.isNotEmpty) {
      query.where((tbl) => tbl.status.equals(status));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.get();
  }

  /// Watch requests for a specific user in a project
  Stream<List<Request>> watchRequestsForUser(
    String projectId,
    String userId, {
    String? status,
  }) {
    final query = select(requests)
      ..where(
        (tbl) => tbl.projectId.equals(projectId) & tbl.createdBy.equals(userId),
      );

    if (status != null && status.isNotEmpty) {
      query.where((tbl) => tbl.status.equals(status));
    }

    query.orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);

    return query.watch();
  }

  /// Get a request by local ID
  Future<Request?> getByLocalId(String id) async {
    return (select(
      requests,
    )..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get a request by server ID
  Future<Request?> getByServerId(String serverId) async {
    return (select(
      requests,
    )..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  /// Delete a request by local ID
  Future<void> deleteRequest(String id) async {
    await (delete(requests)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Update server fields after successful sync
  Future<void> updateRequestServerFields(
    String localId,
    String serverId,
    int serverUpdatedAt,
  ) async {
    await (update(requests)..where((tbl) => tbl.id.equals(localId))).write(
      RequestsCompanion(
        serverId: Value(serverId),
        serverUpdatedAt: Value(serverUpdatedAt),
      ),
    );
  }
}
