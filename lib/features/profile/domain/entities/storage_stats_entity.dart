import 'package:equatable/equatable.dart';

/// Entity representing storage statistics.
class StorageStatsEntity extends Equatable {
  final int dbSizeBytes;
  final int mediaSizeBytes;
  final Map<String, int> recordsByTable;

  const StorageStatsEntity({
    required this.dbSizeBytes,
    required this.mediaSizeBytes,
    required this.recordsByTable,
  });

  /// Get total storage in bytes.
  int get totalBytes => dbSizeBytes + mediaSizeBytes;

  /// Get database size in megabytes.
  double get dbSizeMB => dbSizeBytes / (1024 * 1024);

  /// Get media size in megabytes.
  double get mediaSizeMB => mediaSizeBytes / (1024 * 1024);

  /// Get total size in megabytes.
  double get totalSizeMB => totalBytes / (1024 * 1024);

  @override
  List<Object?> get props => [dbSizeBytes, mediaSizeBytes, recordsByTable];
}
