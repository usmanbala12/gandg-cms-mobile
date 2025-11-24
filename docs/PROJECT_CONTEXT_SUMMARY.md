# Field Link - Project Context Summary

## Project Overview
**Field Link** is a project-scoped, offline-first mobile management system built with Flutter. It enables organizations to manage multiple projects with secure authentication, role-based access control, and comprehensive offline capabilities.

### Core Principles
- **Project Scoping**: Every API call, UI screen, and database operation is filtered by `project_id`
- **Offline-First**: Users can read/write offline; data syncs automatically when online
- **Feature-Based Clean Architecture**: Modular, self-contained features with clear separation of concerns
- **Role-Based Access Control**: Actions limited by user's project and role

---

## Tech Stack

### Frontend & Architecture
- **Framework**: Flutter (Dart)
- **Architecture**: Feature-Based Clean Architecture
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: GetIt
- **Navigation**: GetX

### Storage & Offline
- **Local Database**: Drift (SQLite)
- **Secure Storage**: flutter_secure_storage
- **General Storage**: GetStorage, SharedPreferences

### Networking & Sync
- **HTTP Client**: Dio with interceptors
- **Background Jobs**: WorkManager + BackgroundFetch
- **Connectivity**: connectivity_plus

### Authentication & Security
- **Biometrics**: local_auth
- **Permissions**: permission_handler

### Media & Utilities
- **Image Picker**: image_picker
- **Logging**: logger
- **Internationalization**: intl
- **Utilities**: dartz (Either/Result pattern), equatable

### Notifications (Commented - Ready for Integration)
- **Firebase Cloud Messaging**: firebase_messaging
- **Local Notifications**: flutter_local_notifications

---

## Project Structure

```
lib/
├── core/
│   ├── database/          # Drift database setup & migrations
│   ├── di/                # Dependency injection (GetIt)
│   ├── error/             # Failure classes & error handling
│   ├── network/           # Dio client & interceptors
│   ├── utils/
│   │   ├── biometrics/    # Biometric authentication
│   │   ├── constants/     # API endpoints, colors, enums, strings
│   │   ├── device/        # Device utilities
│   │   ├── formatters/    # Data formatting
│   │   ├── helpers/       # Helper functions
│   │   ├── http/          # HTTP utilities
│   │   ├── local_storage/ # Storage utilities
│   │   ├── logging/       # Logger setup
│   │   ├── permissions/   # Permission handling
│   │   ├── theme/         # Theme configuration
│   │   ├── validators/    # Input validation
│   │   └── widgets/       # Reusable widgets
│   └── widgets/           # Core UI components
│
├── features/
│   ├── authentication/    # Auth module (Phase 2)
│   │   ├── data/          # Repositories, data sources, models
│   │   ├── domain/        # Entities, repositories (abstract), use cases
│   │   └── presentation/  # BLoCs, pages, widgets
│   │
│   ├── project_management/ # Project selection & dashboard (Phase 2)
│   ├── reports/           # Reports CRUD (Phase 3)
│   ├── issues/            # Issues management (Phase 3)
│   ├── requests/          # Approval requests (Phase 3)
│   ├── media/             # Media upload/download (Phase 4)
│   ├── notifications/     # Push & local notifications (Phase 5)
│   ├── sync/              # Sync engine & conflict resolution (Phase 4)
│   ├── dashboard/         # Analytics & overview (Phase 5)
���   └── home/              # Home screen (Phase 2)
│
├── app.dart               # App configuration & routing
└── main.dart              # Entry point
```

---

## Implementation Phases

### Phase 1: Project Setup ✅ (Weeks 1-2)
- [x] Flutter project initialization
- [x] Dependency setup (pubspec.yaml)
- [x] Folder structure created
- [x] Core utilities scaffolded
- [x] DI container initialized
- [x] Theme configuration
- [x] Biometric service setup

**Current Status**: Foundation complete. Ready for Phase 2.

### Phase 2: Authentication + Project Selection (Weeks 3-4)
**Status**: In Progress

