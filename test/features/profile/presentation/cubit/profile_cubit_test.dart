import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:field_link/features/profile/domain/entities/user_profile_entity.dart';
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
    test('initial state is ProfileInitial', () {
      expect(cubit.state, isA<ProfileInitial>());
    });
  });
}
