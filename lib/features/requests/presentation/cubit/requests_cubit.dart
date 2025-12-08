import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/repository_result.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final RequestRepository repository;

  RequestsCubit({required this.repository}) : super(RequestsInitial());

  Future<void> loadRequests({
    required String projectId,
    String? userId,
    bool forceRemote = false,
  }) async {
    emit(RequestsLoading());

    try {
      final result = await repository.getMyRequests(
        projectId: projectId,
        userId: userId,
        forceRemote: forceRemote,
      );

      emit(RequestsLoaded(
        requests: result.data,
        source: result.source,
        message: result.message,
        lastSyncedAt: result.lastSyncedAt,
      ));
    } catch (e) {
      emit(RequestsError(message: e.toString()));
    }
  }

  Future<void> refresh({
    required String projectId,
    String? userId,
  }) async {
    // Keep current data while loading? Or show loading?
    // Usually pull-to-refresh keeps showing list but with spinner.
    // But here we just call loadRequests with forceRemote=true
    await loadRequests(
      projectId: projectId,
      userId: userId,
      forceRemote: true,
    );
  }
}
