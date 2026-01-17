import '../../../../core/domain/repository_result.dart';
import '../entities/user_profile_entity.dart';
import '../entities/sync_status_entity.dart';
import '../entities/storage_stats_entity.dart';

/// Abstract repository for profile-related operations.
abstract class ProfileRepository {
  /// Get user profile.
  /// If [forceRemote] is true, always fetch from server.
  /// Otherwise, use remote-first strategy (fetch from server when online,
  /// fallback to local when offline).
  Future<RepositoryResult<UserProfileEntity>> getUserProfile({
    bool forceRemote = false,
  });

  /// Watch user profile changes as a stream.
  Stream<UserProfileEntity?> watchUserProfile();



  /// Watch sync status as a stream.
  Stream<SyncStatusEntity> watchSyncStatus();

  /// Trigger a manual sync cycle.
  Future<void> syncNow();

  /// Get storage statistics.
  Future<StorageStatsEntity> getStorageStats();

  /// Clear old cached data (older than 30 days).
  Future<void> clearOldCache();

  /// Clear media cache (downloaded files).
  Future<void> clearMediaCache();
}
