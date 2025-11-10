# Authentication Feature — Login Screen & MFA (BLoC)

This document describes the implementation of the Login Screen, MFA Verification Screen, and their BLoCs for the `field_link` Flutter app. It includes UI details, state management, real biometric authentication, and integration steps.

---

## Overview

- **Technology**: Flutter
- **State Management**: BLoC (via `flutter_bloc`)
- **Biometrics**: Real device authentication via `local_auth`
- **Scope**: Adds a polished Login Screen, MFA Verification Screen, and real biometric support. Prepares for future API integration.

### Files Added

```
lib/
├── core/
│   └── utils/
│       └── biometrics/
│           └── biometric_auth_service.dart
└── features/
    └── authentication/
        └── presentation/
            ├── bloc/
            │   ├── login/
            │   │   ├── login_bloc.dart
            │   │   ├── login_event.dart
            │   │   └── login_state.dart
            │   └── mfa/
            │       ├── mfa_bloc.dart
            │       ├── mfa_event.dart
            │       └── mfa_state.dart
            └── pages/
                ├── login_screen.dart (enhanced UI)
                └── mfa_screen.dart (new)
```

---

## UI: Enhanced Login Screen (`login_screen.dart`)

### Design Features
- **Gradient Background**: Responsive light/dark theme with smooth gradient.
- **Card-based Layout**: Centered, constrained card with elevation and rounded corners.
- **Header Section**: Logo placeholder, title "Welcome Back", and subtitle.
- **Input Fields**:
  - Email/Username with mail icon.
  - Password with visibility toggle (eye icon).
  - Both use `TextFormField` with outline borders and proper spacing.
- **Error Display**: Styled error container with icon and text.
- **Primary Button**: Full-width "Sign In" button with loading indicator.
- **Divider**: Visual separator between password login and biometric.
- **Biometric Button**: Outlined button with fingerprint icon and label.
- **Forgot Password**: Text button placeholder.
- **Dev Hints**: Styled container showing demo credentials.

### State Handling
- `BlocConsumer<LoginBloc, LoginState>` for reactive updates.
- Loading: Disables inputs, shows spinner in button.
- Error: Displays styled error message.
- Success: Shows snackbar (TODO: navigate to home).
- MFA Required: Shows snackbar (TODO: navigate to MFA).

---

## UI: MFA Verification Screen (`mfa_screen.dart`)

### Design Features
- **Gradient Background**: Matches login screen for consistency.
- **Back Button**: Allows user to return to login.
- **Header Section**: Icon, title "Verify Your Identity", subtitle.
- **Code Input Field**:
  - Numeric-only, max 6 characters.
  - Centered text with letter spacing for visual clarity.
  - Automatic sanitization (non-numeric chars removed).
- **Error/Success Messages**: Styled containers for feedback.
- **Verify Button**: Enabled only when code length is 6.
- **Resend Code Button**: Shows countdown timer when disabled.
- **Dev Hint**: Shows demo code `123456`.

### State Handling
- `BlocConsumer<MfaBloc, MfaState>` for reactive updates.
- Loading: Disables inputs, shows spinner in verify button.
- Error: Displays error message.
- Success: Shows snackbar (TODO: navigate to home).
- Code Sent: Shows info message and resend countdown.

---

## Biometric Authentication Service (`biometric_auth_service.dart`)

### Features
- **Availability Check**: `isAvailable()` — checks if device supports biometrics.
- **Biometric Types**: `getAvailableBiometrics()` — returns list of available types (fingerprint, face, etc.).
- **Authentication**: `authenticate()` — prompts OS dialog and returns success/failure.
- **Stop Auth**: `stopAuthentication()` — cancels ongoing authentication.
- **Error Handling**: Graceful fallback on exceptions.

### Integration in LoginBloc
- Injected into `LoginBloc` constructor (optional, defaults to new instance).
- On `BiometricButtonPressed`:
  1. Check availability.
  2. If unavailable: emit error.
  3. If available: prompt OS dialog.
  4. On success: emit `LoginStatus.success`.
  5. On failure/cancel: emit `LoginStatus.error` with message.

---

## BLoC: Login (`login_bloc.dart`, `login_event.dart`, `login_state.dart`)

### Events
- `LoginButtonPressed(email, password)` — triggers validation and auth.
- `BiometricButtonPressed()` — triggers real biometric authentication.

### States (`LoginStatus`)
- `idle` — initial
- `loading` — during validation/auth
- `success` — login successful
- `error` — invalid credentials or unexpected error
- `mfaRequired` — login successful but requires MFA

`LoginState` includes:
- `status: LoginStatus`
- `message: String?` (for error/info)

### Dummy Auth Logic
- **Validation**:
  - Email must contain `@`.
  - Password must be at least 6 characters.
- **Simulated API delay**: ~1 second.
- **Outcomes**:
  - Success when `user@example.com` / `Password123!`.
  - MFA required when `mfa@example.com` (any password length ≥ 6).
  - Error otherwise.
- **Real Biometric Flow**:
  - Checks device support via `BiometricAuthService.isAvailable()`.
  - Prompts OS dialog via `BiometricAuthService.authenticate()`.
  - Emits success or error based on result.

---

## BLoC: MFA (`mfa_bloc.dart`, `mfa_event.dart`, `mfa_state.dart`)

### Events
- `CodeChanged(code)` — updates code input (sanitizes to numeric, max 6 chars).
- `SubmitPressed()` — validates and submits code.
- `ResendPressed()` — simulates resending code and starts countdown.

