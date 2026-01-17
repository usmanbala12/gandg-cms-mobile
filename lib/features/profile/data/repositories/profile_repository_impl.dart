import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/meta_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/db/daos/user_dao.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/storage_stats_entity.dart';
import '../../domain/entities/sync_status_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

/// Simplified ProfileRepository - removed unused DAO dependencies
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;
  final SyncManager syncManager;
  final SyncQueueDao syncQueueDao;
  final MetaDao metaDao;
  final UserDao userDao;
  final AppDatabase db;
  final Logger logger;


  static const String _lastSyncKey = 'last_full_sync';

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
    required this.syncManager,
    required this.syncQueueDao,
    required this.metaDao,
    required this.userDao,
    required this.db,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Future<RepositoryResult<UserProfileEntity>> getUserProfile({
    bool forceRemote = false,
  }) async {
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
    return userDao.watchCurrentUser().map((userTableData) {
      if (userTableData != null) {
        return UserProfileModel.fromDrift(userTableData);
      }
      return null;
    });
  }



  @override
  Stream<SyncStatusEntity> watchSyncStatus() async* {
    await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
      final lastSyncStr = await metaDao.getValue(_lastSyncKey);
      final lastSyncMs = lastSyncStr != null ? int.tryParse(lastSyncStr) : null;
      final lastSyncAt = lastSyncMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncMs)
          : null;

      final pendingCount = await syncQueueDao.pendingCount();

      yield SyncStatusEntity(
        lastFullSyncAt: lastSyncAt,
        pendingQueueCount: pendingCount,
        conflictCount: 0, // Conflicts removed in simplified version
      );
    }
  }

  @override
  Future<void> syncNow() async {
    logger.i('Triggering manual sync cycle');
    await syncManager.runSyncCycle();

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await metaDao.setValue(_lastSyncKey, nowMs.toString());
    logger.i('Manual sync completed');
  }

  @override
  Future<StorageStatsEntity> getStorageStats() async {
    logger.i('Calculating storage statistics');

    final recordsByTable = <String, int>{};

    // Count records in remaining tables
    try {
      final queueCount = await db
          .customSelect('SELECT COUNT(*) as count FROM sync_queue')
          .getSingle();
      recordsByTable['sync_queue'] = queueCount.read<int>('count');
    } catch (_) {
      recordsByTable['sync_queue'] = 0;
    }

    try {
      final projectsCount = await db
          .customSelect('SELECT COUNT(*) as count FROM projects')
          .getSingle();
      recordsByTable['projects'] = projectsCount.read<int>('count');
    } catch (_) {
      recordsByTable['projects'] = 0;
    }

    final totalRecords = recordsByTable.values.fold<int>(0, (a, b) => a + b);
    final dbSizeBytes = totalRecords * 1024; // Rough estimate

    logger.i('Storage stats: DB=$dbSizeBytes bytes');

    return StorageStatsEntity(
      dbSizeBytes: dbSizeBytes,
      mediaSizeBytes: 0, // No media cache in simplified version
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
      // Clear old completed sync queue items
      await db.customStatement(
        "DELETE FROM sync_queue WHERE created_at < ? AND status = 'DONE'",
        [thirtyDaysAgo],
      );

      logger.i('Old cache cleared successfully');
    });
  }

  @override
  Future<void> clearMediaCache() async {
    // No media cache in simplified version
    logger.i('Media cache clearing is a no-op in simplified offline mode');
  }
}
