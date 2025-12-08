import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:field_link/core/db/repositories/report_repository.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:logger/logger.dart';

import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final ReportRepository _repository;
  final DashboardCubit _dashboardCubit;
  final Logger _logger;
  StreamSubscription? _dashboardSubscription;
  StreamSubscription? _reportsSubscription;

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
    emit(ReportsLoading());

    try {
      // Cancel existing subscription if any
      await _reportsSubscription?.cancel();

      // Watch reports for real-time updates
      _reportsSubscription = _repository
          .watchReports(projectId: projectId)
          .listen(
            (reports) {
              emit(ReportsLoaded(reports: reports));
            },
            onError: (error) {
              _logger.e('Error watching reports: $error');
              emit(ReportsError(error.toString()));
            },
          );

      // Trigger fetch to ensure fresh data
      await _repository.getReports(
        projectId: projectId,
        forceRemote: forceRefresh,
      );
    } catch (e) {
      _logger.e('Error loading reports: $e');
      emit(ReportsError(e.toString()));
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
