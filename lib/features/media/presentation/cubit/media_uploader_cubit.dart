import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field_link/features/media/domain/entities/media_entity.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';

abstract class MediaUploaderState extends Equatable {
  const MediaUploaderState();

  @override
  List<Object?> get props => [];
}

class MediaUploaderInitial extends MediaUploaderState {}

class MediaUploaderInProcess extends MediaUploaderState {
  final List<File> selectedFiles;
  final List<MediaEntity> uploadedMedia;
  final bool isUploading;
  final String? error;

  const MediaUploaderInProcess({
    required this.selectedFiles,
    required this.uploadedMedia,
    this.isUploading = false,
    this.error,
  });

  @override
  List<Object?> get props => [selectedFiles, uploadedMedia, isUploading, error];

  MediaUploaderInProcess copyWith({
    List<File>? selectedFiles,
    List<MediaEntity>? uploadedMedia,
    bool? isUploading,
    String? error,
  }) {
    return MediaUploaderInProcess(
      selectedFiles: selectedFiles ?? this.selectedFiles,
      uploadedMedia: uploadedMedia ?? this.uploadedMedia,
      isUploading: isUploading ?? this.isUploading,
      error: error,
    );
  }
}

class MediaUploaderCubit extends Cubit<MediaUploaderState> {
  final MediaRepository repository;

  MediaUploaderCubit({required this.repository}) : super(MediaUploaderInitial());

  void addFiles(List<File> files) {
    if (state is MediaUploaderInitial) {
      emit(MediaUploaderInProcess(selectedFiles: files, uploadedMedia: const []));
    } else if (state is MediaUploaderInProcess) {
      final currentState = state as MediaUploaderInProcess;
      emit(currentState.copyWith(
        selectedFiles: [...currentState.selectedFiles, ...files],
      ));
    }
  }

  void removeFile(File file) {
    if (state is MediaUploaderInProcess) {
      final currentState = state as MediaUploaderInProcess;
      emit(currentState.copyWith(
        selectedFiles: currentState.selectedFiles.where((f) => f.path != file.path).toList(),
      ));
    }
  }

  Future<void> uploadFiles({
    required String parentType,
    required String parentId,
  }) async {
    if (state is! MediaUploaderInProcess) return;

    final currentState = state as MediaUploaderInProcess;
    if (currentState.selectedFiles.isEmpty) return;

    emit(currentState.copyWith(isUploading: true, error: null));

    try {
      final uploaded = <MediaEntity>[];
      for (final file in currentState.selectedFiles) {
        final media = await repository.uploadMedia(
          file: file,
          parentType: parentType,
          parentId: parentId,
        );
        uploaded.add(media);
      }

      emit(currentState.copyWith(
        selectedFiles: const [],
        uploadedMedia: [...currentState.uploadedMedia, ...uploaded],
        isUploading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isUploading: false, error: e.toString()));
    }
  }

  void reset() {
    emit(MediaUploaderInitial());
  }
}
