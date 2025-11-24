import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../services/token_storage_service.dart';
import '../utils/biometrics/biometric_auth_service.dart';
import '../db/app_database.dart';
import '../db/daos/project_dao.dart';
import '../db/daos/sync_queue_dao.dart';
import '../db/daos/analytics_dao.dart';
import '../db/daos/report_dao.dart';
import '../db/daos/issue_dao.dart';
import '../db/daos/media_dao.dart';
import '../db/daos/conflict_dao.dart';
import '../db/daos/meta_dao.dart';
import '../db/repositories/report_repository.dart';
import '../db/repositories/media_repository.dart';
import '../sync/sync_manager.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/verify_mfa_usecase.dart';
import '../../features/authentication/domain/usecases/refresh_token_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/presentation/bloc/auth/auth_bloc.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/presentation/bloc/dashboard_cubit.dart';

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

  // Database Layer
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // DAOs
  sl.registerLazySingleton<ProjectDao>(() => ProjectDao(sl<AppDatabase>()));
  sl.registerLazySingleton<SyncQueueDao>(() => SyncQueueDao(sl<AppDatabase>()));
  sl.registerLazySingleton<AnalyticsDao>(() => AnalyticsDao(sl<AppDatabase>()));
  sl.registerLazySingleton<ReportDao>(() => ReportDao(sl<AppDatabase>()));
  sl.registerLazySingleton<IssueDao>(() => IssueDao(sl<AppDatabase>()));
  sl.registerLazySingleton<MediaDao>(() => MediaDao(sl<AppDatabase>()));
  sl.registerLazySingleton<ConflictDao>(() => ConflictDao(sl<AppDatabase>()));
  sl.registerLazySingleton<MetaDao>(() => MetaDao(sl<AppDatabase>()));

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl<Dio>()));

  // Core repositories & services
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepository(
      db: sl(),
      reportDao: sl(),
      syncQueueDao: sl(),
      apiClient: sl(),
    ),
  );

  sl.registerLazySingleton<MediaRepository>(
    () => MediaRepository(
      db: sl(),
      mediaDao: sl(),
      syncQueueDao: sl(),
      apiClient: sl(),
    ),
  );

  sl.registerLazySingleton<SyncManager>(
    () => SyncManager(
      db: sl(),
      syncQueueDao: sl(),
      metaDao: sl(),
      conflictDao: sl(),
      apiClient: sl(),
      reportRepository: sl(),
      mediaRepository: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      projectDao: sl(),
      analyticsDao: sl(),
      metaDao: sl(),
      apiClient: sl(),
      syncManager: sl(),
      tokenStorageService: sl(),
    ),
  );

  // Features - Authentication
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorageService: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => VerifyMFAUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // BLoCs
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

  sl.registerFactory(() => DashboardCubit(repository: sl()));
}

/// Backward-compatible init function that uses default base URL.
/// For new code, use initDependencies(baseUrl: '...') instead.
Future<void> init() async {
  await initDependencies(baseUrl: 'http://72.61.19.130:8080');
}
