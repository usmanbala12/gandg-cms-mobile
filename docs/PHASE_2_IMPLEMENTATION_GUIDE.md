# Phase 2 Implementation Guide: Authentication + Project Selection

**Duration**: Weeks 3-4  
**Status**: In Progress  
**Objective**: Complete authentication flow with MFA and project selection

---

## Overview

Phase 2 focuses on establishing a secure authentication system with multi-factor authentication (MFA) support and project selection. This phase is critical as it:

1. Establishes user identity and session management
2. Fetches and caches user's assigned projects
3. Sets up the foundation for project-scoped data access
4. Enables offline login via biometrics or cached tokens

---

## Module 1: Authentication Module

### 1.1 Data Layer Implementation

#### 1.1.1 Create Models

**File**: `lib/features/authentication/data/models/user_model.dart`

```dart
import 'package:field_link/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
  }) : super(
    id: id,
    email: email,
    name: name,
    photoUrl: photoUrl,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
    };
  }
}
```

**File**: `lib/features/authentication/data/models/auth_response_model.dart`

```dart
import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final bool mfaRequired;
  final String? mfaToken;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.mfaRequired = false,
    this.mfaToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      mfaRequired: json['mfa_required'] as bool? ?? false,
      mfaToken: json['mfa_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'mfa_required': mfaRequired,
      'mfa_token': mfaToken,
    };
  }
}
```

**File**: `lib/features/authentication/data/models/mfa_response_model.dart`

```dart
class MFAResponseModel {
  final String accessToken;
  final String refreshToken;
  final String userId;

  MFAResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  factory MFAResponseModel.fromJson(Map<String, dynamic> json) {
    return MFAResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
    };
  }
}
```

#### 1.1.2 Create Data Sources

**File**: `lib/features/authentication/data/datasources/auth_remote_data_source.dart`

```dart
import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/mfa_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<MFAResponseModel> verifyMFA(String mfaToken, String code);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Login failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<MFAResponseModel> verifyMFA(String mfaToken, String code) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/mfa/verify',
        data: {
          'mfa_token': mfaToken,
          'code': code,
        },
      );

      if (response.statusCode == 200) {
        return MFAResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('MFA verification failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/api/v1/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Token refresh failed with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await dio.post(
        '/api/v1/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }
}
```

**File**: `lib/features/authentication/data/datasources/auth_local_data_source.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAccessToken(String token);
  Future<void> cacheRefreshToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<UserModel?> getCachedUser();
  Future<void> clearAuthData();
  Future<bool> isTokenExpired();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheAccessToken(String token) async {
    await secureStorage.write(key: _accessTokenKey, value: token);
    // Store expiry time (assuming 1 hour expiry)
    final expiryTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
    await sharedPreferences.setInt(_tokenExpiryKey, expiryTime);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    await secureStorage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(_userKey, user.toJson().toString());
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson == null) return null;
    // Parse the JSON string back to UserModel
    // Note: This is a simplified version; implement proper JSON parsing
    return null;
  }

  @override
  Future<void> clearAuthData() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.remove(_tokenExpiryKey);
  }

  @override
  Future<bool> isTokenExpired() async {
    final expiryTime = sharedPreferences.getInt(_tokenExpiryKey);
    if (expiryTime == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }
}
```

#### 1.1.3 Create Repository Implementation

