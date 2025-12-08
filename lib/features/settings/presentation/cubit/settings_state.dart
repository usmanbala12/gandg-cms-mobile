part of 'settings_cubit.dart';

enum SettingsStatus {
  initial,
  loading,
  loaded,
  syncing,
  syncSuccess,
  syncError
}

class SettingsState extends Equatable {
  final SettingsStatus status;
  final ThemeMode themeMode;
  final String cacheSize;
  final String mediaSize;
  final DateTime? lastSyncTime;
  final String? errorMessage;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.themeMode = ThemeMode.system,
    this.cacheSize = '...',
    this.mediaSize = '...',
    this.lastSyncTime,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    ThemeMode? themeMode,
    String? cacheSize,
    String? mediaSize,
    DateTime? lastSyncTime,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      themeMode: themeMode ?? this.themeMode,
      cacheSize: cacheSize ?? this.cacheSize,
      mediaSize: mediaSize ?? this.mediaSize,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        themeMode,
        cacheSize,
        mediaSize,
        lastSyncTime,
        errorMessage,
      ];
}
