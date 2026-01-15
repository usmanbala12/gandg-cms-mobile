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

      // Fetch reports from remote
      final result = await _repository.getReports(
        projectId: projectId,
        forceRemote: forceRefresh,
      );

      if (result.hasError) {
        emit(ReportsError(result.message ?? 'Unknown error'));
      } else {
        // Emit the fetched reports
        emit(ReportsLoaded(
          reports: result.data,
          message: result.message,
        ));
      }
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
