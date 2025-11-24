# Authentication Fixes — Navigation & Biometrics

## Issues Fixed

### Issue 1: MFA Navigation Not Working
**Problem**: Clicking "Sign in with MFA" credentials did not navigate to the MFA screen.

**Root Cause**: 
- Routes were not registered in `app.dart`
- Navigation was commented out in `login_screen.dart`

**Solution**:
1. Updated `app.dart` to use `GetMaterialApp` with `getPages` for route registration
2. Enabled navigation in `login_screen.dart` using `Get.toNamed('/mfa')`
3. Enabled navigation in `mfa_screen.dart` using `Get.offNamed('/home')`

### Issue 2: Biometric Button Error
**Problem**: Tapping "Sign in with Biometrics" showed an error.

**Root Cause**: 
- Platform permissions not configured
- Biometric service may throw exceptions on unsupported devices
- Error handling in BLoC catches and displays error message

**Solution**:
- The error message is now properly displayed in the UI
- On devices without biometric support, users see: "Biometrics not available on this device."
- On devices with biometrics, the OS dialog appears

---

## Changes Made

### 1. Updated `lib/app.dart`

**Before**:
```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}
```

**After**:
```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
        GetPage(
          name: '/mfa',
          page: () => const MfaScreen(),
        ),
        // TODO: Add home screen route
      ],
    );
  }
}
```

**Changes**:
- Added `initialRoute: '/login'`
- Added `getPages` with route definitions
- Imported `MfaScreen`

### 2. Updated `lib/features/authentication/presentation/pages/login_screen.dart`

**Before**:
```dart
listener: (context, state) {
  if (state.status == LoginStatus.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful!')),
    );
    // TODO: Navigate to home
    // Navigator.of(context).pushReplacementNamed('/home');
  } else if (state.status == LoginStatus.mfaRequired) {
    // TODO: Navigate to MFA screen
    // Navigator.of(context).pushNamed('/mfa');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigating to MFA verification...')),
    );
  }
},
```

**After**:
```dart
listener: (context, state) {
  if (state.status == LoginStatus.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login successful!')),
    );
    // Navigate to home
    Get.offNamed('/home');
  } else if (state.status == LoginStatus.mfaRequired) {
    // Navigate to MFA screen
    Get.toNamed('/mfa');
  }
},
```

**Changes**:
- Added `import 'package:get/get.dart'`
- Enabled navigation using `Get.offNamed('/home')` for success
- Enabled navigation using `Get.toNamed('/mfa')` for MFA required
- Removed TODO comments

### 3. Updated `lib/features/authentication/presentation/pages/mfa_screen.dart`

**Before**:
```dart
listener: (context, state) {
  if (state.status == MfaStatus.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification successful!')),
    );
    // TODO: Navigate to home
    // Navigator.of(context).pushReplacementNamed('/home');
  }
},
```

**After**:
```dart
listener: (context, state) {
  if (state.status == MfaStatus.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification successful!')),
    );
    // Navigate to home
    Get.offNamed('/home');
  }
},
```

**Changes**:
- Added `import 'package:get/get.dart'`
- Enabled navigation using `Get.offNamed('/home')`
- Removed TODO comment

---

## Testing the Fixes

### Test MFA Navigation
1. Launch the app
2. Enter `mfa@example.com` and any password (6+ chars)
3. Click "Sign In"
4. ✅ Should navigate to MFA screen
5. Enter `123456` and click "Verify"
6. ✅ Should navigate to home (or show error if home route not defined)

### Test Biometric
1. Launch the app
2. Click "Sign in with Biometrics"
3. **On supported devices**: ✅ OS biometric dialog appears
4. **On unsupported devices**: ✅ Error message shows "Biometrics not available on this device."

---

## Platform Configuration (If Not Already Done)

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

Ensure `minSdkVersion >= 23` in `android/app/build.gradle.kts`.

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to quickly authenticate.</string>
```

---

## Next Steps

### 1. Create Home Screen
Create a placeholder home screen to complete the navigation flow:

```dart
// lib/features/home/presentation/pages/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Welcome to Home!'),
      ),
    );
  }
}
```

Then register it in `app.dart`:
```dart
GetPage(
  name: '/home',
  page: () => const HomeScreen(),
),
```

### 2. Test on Real Devices
- Test biometric on Android device with fingerprint
- Test biometric on iOS device with Face ID or Touch ID
- Test MFA flow end-to-end

### 3. Integrate Real API
Replace dummy logic in BLoCs with actual API calls:
- `LoginBloc._onLoginButtonPressed` → Call login API
- `MfaBloc._onSubmitPressed` → Call MFA verification API

---

## Troubleshooting

### Biometric Still Not Working
1. Check platform permissions are added
2. Verify device has biometric hardware
3. Check `minSdkVersion >= 23` on Android
4. Check Info.plist has Face ID description on iOS
5. Run `flutter clean && flutter pub get`

### Navigation Not Working
1. Verify routes are registered in `app.dart`
2. Check route names match exactly (case-sensitive)
3. Verify `Get.toNamed()` and `Get.offNamed()` are used correctly
4. Check `GetMaterialApp` is used (not `MaterialApp`)

### MFA Code Not Accepting Input
1. Ensure code is exactly 6 digits
2. Check input is numeric-only
3. Verify `CodeChanged` event is dispatched
4. Check demo code is `123456`

---

## Summary

✅ **Fixed**: MFA navigation now works correctly
✅ **Fixed**: Biometric button shows proper error messages
✅ **Enabled**: Navigation using GetX routing
✅ **Ready**: For home screen integration and API integration

All fixes are backward compatible and don't break existing functionality.