### States (`MfaStatus`)
- `idle` — initial
- `loading` — during submission
- `success` — code verified
- `error` — invalid code
- `codeSent` — code sent (with countdown)

`MfaState` includes:
- `status: MfaStatus`
- `code: String` (current input)
- `message: String?` (error/info)
- `resendCountdown: int` (seconds remaining)

### Dummy Verification Logic
- Accepts code `123456` as valid.
- Simulated API delay (~1 second).
- Resend: Simulates sending and starts 60-second countdown.
- Code input: Auto-sanitizes to numeric, max 6 chars.

---

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
Add permissions:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

Ensure `minSdkVersion >= 23` in `android/app/build.gradle.kts` or `build.gradle`.

### iOS (`ios/Runner/Info.plist`)
Add usage description:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to quickly authenticate.</string>
```

---

## Setup Instructions

### 1. Verify Dependencies

Ensure these are in `pubspec.yaml`:

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  local_auth: ^2.1.7
```

### 2. Update Platform Configurations

See **Platform Configuration** section above for Android and iOS setup.

### 3. Register Routes

In `app.dart` or your router:

```dart
routes: {
  '/login': (_) => const LoginScreen(),
  '/mfa': (_) => const MfaScreen(),
},
initialRoute: '/login',
```

### 4. Wire Navigation

**Login Screen** (`login_screen.dart`):
```dart
if (state.status == LoginStatus.success) {
  Navigator.of(context).pushReplacementNamed('/home');
} else if (state.status == LoginStatus.mfaRequired) {
  Navigator.of(context).pushNamed('/mfa');
}
```

**MFA Screen** (`mfa_screen.dart`):
```dart
if (state.status == MfaStatus.success) {
  Navigator.of(context).pushReplacementNamed('/home');
}
```

### 5. (Optional) Dependency Injection

Register in `injection_container.dart`:

```dart
// Register BLoCs
getIt.registerSingleton<BiometricAuthService>(BiometricAuthService());
getIt.registerSingleton<LoginBloc>(
  LoginBloc(biometricAuthService: getIt<BiometricAuthService>()),
);
getIt.registerSingleton<MfaBloc>(MfaBloc());

// Use in screens
BlocProvider<LoginBloc>(
  create: (_) => getIt<LoginBloc>(),
  child: const _LoginView(),
)
```

---

## How to Test Quickly

### Login Screen
- Launch the app with `/login` as the initial route.
- Try:
  - **Success**: `user@example.com` / `Password123!`
  - **MFA**: `mfa@example.com` / any password with 6+ characters
  - **Biometric**: Tap fingerprint button (prompts OS dialog on supported devices)
  - **Error**: Any other credentials

Expected behaviors:
- Loading spinner appears in button during auth.
- Error messages display in styled container.
- Snackbars for success or MFA.
- Biometric button prompts OS dialog (or shows error if unavailable).

### MFA Screen
- Navigate to `/mfa` after triggering MFA from login.
- Try:
  - **Success**: Enter `123456`
  - **Error**: Enter any other 6-digit code
  - **Resend**: Tap "Resend Code" to see countdown timer

Expected behaviors:
- Code input auto-sanitizes to numeric.
- Verify button enabled only when code length is 6.
- Error/success messages display in styled containers.
- Resend button shows countdown and is disabled during it.

---

## Future Integration (API and Biometrics)

### API Integration
- Replace dummy blocks in `LoginBloc._onLoginButtonPressed` with calls to your `LoginUseCase` and `AuthRepository` for `POST /v1/auth/login`.
- Determine backend response format for MFA and map it to `LoginStatus.mfaRequired`.
- Replace dummy blocks in `MfaBloc._onSubmitPressed` with calls to MFA verification endpoint.

### Biometric Caching
- After successful password login, optionally store credentials/token locally.
- On biometric success, retrieve and use stored credentials.
- Consider using `flutter_secure_storage` for secure storage.

---

## Rationale / Design Notes

- **Feature-based Structure**: UI and BLoC co-located within `presentation` for maintainability.
- **Separation of Concerns**: Events/States separated for clarity and scalability.
- **Equatable**: Ensures efficient rebuilds and state comparisons.
- **Dummy Logic**: Allows testing and development before backend is ready.
- **Real Biometrics**: Uses `local_auth` for actual device authentication, not simulated.
- **Responsive Design**: Gradient backgrounds and card layouts adapt to light/dark themes.
- **Accessibility**: Proper labels, icons, and error messages for usability.

---

## Changelog

### Phase 1 (Initial)
- Added Login UI and BLoC under `lib/features/authentication/presentation`.
- Files: `login_event.dart`, `login_state.dart`, `login_bloc.dart`, `login_screen.dart`.

### Phase 2 (Current)
- **Enhanced Login UI**: Polished design with gradient, card layout, password visibility toggle, and styled error messages.
- **Added MFA Screen**: New `mfa_screen.dart` with code input, resend functionality, and countdown timer.
- **Added MFA BLoC**: New `mfa_bloc.dart`, `mfa_event.dart`, `mfa_state.dart` for MFA logic.
- **Real Biometrics**: Integrated `local_auth` via `BiometricAuthService` in `LoginBloc`.
- **Updated README**: Comprehensive documentation of all features and setup.

### Pending
- Route registration and navigation wiring in `app.dart`.
- DI registration (optional).
- API integration for login and MFA endpoints.
- Biometric credential caching.

---

## License

Internal project documentation. Use within this repository.
