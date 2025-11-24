import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:field_link/features/dashboard/domain/analytics_entity.dart';
import 'package:logger/logger.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required DashboardRepository repository, Logger? logger})
    : _repository = repository,
      _logger = logger ?? Logger(),
      super(const DashboardState());

  final DashboardRepository _repository;
  final Logger _logger;
  StreamSubscription<List<Project>>? _projectsSub;
  StreamSubscription<AnalyticsEntity?>? _analyticsSub;

  Future<void> init() async {
    _logger.i('🚀 Initializing dashboard...');
    emit(
      state.copyWith(
        loading: true,
        error: null,
        requiresReauthentication: false,
      ),
    );
    _projectsSub?.cancel();
    _projectsSub = _repository.watchProjects().listen(
      (projects) => unawaited(_handleProjectsUpdate(projects)),
    );

    List<Project> projects;
    try {
      _logger.i('📥 Fetching projects...');

      // Check for cached projects first to show something immediately
      projects = await _repository.getProjects(forceRemote: false);

      // If we have 0 projects, it might be because we're not authenticated
      // The repository logs this warning, but we should handle it in the UI too
      if (projects.isEmpty) {
        // We can't easily check auth status here without injecting TokenStorageService
        // but the repository handles the auth check internally.
        // If we get 0 projects, we might want to trigger a refresh which forces remote
        // and will throw DashboardAuthorizationException if not authenticated.
        _logger.i('⚠️ No projects found in cache. Attempting remote fetch...');
        try {
          projects = await _repository.getProjects(forceRemote: true);
        } catch (e) {
          // If this fails, we'll catch it below
          if (e is DashboardAuthorizationException) {
            rethrow;
          }
          _logger.w('⚠️ Remote fetch failed, sticking with empty list: $e');
        }
      }

      _logger.i('✅ Successfully loaded ${projects.length} projects');
    } on DashboardAuthorizationException catch (error) {
      _logger.e('🚫 Authorization error during init: ${error.message}');
      emit(
        state.copyWith(
          loading: false,
          error: error.message,
          requiresReauthentication: true,
        ),
      );
      return;
    } on DashboardRepositoryException catch (error) {
      _logger.e('❌ Repository error during init: ${error.message}');
      emit(state.copyWith(loading: false, error: error.message));
      return;
    } catch (error) {
      _logger.e('❌ Unexpected error during init: $error');
      emit(state.copyWith(loading: false, error: error.toString()));
      return;
    }
    var selectedId = await _repository.getActiveProjectId();
    if (selectedId == null && projects.isNotEmpty) {
      selectedId = projects.first.id;
      await _repository.setActiveProjectId(selectedId);
    }

    emit(
      state.copyWith(
        projects: projects,
        selectedProjectId: selectedId,
        loading: false,
        lastSynced: state.lastSynced,
        offline: false,
        requiresReauthentication: false,
      ),
    );

    if (selectedId != null) {
      await _subscribeToAnalytics(selectedId);
      await loadAnalytics(forceRefresh: false, projectId: selectedId);
    }
  }

  Future<void> selectProject(String projectId) async {
    if (projectId == state.selectedProjectId) {
      return;
    }

    emit(
      state.copyWith(
        selectedProjectId: projectId,
        loading: true,
        error: null,
        offline: false,
        requiresReauthentication: false,
      ),
    );

    await _repository.setActiveProjectId(projectId);
    await _subscribeToAnalytics(projectId);
    await loadAnalytics(forceRefresh: false, projectId: projectId);
  }

  Future<void> loadAnalytics({
    bool forceRefresh = false,
    String? projectId,
  }) async {
    final targetId = projectId ?? state.selectedProjectId;
    if (targetId == null) {
      _logger.w('⚠️ Cannot load analytics: No project selected');
      return;
    }

    _logger.i(
      '📊 Loading analytics for project: $targetId (forceRefresh: $forceRefresh)',
    );
    emit(
      state.copyWith(
        loading: true,
        error: null,
        offline: false,
        requiresReauthentication: false,
      ),
    );

    try {
      final analytics = await _repository.getProjectAnalytics(
        targetId,
        forceRefresh: forceRefresh,
      );
      _logger.i('✅ Analytics loaded successfully');
      emit(
        state.copyWith(
          analytics: analytics,
          loading: false,
          lastSynced: analytics.lastSyncedAt,
          analyticsStale: analytics.isStale || analytics.isExpired,
          offline: false,
          requiresReauthentication: false,
        ),
      );
    } on DashboardAuthorizationException catch (error) {
      _logger.e('🚫 Authorization error loading analytics: ${error.message}');
      emit(
        state.copyWith(
          loading: false,
          error: error.message,
          requiresReauthentication: true,
        ),
      );
    } on DashboardOfflineException catch (error) {
      _logger.w('📴 Offline error loading analytics: ${error.message}');
      emit(
        state.copyWith(
          loading: false,
          offline: true,
          error: error.message,
          analyticsStale: true,
        ),
      );
    } on DashboardRepositoryException catch (error) {
      _logger.e('❌ Repository error loading analytics: ${error.message}');
      emit(state.copyWith(loading: false, error: error.message));
    } catch (error) {
      _logger.e('❌ Unexpected error loading analytics: $error');
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }

  Future<void> refresh() async {
    final projectId = state.selectedProjectId;
    if (projectId == null) return;

    emit(
      state.copyWith(
        loading: true,
        error: null,
        requiresReauthentication: false,
      ),
    );
    unawaited(_repository.runSync(projectId));
    await loadAnalytics(forceRefresh: true, projectId: projectId);
  }

  Future<void> _handleProjectsUpdate(List<Project> projects) async {
    var selectedId = state.selectedProjectId;
    final hasSelection =
        selectedId != null &&
        projects.any((project) => project.id == selectedId);

    if (!hasSelection) {
      selectedId = projects.isNotEmpty ? projects.first.id : null;
      if (selectedId != null) {
        await _repository.setActiveProjectId(selectedId);
        await _subscribeToAnalytics(selectedId);
        await loadAnalytics(forceRefresh: false, projectId: selectedId);
      }
    }

    emit(state.copyWith(projects: projects, selectedProjectId: selectedId));
  }

  Future<void> _subscribeToAnalytics(String projectId) async {
    await _analyticsSub?.cancel();
    _analyticsSub = _repository.watchAnalytics(projectId).listen((entity) {
      if (entity == null) return;
      emit(
        state.copyWith(
          analytics: entity,
          lastSynced: entity.lastSyncedAt,
          analyticsStale: entity.isStale || entity.isExpired,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _projectsSub?.cancel();
    _analyticsSub?.cancel();
    return super.close();
  }
}
