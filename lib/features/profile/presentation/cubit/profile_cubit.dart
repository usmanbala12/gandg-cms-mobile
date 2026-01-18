import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../../features/authentication/domain/repositories/auth_repository.dart';
import '../../domain/entities/storage_stats_entity.dart';
import '../../domain/entities/sync_status_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_state.dart';

/// Cubit for managing profile screen state.
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;
  final AuthRepository authRepository;
  final Logger logger;

  StreamSubscription<SyncStatusEntity>? _syncStatusSubscription;

  ProfileCubit({
    required this.profileRepository,
    required this.authRepository,
    Logger? logger,
  })  : logger = logger ?? Logger(),
        super(const ProfileInitial());

  /// Initialize profile screen - load all data.
  Future<void> init() async {
    emit(const ProfileLoading());

    try {
      logger.i('Initializing profile screen');

      // Load user profile
      final userResult = await profileRepository.getUserProfile();
      final user = userResult.data;

      // Load storage stats
      final storageStats = await profileRepository.getStorageStats();

      // Get initial sync status
      final syncStatusStream =
          profileRepository.watchSyncStatus().asBroadcastStream();
      final syncStatus = await syncStatusStream.first;

      // Emit loaded state
      emit(ProfileLoaded(
        user: user,
        syncStatus: syncStatus,
        storageStats: storageStats,
        message: userResult.message,
      ));

      // Subscribe to sync status updates
      _syncStatusSubscription = syncStatusStream.listen(
        (status) {
          if (state is ProfileLoaded) {
            emit((state as ProfileLoaded).copyWith(syncStatus: status));
          }
        },
        onError: (error) {
          logger.e('Error in sync status stream: $error');
        },
      );

      logger.i('Profile screen initialized successfully');
    } catch (e) {
      logger.e('Error initializing profile: $e');
      emit(ProfileError(message: 'Failed to load profile: $e'));
    }
  }

  /// Refresh user profile from server.
  Future<void> refreshUser() async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isRefreshingUser: true));

    try {
      logger.i('Refreshing user profile');
      final userResult = await profileRepository.getUserProfile(
        forceRemote: true,
      );

      emit(currentState.copyWith(
        user: userResult.data,
        isRefreshingUser: false,
        message: userResult.message,
      ));

      logger.i('User profile refreshed successfully');
    } catch (e) {
      logger.e('Error refreshing user profile: $e');
      emit(currentState.copyWith(
        isRefreshingUser: false,
        message: 'Failed to refresh profile: $e',
      ));
    }
  }



  /// Trigger manual sync.
  Future<void> syncNow() async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isSyncing: true));

    try {
      logger.i('Triggering manual sync');
      await profileRepository.syncNow();

      // Refresh storage stats after sync
      final storageStats = await profileRepository.getStorageStats();

      emit(currentState.copyWith(
        isSyncing: false,
        storageStats: storageStats,
        message: 'Sync completed successfully',
      ));

      logger.i('Manual sync completed');
    } catch (e) {
      logger.e('Error during manual sync: $e');
      emit(currentState.copyWith(
        isSyncing: false,
        message: 'Sync failed: $e',
      ));
    }
  }

  /// Clear old cached data.
  Future<void> clearOldCache() async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isClearingCache: true));

    try {
      logger.i('Clearing old cache');
      await profileRepository.clearOldCache();

      // Refresh storage stats
      final storageStats = await profileRepository.getStorageStats();

      emit(currentState.copyWith(
        isClearingCache: false,
        storageStats: storageStats,
        message: 'Old cache cleared successfully',
      ));

      logger.i('Old cache cleared');
    } catch (e) {
      logger.e('Error clearing old cache: $e');
      emit(currentState.copyWith(
        isClearingCache: false,
        message: 'Failed to clear cache: $e',
      ));
    }
  }

  /// Clear media cache.
  Future<void> clearMediaCache() async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isClearingCache: true));

    try {
      logger.i('Clearing media cache');
      await profileRepository.clearMediaCache();

      // Refresh storage stats
      final storageStats = await profileRepository.getStorageStats();

      emit(currentState.copyWith(
        isClearingCache: false,
        storageStats: storageStats,
        message: 'Media cache cleared successfully',
      ));

      logger.i('Media cache cleared');
    } catch (e) {
      logger.e('Error clearing media cache: $e');
      emit(currentState.copyWith(
        isClearingCache: false,
        message: 'Failed to clear media cache: $e',
      ));
    }
  }

  /// Logout user.
  Future<void> logout() async {
    try {
      logger.i('Logging out user');
      final result = await authRepository.logout();

      result.fold(
        (failure) {
          logger.e('Logout failed: $failure');
          if (state is ProfileLoaded) {
            emit((state as ProfileLoaded).copyWith(
              message: 'Logout failed: ${failure.toString()}',
            ));
          }
        },
        (_) {
          logger.i('Logout successful');
          emit(const ProfileLoggedOut());
        },
      );
    } catch (e) {
      logger.e('Error during logout: $e');
      if (state is ProfileLoaded) {
        emit((state as ProfileLoaded).copyWith(
          message: 'Logout error: $e',
        ));
      }
    }
  }

  /// Update user profile (full name and email).
  Future<void> updateProfile({
    required String fullName,
    required String email,
  }) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isUpdatingProfile: true));

    try {
      logger.i('Updating user profile');
      final result = await profileRepository.updateProfile(
        fullName: fullName,
        email: email,
      );

      if (result.hasError) {
        emit(currentState.copyWith(
          isUpdatingProfile: false,
          message: result.message ?? 'Failed to update profile',
        ));
        return;
      }

      emit(currentState.copyWith(
        user: result.data,
        isUpdatingProfile: false,
        message: 'Profile updated successfully',
      ));

      logger.i('Profile updated successfully');
    } catch (e) {
      logger.e('Error updating profile: $e');
      emit(currentState.copyWith(
        isUpdatingProfile: false,
        message: 'Failed to update profile: $e',
      ));
    }
  }

  /// Change user password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(currentState.copyWith(isChangingPassword: true));

    try {
      logger.i('Changing user password');
      final result = await profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (result.hasError) {
        emit(currentState.copyWith(
          isChangingPassword: false,
          message: result.message ?? 'Failed to change password',
        ));
        return;
      }

      emit(currentState.copyWith(
        isChangingPassword: false,
        message: 'Password changed successfully',
      ));

      logger.i('Password changed successfully');
    } catch (e) {
      logger.e('Error changing password: $e');
      emit(currentState.copyWith(
        isChangingPassword: false,
        message: 'Failed to change password: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _syncStatusSubscription?.cancel();
    return super.close();
  }
}
