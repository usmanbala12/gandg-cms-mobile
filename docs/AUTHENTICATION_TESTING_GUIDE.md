# Authentication Module - Testing & Debugging Guide

---

## Quick Start Testing

### 1. Run the App

```bash
flutter clean
flutter pub get
flutter run
```

### 2. Test Login Flow

**Valid Credentials (No MFA):**
- Email: `user@example.com`
- Password: `password123`

**Expected Result:**
- Login succeeds
- Tokens saved securely
- Navigates to Home screen

**Invalid Credentials:**
- Email: `invalid@example.com`
- Password: `wrong`

**Expected Result:**
- Error message: "Invalid credentials or session expired"
- Remains on login page

### 3. Test MFA Flow

**Trigger MFA:**
- Email: `mfa@example.com`
- Password: `any6charpassword`

**Expected Result:**
- Login succeeds
- MFA required state triggered
- Navigates to MFA page

**Verify MFA Code:**
- Enter any 6-digit code (e.g., `123456`)

**Expected Result:**
- Code verified
- Tokens saved
- Navigates to Home screen

### 4. Test Biometric Login

**Prerequisites:**
- Device with biometric support (fingerprint/face)
- Biometric enrolled on device

**Steps:**
1. Login normally first
2. When prompted, enable biometric
3. Close and reopen app
4. Should show biometric login page
5. Tap biometric button
6. Authenticate with fingerprint/face

**Expected Result:**
- Biometric authentication succeeds
- Token refreshed
- Navigates to Home screen

### 5. Test Logout

**Steps:**
1. Login successfully
2. Navigate to Home screen
3. Tap logout button (if available)
4. Confirm logout

**Expected Result:**
- Tokens cleared
- Biometric disabled
- Returns to login page

---

## Debugging

### Enable Logging

Add to `auth_bloc.dart` for debugging:

```dart
// In event handlers
print('[AuthBloc] LoginRequested: email=$email');
print('[AuthBloc] State changed to: ${state.status}');
```

### Check Token Storage

Create a debug widget to inspect stored tokens:

```dart
class TokenDebugWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        sl<TokenStorageService>().getAccessToken(),
        sl<TokenStorageService>().getRefreshToken(),
        sl<TokenStorageService>().isBiometricEnabled(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        final data = snapshot.data as List;
        return Column(
          children: [
            Text('Access Token: ${data[0] ?? "null"}'),
            Text('Refresh Token: ${data[1] ?? "null"}'),
            Text('Biometric Enabled: ${data[2]}'),
          ],
        );
      },
    );
  }
}
```

### Monitor Network Requests

Add logging to `auth_interceptor.dart`:

```dart
@override
Future<void> onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  print('[AuthInterceptor] Request: ${options.method} ${options.path}');
  print('[AuthInterceptor] Headers: ${options.headers}');
  return handler.next(options);
}

@override
Future<void> onError(
  DioException err,
  ErrorInterceptorHandler handler,
) async {
  print('[AuthInterceptor] Error: ${err.response?.statusCode}');
  print('[AuthInterceptor] Error body: ${err.response?.data}');
  return handler.next(err);
}
```

### Check BLoC State Changes

Wrap app with BlocObserver:

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    print('${bloc.runtimeType} $change');
    super.onChange(bloc, change);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    print('${bloc.runtimeType} $event');
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  await di.init();
  runApp(const App());
}
```

---

## Common Issues & Solutions

### Issue 1: "No internet connection" Error

**Cause**: API base URL not configured or network unreachable

**Solution**:
1. Check `lib/core/network/dio_client.dart` - ensure baseUrl is set
2. Verify device has internet connection
3. Check if API server is running and accessible

### Issue 2: Token Not Persisting

**Cause**: FlutterSecureStorage not initialized or permissions missing

**Solution**:
1. Ensure `flutter_secure_storage` is added to pubspec.yaml
2. Check Android/iOS permissions:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`
3. Run `flutter clean` and rebuild

### Issue 3: Biometric Not Working

**Cause**: Device doesn't support biometrics or not enrolled

**Solution**:
1. Check device supports biometrics (Settings → Biometrics)
2. Enroll fingerprint/face on device
3. Check `local_auth` permissions in manifest
4. Test on physical device (emulator may not support)

### Issue 4: MFA Code Not Verifying

**Cause**: Code format incorrect or API response format mismatch

**Solution**:
1. Ensure code is exactly 6 digits
2. Check API response format matches `AuthTokensModel`
3. Verify API endpoint returns `access_token` and `refresh_token`

### Issue 5: Token Refresh Loop

**Cause**: Refresh endpoint returning 401 or infinite retry