#### Authentication Module
- [ ] **Data Layer**
  - [ ] AuthRemoteDataSource (API calls)
  - [ ] AuthLocalDataSource (token caching)
  - [ ] AuthRepositoryImpl (concrete implementation)
  - [ ] Models (User, AuthResponse, MFA)
  
- [ ] **Domain Layer** (Partially Complete)
  - [x] User entity
  - [x] AuthRepository (abstract)
  - [x] LoginUseCase
  - [ ] MFAVerifyUseCase
  - [ ] RefreshTokenUseCase
  - [ ] LogoutUseCase
  - [ ] BiometricLoginUseCase
  
- [ ] **Presentation Layer** (Partially Complete)
  - [x] LoginBloc with biometric support
  - [x] LoginScreen UI
  - [ ] MFAScreen (needs completion)
  - [ ] BiometricSetupScreen
  - [ ] ProjectSelectionScreen
  - [ ] LogoutDialog

#### Project Management Module
- [ ] ProjectRepository & DAO
- [ ] ProjectBloc
- [ ] ProjectListScreen
- [ ] ProjectDetailsScreen
- [ ] Active project context management

#### Home Module
- [ ] HomeScreen with navigation
- [ ] Bottom navigation setup

### Phase 3: Reports, Issues, Requests (Weeks 5-6)
- [ ] Reports module (CRUD + offline)
- [ ] Issues module (CRUD + comments)
- [ ] Requests module (approval workflow)
- [ ] Offline storage integration for all three

### Phase 4: Media + Sync Engine (Weeks 7-8)
- [ ] Media module (upload/download)
- [ ] Sync engine & background jobs
- [ ] Conflict resolution UI
- [ ] Retry logic with exponential backoff

### Phase 5: Dashboard + Notifications (Week 9)
- [ ] Dashboard with analytics
- [ ] Notifications module
- [ ] Firebase Cloud Messaging setup
- [ ] Local notifications

### Phase 6: Testing & Optimization (Week 10)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] CI/CD setup (GitHub Actions/Codemagic)

---

## API Endpoints Reference

### Authentication
```
POST   /api/v1/auth/login
POST   /api/v1/auth/mfa/verify
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/mfa/setup
POST   /api/v1/auth/mfa/enable
POST   /api/v1/auth/mfa/disable
POST   /api/v1/auth/password-reset/*
```

### Projects
```
GET    /api/v1/projects
GET    /api/v1/projects/{id}
GET    /api/v1/projects/{id}/approval-workflows
GET    /api/v1/projects/{id}/media/gallery
```

### Reports
```
GET    /api/v1/projects/{id}/reports
GET    /api/v1/reports/{id}
GET    /api/v1/reports/search
GET    /api/v1/reports/{id}/media
GET    /api/v1/reports/{id}/comments
POST   /api/v1/reports
PUT    /api/v1/reports/{id}
DELETE /api/v1/reports/{id}
```

### Issues
```
GET    /api/v1/projects/{id}/issues
GET    /api/v1/issues/{id}
POST   /api/v1/issues/{id}/assign
PUT    /api/v1/issues/{id}/status
POST   /api/v1/issues/{id}/comments
POST   /api/v1/issues/{id}/media
POST   /api/v1/issues
PUT    /api/v1/issues/{id}
DELETE /api/v1/issues/{id}
```

### Requests
```
GET    /api/v1/projects/{id}/requests
GET    /api/v1/projects/{id}/requests/analytics
GET    /api/v1/requests/{id}
POST   /api/v1/requests/{id}/approve
POST   /api/v1/requests/{id}/reject
GET    /api/v1/requests/pending
POST   /api/v1/requests
PUT    /api/v1/requests/{id}
DELETE /api/v1/requests/{id}
```

### Media
```
GET    /api/v1/media
POST   /api/v1/media/upload
GET    /api/v1/media/{id}
GET    /api/v1/media/{id}/download
GET    /api/v1/projects/{id}/media/gallery
```

### Notifications
```
GET    /api/v1/notifications
PUT    /api/v1/notifications/{id}/read
```

### Sync
```
POST   /api/v1/sync/batch
GET    /api/v1/sync/download
GET    /api/v1/sync/conflicts
POST   /api/v1/sync/conflicts/{id}/resolve
```

