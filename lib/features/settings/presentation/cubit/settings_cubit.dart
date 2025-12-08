import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/sync/sync_manager.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SyncManager syncManager;
  final SharedPreferences sharedPreferences;

  static const String _themeKey = 'theme_mode';

  SettingsCubit({
    required this.syncManager,
    required this.sharedPreferences,
  }) : super(const SettingsState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeIndex = sharedPreferences.getInt(_themeKey);
    if (themeIndex != null) {
      final themeMode = ThemeMode.values[themeIndex];
      emit(state.copyWith(themeMode: themeMode));
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await sharedPreferences.setInt(_themeKey, newMode.index);
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> triggerSync(String projectId) async {
    emit(state.copyWith(status: SettingsStatus.syncing));
    try {
      await syncManager.runSyncCycle(projectId: projectId);
      emit(state.copyWith(status: SettingsStatus.syncSuccess));
      // Reset status after a delay or keep it?
      // Let's reload storage info to refresh last sync time
      await loadStorageInfo();
    } catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.syncError,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadStorageInfo() async {
    // TODO: Implement actual storage info loading
    emit(state.copyWith(
      status: SettingsStatus.loaded,
      cacheSize: '12.5 MB',
      mediaSize: '45.2 MB',
      lastSyncTime: DateTime.now(),
    ));
  }
}