**File**: `lib/features/authentication/data/repositories/auth_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);

      // Cache tokens
      await localDataSource.cacheAccessToken(response.accessToken);
      await localDataSource.cacheRefreshToken(response.refreshToken);
      await localDataSource.cacheUser(response.user);

      return Right(response.user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String name,
  ) async {
    // TODO: Implement registration
    return Left(ServerFailure('Registration not implemented'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final accessToken = await localDataSource.getAccessToken();
      if (accessToken != null) {
        await remoteDataSource.logout(accessToken);
      }
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return Left(CacheFailure('No cached user found'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 1.2 Domain Layer Enhancements

#### 1.2.1 Create Additional Use Cases

**File**: `lib/features/authentication/domain/usecases/mfa_verify_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class MFAVerifyUseCase {
  final AuthRepository repository;

  MFAVerifyUseCase(this.repository);

  Future<Either<Failure, String>> call(String mfaToken, String code) {
    // TODO: Implement MFA verification
    return Future.value(Left(ServerFailure('Not implemented')));
  }
}
```

**File**: `lib/features/authentication/domain/usecases/logout_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}
```

**File**: `lib/features/authentication/domain/usecases/get_current_user_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentUser();
  }
}
```

### 1.3 Presentation Layer Enhancements

#### 1.3.1 Update Login BLoC

**File**: `lib/features/authentication/presentation/bloc/login/login_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginButtonPressed({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class BiometricButtonPressed extends LoginEvent {
  const BiometricButtonPressed();
}

class CheckAuthStatusEvent extends LoginEvent {
  const CheckAuthStatusEvent();
}
```

**File**: `lib/features/authentication/presentation/bloc/login/login_state.dart`

```dart
import 'package:equatable/equatable.dart';

enum LoginStatus {
  initial,
  loading,
  success,
  error,
  mfaRequired,
  offline,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String? message;
  final String? mfaToken;

  const LoginState({
    required this.status,
    this.message,
    this.mfaToken,
  });

  factory LoginState.initial() {
    return const LoginState(status: LoginStatus.initial);
  }

  LoginState copyWith({
    LoginStatus? status,
    String? message,
    String? mfaToken,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message,
      mfaToken: mfaToken ?? this.mfaToken,
    );
  }

  @override
  List<Object?> get props => [status, message, mfaToken];
}
```

#### 1.3.2 Create MFA BLoC

**File**: `lib/features/authentication/presentation/bloc/mfa/mfa_event.dart`

```dart
import 'package:equatable/equatable.dart';

abstract class MFAEvent extends Equatable {
  const MFAEvent();

  @override
  List<Object?> get props => [];
}

class MFACodeSubmitted extends MFAEvent {
  final String code;
  final String mfaToken;

  const MFACodeSubmitted({
    required this.code,
    required this.mfaToken,
  });

  @override
  List<Object?> get props => [code, mfaToken];
}

class MFAResendCode extends MFAEvent {
  final String mfaToken;

  const MFAResendCode({required this.mfaToken});

  @override
  List<Object?> get props => [mfaToken];
}
```

**File**: `lib/features/authentication/presentation/bloc/mfa/mfa_state.dart`

```dart
import 'package:equatable/equatable.dart';

enum MFAStatus {
  initial,
  loading,
  success,
  error,
  codeSent,
}

class MFAState extends Equatable {
  final MFAStatus status;
  final String? message;
  final int? remainingTime;

  const MFAState({
    required this.status,
    this.message,
    this.remainingTime,
  });

  factory MFAState.initial() {
    return const MFAState(status: MFAStatus.initial);
  }

  MFAState copyWith({
    MFAStatus? status,
    String? message,
    int? remainingTime,
  }) {
    return MFAState(
      status: status ?? this.status,
      message: message,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object?> get props => [status, message, remainingTime];
}
```

**File**: `lib/features/authentication/presentation/bloc/mfa/mfa_bloc.dart`

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'mfa_event.dart';
import 'mfa_state.dart';

class MFABloc extends Bloc<MFAEvent, MFAState> {
  MFABloc() : super(MFAState.initial()) {
    on<MFACodeSubmitted>(_onMFACodeSubmitted);
    on<MFAResendCode>(_onMFAResendCode);
  }

  FutureOr<void> _onMFACodeSubmitted(
    MFACodeSubmitted event,
    Emitter<MFAState> emit,
  ) async {
    if (event.code.isEmpty || event.code.length != 6) {
      emit(state.copyWith(
        status: MFAStatus.error,
        message: 'Please enter a valid 6-digit code.',
      ));
      return;
    }

    emit(state.copyWith(status: MFAStatus.loading, message: null));

    // TODO: Call MFA verification use case
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: MFAStatus.success,
      message: 'MFA verification successful.',
    ));
  }

  FutureOr<void> _onMFAResendCode(
    MFAResendCode event,
    Emitter<MFAState> emit,
  ) async {
    emit(state.copyWith(status: MFAStatus.loading, message: null));

    // TODO: Call resend MFA code use case
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: MFAStatus.codeSent,
      message: 'Code sent to your registered email.',
      remainingTime: 60,
    ));
  }
}
```

#### 1.3.3 Complete MFA Screen

**File**: `lib/features/authentication/presentation/pages/mfa_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mfa/mfa_bloc.dart';
import '../bloc/mfa/mfa_event.dart';
import '../bloc/mfa/mfa_state.dart';

class MFAScreen extends StatefulWidget {
  final String mfaToken;

  const MFAScreen({
    Key? key,
    required this.mfaToken,
  }) : super(key: key);

  @override
  State<MFAScreen> createState() => _MFAScreenState();
}

class _MFAScreenState extends State<MFAScreen> {
  late TextEditingController _codeController;
  late FocusNode _codeFocusNode;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Factor Authentication'),
        centerTitle: true,
      ),
      body: BlocListener<MFABloc, MFAState>(
        listener: (context, state) {
          if (state.status == MFAStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Success')),
            );
            // Navigate to home or project selection
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state.status == MFAStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We\'ve sent a 6-digit code to your registered email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<MFABloc, MFAState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.status == MFAStatus.loading
                          ? null
                          : () {
                              context.read<MFABloc>().add(
                                    MFACodeSubmitted(
                                      code: _codeController.text,
                                      mfaToken: widget.mfaToken,
                                    ),
                                  );
                            },
                      child: state.status == MFAStatus.loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify Code'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<MFABloc>().add(
                        MFAResendCode(mfaToken: widget.mfaToken),
                      );
                },
                child: const Text('Didn\'t receive the code? Resend'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Module 2: Project Management Module

### 2.1 Create Project Entity

**File**: `lib/features/project_management/domain/entities/project.dart`

```dart
import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String userRole;

  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.startDate,
    this.endDate,
    required this.userRole,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    startDate,
    endDate,
    userRole,
  ];
}
```

### 2.2 Create Project Repository

**File**: `lib/features/project_management/domain/repositories/project_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getUserProjects();
  Future<Either<Failure, Project>> getProjectById(String projectId);
  Future<Either<Failure, void>> setActiveProject(String projectId);
  Future<Either<Failure, String?>> getActiveProjectId();
}
```

### 2.3 Create Project Use Cases

**File**: `lib/features/project_management/domain/usecases/get_user_projects_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetUserProjectsUseCase {
  final ProjectRepository repository;

  GetUserProjectsUseCase(this.repository);

  Future<Either<Failure, List<Project>>> call() {
    return repository.getUserProjects();
  }
}
```

**File**: `lib/features/project_management/domain/usecases/set_active_project_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/project_repository.dart';

class SetActiveProjectUseCase {
  final ProjectRepository repository;

  SetActiveProjectUseCase(this.repository);

  Future<Either<Failure, void>> call(String projectId) {
    return repository.setActiveProject(projectId);
  }
}
```

---

## Module 3: Home Module

### 3.1 Create Home Screen

**File**: `lib/features/home/presentation/pages/home_screen.dart`

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Link'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Field Link',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a project to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

---

## Dependency Injection Setup

**File**: `lib/core/di/injection_container.dart` (Update)

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/datasources/auth_local_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/presentation/bloc/login/login_bloc.dart';
import '../../features/authentication/presentation/bloc/mfa/mfa_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DioClient.dio);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core

  // Features - Authentication
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // BLoCs
  sl.registerLazySingleton(() => LoginBloc());
  sl.registerLazySingleton(() => MFABloc());
}
```

---

## Testing Checklist

- [ ] Test login with valid credentials
- [ ] Test login with invalid credentials
- [ ] Test MFA flow
- [ ] Test biometric authentication
- [ ] Test token caching and retrieval
- [ ] Test offline login with cached token
- [ ] Test logout functionality
- [ ] Test project selection
- [ ] Test navigation between screens

---

## Next Steps After Phase 2

1. Setup Drift database with schema
2. Implement project selection screen
3. Create project context provider
4. Setup navigation guards
5. Begin Phase 3: Reports, Issues, Requests modules

---

## Important Notes

- Always use `Either<Failure, T>` for error handling
- Cache sensitive data using `FlutterSecureStorage`
- Implement proper token refresh logic
- Add comprehensive error messages for user feedback
- Test offline scenarios thoroughly
- Keep BLoCs focused on business logic, not UI

---

**Last Updated**: [Current Date]
**Status**: Ready for Implementation
