# Home Screen Testing Guide

## ✅ What's New

A simple dummy home screen has been created and integrated into the authentication flow. The home screen displays:

- ✅ Success confirmation
- ✅ Authentication status (Login, Session, Security)
- ✅ Available features (Dashboard, Settings, Notifications, Help)
- ✅ Logout functionality

---

## 🚀 Complete Authentication Flow

### Flow 1: Direct Login (No MFA)

```
Login Screen
    ↓
Enter: user@example.com / Password123!
    ↓
Click "Sign In"
    ↓
Loading... (1 second)
    ↓
✅ Success Snackbar
    ↓
Home Screen
```

### Flow 2: Login with MFA

```
Login Screen
    ↓
Enter: mfa@example.com / any password (6+ chars)
    ↓
Click "Sign In"
    ↓
Loading... (1 second)
    ↓
MFA Screen
    ↓
Enter: 123456
    ↓
Click "Verify"
    ↓
Loading... (1 second)
    ↓
✅ Success Snackbar
    ↓
Home Screen
```

### Flow 3: Biometric Login

```
Login Screen
    ↓
Click "Sign in with Biometrics"
    ↓
Loading... (800ms)
    ↓
OS Biometric Dialog (Fingerprint/Face ID)
    ↓
User authenticates
    ↓
✅ Success Snackbar
    ↓
Home Screen
```

---

## 🧪 Test Scenarios

### Test 1: Direct Login Success
**Steps**:
1. Launch the app
2. Email: `user@example.com`
3. Password: `Password123!`
4. Click "Sign In"

**Expected Result**:
- ✅ Loading spinner shows
- ✅ Success snackbar appears
- ✅ Navigates to Home Screen
- ✅ Home screen shows "Welcome!" message

---

### Test 2: MFA Flow
**Steps**:
1. Launch the app
2. Email: `mfa@example.com`
3. Password: `any6chars` (any password with 6+ characters)
4. Click "Sign In"
5. On MFA screen, enter: `123456`
6. Click "Verify"

**Expected Result**:
- ✅ Navigates to MFA screen
- ✅ Code input accepts only numeric characters
- ✅ Verify button enabled when code is 6 digits
- ✅ Success snackbar appears
- ✅ Navigates to Home Screen

---

### Test 3: MFA Invalid Code
**Steps**:
1. Follow Test 2 steps 1-4
2. On MFA screen, enter: `654321` (wrong code)
3. Click "Verify"

**Expected Result**:
- ✅ Loading spinner shows
- ✅ Error message: "Invalid verification code. Please try again."
- ✅ Code input remains focused
- ✅ Can retry with correct code

---

### Test 4: MFA Resend Code
**Steps**:
1. Follow Test 2 steps 1-4
2. Click "Resend Code"

**Expected Result**:
- ✅ Loading spinner shows
- ✅ Success message: "Verification code sent to your email."
- ✅ Resend button shows countdown (60 seconds)
- ✅ Resend button disabled during countdown
- ✅ After countdown, button re-enables

---

### Test 5: Biometric Login
**Steps**:
1. Launch the app
2. Click "Sign in with Biometrics"

**Expected Result on Supported Device**:
- ✅ Loading spinner shows
- ✅ OS biometric dialog appears (Fingerprint/Face ID)
- ✅ User authenticates with biometric
- ✅ Success snackbar appears
- ✅ Navigates to Home Screen

**Expected Result on Unsupported Device**:
- ✅ Loading spinner shows
- ✅ Error message: "Biometrics not available on this device."
- ✅ Can still login with password

---

### Test 6: Invalid Credentials
**Steps**:
1. Launch the app
2. Email: `invalid@email.com`
3. Password: `WrongPassword123!`
4. Click "Sign In"

**Expected Result**:
- ✅ Loading spinner shows
- ✅ Error message: "Invalid email or password."
- ✅ Error displays in styled container
- ✅ Can retry with correct credentials

---

### Test 7: Validation Errors
**Steps**:
1. Launch the app
2. Leave email empty or enter invalid email
3. Click "Sign In"

**Expected Result**:
- ✅ Error message: "Please enter a valid email."
- ✅ No loading spinner (validation happens immediately)

**Steps**:
1. Launch the app
2. Email: `user@example.com`
3. Password: `short` (less than 6 characters)
4. Click "Sign In"

**Expected Result**:
- ✅ Error message: "Password must be at least 6 characters."
- ✅ No loading spinner (validation happens immediately)

---

### Test 8: Home Screen Features
**Steps**:
1. Complete login flow to reach Home Screen
2. Click on any feature card (Dashboard, Settings, etc.)

**Expected Result**:
- ✅ Snackbar shows: "[Feature] coming soon!"
- ✅ Feature cards are clickable

---

### Test 9: Logout from Home Screen
**Steps**:
1. Complete login flow to reach Home Screen
2. Click logout button (top-right or bottom)

**Expected Result**:
- ✅ Logout confirmation dialog appears
- ✅ Click "Logout" to confirm
- ✅ Navigates back to Login Screen
- ✅ Can login again

---

### Test 10: Back Button on MFA Screen
**Steps**:
1. Complete login to reach MFA screen
2. Click back button (top-left)

