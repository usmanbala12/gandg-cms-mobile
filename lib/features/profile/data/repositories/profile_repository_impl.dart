import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/conflict_dao.dart';
import '../../../../core/db/daos/media_dao.dart';
import '../../../../core/db/daos/meta_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/db/daos/user_dao.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/storage_stats_entity.dart';
import '../../domain/entities/sync_status_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final SyncManager syncManager;
  final SyncQueueDao syncQueueDao;
  final ConflictDao conflictDao;
  final MetaDao metaDao;
  final MediaDao mediaDao;
  final UserDao userDao;
  final AppDatabase db;
  final Logger logger;

  static const String _preferencesKey = 'notification_preferences';
  static const String _lastSyncKey = 'last_full_sync';

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
    required this.syncManager,
    required this.syncQueueDao,
    required this.conflictDao,
    required this.metaDao,
    required this.mediaDao,
    required this.userDao,
    required this.db,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Future<RepositoryResult<UserProfileEntity>> getUserProfile({
    bool forceRemote = false,
  }) async {
    // User profile comes from login response stored in UserDao.
    // No remote /me endpoint call is needed.
    logger.d('getUserProfile: Reading user from local DB (UserDao)');

    try {
      final userTableData = await userDao.getCurrentUser();

      if (userTableData != null) {
        final profile = UserProfileModel.fromDrift(userTableData);
        logger.i('Successfully loaded user profile: ${profile.fullName}');
        return RepositoryResult.local(
          profile,
          message: 'Profile loaded from login data.',
        );
      } else {
        logger.w('No user profile found in local DB');
        return RepositoryResult.error(
          const UserProfileEntity(
            id: '',
            fullName: 'Unknown',
            email: '',
          ),
          'No user profile available. Please log in.',
        );
      }
    } catch (e) {
      logger.e('Error reading user profile from DB: $e');
      return RepositoryResult.error(
        const UserProfileEntity(
          id: '',
          fullName: 'Unknown',
          email: '',
        ),
        'Failed to load profile: $e',
      );
    }
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile() {
    // Watch user profile changes from UserDao (reactive Drift stream)
    return userDao.watchCurrentUser().map((userTableData) {
      if (userTableData != null) {
        return UserProfileModel.fromDrift(userTableData);
      }
      return null;
    });
  }

  @override
  Future<UserPreferencesEntity> getPreferences() async {
    final cachedJson = sharedPreferences.getString(_preferencesKey);
    if (cachedJson != null) {
      try {
        final map = jsonDecode(cachedJson) as Map<String, dynamic>;
        return UserPreferencesModel.fromJson(map);
      } catch (e) {
        logger.e('Error parsing cached preferences: $e');
        return const UserPreferencesEntity();
      }
    }
    return const UserPreferencesEntity();
  }

  @override
  Future<void> updatePreferences(UserPreferencesEntity preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);

    // Save locally
    await sharedPreferences.setString(
      _preferencesKey,
      jsonEncode(model.toJson()),
    );
    logger.i('Updated notification preferences locally');

    // Try to sync to server if online
    final isOnline = await networkInfo.isOnline();
    if (isOnline) {
      try {
        await remoteDataSource.updateNotificationPreferences(model);
        logger.i('Successfully synced preferences to server');
      } catch (e) {
        logger.w('Failed to sync preferences to server: $e');
        // Enqueue for later sync
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: const Uuid().v4(),
            projectId: '', // Preferences are user-level, not project-specific
            entityType: 'user_preferences',
            entityId: 'current_user',
            action: 'update',
            payload: Value(jsonEncode(model.toJson())),
            status: const Value('PENDING'),
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        logger.i('Enqueued preferences update for later sync');
      }
    } else {
      // Offline - enqueue for later sync
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: '',
          entityType: 'user_preferences',
          entityId: 'current_user',
          action: 'update',
          payload: Value(jsonEncode(model.toJson())),
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      logger.i('Device offline, enqueued preferences update for later sync');
    }
  }

  @override
  Stream<SyncStatusEntity> watchSyncStatus() async* {
    // Create a periodic stream that checks sync status
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      final lastSyncStr = await metaDao.getValue(_lastSyncKey);
      final lastSyncMs = lastSyncStr != null ? int.tryParse(lastSyncStr) : null;
      final lastSyncAt = lastSyncMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
          : null;

      final pendingCount = await syncQueueDao.pendingCount();
      final conflicts = await conflictDao.getUnresolvedConflicts();

      yield SyncStatusEntity(
        lastFullSyncAt: lastSyncAt,
        pendingQueueCount: pendingCount,
        conflictCount: conflicts.length,
      );
    }
  }

  @override
  Future<void> syncNow() async {
    logger.i('Triggering manual sync cycle');
    await syncManager.runSyncCycle();

    // Update last sync timestamp
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await metaDao.setValue(_lastSyncKey, nowMs.toString());
    logger.i('Manual sync completed');
  }

  @override
  Future<StorageStatsEntity> getStorageStats() async {
    logger.i('Calculating storage statistics');

    // Get record counts by table
    final recordsByTable = <String, int>{};

    // Count records in key tables
    final issuesCount = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM issues',
        )
        .getSingle();
    recordsByTable['issues'] = issuesCount.read<int>('count');

    final reportsCount = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM reports',
        )
        .getSingle();
    recordsByTable['reports'] = reportsCount.read<int>('count');

    final requestsCount = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM requests',
        )
        .getSingle();
    recordsByTable['requests'] = requestsCount.read<int>('count');

    final mediaCount = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM media_files',
        )
        .getSingle();
    recordsByTable['media'] = mediaCount.read<int>('count');

    // Calculate approximate DB size
    // This is a rough estimate; for exact size, you'd need to query the file system
    final totalRecords = recordsByTable.values.fold<int>(0, (a, b) => a + b);
    final dbSizeBytes = totalRecords * 1024; // Rough estimate: 1KB per record

    // Calculate media cache size
    // Note: We'll sum up all media files across all projects
    // For a more accurate calculation, you could query the filesystem
    final mediaSizeResult = await db
        .customSelect(
          'SELECT COALESCE(SUM(size), 0) as total FROM media_files',
        )
        .getSingle();
    final mediaSizeBytes = mediaSizeResult.read<int>('total');

    logger
        .i('Storage stats: DB=$dbSizeBytes bytes, Media=$mediaSizeBytes bytes');

    return StorageStatsEntity(
      dbSizeBytes: dbSizeBytes,
      mediaSizeBytes: mediaSizeBytes,
      recordsByTable: recordsByTable,
    );
  }

  @override
  Future<void> clearOldCache() async {
    logger.i('Clearing old cache (older than 30 days)');

    final thirtyDaysAgo = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    await db.transaction(() async {
      // Clear old issues
      await db.customStatement(
        'DELETE FROM issues WHERE created_at < ? AND sync_status = ?',
        [thirtyDaysAgo, 'SYNCED'],
      );

      // Clear old reports
      await db.customStatement(
        'DELETE FROM reports WHERE created_at < ?',
        [thirtyDaysAgo],
      );

      // Clear old requests
      await db.customStatement(
        'DELETE FROM requests WHERE created_at < ?',
        [thirtyDaysAgo],
      );

      logger.i('Old cache cleared successfully');
    });
  }

  @override
  Future<void> clearMediaCache() async {
    logger.i('Clearing media cache');

    await db.transaction(() async {
      // Delete all media files from DB
      // Note: This doesn't delete actual files from filesystem
      // You'd need to implement file deletion separately if needed
      await db.customStatement('DELETE FROM media_files');

      logger.i('Media cache cleared successfully');
    });
  }
}