**Solution**:
1. Check `auth_interceptor.dart` - verify refresh endpoint path
2. Ensure refresh endpoint doesn't require Authorization header
3. Check refresh token is valid and not expired
4. Verify API returns new tokens in correct format

### Issue 6: Theme Not Applying

**Cause**: Theme not properly registered or cached

**Solution**:
1. Run `flutter clean`
2. Verify theme is set in `app.dart`
3. Check `TAppTheme.lightTheme` and `darkTheme` are properly configured
4. Restart app

---

## Performance Testing

### Measure Login Time

```dart
final stopwatch = Stopwatch()..start();
context.read<AuthBloc>().add(LoginRequested(email: email, password: password));
// In BLoC
stopwatch.stop();
print('Login took ${stopwatch.elapsedMilliseconds}ms');
```

**Target**: < 2 seconds for successful login

### Monitor Memory Usage

Use DevTools Memory profiler:
```bash
flutter pub global activate devtools
devtools
```

**Target**: < 50MB for auth module

### Check Token Refresh Performance

```dart
final stopwatch = Stopwatch()..start();
final result = await refreshTokenUseCase(refreshToken);
stopwatch.stop();
print('Token refresh took ${stopwatch.elapsedMilliseconds}ms');
```

**Target**: < 500ms for token refresh

---

## API Response Validation

### Validate Login Response

```dart
// Expected format
{
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "photo_url": "string or null"
  },
  "tokens": {
    "access_token": "string",
    "refresh_token": "string",
    "mfa_token": "string or null"
  },
  "mfa_required": boolean
}
```

### Validate MFA Response

```dart
// Expected format
{
  "access_token": "string",
  "refresh_token": "string",
  "mfa_token": "string or null"
}
```

### Validate Refresh Response

```dart
// Expected format
{
  "access_token": "string",
  "refresh_token": "string"
}
```

---

## Security Testing

### Test Token Encryption

```dart
// Verify tokens are encrypted in storage
final prefs = await SharedPreferences.getInstance();
final plainToken = prefs.getString('access_token');
print('Token in SharedPreferences: $plainToken'); // Should be null

// Tokens should only be in FlutterSecureStorage
final secureStorage = const FlutterSecureStorage();
final secureToken = await secureStorage.read(key: 'access_token');
print('Token in SecureStorage: $secureToken'); // Should have value
```

### Test Token Refresh on 401

```dart
// Manually trigger 401 response
// Verify interceptor:
// 1. Detects 401
// 2. Calls refresh endpoint
// 3. Updates token
// 4. Retries original request
```

### Test Biometric Security

```dart
// Verify biometric flag is set
final isBiometricEnabled = await sl<TokenStorageService>().isBiometricEnabled();
print('Biometric enabled: $isBiometricEnabled');

// Verify email is stored
final email = await sl<TokenStorageService>().getUserEmail();
print('Stored email: $email');
```

---

## UI Testing

### Test Light Theme

1. Go to Settings → Display → Light theme
2. Verify:
   - Background is white (#FFFFFF)
   - Text is black (#000000)
   - Borders are subtle gray (#E0E0E0)
   - No gradients or shadows

### Test Dark Theme

1. Go to Settings → Display → Dark theme
2. Verify:
   - Background is black (#000000)
   - Text is white (#FFFFFF)
   - Borders are subtle gray (#303030)
   - No gradients or shadows

### Test Responsive Design

1. Test on different screen sizes:
   - Phone (small): 360x640
   - Phone (large): 480x800
   - Tablet: 600x1024
2. Verify layout adapts properly
3. Check text is readable
4. Verify buttons are tappable

### Test Accessibility

1. Enable screen reader
2. Verify all elements are announced
3. Check color contrast (WCAG AA standard)
4. Test keyboard navigation

---

## Regression Testing Checklist

- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] MFA verification
- [ ] Token refresh on 401
- [ ] Biometric login
- [ ] Logout
- [ ] Network error handling
- [ ] Theme switching
- [ ] Form validation
- [ ] Error messages display
- [ ] Loading states show
- [ ] Navigation works correctly
- [ ] Tokens persist after app restart
- [ ] Biometric setting persists
- [ ] No memory leaks
- [ ] No infinite loops

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Auth Module Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze
```

---

## Support & Troubleshooting

### Get Help

1. Check logs: `flutter logs`
2. Enable verbose mode: `flutter run -v`
3. Check BLoC state: Use BlocObserver
4. Inspect network: Use Dio logging
5. Review error messages: Check SnackBars

### Report Issues

Include:
1. Error message
2. Stack trace
3. Steps to reproduce
4. Device/OS info
5. App version

---

**Last Updated**: [Current Date]  
**Status**: Ready for Testing
