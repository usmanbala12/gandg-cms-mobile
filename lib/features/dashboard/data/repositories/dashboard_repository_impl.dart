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
import 'package:field_link/core/network/api_client.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/sync/sync_manager.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:logger/logger.dart';

/// Abstraction for dashboard data orchestration.
abstract class DashboardRepository {
  Stream<List<Project>> watchProjects();

  Future<List<Project>> getProjects({bool forceRemote = false});

  Future<String?> getActiveProjectId();

  Future<void> setActiveProjectId(String projectId);

  Future<AnalyticsEntity> getProjectAnalytics(
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
    Logger? logger,
  }) : _projectDao = projectDao,
       _analyticsDao = analyticsDao,
       _metaDao = metaDao,
       _apiClient = apiClient,
       _syncManager = syncManager,
       _tokenStorageService = tokenStorageService,
       _logger = logger ?? Logger();

  final ProjectDao _projectDao;
  final AnalyticsDao _analyticsDao;
  final MetaDao _metaDao;
  final ApiClient _apiClient;
  final SyncManager _syncManager;
  final TokenStorageService _tokenStorageService;
  final Logger _logger;

  static const String _activeProjectKey = 'active_project_id';

  @override
  Stream<List<Project>> watchProjects() {
    return _projectDao.watchAllProjects();
  }

  @override
  Future<List<Project>> getProjects({bool forceRemote = false}) async {
    final cached = await _projectDao.getProjects();
    if (!forceRemote && cached.isNotEmpty) {
      return cached;
    }

    // Validate authentication before making API calls
    _logger.i('🔐 Checking authentication status before fetching projects...');
    final isAuthenticated = await _tokenStorageService.isAuthenticated();

    if (!isAuthenticated) {
      _logger.w('🚫 User not authenticated - cannot fetch remote projects');
      _logger.w('   Cached projects available: ${cached.length}');
      _logger.w('   Force remote: $forceRemote');

      if (forceRemote) {
        _logger.e('❌ Cannot force remote fetch without authentication');
        throw DashboardAuthorizationException(
          message:
              'You must be logged in to fetch projects. Please sign in to continue.',
        );
      }

      // Return cached data if available
      _logger.i(
        '📦 Returning ${cached.length} cached projects (user not authenticated)',
      );
      return cached;
    }

    _logger.i('✅ User authenticated, proceeding with remote fetch...');

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
      if (forceRemote) {
        throw DashboardRepositoryException(
          message: error.message ?? 'Unable to fetch projects',
        );
      }
    } catch (error, stackTrace) {
      _logger.e(
        'Unexpected failure fetching remote projects',
        error: error,
        stackTrace: stackTrace,
      );
      if (forceRemote) {
        throw DashboardRepositoryException(message: error.toString());
      }
    }

    return _projectDao.getProjects();
  }

  @override
  Future<String?> getActiveProjectId() => _metaDao.getValue(_activeProjectKey);

  @override
  Future<void> setActiveProjectId(String projectId) async {
    await _metaDao.setValue(_activeProjectKey, projectId);
  }

  @override
  Future<AnalyticsEntity> getProjectAnalytics(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    final cached = await _analyticsDao.getAnalyticsForProject(projectId);
    final nowUtc = DateTime.now().toUtc();
    final nowMs = nowUtc.millisecondsSinceEpoch;

    final lastSynced = cached?.lastSynced ?? 0;
    final isStale =
        nowMs - lastSynced > const Duration(hours: 24).inMilliseconds;

    if (!forceRefresh && cached != null && !isStale) {
      return AnalyticsEntity.fromRow(cached, now: nowUtc);
    }

    // Validate authentication before making API calls
    final isAuthenticated = await _tokenStorageService.isAuthenticated();
    if (!isAuthenticated) {
      _logger.w('⛔ User not authenticated - cannot fetch analytics');
      if (cached != null) {
        return AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true);
      }
      throw DashboardAuthorizationException(
        message: 'You must be logged in to fetch analytics. Please sign in.',
      );
    }

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
      return AnalyticsEntity.fromRow(updatedRow!, now: nowUtc);
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
      if (_isConnectivityError(error)) {
        if (cached != null) {
          return AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true);
        }
        throw DashboardOfflineException();
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
        return AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true);
      }
      throw DashboardOfflineException();
    } catch (error, stackTrace) {
      _logger.e(
        'Unexpected analytics fetch failure',
        error: error,
        stackTrace: stackTrace,
      );
      if (cached != null) {
        return AnalyticsEntity.fromRow(cached, now: nowUtc, isStale: true);
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
