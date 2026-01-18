import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';

part 'request_create_state.dart';

class RequestCreateCubit extends Cubit<RequestCreateState> {
  final RequestRepository repository;

  RequestCreateCubit({required this.repository})
      : super(RequestCreateInitial());

  Future<void> submit({
    required String projectId,
    required String type,
    required String title,
    required String description,
    required String priority,
    required String createdBy,
    double? amount,
    bool isDraft = false,
  }) async {
    emit(RequestCreateSubmitting());

    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final request = RequestEntity(
        id: const Uuid().v4(),
        projectId: projectId,
        type: type,
        title: title,
        description: description,
        amount: amount,
        // currency is set by backend automatically (NGN)
        priority: priority,
        status: isDraft ? 'DRAFT' : 'PENDING',
        createdBy: createdBy,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createRequest(request);
      emit(RequestCreateSuccess());
    } catch (e) {
      emit(RequestCreateError(message: e.toString()));
    }
  }

  void reset() {
    emit(RequestCreateInitial());
  }
}
