# Developer Quick Reference Guide

**Project**: Field Link  
**Purpose**: Quick lookup for common patterns, commands, and conventions

---

## Table of Contents

1. [Project Setup](#project-setup)
2. [Common Commands](#common-commands)
3. [File Structure](#file-structure)
4. [Code Patterns](#code-patterns)
5. [Naming Conventions](#naming-conventions)
6. [Error Handling](#error-handling)
7. [Testing](#testing)
8. [Debugging](#debugging)
9. [Performance Tips](#performance-tips)
10. [Common Issues & Solutions](#common-issues--solutions)

---

## Project Setup

### Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd field_link

# Install dependencies
flutter pub get

# Generate code (Drift, BLoC, etc.)
flutter pub run build_runner build

# Run app
flutter run

# Run on specific device
flutter run -d <device-id>
```

### Environment Configuration

```bash
# List available devices
flutter devices

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Run on web
flutter run -d web

# Run with verbose logging
flutter run -v
```

---

## Common Commands

### Build Commands

```bash
# Build APK (Android)
flutter build apk --release

# Build AAB (Android App Bundle)
flutter build appbundle --release

# Build IPA (iOS)
flutter build ios --release

# Build web
flutter build web --release

# Build Windows
flutter build windows --release
```

### Code Generation

```bash
# Generate all code (Drift, BLoC, etc.)
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build

# Generate Drift code only
flutter pub run build_runner build --verbose
```

### Testing Commands

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/authentication/login_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Cleaning Commands

```bash
# Clean build artifacts
flutter clean

# Remove generated files
flutter pub run build_runner clean

# Remove all cache
flutter clean && flutter pub get

# Remove specific generated files
rm -rf lib/**/*.g.dart
```

---

## File Structure

### Feature Module Structure

```
features/
└── feature_name/
    ├── data/
    │   ├── datasources/
    │   │   ├── feature_remote_data_source.dart
    │   │   └── feature_local_data_source.dart
    │   ├── models/
    │   │   └── feature_model.dart
    │   └── repositories/
    │       └── feature_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   └── feature_entity.dart
    │   ├── repositories/
    │   │   └── feature_repository.dart
    │   └── usecases/
    │       └── feature_usecase.dart
    └── presentation/
        ├── bloc/
        │   ├── feature_bloc.dart
        │   ├── feature_event.dart
        │   └── feature_state.dart
        ├── pages/
        │   └── feature_screen.dart
        └── widgets/
            └── feature_widget.dart
```

### Core Module Structure

```
core/
├── database/
│   ├── app_database.dart
│   ├── tables/
│   └── daos/
├── di/
│   └── injection_container.dart
├── error/
│   └── failures.dart
├── network/
│   └── dio_client.dart
└── utils/
    ├── biometrics/
    ├── constants/
    ├── device/
    ├── formatters/
    ├── helpers/
    ├── http/
    ├── local_storage/
    ├── logging/
    ├── permissions/
    ├── theme/
    ├── validators/
    └── widgets/
```

---

## Code Patterns

### 1. Entity Definition

```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}
```

### 2. Model Definition (extends Entity)

```dart
import 'package:field_link/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String name,
  }) : super(
    id: id,
    email: email,
    name: name,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
```

### 3. Repository Pattern

```dart
// Abstract (Domain Layer)
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}

// Implementation (Data Layer)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final user = await remoteDataSource.getUser(id);
      await localDataSource.cacheUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 4. Use Case Pattern

```dart
import 'package:dartz/dartz.dart';

class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}

// Usage
final result = await getUserUseCase('user_123');
result.fold(
  (failure) => print('Error: $failure'),
  (user) => print('User: ${user.name}'),
);
```

### 5. BLoC Pattern

```dart
import 'package:bloc/bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUserUseCase getUserUseCase;

  UserBloc({required this.getUserUseCase}) : super(UserState.initial()) {
    on<GetUserEvent>(_onGetUser);
  }

  FutureOr<void> _onGetUser(GetUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading));
    
    final result = await getUserUseCase(event.userId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: UserStatus.error,
        message: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: UserStatus.success,
        user: user,
      )),
    );
  }
}
```

### 6. BLoC State Pattern

```dart
enum UserStatus { initial, loading, success, error }

class UserState extends Equatable {
  final UserStatus status;
  final User? user;
  final String? message;

  const UserState({
    required this.status,
    this.user,
    this.message,
  });

  factory UserState.initial() {
    return const UserState(status: UserStatus.initial);
  }

  UserState copyWith({
    UserStatus? status,
    User? user,
    String? message,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
```

### 7. BLoC Event Pattern

```dart
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserEvent extends UserEvent {
  final String userId;

  const GetUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
```

### 8. Screen with BLoC

```dart
class UserScreen extends StatelessWidget {
  final String userId;

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserBloc>()..add(GetUserEvent(userId: userId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('User')),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state.status == UserStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == UserStatus.error) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state.status == UserStatus.success && state.user != null) {
              return Center(child: Text('User: ${state.user!.name}'));
            }
            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }
}
```

### 9. Drift DAO Pattern

```dart
@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> {
  UserDao(AppDatabase db) : super(db);

  Future<User?> getUserById(String id) {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  Stream<List<User>> watchAllUsers() {
    return select(users).watch();
  }

  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<void> updateUser(UsersCompanion user) {
    return update(users).replace(user);
  }

  Future<void> deleteUser(String id) {
    return (delete(users)..where((u) => u.id.equals(id))).go();
  }
}
```

### 10. Dependency Injection

```dart
// Register singleton
sl.registerSingleton<UserRepository>(
  UserRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ),
);

// Register lazy singleton
sl.registerLazySingleton(() => GetUserUseCase(sl()));

// Register factory (new instance each time)
sl.registerFactory(() => UserBloc(getUserUseCase: sl()));

// Get instance
final userRepository = sl<UserRepository>();
```

---

## Naming Conventions

### Files

| Type | Pattern | Example |
|------|---------|---------|
| Entity | `entity_name.dart` | `user.dart` |
| Model | `entity_name_model.dart` | `user_model.dart` |
| Repository (abstract) | `entity_name_repository.dart` | `user_repository.dart` |
| Repository (impl) | `entity_name_repository_impl.dart` | `user_repository_impl.dart` |
| Remote Data Source | `entity_name_remote_data_source.dart` | `user_remote_data_source.dart` |
| Local Data Source | `entity_name_local_data_source.dart` | `user_local_data_source.dart` |
| Use Case | `action_usecase.dart` | `get_user_usecase.dart` |
| BLoC | `entity_name_bloc.dart` | `user_bloc.dart` |
| Event | `entity_name_event.dart` | `user_event.dart` |
| State | `entity_name_state.dart` | `user_state.dart` |
| Screen | `entity_name_screen.dart` | `user_screen.dart` |
| Widget | `entity_name_widget.dart` | `user_widget.dart` |

### Classes

| Type | Pattern | Example |
|------|---------|---------|
| Entity | `PascalCase` | `User` |
| Model | `PascalCase + Model` | `UserModel` |
| Repository | `PascalCase + Repository` | `UserRepository` |
| Use Case | `PascalCase + UseCase` | `GetUserUseCase` |
| BLoC | `PascalCase + Bloc` | `UserBloc` |
| Event | `PascalCase + Event` | `GetUserEvent` |
| State | `PascalCase + State` | `UserState` |
| Screen | `PascalCase + Screen` | `UserScreen` |
| Widget | `PascalCase + Widget` | `UserWidget` |

### Variables & Methods

```dart
// camelCase for variables
String userName = 'John';
int userAge = 30;

// camelCase for methods
void getUserData() {}
String formatUserName() {}

// UPPER_SNAKE_CASE for constants
const String API_BASE_URL = 'https://api.example.com';
const int MAX_RETRY_COUNT = 3;

// _private for private members
String _privateData = 'secret';
void _privateMethod() {}
```

---

## Error Handling

### Failure Classes

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

### Using Either for Error Handling

```dart
// Success case
Either<Failure, User> result = Right(user);

// Failure case
Either<Failure, User> result = Left(ServerFailure('Error message'));

// Pattern matching
result.fold(
  (failure) {
    if (failure is ServerFailure) {
      print('Server error: ${failure.message}');
    } else if (failure is CacheFailure) {
      print('Cache error: ${failure.message}');
    }
  },
  (user) => print('Success: ${user.name}'),
);
```

---

## Testing

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetUserUseCase', () {
    late GetUserUseCase useCase;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      useCase = GetUserUseCase(mockRepository);
    });

    test('should return User when repository call is successful', () async {
      // Arrange
      const userId = 'user_123';
      final user = User(id: userId, email: 'test@example.com', name: 'Test');
      when(mockRepository.getUser(userId)).thenAnswer((_) async => Right(user));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, Right(user));
      verify(mockRepository.getUser(userId)).called(1);
    });

    test('should return Failure when repository call fails', () async {
      // Arrange
      const userId = 'user_123';
      when(mockRepository.getUser(userId))
          .thenAnswer((_) async => Left(ServerFailure('Error')));

      // Act
      final result = await useCase(userId);

      // Assert
      expect(result, isA<Left>());
      verify(mockRepository.getUser(userId)).called(1);
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  group('UserScreen', () {
    late MockUserBloc mockUserBloc;

    setUp(() {
      mockUserBloc = MockUserBloc();
    });

    testWidgets('displays loading indicator when state is loading', (WidgetTester tester) async {
      when(mockUserBloc.state).thenReturn(
        UserState(status: UserStatus.loading),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<UserBloc>.value(
            value: mockUserBloc,
            child: const UserScreen(userId: 'user_123'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays user data when state is success', (WidgetTester tester) async {
      final user = User(id: 'user_123', email: 'test@example.com', name: 'Test User');
      when(mockUserBloc.state).thenReturn(
        UserState(status: UserStatus.success, user: user),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<UserBloc>.value(
            value: mockUserBloc,
            child: const UserScreen(userId: 'user_123'),
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
    });
  });
}
```

---

## Debugging

### Print Debugging

```dart
// Simple print
print('Debug: $value');

// Using logger
import 'package:logger/logger.dart';

final logger = Logger();
logger.d('Debug message');
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

### BLoC Debugging

```dart
// Add logging to BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserState.initial()) {
    on<GetUserEvent>(_onGetUser);
  }

  FutureOr<void> _onGetUser(GetUserEvent event, Emitter<UserState> emit) async {
    print('[UserBloc] GetUserEvent received: ${event.userId}');
    emit(state.copyWith(status: UserStatus.loading));
    
    final result = await getUserUseCase(event.userId);
    
    result.fold(
      (failure) {
        print('[UserBloc] Error: $failure');
        emit(state.copyWith(status: UserStatus.error));
      },
      (user) {
        print('[UserBloc] Success: ${user.name}');
        emit(state.copyWith(status: UserStatus.success, user: user));
      },
    );
  }
}
```

### Flutter DevTools

```bash
# Open DevTools
flutter pub global activate devtools
devtools

# Or use in VS Code
# Install "Dart" extension, then press Ctrl+Shift+D
```

---

## Performance Tips

### 1. Use const Constructors

```dart
// Good
const Text('Hello');
const SizedBox(height: 16);

// Avoid
Text('Hello');
SizedBox(height: 16);
```

### 2. Use const Collections

```dart
// Good
const List<String> items = ['a', 'b', 'c'];
const Map<String, int> map = {'a': 1, 'b': 2};

// Avoid
List<String> items = ['a', 'b', 'c'];
Map<String, int> map = {'a': 1, 'b': 2};
```

### 3. Optimize Database Queries

```dart
// Good - specific query
Future<List<Report>> getReportsByProject(String projectId) {
  return (select(reports)..where((r) => r.projectId.equals(projectId))).get();
}

// Avoid - fetch all then filter
Future<List<Report>> getAllReports() async {
  final all = await select(reports).get();
  return all.where((r) => r.projectId == projectId).toList();
}
```

### 4. Use Lazy Loading

```dart
// Good
sl.registerLazySingleton(() => UserRepository(sl()));

// Avoid
sl.registerSingleton(UserRepository(sl()));
```

### 5. Cache Frequently Accessed Data

```dart
// Use watch() for reactive updates
userDao.watchUserById(userId).listen((user) {
  // UI updates automatically
});
```

---

## Common Issues & Solutions

### Issue 1: "The method 'xxx' isn't defined for the class 'yyy'"

**Solution**: Run code generation
```bash
flutter pub run build_runner build
```

### Issue 2: "Unhandled Exception: MissingPluginException"

**Solution**: Rebuild the app
```bash
flutter clean
flutter pub get
flutter run
```

### Issue 3: "Bad state: Stream has already been listened to"

**Solution**: Use broadcast stream or create new stream each time
```dart
// Good
Stream<List<User>> watchUsers() {
  return select(users).watch();
}

// Avoid
late Stream<List<User>> _usersStream;
Stream<List<User>> get usersStream => _usersStream;
```

### Issue 4: "Null check operator used on a null value"

**Solution**: Add null checks
```dart
// Good
final user = await userDao.getUserById(id);
if (user != null) {
  print(user.name);
}

// Avoid
final user = await userDao.getUserById(id);
print(user!.name); // Can throw if user is null
```

### Issue 5: "The getter 'xxx' was called on null"

**Solution**: Use null coalescing operator
```dart
// Good
String name = user?.name ?? 'Unknown';

// Avoid
String name = user.name; // Throws if user is null
```

---

## Useful Links

- [Flutter Docs](https://flutter.dev/docs)
- [Dart Docs](https://dart.dev/guides)
- [BLoC Library](https://bloclibrary.dev)
- [Drift Docs](https://drift.simonbinder.eu)
- [Dio Docs](https://pub.dev/packages/dio)
- [GetIt Docs](https://pub.dev/packages/get_it)

---

**Last Updated**: [Current Date]  
**Maintained By**: Development Team
