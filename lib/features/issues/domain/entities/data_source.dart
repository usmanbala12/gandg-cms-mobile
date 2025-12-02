import 'package:equatable/equatable.dart';
import 'issue_entity.dart';

/// Enum representing the source of data for issues.
enum DataSource {
  /// Data fetched from remote API server.
  remote,

  /// Data read from local database (offline or fallback).
  local,

  /// Error occurred, no data available.
  error,
}

/// Wrapper class for issue list results with metadata about data source.
class IssueListResult extends Equatable {
  /// List of issues returned.
  final List<IssueEntity> issues;

  /// Source of the data (remote, local, or error).
  final DataSource source;

  /// Error message if source is error, or warning message for other sources.
  final String? errorMessage;

  /// Timestamp of last successful sync (if available).
  final int? lastSyncedAt;

  const IssueListResult({
    required this.issues,
    required this.source,
    this.errorMessage,
    this.lastSyncedAt,
  });

  /// Factory for successful remote fetch.
  factory IssueListResult.remote(
    List<IssueEntity> issues, {
    int? lastSyncedAt,
  }) {
    return IssueListResult(
      issues: issues,
      source: DataSource.remote,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Factory for local/cached data.
  factory IssueListResult.local(
    List<IssueEntity> issues, {
    String? message,
    int? lastSyncedAt,
  }) {
    return IssueListResult(
      issues: issues,
      source: DataSource.local,
      errorMessage: message,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Factory for error state.
  factory IssueListResult.error(String errorMessage) {
    return IssueListResult(
      issues: const [],
      source: DataSource.error,
      errorMessage: errorMessage,
    );
  }

  /// Check if data is stale (older than 5 minutes).
  bool get isStale {
    if (lastSyncedAt == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    final fiveMinutes = 5 * 60 * 1000;
    return (now - lastSyncedAt!) > fiveMinutes;
  }

  /// Check if this result represents fresh remote data.
  bool get isFresh => source == DataSource.remote;

  /// Check if this result represents an error state.
  bool get hasError => source == DataSource.error;

  @override
  List<Object?> get props => [issues, source, errorMessage, lastSyncedAt];

  @override
  String toString() {
    return 'IssueListResult(source: $source, count: ${issues.length}, '
        'error: $errorMessage, lastSync: $lastSyncedAt)';
  }
}
