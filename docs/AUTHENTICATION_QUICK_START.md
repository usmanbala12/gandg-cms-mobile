# Authentication Module - Quick Start Guide

**Get up and running in 5 minutes!**

---

## 1. Prerequisites

- Flutter SDK installed
- Android Studio or Xcode
- Physical device or emulator with biometric support (optional)

---

## 2. Setup (2 minutes)

### Clone/Update Project
```bash
cd field_link
flutter clean
flutter pub get
```

### Configure API Base URL
Edit `lib/core/network/dio_client.dart`:
```dart
baseUrl: 'https://your-api-domain.com',  // Change this
```

---

## 3. Run the App (1 minute)

```bash
flutter run
```

---

## 4. Test Login (2 minutes)

### Test Case 1: Valid Login
- **Email**: `user@example.com`
- **Password**: `password123`
- **Expected**: Navigates to Home screen

### Test Case 2: MFA Required
- **Email**: `mfa@example.com`
- **Password**: `any6charpassword`
- **Expected**: Shows MFA verification page
- **Enter Code**: `123456` (any 6 digits)
- **Expected**: Navigates to Home screen

### Test Case 3: Invalid Credentials
- **Email**: `invalid@example.com`
- **Password**: `wrong`
- **Expected**: Shows error message

---

## 5. Key Files to Know

### Authentication Flow
```
lib/features/authentication/
├── presentation/
│   ├── pages/
│   │   ├── login_page.dart          ← Login UI
│   │   ├── mfa_page.dart            ← MFA UI
│   │   └── biometric_login_page.dart ← Biometric UI
│   └── bloc/
│       └── auth/
│           ├── auth_bloc.dart       ← Business logic
│           ├── auth_event.dart      ← Events
│           └── auth_state.dart      ← States
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart     ← Interface
│   └── usecases/
│       ├── login_usecase.dart
│       ├── verify_mfa_usecase.dart
│       └── logout_usecase.dart
└── data/
    ├── datasources/
    │   └── auth_remote_datasource.dart ← API calls
    ├── models/
    │   ├── user_model.dart
    │   ├── auth_tokens_model.dart
    │   └── auth_response_model.dart
    └── repositories/
        └── auth_repository_impl.dart ← Implementation
```

### Core Services
```
lib/core/
├���─ services/
│   └── token_storage_service.dart   ← Token management
├── network/
│   ├── dio_client.dart              ← HTTP client
│   └── auth_interceptor.dart        ← Token refresh
└── di/
    └── injection_container.dart     ← Dependency injection
```

---

## 6. Common Tasks

### Add a New Login Field
1. Edit `lib/features/authentication/presentation/pages/login_page.dart`
2. Add TextFormField
3. Update `LoginRequested` event in `auth_event.dart`
4. Update `_onLoginRequested` handler in `auth_bloc.dart`

### Change API Endpoint
1. Edit `lib/features/authentication/data/datasources/auth_remote_datasource.dart`
2. Update endpoint path (e.g., `/api/v1/auth/login`)
3. Update request/response format if needed

### Customize Error Messages
1. Edit `lib/features/authentication/data/repositories/auth_repository_impl.dart`
2. Update `_mapDioExceptionToFailure` method
3. Customize error messages in the mapping

### Change Theme Colors
1. Edit `lib/core/utils/theme/theme.dart`
2. Update `lightTheme` and `darkTheme`
3. Restart app

---

## 7. Debugging

### View BLoC State Changes
Add to `main.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} $change');
    super.onChange(bloc, change);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await di.init();
  runApp(const App());
}
```

### Check Stored Tokens
```dart
final tokenService = sl<TokenStorageService>();
final accessToken = await tokenService.getAccessToken();
final refreshToken = await tokenService.getRefreshToken();
print('Access: $accessToken');
print('Refresh: $refreshToken');
```

### Enable Network Logging
Add to `auth_interceptor.dart`:
```dart
print('[AuthInterceptor] Request: ${options.method} ${options.path}');
print('[AuthInterceptor] Headers: ${options.headers}');
```

---

## 8. Testing Checklist

- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] MFA verification
- [ ] Biometric login (if device supports)
- [ ] Logout
- [ ] Network error handling
- [ ] Theme switching (light/dark)
- [ ] Form validation
- [ ] Error messages display

---

## 9. Troubleshooting

### "No internet connection" Error
- Check API base URL is configured
- Verify device has internet
- Check API server is running

### Tokens Not Persisting
- Run `flutter clean`
- Check FlutterSecureStorage permissions
- Verify tokens are being saved

### Biometric Not Working
- Check device supports biometrics
- Enroll fingerprint/face on device
- Test on physical device (not emulator)

### Theme Not Applying
- Run `flutter clean`
- Restart app
- Check theme is set in `app.dart`

---

## 10. Next Steps

1. **Test with Backend**: Configure API URL and test with real API
2. **Implement Password Reset**: Create UI for password reset flow
3. **Add Analytics**: Track login events
4. **Implement Project Selection**: Add project selection screen
5. **Add Role-Based Access**: Implement permission checks

---

## 11. Documentation

- **Full Implementation**: `AUTHENTICATION_MODULE_IMPLEMENTATION.md`
- **Testing Guide**: `AUTHENTICATION_TESTING_GUIDE.md`
- **Complete Summary**: `IMPLEMENTATION_COMPLETE_SUMMARY.md`

---

## 12. Support

### Get Help
1. Check error message in SnackBar
2. Review logs: `flutter logs`
3. Check BLoC state with observer
4. Review API response format
5. Check network connectivity

### Report Issues
Include:
- Error message
- Steps to reproduce
- Device/OS info
- App version

---

## Quick Reference

### Login Flow
```
User enters credentials
  ↓
Tap "Sign In"
  ↓
LoginRequested event
  ↓
AuthBloc validates & calls API
  ↓
If MFA required → Show MFA page
If success → Save tokens → Show Home
If error → Show error message
```

### MFA Flow
```
User enters 6-digit code
  ↓
Tap "Verify Code"
  ↓
MFARequested event
  ↓
AuthBloc validates & calls API
  ↓
If success → Save tokens → Show Home
If error → Show error message
```

### Biometric Flow
```
App startup
  ↓
Check if biometric enabled
  ↓
If yes → Show biometric page
If no → Show login page
  ↓
User authenticates with biometric
  ↓
Refresh token & show Home
```

---

## File Structure

```
field_link/
├── lib/
│   ├── features/
│   │   └── authentication/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   ├── core/
│   │   ├── services/
│   │   ├── network/
│   │   ├── di/
│   │   └── utils/
│   ├── app.dart
│   └── main.dart
├── android/
├── ios/
└── pubspec.yaml
```

---

## Environment Setup

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSFaceIDUsageDescription</key>
<string>We need Face ID to authenticate you</string>
```

---

**Ready to go! Happy coding! 🚀**

For detailed information, see the full documentation files.
