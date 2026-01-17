import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:field_link/features/reports/domain/repositories/report_repository.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:logger/logger.dart';

import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportRepository _repository;
  final DashboardCubit _dashboardCubit;
  final Logger _logger;
  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _reportsSubscription;

  // Pagination state
  int _currentPage = 0;
  static const int _pageSize = 10;
  bool _hasReachedMax = false;

  ReportsCubit({
    required ReportRepository repository,
    required DashboardCubit dashboardCubit,
    Logger? logger,
  }) : _repository = repository,
       _dashboardCubit = dashboardCubit,
       _logger = logger ?? Logger(),
       super(ReportsInitial()) {
    _dashboardSubscription = _dashboardCubit.stream.listen((state) {
      if (state.selectedProjectId != null) {
        // Reset pagination on project change
        _currentPage = 0;
        _hasReachedMax = false;
        loadReports(state.selectedProjectId!);
      } else {
        emit(ReportsNoProjectSelected());
      }
    });

    // Initial load if project is already selected
    if (_dashboardCubit.state.selectedProjectId != null) {
      loadReports(_dashboardCubit.state.selectedProjectId!);
    } else {
      emit(ReportsNoProjectSelected());
    }
  }

  Future<void> loadReports(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    _logger.i(
      'Loading reports for project: $projectId (forceRefresh: $forceRefresh)',
    );
    
    // Reset pagination on fresh load or refresh
    _currentPage = 0;
    _hasReachedMax = false;
    
    // Don't emit loading if refreshing to avoid flicker, unless it's initial
    if (state is! ReportsLoaded) {
      emit(ReportsLoading());
    } else if (forceRefresh) {
      // Optional: emit a refreshing state if you had one, or keeping existing list is fine
      // But clearing list might be safer for "pull to refresh" to ensure consistency
      // For now we just keep the loading indicator minimal or rely on RefreshIndicator
    }

    try {
      // Cancel existing subscription if any (though we use futures now)
      await _reportsSubscription?.cancel();

      // Fetch reports from remote (page 0)
      final result = await _repository.getReports(
        projectId: projectId,
        forceRemote: forceRefresh,
        page: 0,
        size: _pageSize,
      );

      if (result.hasError) {
        emit(ReportsError(result.message ?? 'Unknown error'));
      } else {
        final newReports = result.data ?? [];
        _hasReachedMax = newReports.length < _pageSize;
        
        // Emit the fetched reports
        emit(ReportsLoaded(
          reports: newReports,
          message: result.message,
          hasReachedMax: _hasReachedMax,
        ));
      }
    } catch (e) {
      _logger.e('Error loading reports: $e');
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> loadMoreReports() async {
    final projectId = _dashboardCubit.state.selectedProjectId;
    if (projectId == null) return;
    
    if (_hasReachedMax) return;
    if (state is! ReportsLoaded) return;
    
    final currentState = state as ReportsLoaded;
    if (currentState.isFetchingMore) return;

    // Set fetching more flag
    emit(currentState.copyWith(isFetchingMore: true));

    try {
      final nextPage = _currentPage + 1;
      
      final result = await _repository.getReports(
        projectId: projectId,
        page: nextPage,
        size: _pageSize,
      );

      if (result.hasError) {
        emit(currentState.copyWith(
          isFetchingMore: false,
          // Could set a one-time error message or just ignore
        ));
      } else {
        final newReports = result.data ?? [];
        _hasReachedMax = newReports.length < _pageSize;
        _currentPage = nextPage;
        
        emit(currentState.copyWith(
          reports: [...currentState.reports, ...newReports],
          hasReachedMax: _hasReachedMax,
          isFetchingMore: false,
        ));
      }
    } catch (e) {
      _logger.e('Error loading more reports: $e');
      emit(currentState.copyWith(isFetchingMore: false));
    }
  }

  Future<void> refresh() async {
    final projectId = _dashboardCubit.state.selectedProjectId;
    if (projectId != null) {
      await loadReports(projectId, forceRefresh: true);
    }
  }

  @override
  Future<void> close() {
    _dashboardSubscription?.cancel();
    _reportsSubscription?.cancel();
    return super.close();
  }
}
