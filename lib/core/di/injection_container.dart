import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:field_link/core/network/dio_client.dart';
import 'package:field_link/core/network/api_client.dart';
import 'package:field_link/core/network/network_info.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/services/location_service.dart';
import 'package:field_link/core/utils/biometrics/biometric_auth_service.dart';
import 'package:field_link/core/db/app_database.dart';
import 'package:field_link/core/db/daos/project_dao.dart';
import 'package:field_link/core/db/daos/sync_queue_dao.dart';
import 'package:field_link/core/db/daos/meta_dao.dart';
import 'package:field_link/core/db/daos/user_dao.dart';
import 'package:field_link/core/sync/sync_manager.dart';
import 'package:field_link/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:field_link/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:field_link/features/authentication/domain/repositories/auth_repository.dart';
import 'package:field_link/features/authentication/domain/usecases/login_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/verify_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/setup_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/enable_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/disable_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/request_password_reset_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/confirm_password_reset_usecase.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/core/services/token_refresh_service.dart';
import 'package:field_link/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:field_link/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:field_link/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_link/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:field_link/features/issues/data/datasources/issue_remote_datasource.dart';
import 'package:field_link/features/issues/data/repositories/issue_repository_impl.dart';
import 'package:field_link/features/issues/domain/repositories/issue_repository.dart';

import 'package:field_link/features/issues/presentation/bloc/issues_bloc.dart';
import 'package:field_link/features/requests/data/datasources/request_remote_datasource.dart';
import 'package:field_link/features/requests/data/repositories/request_repository_impl.dart';
import 'package:field_link/features/requests/domain/repositories/request_repository.dart';
import 'package:field_link/features/requests/presentation/cubit/request_create_cubit.dart';
import 'package:field_link/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:field_link/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:field_link/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:field_link/features/notifications/domain/repositories/notification_repository.dart';
import 'package:field_link/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_link/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:field_link/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:field_link/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:field_link/features/profile/domain/repositories/profile_repository.dart';
import 'package:field_link/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_link/features/reports/domain/repositories/report_repository.dart';
import 'package:field_link/features/media/data/datasources/media_remote_datasource.dart';
import 'package:field_link/features/media/data/repositories/media_repository_impl.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies({required String baseUrl}) async {
  DioClient.configure(baseUrl: baseUrl);

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => DioClient.dio);

  // Core Services
  sl.registerLazySingleton(
    () => TokenStorageService(secureStorage: sl(), sharedPreferences: sl()),
  );

  // Initialize Dio with token storage
  DioClient.initialize(sl<TokenStorageService>());

  sl.registerLazySingleton(() => BiometricAuthService());
  sl.registerLazySingleton(() => LocationService());

  sl.registerLazySingleton(
    () => TokenRefreshService(
      tokenStorageService: sl(),
      refreshTokenUseCase: sl(),
    ),
  );

  // Database Layer (Simplified - only essential tables)
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // DAOs (Simplified - only essential DAOs)
  sl.registerLazySingleton<ProjectDao>(() => ProjectDao(sl<AppDatabase>()));
  sl.registerLazySingleton<SyncQueueDao>(() => SyncQueueDao(sl<AppDatabase>()));
  sl.registerLazySingleton<MetaDao>(() => MetaDao(sl<AppDatabase>()));
  sl.registerLazySingleton<UserDao>(() => UserDao(sl<AppDatabase>()));

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl<Dio>()));

  // Core repositories & services (Simplified)
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remoteDataSource: ReportRemoteDataSource(sl()),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<IssueRemoteDataSource>(
    () => IssueRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<IssueRepository>(
    () => IssueRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      db: sl(),
      syncQueueDao: sl(),
      metaDao: sl(),
      apiClient: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      projectDao: sl(),
      metaDao: sl(),
      apiClient: sl(),
      syncManager: sl(),
      tokenStorageService: sl(),
      networkInfo: sl(),
    ),
  );

  // Features - Media
  sl.registerLazySingleton<MediaRemoteDataSource>(
    () => MediaRemoteDataSource(dio: sl()),
  );

  sl.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(remoteDataSource: sl()),
  );

  // Features - Authentication
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorageService: sl(),
      userDao: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyMFAUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SetupMfaUseCase(sl()));
  sl.registerLazySingleton(() => EnableMfaUseCase(sl()));
  sl.registerLazySingleton(() => DisableMfaUseCase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmPasswordResetUseCase(sl()));

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      verifyMFAUseCase: sl(),
      refreshTokenUseCase: sl(),
      setupMfaUseCase: sl(),
      enableMfaUseCase: sl(),
      disableMfaUseCase: sl(),
      requestPasswordResetUseCase: sl(),
      confirmPasswordResetUseCase: sl(),
      biometricAuthService: sl(),
      tokenStorageService: sl(),
      tokenRefreshService: sl(),
    ),
  );

  sl.registerFactory(() => DashboardCubit(repository: sl()));

  sl.registerFactory(() => IssuesBloc(repository: sl()));
  sl.registerFactoryParam<ReportsCubit, DashboardCubit, void>(
    (dashboardCubit, _) => ReportsCubit(
      repository: sl(),
      dashboardCubit: dashboardCubit,
    ),
  );

  // Features - Requests
  sl.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => RequestsCubit(repository: sl()));
  sl.registerFactory(() => RequestCreateCubit(repository: sl()));

  // Features - Notifications (Remote only - no local caching)
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => NotificationsCubit(repository: sl()));

  // Features - Settings
  sl.registerFactory(() => SettingsCubit(
        syncManager: sl(),
        sharedPreferences: sl(),
      ));

  // Features - Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(dio: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
      sharedPreferences: sl(),
      syncManager: sl(),
      syncQueueDao: sl(),
      metaDao: sl(),
      userDao: sl(),
      db: sl(),
    ),
  );

  sl.registerFactory(
    () => ProfileCubit(
      profileRepository: sl(),
      authRepository: sl(),
    ),
  );
}

/// Backward-compatible init function that uses default base URL.
/// For new code, use initDependencies(baseUrl: '...') instead.
Future<void> init() async {
  await initDependencies(baseUrl: 'http://72.61.19.130:8080');
}
