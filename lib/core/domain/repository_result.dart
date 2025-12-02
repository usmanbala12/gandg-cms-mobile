import 'package:equatable/equatable.dart';

/// Enum representing the source of data.
enum DataSource {
  /// Data fetched from remote API server.
  remote,

  /// Data read from local database (offline or fallback).
  local,

  /// Error occurred, no data available.
  error,
}

/// Generic wrapper class for repository results with metadata about data source.
///
/// This class provides a consistent pattern for handling remote-first data fetching
/// with offline fallback across all features.
class RepositoryResult<T> extends Equatable {
  /// The data returned from the repository.
  final T data;

  /// Source of the data (remote, local, or error).
  final DataSource source;

  /// Error message if source is error, or warning message for other sources.
  final String? message;

  /// Timestamp of last successful sync (if available).
  final int? lastSyncedAt;

  const RepositoryResult({
    required this.data,
    required this.source,
    this.message,
    this.lastSyncedAt,
  });

  /// Factory for successful remote fetch.
  factory RepositoryResult.remote(T data, {int? lastSyncedAt}) {
    return RepositoryResult(
      data: data,
      source: DataSource.remote,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Factory for local/cached data.
  factory RepositoryResult.local(T data, {String? message, int? lastSyncedAt}) {
    return RepositoryResult(
      data: data,
      source: DataSource.local,
      message: message,
      lastSyncedAt: lastSyncedAt,
    );
  }

  /// Factory for error state with empty data.
  /// Note: T must have a sensible default value (e.g., empty list, null object).
  factory RepositoryResult.error(T emptyData, String errorMessage) {
    return RepositoryResult(
      data: emptyData,
      source: DataSource.error,
      message: errorMessage,
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

  /// Check if this result is from local cache.
  bool get isLocal => source == DataSource.local;

  @override
  List<Object?> get props => [data, source, message, lastSyncedAt];

  @override
  String toString() {
    return 'RepositoryResult(source: $source, '
        'message: $message, lastSync: $lastSyncedAt)';
  }

  /// Create a copy with updated fields.
  RepositoryResult<T> copyWith({
    T? data,
    DataSource? source,
    String? message,
    int? lastSyncedAt,
  }) {
    return RepositoryResult(
      data: data ?? this.data,
      source: source ?? this.source,
      message: message ?? this.message,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
