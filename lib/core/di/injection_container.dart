import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/token_storage_service.dart';
import '../utils/biometrics/biometric_auth_service.dart';
import '../db/app_database.dart';
import '../db/daos/project_dao.dart';
import '../db/daos/sync_queue_dao.dart';
import '../db/daos/analytics_dao.dart';
import '../db/daos/report_dao.dart';
import '../db/daos/issue_dao.dart';
import '../db/daos/issue_comment_dao.dart';
import '../db/daos/issue_history_dao.dart';
import '../db/daos/issue_media_dao.dart';
import '../db/daos/media_dao.dart';
import '../db/daos/conflict_dao.dart';
import '../db/daos/meta_dao.dart';
import '../db/daos/request_dao.dart';
import '../db/daos/user_dao.dart';
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
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/data/repositories/media_repository_impl.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/issues/data/datasources/issue_remote_datasource.dart';
import '../../features/issues/data/repositories/issue_repository_impl.dart';
import '../../features/issues/domain/repositories/issue_repository.dart';

import '../../features/issues/presentation/bloc/issues_bloc.dart';
import '../../features/requests/data/datasources/request_remote_datasource.dart';
import '../../features/requests/data/repositories/request_repository_impl.dart';
import '../../features/requests/domain/repositories/request_repository.dart';
import '../../features/requests/presentation/cubit/request_create_cubit.dart';
import '../../features/requests/presentation/cubit/requests_cubit.dart';
import '../../core/db/daos/notification_dao.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

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
  sl.registerLazySingleton<IssueCommentDao>(
    () => IssueCommentDao(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<IssueHistoryDao>(
    () => IssueHistoryDao(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<IssueMediaDao>(
    () => IssueMediaDao(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<MediaDao>(() => MediaDao(sl<AppDatabase>()));
  sl.registerLazySingleton<ConflictDao>(() => ConflictDao(sl<AppDatabase>()));
  sl.registerLazySingleton<MetaDao>(() => MetaDao(sl<AppDatabase>()));
  sl.registerLazySingleton<RequestDao>(() => RequestDao(sl<AppDatabase>()));
  sl.registerLazySingleton<UserDao>(() => UserDao(sl<AppDatabase>()));

  // Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // API Client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl<Dio>()));

  // Core repositories & services
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      db: sl(),
      reportDao: sl(),
      syncQueueDao: sl(),
      remoteDataSource: ReportRemoteDataSource(sl()),
      mediaDao: sl(),
      metaDao: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<MediaRepository>(
    () => MediaRepositoryImpl(
      db: sl(),
      mediaDao: sl(),
      syncQueueDao: sl(),
      apiClient: sl(),
    ),
  );

  sl.registerLazySingleton<IssueRemoteDataSource>(
    () => IssueRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<IssueRepository>(
    () => IssueRepositoryImpl(
      db: sl(),
      issueDao: sl(),
      issueCommentDao: sl(),
      issueHistoryDao: sl(),
      issueMediaDao: sl(),
      syncQueueDao: sl(),
      metaDao: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
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
      issueRepository: sl(),
      requestRepository: sl(),
      issueDao: sl(),
      issueCommentDao: sl(),
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
      networkInfo: sl(),
    ),
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

  sl.registerFactory(() => IssuesBloc(repository: sl()));

  // Features - Requests
  sl.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(
      db: sl(),
      requestDao: sl(),
      metaDao: sl(),
      syncQueueDao: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(() => RequestsCubit(repository: sl()));
  sl.registerFactory(() => RequestCreateCubit(repository: sl()));

  // Features - Notifications
  sl.registerLazySingleton<NotificationDao>(
    () => NotificationDao(sl<AppDatabase>()),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      notificationDao: sl(),
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
      conflictDao: sl(),
      metaDao: sl(),
      mediaDao: sl(),
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
