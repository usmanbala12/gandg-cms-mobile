import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/project_dao.dart';
import 'package:field_link/core/db/db_utils.dart';
import 'package:field_link/core/domain/repository_result.dart';
import 'package:field_link/core/network/api_client.dart';
import 'package:field_link/core/network/network_info.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/sync/sync_manager.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:logger/logger.dart';

/// Abstraction for dashboard data orchestration.
abstract class DashboardRepository {
  Stream<List<Project>> watchProjects();

  Future<RepositoryResult<List<Project>>> getProjects({
    bool forceRemote = false,
  });

  Future<String?> getActiveProjectId();

  Future<void> setActiveProjectId(String projectId);

  Future<RepositoryResult<AnalyticsEntity>> getProjectAnalytics(
    String projectId, {
    bool forceRefresh = false,
  });

  Stream<AnalyticsEntity?> watchAnalytics(String projectId);

  Future<void> runSync(String projectId);
}

/// Simplified DashboardRepository - analytics are remote-only.
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required ProjectDao projectDao,
    required MetaDao metaDao,
    required ApiClient apiClient,
    required SyncManager syncManager,
    required TokenStorageService tokenStorageService,
    required NetworkInfo networkInfo,
    Logger? logger,
  }) : _projectDao = projectDao,
       _metaDao = metaDao,
       _apiClient = apiClient,
       _syncManager = syncManager,
       _tokenStorageService = tokenStorageService,
       _networkInfo = networkInfo,
       _logger = logger ?? Logger();

  final ProjectDao _projectDao;
  final MetaDao _metaDao;
  final ApiClient _apiClient;
  final SyncManager _syncManager;
  final TokenStorageService _tokenStorageService;
  final NetworkInfo _networkInfo;
  final Logger _logger;

  static const String _activeProjectKey = 'active_project_id';

  @override
  Stream<List<Project>> watchProjects() {
    return _projectDao.watchAllProjects();
  }

  @override
  Future<RepositoryResult<List<Project>>> getProjects({
    bool forceRemote = false,
  }) async {
    // Get cached projects
    final cached = await _projectDao.getProjects();

    // Get last sync timestamp
    final lastSyncStr = await _metaDao.getValue('projects_last_synced');
    final lastSyncedAt = lastSyncStr != null ? int.tryParse(lastSyncStr) : null;

    // Check connectivity
    final isOnline = await _networkInfo.isOnline();
    _logger.d(
      'getProjects: online=$isOnline, forceRemote=$forceRemote, cached=${cached.length}',
    );

    // If offline, return cached data
    if (!isOnline) {
      _logger.i('Device offline, returning ${cached.length} cached projects');
      return RepositoryResult.local(
        cached,
        message: 'Offline mode. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // Validate authentication before making API calls
    final isAuthenticated = await _tokenStorageService.isAuthenticated();
    _logger.d('getProjects authentication check: $isAuthenticated');

    if (!isAuthenticated) {
      _logger.w('User not authenticated - cannot fetch remote projects');
      if (forceRemote || cached.isEmpty) {
        throw DashboardAuthorizationException(
          message:
              'You must be logged in to fetch projects. Please sign in to continue.',
        );
      }
      return RepositoryResult.local(
        cached,
        message: 'Not authenticated. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // Online - fetch from remote
    _logger.i('Fetching projects from remote API...');
    try {
      final remote = await _apiClient.fetchProjects();
      _logger.i('Successfully fetched ${remote.length} projects from remote');

      final nowMs = now();
      for (final item in remote) {
        final id = (item['id'] as String?)?.trim();
        if (id == null || id.isEmpty) {
          continue;
        }

        final project = ProjectsCompanion.insert(
          id: id,
          name: (item['name'] as String?)?.trim().isNotEmpty == true
              ? (item['name'] as String)
              : 'Untitled Project',
          location: Value(_encodeString(item['location'])),
          metadata: Value(_encodeString(item['metadata'])),
          lastSynced: Value(nowMs),
          createdAt: _parseEpoch(item['createdAt']) ?? nowMs,
          updatedAt: _parseEpoch(item['updatedAt']) ?? nowMs,
        );
        await _projectDao.upsertProject(project);
      }

      // Update last synced timestamp
      await _metaDao.setValue('projects_last_synced', nowMs.toString());

      // Return fresh remote data
      final projects = await _projectDao.getProjects();
      _logger.i('✅ Returned ${projects.length} projects from remote');
      return RepositoryResult.remote(projects, lastSyncedAt: nowMs);
    } on DioException catch (error, stackTrace) {
      final status = error.response?.statusCode;
      _logger.e(
        'Failed to fetch remote projects (status: $status)',
        error: error,
        stackTrace: stackTrace,
      );

      // Handle authentication/authorization errors
      if (status == 401 || status == 403) {
        await _tokenStorageService.clearTokens();
        throw DashboardAuthorizationException(
          message: status == 401
              ? 'Your session has expired. Please sign in again.'
              : 'Access denied. Please sign in again.',
        );
      }

      // Network error or server error - fallback to local
      return RepositoryResult.local(
        cached,
        message: 'Network error. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Unexpected failure fetching remote projects',
        error: error,
        stackTrace: stackTrace,
      );
      return RepositoryResult.local(
        cached,
        message: 'Error loading data. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }
  }

  @override
  Future<String?> getActiveProjectId() => _metaDao.getValue(_activeProjectKey);

  @override
  Future<void> setActiveProjectId(String projectId) async {
    await _metaDao.setValue(_activeProjectKey, projectId);
  }

  @override
  Future<RepositoryResult<AnalyticsEntity>> getProjectAnalytics(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    final isOnline = await _networkInfo.isOnline();

    if (!isOnline) {
      _logger.i('Device offline, cannot fetch analytics');
      return RepositoryResult.error(
        AnalyticsEntity.empty(projectId),
        'You are offline. Analytics cannot be loaded.',
      );
    }

    // Validate authentication
    final isAuthenticated = await _tokenStorageService.isAuthenticated();
    if (!isAuthenticated) {
      throw DashboardAuthorizationException(
        message: 'You must be logged in to fetch analytics. Please sign in.',
      );
    }

    try {
      final remote = await _apiClient.fetchProjectAnalytics(projectId);
      final nowDt = DateTime.now();

      final entity = AnalyticsEntity.fromRemote(projectId, remote, now: nowDt);

      // Run a background sync cycle
      unawaited(_syncManager.runSyncCycle(projectId: projectId));

      return RepositoryResult.remote(
        entity,
        lastSyncedAt: nowDt.millisecondsSinceEpoch,
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      if (status == 401 || status == 403) {
        await _tokenStorageService.clearTokens();
        throw DashboardAuthorizationException(
          message: status == 401
              ? 'Your session has expired. Please sign in again.'
              : 'Access denied. Please sign in again.',
        );
      }

      return RepositoryResult.error(
        AnalyticsEntity.empty(projectId),
        'Network error loading analytics.',
      );
    } catch (error) {
      _logger.e('Error fetching analytics: $error');
      return RepositoryResult.error(
        AnalyticsEntity.empty(projectId),
        'Error loading analytics.',
      );
    }
  }

  @override
  Stream<AnalyticsEntity?> watchAnalytics(String projectId) {
    // Remote-only: no local stream
    return Stream.value(null);
  }

  @override
  Future<void> runSync(String projectId) {
    return _syncManager.runSyncCycle(projectId: projectId);
  }

  static String? _encodeString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static int? _parseEpoch(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.millisecondsSinceEpoch;
      }
      return int.tryParse(value);
    }
    return null;
  }

  static int _extractInt(Map<String, dynamic> payload, List<String> keys) {
    for (final key in keys) {
      final value = payload[key];
      if (value != null) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return 0;
  }
}

class DashboardRepositoryException implements Exception {
  DashboardRepositoryException({required this.message});
  final String message;
  @override
  String toString() => message;
}

class DashboardOfflineException implements Exception {
  DashboardOfflineException([this.message = 'Device appears to be offline']);
  final String message;
  @override
  String toString() => message;
}

class DashboardAuthorizationException implements Exception {
  DashboardAuthorizationException({required this.message});
  final String message;
  @override
  String toString() => message;
}
