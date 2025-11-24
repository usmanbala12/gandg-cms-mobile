# Field Link - AI Agent Instructions

## Project Overview
Field Link is a **project-scoped, offline-first** Flutter mobile app for field management. Every operation must filter by `project_id`, and all features work offline-first with automatic background sync.

## Architecture: Feature-Based Clean Architecture

### Layer Structure (3-layer per feature)
```
features/<feature_name>/
├── data/           # Models, DataSources, RepositoryImpl
│   ├── models/     # JSON serializable, extend entities
│   ├── datasources/ # Remote & Local data sources
│   └── repositories/ # Concrete implementations
├── domain/         # Entities, Abstract Repositories, UseCases
│   ├── entities/   # Pure Dart objects, extend Equatable
│   ├── repositories/ # Abstract classes
│   └── usecases/   # Single responsibility use cases
└── presentation/   # BLoCs, Pages, Widgets
    ├── bloc/       # State management with flutter_bloc
    ├── pages/      # Full screen widgets
    └── widgets/    # Reusable UI components
```

**Critical**: Never skip layers. Data flows: `Page → BLoC → UseCase → Repository → DataSource → API/DB`.

## Core Patterns & Principles

### 1. Project Scoping (MANDATORY)
```dart
// ❌ NEVER do this
Future<List<Report>> getReports() { ... }

// ✅ ALWAYS filter by projectId
Future<Either<Failure, List<Report>>> getReports(String projectId) async {
  return reportDao.getReportsByProject(projectId);
}
```
Every API call, database query, and UI screen MUST be scoped to the active `project_id`.

### 2. Offline-First Flow
```
User Action → Write to Drift DB → Add to SyncQueue → Update UI from local DB
           ↓ (background)
           Sync with server → Update local DB → Remove from queue
```
**Never** wait for server responses. Write locally first, sync in background via `SyncManager`.

### 3. Error Handling with Either
```dart
// All repositories return Either<Failure, T>
Future<Either<Failure, User>> login(String email, String password);

// Usage in use cases
final result = await repository.login(email, password);
return result.fold(
  (failure) => Left(failure),
  (user) => Right(user),
);
```
Use `dartz` package. Failure types: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `ValidationFailure`.

### 4. State Management with BLoC
```dart
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  
  LoginBloc(this.loginUseCase) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }
  
  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await loginUseCase(email: event.email, password: event.password);
    result.fold(
      (failure) => emit(LoginFailure(message: failure.message)),
      (user) => emit(LoginSuccess(user: user)),
    );
  }
}
```

### 5. Dependency Injection (GetIt)
Register in `lib/core/di/injection_container.dart`:
```dart
// Initialize in main.dart
await init(); // or initDependencies(baseUrl: '...')

// Access anywhere
final authBloc = sl<AuthBloc>();
```

## Critical Implementation Details

### Database: Drift ORM
- **Code generation required**: Run `flutter pub run build_runner build` after table/DAO changes
- **All tables** in `lib/core/db/tables/`, **DAOs** in `lib/core/db/daos/`
- Use `sync_status` field: `'pending'`, `'synced'`, `'conflict'`
- Example DAO query:
```dart
Future<List<Report>> getReportsByProject(String projectId) {
  return (select(reports)..where((t) => t.projectId.equals(projectId))).get();
}
```

### Sync Queue Pattern
```dart
// After local write, enqueue for sync
await reportRepository.createReportLocallyAndEnqueue(
  projectId,
  reportData,
);

// SyncManager handles background upload
await syncManager.runSyncCycle(projectId: projectId);
```
See `lib/core/sync/sync_manager.dart` for conflict resolution.

### Authentication Flow
1. Login → Store tokens in `flutter_secure_storage` via `TokenStorageService`
2. `AuthInterceptor` (Dio) auto-adds `Authorization: Bearer <token>` to requests
3. On 401, interceptor auto-refreshes token
4. Biometric login stores credentials securely for quick re-auth

### Navigation with GetX
```dart
Get.to(() => DashboardPage());
Get.offAll(() => LoginPage()); // Clear stack
```

## Naming Conventions

### Files (snake_case)
- Entities: `user.dart`
- Models: `user_model.dart`
- Repositories: `auth_repository.dart` (abstract), `auth_repository_impl.dart`
- Use Cases: `login_usecase.dart`
- BLoCs: `auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`

### Classes (PascalCase)
- Prefix utility classes with `T`: `TValidator`, `TDeviceUtils`, `TAppTheme`
- Suffix: `UserModel`, `AuthRepository`, `LoginUseCase`, `AuthBloc`

### Constants
- API paths: `lib/core/utils/constants/api_constants.dart`
- Colors: `lib/core/utils/constants/colors.dart`
- Strings: `lib/core/utils/constants/text_strings.dart`

## Essential Commands

```bash
# Code generation (after Drift/JSON changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch

# Run tests with coverage
flutter test --coverage

# Debug database (use DbInspectorPage in debug mode)
# See lib/core/db/debug/db_inspector_page.dart
```

## Testing Strategy
- Unit tests for UseCases and Repositories using `mocktail`
- Widget tests for UI components
- Integration tests for sync flows
- Mock `AppDatabase` with `AppDatabase.forTesting(testDb)`

## Key Files Reference
- **DI Setup**: `lib/core/di/injection_container.dart`
- **Database**: `lib/core/db/app_database.dart`
- **Sync Engine**: `lib/core/sync/sync_manager.dart`
- **Auth Interceptor**: `lib/core/network/auth_interceptor.dart`
- **API Base URL**: Set in `main.dart` via `DioClient.configure(baseUrl: '...')`

## Documentation
- **Full context**: `PROJECT_CONTEXT_SUMMARY.md`
- **Phase 2 guide**: `PHASE_2_IMPLEMENTATION_GUIDE.md`
- **Database schema**: `DATABASE_SCHEMA_GUIDE.md`
- **Dev quick ref**: `DEVELOPER_QUICK_REFERENCE.md`
- **Offline patterns**: `OFFLINE_FIRST_QUICK_START.md`

## Current Status
✅ **Phase 1 Complete**: Core setup, authentication, database schema  
🔄 **Phase 2 In Progress**: Project management, home screen  
⏳ **Pending**: Reports, issues, media upload, notifications, full sync engine

## When Creating New Features
1. Create feature folder under `lib/features/<name>/`
2. Start with `domain/` layer (entities, repos, use cases)
3. Implement `data/` layer (models, data sources, repo impl)
4. Add to DI container (`injection_container.dart`)
5. Build `presentation/` layer (BLoC, pages, widgets)
6. **Always** filter by `project_id` in all repository methods
7. Design for offline: write to Drift first, sync later
8. Run `build_runner` if using Drift tables or JSON serialization