---

## Database Schema (Drift)

### Core Tables
```sql
-- Users
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- User Projects (Many-to-Many)
CREATE TABLE user_projects (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  project_id TEXT NOT NULL,
  role TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE(user_id, project_id)
);

-- Projects
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  start_date DATETIME,
  end_date DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Reports
CREATE TABLE reports (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  created_by TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  sync_status TEXT DEFAULT 'synced',
  FOREIGN KEY (project_id) REFERENCES projects(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Issues
CREATE TABLE issues (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  priority TEXT NOT NULL,
  assigned_to TEXT,
  created_by TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  sync_status TEXT DEFAULT 'synced',
  FOREIGN KEY (project_id) REFERENCES projects(id),
  FOREIGN KEY (assigned_to) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Requests (Approval Requests)
CREATE TABLE requests (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL,
  status TEXT NOT NULL,
  requested_by TEXT NOT NULL,
  approved_by TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  sync_status TEXT DEFAULT 'synced',
  FOREIGN KEY (project_id) REFERENCES projects(id),
  FOREIGN KEY (requested_by) REFERENCES users(id),
  FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- Media
CREATE TABLE media (
  id TEXT PRIMARY KEY,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  uploaded_by TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  sync_status TEXT DEFAULT 'synced',
  FOREIGN KEY (uploaded_by) REFERENCES users(id)
);

-- Media Associations
CREATE TABLE media_associations (
  id TEXT PRIMARY KEY,
  media_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  FOREIGN KEY (media_id) REFERENCES media(id),
  UNIQUE(media_id, entity_type, entity_id)
);

-- Sync Queue
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  payload TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT
);

-- Notifications
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  type TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  is_read BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Sync History (for diagnostics)
CREATE TABLE sync_history (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  status TEXT NOT NULL,
  error_message TEXT,
  synced_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## Key Implementation Patterns

### 1. Feature Structure (Clean Architecture)
Each feature follows this structure:
```
feature/
├── data/
│   ├── datasources/
│   │   ├── remote_data_source.dart
│   │   └── local_data_source.dart
│   ├── models/
│   │   └── model.dart
│   └── repositories/
│       └── repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── entity.dart
│   ├── repositories/
│   │   └── repository.dart
│   └── usecases/
│       └── usecase.dart
└── presentation/
    ├── bloc/
    │   ├── event.dart
    │   ├── state.dart
    │   └── bloc.dart
    ├── pages/
    │   └── page.dart
    └── widgets/
        └── widget.dart
```

### 2. Error Handling (Failures)
```dart
abstract class Failure extends Equatable {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  final String message;
  const CacheFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure();
  @override
  List<Object?> get props => [];
}
```

### 3. Result Pattern (Either)
```dart
// Success case
Either<Failure, User> result = Right(user);

// Failure case
Either<Failure, User> result = Left(ServerFailure('Error message'));

// Usage
result.fold(
  (failure) => handleError(failure),
  (user) => handleSuccess(user),
);
```

### 4. BLoC Pattern
```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState.initial()) {
    on<MyEvent>(_onMyEvent);
  }

  FutureOr<void> _onMyEvent(MyEvent event, Emitter<MyState> emit) async {
    emit(state.copyWith(status: Status.loading));
    final result = await usecase.call(event.param);
    result.fold(
      (failure) => emit(state.copyWith(status: Status.error, message: failure.message)),
      (data) => emit(state.copyWith(status: Status.success, data: data)),
    );
  }
}
```

### 5. Project Scoping
Every repository method must filter by `project_id`:
```dart
Future<Either<Failure, List<Report>>> getReports(String projectId) async {
  // API call filtered by projectId
  // Local DB query filtered by projectId
}
```

### 6. Offline-First Flow
```
User Action
  ↓
Write to Local DB (Drift)
  ↓
Add to Sync Queue
  ↓
Update UI from Local DB
  ↓
Background Sync (when online)
  ↓
Upload to Server
  ↓
Update Local DB with server response
  ↓
Remove from Sync Queue
  ↓
