import 'package:equatable/equatable.dart';

/// Entity representing the current sync status.
class SyncStatusEntity extends Equatable {
  final DateTime? lastFullSyncAt;
  final int pendingQueueCount;
  final int conflictCount;

  const SyncStatusEntity({
    this.lastFullSyncAt,
    required this.pendingQueueCount,
    required this.conflictCount,
  });

  @override
  List<Object?> get props => [lastFullSyncAt, pendingQueueCount, conflictCount];
}
