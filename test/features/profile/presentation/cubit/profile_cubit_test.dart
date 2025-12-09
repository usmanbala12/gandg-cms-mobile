import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:field_link/features/profile/domain/entities/user_profile_entity.dart';
import 'package:field_link/features/profile/domain/entities/user_preferences_entity.dart';
import 'package:field_link/features/profile/domain/entities/sync_status_entity.dart';
import 'package:field_link/features/profile/domain/entities/storage_stats_entity.dart';
import 'package:field_link/features/profile/domain/repositories/profile_repository.dart';
import 'package:field_link/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_link/features/authentication/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

// Mock classes for mocktail
class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ProfileCubit cubit;
  late MockProfileRepository mockProfileRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockAuthRepository = MockAuthRepository();
    cubit = ProfileCubit(
      profileRepository: mockProfileRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ProfileCubit', () {
    const testUser = UserProfileEntity(
      id: '1',
      fullName: 'John Doe',
      email: 'john@example.com',
      role: 'Engineer',
    );

    const testPreferences = UserPreferencesEntity(
      appNotificationsEnabled: true,
      emailNotificationsEnabled: true,
    );

    final testSyncStatus = SyncStatusEntity(
      lastFullSyncAt: DateTime.now(),
      pendingQueueCount: 5,
      conflictCount: 2,
    );

    const testStorageStats = StorageStatsEntity(
      dbSizeBytes: 1024000,
      mediaSizeBytes: 2048000,
      recordsByTable: {'issues': 10, 'reports': 5},
    );

    test('initial state is ProfileInitial', () {
      expect(cubit.state, isA<ProfileInitial>());
    });

    test('logout calls AuthRepository and emits ProfileLoggedOut', () async {
      // Arrange
      when(mockAuthRepository.logout() as Function()).thenAnswer(
        (_) async => const Right(null),
      );

      // Act
      await cubit.logout();

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
      expect(cubit.state, isA<ProfileLoggedOut>());
    });

    test('updatePreferences updates state with new preferences', () async {
      // Arrange
      when(() => mockProfileRepository.updatePreferences(any()))
          .thenAnswer((_) async => Future.value());

      // Set initial loaded state
      cubit.emit(ProfileLoaded(
        user: testUser,
        preferences: testPreferences,
        syncStatus: testSyncStatus,
        storageStats: testStorageStats,
      ));

      const newPreferences = UserPreferencesEntity(
        appNotificationsEnabled: false,
        emailNotificationsEnabled: true,
      );

      // Act
      await cubit.updatePreferences(newPreferences);

      // Assert
      verify(() => mockProfileRepository.updatePreferences(newPreferences))
          .called(1);
      expect(cubit.state, isA<ProfileLoaded>());
      final state = cubit.state as ProfileLoaded;
      expect(state.preferences.appNotificationsEnabled, false);
    });
  });
}