**Expected Result**:
- ✅ Returns to Login Screen
- ✅ Can enter different credentials

---

### Test 11: Password Visibility Toggle
**Steps**:
1. Launch the app
2. Enter password: `Password123!`
3. Click eye icon to toggle visibility

**Expected Result**:
- ✅ Password text is hidden by default
- ✅ Clicking eye icon shows password
- ✅ Clicking again hides password
- ✅ Icon changes accordingly

---

### Test 12: Theme Switching
**Steps**:
1. Launch the app
2. Change system theme (Light/Dark)

**Expected Result**:
- ✅ Login screen updates gradient colors
- ✅ MFA screen updates gradient colors
- ✅ Home screen updates gradient colors
- ✅ All text and icons adapt to theme
- ✅ Cards and buttons maintain visibility

---

### Test 13: Responsive Design
**Steps**:
1. Launch the app on different screen sizes
2. Rotate device between portrait and landscape

**Expected Result**:
- ✅ All screens display correctly
- ✅ Text is readable
- ✅ Buttons are clickable
- ✅ No overflow or layout issues
- ✅ Scrolling works when needed

---

## 📋 Checklist

### Login Screen
- [ ] Email field accepts input
- [ ] Password field obscures text
- [ ] Password visibility toggle works
- [ ] Sign In button works
- [ ] Biometric button works
- [ ] Error messages display correctly
- [ ] Loading indicator shows
- [ ] Forgot password link is clickable
- [ ] Demo credentials hint is visible

### MFA Screen
- [ ] Code input accepts only numeric
- [ ] Code input max 6 characters
- [ ] Verify button enabled at 6 digits
- [ ] Verify button disabled before 6 digits
- [ ] Error messages display correctly
- [ ] Success messages display correctly
- [ ] Resend button shows countdown
- [ ] Back button returns to login
- [ ] Loading indicator shows

### Home Screen
- [ ] Success icon displays
- [ ] Welcome message displays
- [ ] Authentication status shows
- [ ] Feature cards display
- [ ] Feature cards are clickable
- [ ] Logout button works
- [ ] Logout dialog appears
- [ ] Logout confirmation works
- [ ] Logout cancellation works

### Navigation
- [ ] Login → Home (direct login)
- [ ] Login → MFA → Home (MFA flow)
- [ ] Login → Home (biometric)
- [ ] Home → Login (logout)
- [ ] MFA → Login (back button)

### Error Handling
- [ ] Invalid email shows error
- [ ] Short password shows error
- [ ] Invalid credentials show error
- [ ] Invalid MFA code shows error
- [ ] Biometric unavailable shows error
- [ ] All errors display in styled container

### UI/UX
- [ ] Gradient backgrounds display correctly
- [ ] Cards have proper elevation
- [ ] Buttons have proper styling
- [ ] Icons display correctly
- [ ] Text is readable
- [ ] Spacing is consistent
- [ ] Light theme works
- [ ] Dark theme works
- [ ] Responsive on different sizes

---

## 🎯 Demo Credentials

| Scenario | Email | Password | Code |
|----------|-------|----------|------|
| Direct Login | `user@example.com` | `Password123!` | N/A |
| MFA Required | `mfa@example.com` | any (6+ chars) | `123456` |
| Invalid | any other | any | N/A |

---

## 🚀 Running Tests

### Run on Android Emulator
```bash
flutter run -d emulator-5554
```

### Run on iOS Simulator
```bash
flutter run -d iPhone
```

### Run on Physical Device
```bash
flutter run -d <device_id>
```

### Run with Verbose Logging
```bash
flutter run -v
```

---

## 📸 Screenshots to Verify

1. **Login Screen** - Gradient background, card layout, input fields
2. **MFA Screen** - Code input, resend button, countdown timer
3. **Home Screen** - Success message, status cards, feature list
4. **Error States** - Error messages in styled containers
5. **Loading States** - Spinner in buttons during operations

---

## 🐛 Troubleshooting

### App Crashes on Navigation
- Check routes are registered in `app.dart`
- Verify route names match exactly
- Check imports are correct

### Home Screen Not Showing
- Verify `/home` route is registered
- Check `Get.offNamed('/home')` is called
- Check HomeScreen import in app.dart

### Biometric Not Working
- Check platform permissions are set
- Verify device has biometric hardware
- Check `minSdkVersion >= 23` on Android
- Check Info.plist on iOS

### MFA Code Not Accepting Input
- Ensure code is numeric-only
- Check max length is 6
- Verify `CodeChanged` event is dispatched

---

## ✅ Success Criteria

All tests pass when:
- ✅ Direct login navigates to home
- ✅ MFA flow works end-to-end
- ✅ Biometric works on supported devices
- ✅ Error messages display correctly
- ✅ Logout returns to login
- ✅ All UI elements display correctly
- ✅ Theme switching works
- ✅ Responsive design works
- ✅ No crashes or exceptions

---

## 🎉 You're Ready!

The complete authentication system is now ready for testing. Run the app and test all scenarios above to ensure everything works correctly.

**Next Steps**:
1. Run all test scenarios
2. Test on real devices (especially for biometrics)
3. Verify theme switching
4. Check responsive design
5. Integrate with real API when backend is ready

---

**Happy Testing! 🚀**
