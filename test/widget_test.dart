// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:field_link/app.dart';
import 'package:field_link/core/di/injection_container.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/utils/biometrics/biometric_auth_service.dart';
import 'package:field_link/features/authentication/domain/usecases/login_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/verify_mfa_usecase.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockVerifyMFAUseCase extends Mock implements VerifyMFAUseCase {}

class MockRefreshTokenUseCase extends Mock implements RefreshTokenUseCase {}

class MockBiometricAuthService extends Mock implements BiometricAuthService {}

class MockTokenStorageService extends Mock implements TokenStorageService {}

void main() {
  late MockLoginUseCase loginUseCase;
  late MockLogoutUseCase logoutUseCase;
  late MockVerifyMFAUseCase verifyMFAUseCase;
  late MockRefreshTokenUseCase refreshTokenUseCase;
  late MockBiometricAuthService biometricAuthService;
  late MockTokenStorageService tokenStorageService;

  setUp(() async {
    await sl.reset();

    loginUseCase = MockLoginUseCase();
    logoutUseCase = MockLogoutUseCase();
    verifyMFAUseCase = MockVerifyMFAUseCase();
    refreshTokenUseCase = MockRefreshTokenUseCase();
    biometricAuthService = MockBiometricAuthService();
    tokenStorageService = MockTokenStorageService();

    sl.registerLazySingleton<LoginUseCase>(() => loginUseCase);
    sl.registerLazySingleton<LogoutUseCase>(() => logoutUseCase);
    sl.registerLazySingleton<VerifyMFAUseCase>(() => verifyMFAUseCase);
    sl.registerLazySingleton<RefreshTokenUseCase>(() => refreshTokenUseCase);
    sl.registerLazySingleton<BiometricAuthService>(() => biometricAuthService);
    sl.registerLazySingleton<TokenStorageService>(() => tokenStorageService);

    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: sl(),
        logoutUseCase: sl(),
        verifyMFAUseCase: sl(),
        refreshTokenUseCase: sl(),
        biometricAuthService: sl(),
        tokenStorageService: sl(),
      ),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('App renders login page when unauthenticated', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
