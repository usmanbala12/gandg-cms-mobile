part of 'profile_cubit.dart';

/// Base state for profile screen.
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile screen is first loaded.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state while fetching profile data.
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Loaded state with all profile data.
class ProfileLoaded extends ProfileState {
  final UserProfileEntity? user;
  final SyncStatusEntity syncStatus;
  final StorageStatsEntity storageStats;
  final bool isRefreshingUser;
  final bool isSyncing;
  final bool isClearingCache;
  final String? message;

  const ProfileLoaded({
    this.user,
    required this.syncStatus,
    required this.storageStats,
    this.isRefreshingUser = false,
    this.isSyncing = false,
    this.isClearingCache = false,
    this.message,
  });

  ProfileLoaded copyWith({
    UserProfileEntity? user,
    SyncStatusEntity? syncStatus,
    StorageStatsEntity? storageStats,
    bool? isRefreshingUser,
    bool? isSyncing,
    bool? isClearingCache,
    String? message,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      syncStatus: syncStatus ?? this.syncStatus,
      storageStats: storageStats ?? this.storageStats,
      isRefreshingUser: isRefreshingUser ?? this.isRefreshingUser,
      isSyncing: isSyncing ?? this.isSyncing,
      isClearingCache: isClearingCache ?? this.isClearingCache,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        user,
        syncStatus,
        storageStats,
        isRefreshingUser,
        isSyncing,
        isClearingCache,
        message,
      ];
}

/// Error state when profile data fails to load.
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when user has logged out.
class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
