import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/analytics_dao.dart';
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

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({
    required ProjectDao projectDao,
    required AnalyticsDao analyticsDao,
    required MetaDao metaDao,
    required ApiClient apiClient,
    required SyncManager syncManager,
    required TokenStorageService tokenStorageService,
    required NetworkInfo networkInfo,
    Logger? logger,
  }) : _projectDao = projectDao,
       _analyticsDao = analyticsDao,
       _metaDao = metaDao,
       _apiClient = apiClient,
       _syncManager = syncManager,
       _tokenStorageService = tokenStorageService,
       _networkInfo = networkInfo,
       _logger = logger ?? Logger();

  final ProjectDao _projectDao;
  final AnalyticsDao _analyticsDao;
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
    _logger.i('🔐 Checking authentication status before fetching projects...');
    final isAuthenticated = await _tokenStorageService.isAuthenticated();

    if (!isAuthenticated) {
      _logger.w('🚫 User not authenticated - cannot fetch remote projects');
      if (forceRemote || cached.isEmpty) {
        throw DashboardAuthorizationException(
          message:
              'You must be logged in to fetch projects. Please sign in to continue.',
        );
      }
      // Return cached data if available
      _logger.i(
        '📦 Returning ${cached.length} cached projects (user not authenticated)',
      );
      return RepositoryResult.local(
        cached,
        message: 'Not authenticated. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // Online - fetch from remote
    _logger.i('🔄 Fetching projects from remote API...');
    try {
      final remote = await _apiClient.fetchProjects();
      _logger.i('✅ Successfully fetched ${remote.length} projects from remote');

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
      final responseData = error.response?.data;
      _logger.e(
        '❌ Failed to fetch remote projects (status: $status)',
        error: error,
        stackTrace: stackTrace,
      );

      // Handle authentication/authorization errors
      if (status == 401 || status == 403) {
        _logger.e(
          '🚫 Authentication failed: ${status == 401 ? "Token expired or invalid (401)" : "Access forbidden (403)"} ',
        );
        if (responseData != null) {
          _logger.e('Server response: $responseData');
        }

        // Clear potentially invalid tokens
        await _tokenStorageService.clearTokens();

        throw DashboardAuthorizationException(
          message: status == 401
              ? 'Your session has expired. Please sign in again.'
              : 'Access denied. Please sign in again.',
        );
      }

      // Network error or server error - fallback to local
      _logger.w('Network error fetching projects, falling back to cached data');
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

      // Fallback to local
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
    final cached = await _analyticsDao.getAnalyticsForProject(projectId);
    final nowUtc = DateTime.now().toUtc();
    final nowMs = nowUtc.millisecondsSinceEpoch;

    final lastSynced = cached?.lastSynced ?? 0;
    final isStale =
        nowMs - lastSynced > const Duration(hours: 24).inMilliseconds;

    // Check connectivity
    final isOnline = await _networkInfo.isOnline();
    _logger.d(
      'getProjectAnalytics: online=$isOnline, forceRefresh=$forceRefresh',
    );

    // If offline, return cached data
    if (!isOnline) {
      _logger.i('Device offline, returning cached analytics');
      if (cached != null) {
        return RepositoryResult.local(
          AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
          message: 'Offline mode. Showing cached data.',
          lastSyncedAt: lastSynced,
        );
      }
      return RepositoryResult.error(
        AnalyticsEntity.empty(projectId),
        'No cached analytics available offline.',
      );
    }

    // Validate authentication before making API calls
    final isAuthenticated = await _tokenStorageService.isAuthenticated();
    if (!isAuthenticated) {
      _logger.w('⛔ User not authenticated - cannot fetch analytics');
      if (cached != null) {
        return RepositoryResult.local(
          AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
          message: 'Not authenticated. Showing cached data.',
          lastSyncedAt: lastSynced,
        );
      }
      throw DashboardAuthorizationException(
        message: 'You must be logged in to fetch analytics. Please sign in.',
      );
    }

    // Return cached data if not stale and not forcing refresh
    if (!forceRefresh && cached != null && !isStale) {
      _logger.i('📦 Returning fresh cached analytics');
      return RepositoryResult.local(
        AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: false),
        message: 'Showing cached data.',
        lastSyncedAt: lastSynced,
      );
    }

    // Online - fetch from remote
    try {
      final remote = await _apiClient.fetchProjectAnalytics(projectId);
      final companion = _mapRemoteAnalytics(
        projectId,
        remote,
        existing: cached,
        nowMs: nowMs,
      );
      await _analyticsDao.upsertAnalytics(companion);
      await _metaDao.setValue('analytics_last_synced_$projectId', '$nowMs');

      // Run a background sync cycle to keep related data fresh.
      unawaited(_syncManager.runSyncCycle(projectId: projectId));

      // Fetch the persisted row to return
      final updatedRow = await _analyticsDao.getAnalyticsForProject(projectId);
      return RepositoryResult.remote(
        AnalyticsEntity.fromRow(updatedRow!, now: nowUtc),
        lastSyncedAt: nowMs,
      );
    } on DioException catch (error, stackTrace) {
      final status = error.response?.statusCode;
      _logger.e(
        '❌ Analytics fetch failed for project $projectId (status: $status)',
        error: error,
        stackTrace: stackTrace,
      );

      if (status == 401 || status == 403) {
        _logger.e('🚫 Authentication failed while fetching analytics');
        await _tokenStorageService.clearTokens();
        throw DashboardAuthorizationException(
          message: status == 401
              ? 'Your session has expired. Please sign in again.'
              : 'Access denied. Please sign in again.',
        );
      }

      // Network error - fallback to cached
      if (_isConnectivityError(error)) {
        _logger.w(
          'Network error fetching analytics, falling back to cached data',
        );
        if (cached != null) {
          return RepositoryResult.local(
            AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
            message: 'Network error. Showing cached data.',
            lastSyncedAt: lastSynced,
          );
        }
        return RepositoryResult.error(
          AnalyticsEntity.empty(projectId),
          'Network error and no cached data available.',
        );
      }

      // Other errors - fallback to cached
      if (cached != null) {
        return RepositoryResult.local(
          AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
          message: 'Server error. Showing cached data.',
          lastSyncedAt: lastSynced,
        );
      }
      throw DashboardRepositoryException(
        message: error.message ?? 'Unknown error',
      );
    } on SocketException catch (error, stackTrace) {
      _logger.w(
        'Socket error fetching analytics',
        error: error,
        stackTrace: stackTrace,
      );
      if (cached != null) {
        return RepositoryResult.local(
          AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
          message: 'Connection error. Showing cached data.',
          lastSyncedAt: lastSynced,
        );
      }
      return RepositoryResult.error(
        AnalyticsEntity.empty(projectId),
        'Connection error and no cached data available.',
      );
    } catch (error, stackTrace) {
      _logger.e(
        'Unexpected analytics fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      if (cached != null) {
        return RepositoryResult.local(
          AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true),
          message: 'Error loading data. Showing cached data.',
          lastSyncedAt: lastSynced,
        );
      }
      throw DashboardRepositoryException(message: error.toString());
    }
  }

  @override
  Stream<AnalyticsEntity?> watchAnalytics(String projectId) {
    return _analyticsDao.watchAnalyticsForProject(projectId).map((row) {
      if (row == null) return null;
      final nowUtc = DateTime.now().toUtc();
      final isStale = row.lastSynced == null
          ? true
          : nowUtc.millisecondsSinceEpoch - row.lastSynced! >
                const Duration(hours: 24).inMilliseconds;
      return AnalyticsEntity.fromRow(row, now: nowUtc, isStale: isStale);
    });
  }

  @override
  Future<void> runSync(String projectId) {
    return _syncManager.runSyncCycle(projectId: projectId);
  }

  ProjectAnalyticsCompanion _mapRemoteAnalytics(
    String projectId,
    Map<String, dynamic> payload, {
    required int nowMs,
    ProjectAnalytic? existing,
  }) {
    final reportsCount = _extractInt(payload, const [
      'reportsCount',
      'reports_count',
      'reports',
    ]);
    final pendingRequests = _extractInt(payload, const [
      'pendingRequests',
      'requestsPending',
      'pending',
      'totalPending',
      'pending_requests',
    ]);
    final openIssues = _extractInt(payload, const [
      'openIssues',
      'issuesOpen',
      'issues',
      'open_issues',
    ]);

    final reportsTrend =
        payload['reportsTimeseries'] ??
        payload['reports_timeseries'] ??
        payload['reportTrend'];
    final statusBreakdown =
        payload['requestsByStatus'] ??
        payload['statusCounts'] ??
        payload['status_counts'];
    final activity = payload['recentActivity'] ?? payload['activity'];

    return ProjectAnalyticsCompanion.insert(
      projectId: projectId,
      reportsCount: Value(reportsCount),
      requestsPending: Value(pendingRequests),
      openIssues: Value(openIssues),
      reportsTimeseries: Value(_encodeJson(reportsTrend)),
      requestsByStatus: Value(_encodeJson(statusBreakdown)),
      recentActivity: Value(_encodeJson(activity)),
      lastSynced: Value(nowMs),
      createdAt: existing?.createdAt ?? nowMs,
      updatedAt: nowMs,
    );
  }

  static bool _isConnectivityError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout;
    }
    return error is SocketException;
  }

  static String? _encodeJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  static String? _encodeString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value;
    }
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
