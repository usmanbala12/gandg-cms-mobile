import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../../../features/authentication/domain/repositories/auth_repository.dart';
import '../../domain/entities/storage_stats_entity.dart';
import '../../domain/entities/sync_status_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
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

      // Load preferences
      final preferences = await profileRepository.getPreferences();

      // Load storage stats
      final storageStats = await profileRepository.getStorageStats();

      // Get initial sync status
      final syncStatusStream =
          profileRepository.watchSyncStatus().asBroadcastStream();
      final syncStatus = await syncStatusStream.first;

      // Emit loaded state
      emit(ProfileLoaded(
        user: user,
        preferences: preferences,
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

  /// Update notification preferences.
  Future<void> updatePreferences(UserPreferencesEntity preferences) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;

    try {
      logger.i('Updating notification preferences');
      await profileRepository.updatePreferences(preferences);

      emit(currentState.copyWith(
        preferences: preferences,
        message: 'Preferences updated successfully',
      ));

      logger.i('Notification preferences updated');
    } catch (e) {
      logger.e('Error updating preferences: $e');
      emit(currentState.copyWith(
        message: 'Failed to update preferences: $e',
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

  @override
  Future<void> close() {
    _syncStatusSubscription?.cancel();
    return super.close();
  }
}