Handle Conflicts (if any)
```

---

## Naming Conventions

### Files
- **Entities**: `entity_name.dart` (e.g., `user.dart`)
- **Models**: `entity_name_model.dart` (e.g., `user_model.dart`)
- **Repositories**: `entity_name_repository.dart` (abstract), `entity_name_repository_impl.dart` (concrete)
- **Data Sources**: `entity_name_remote_data_source.dart`, `entity_name_local_data_source.dart`
- **Use Cases**: `entity_name_usecase.dart` or `action_usecase.dart` (e.g., `login_usecase.dart`)
- **BLoCs**: `entity_name_bloc.dart`, `entity_name_event.dart`, `entity_name_state.dart`
- **Pages**: `entity_name_screen.dart` or `entity_name_page.dart`
- **Widgets**: `entity_name_widget.dart` or `action_widget.dart`

### Classes
- **Entities**: PascalCase (e.g., `User`, `Report`)
- **Models**: PascalCase with "Model" suffix (e.g., `UserModel`)
- **Repositories**: PascalCase with "Repository" suffix (e.g., `AuthRepository`)
- **Use Cases**: PascalCase with "UseCase" suffix (e.g., `LoginUseCase`)
- **BLoCs**: PascalCase with "Bloc" suffix (e.g., `LoginBloc`)
- **Events**: PascalCase with "Event" suffix (e.g., `LoginButtonPressed`)
- **States**: PascalCase with "State" suffix (e.g., `LoginState`)

### Variables & Methods
- camelCase for variables and methods
- `_private` for private members
- `final` for immutable values

---

## Current Implementation Status

### ✅ Completed
- Project setup & dependencies
- Core utilities (theme, constants, validators, formatters)
- Biometric authentication service
- Permission handler
- DI container (GetIt)
- Dio client setup
- LoginBloc with biometric support
- LoginScreen UI
- User entity
- AuthRepository (abstract)
- LoginUseCase

### 🔄 In Progress
- Authentication data layer (models, data sources, repository implementation)
- MFA verification flow
- Project selection screen

### ⏳ Pending
- All other modules (Reports, Issues, Requests, Media, Sync, Notifications, Dashboard)
- Database schema & Drift setup
- Background job configuration
- Firebase Cloud Messaging setup
- Comprehensive testing

---

## Next Steps (Immediate)

1. **Complete Authentication Data Layer**
   - Create `AuthRemoteDataSource` with API calls
   - Create `AuthLocalDataSource` for token caching
   - Create `AuthRepositoryImpl` (concrete implementation)
   - Create models: `UserModel`, `AuthResponse`, `MFAResponse`

2. **Implement MFA Flow**
   - Create `MFAVerifyUseCase`
   - Create `MFABloc` with MFA events/states
   - Complete `MFAScreen` UI

3. **Setup Database (Drift)**
   - Create database schema
   - Generate Drift code
   - Create DAOs for each entity

4. **Implement Project Management**
   - Create `ProjectRepository` & `ProjectRepositoryImpl`
   - Create `ProjectBloc`
   - Create `ProjectSelectionScreen`
   - Implement active project context

5. **Setup Navigation**
   - Implement proper routing based on auth state
   - Create navigation guards for project scoping

---

## Important Notes

- **Always filter by project_id**: Every API call and DB query must be scoped to the active project
- **Offline-first mindset**: Design all features to work offline first, then sync when online
- **Error handling**: Use Either<Failure, T> pattern consistently
- **Testing**: Write tests as you implement features
- **Documentation**: Keep code well-documented with clear comments
- **Performance**: Optimize DB queries, cache frequently accessed data
- **Security**: Never store sensitive data in plain text; use flutter_secure_storage

---

## Resources & References

- [Flutter Documentation](https://flutter.dev)
- [BLoC Pattern](https://bloclibrary.dev)
- [Clean Architecture](https://resocoder.com/flutter-clean-architecture)
- [Drift Documentation](https://drift.simonbinder.eu)
- [Dio Documentation](https://pub.dev/packages/dio)
- [GetIt Documentation](https://pub.dev/packages/get_it)

---

**Last Updated**: [Current Date]
**Project Status**: Phase 2 - In Progress
**Next Review**: After Phase 2 completion
