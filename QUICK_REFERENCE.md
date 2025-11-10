# Quick Reference Card — Authentication System

## 🚀 Run the App
```bash
flutter run
```

---

## 🧪 Test Credentials

### Direct Login (No MFA)
```
Email: user@example.com
Password: Password123!
```
✅ Navigates directly to Home Screen

### Login with MFA
```
Email: mfa@example.com
Password: any6chars (any password with 6+ characters)
MFA Code: 123456
```
✅ Navigates to MFA Screen → Home Screen

### Biometric Login
```
Click "Sign in with Biometrics"
```
✅ Shows OS biometric dialog (or error if unavailable)

---

## 📱 Screens

| Screen | Route | Purpose |
|--------|-------|---------|
| Login | `/login` | Email/password login + biometric |
| MFA | `/mfa` | 6-digit code verification |
| Home | `/home` | Success confirmation + logout |

---

## 🎯 Key Files

| File | Purpose |
|------|---------|
| `lib/app.dart` | Route registration |
| `lib/features/authentication/presentation/pages/login_screen.dart` | Login UI |
| `lib/features/authentication/presentation/pages/mfa_screen.dart` | MFA UI |
| `lib/features/home/presentation/pages/home_screen.dart` | Home UI |
| `lib/features/authentication/presentation/bloc/login/login_bloc.dart` | Login logic |
| `lib/features/authentication/presentation/bloc/mfa/mfa_bloc.dart` | MFA logic |
| `lib/core/utils/biometrics/biometric_auth_service.dart` | Biometric service |

---

## 🔄 Navigation Flow

```
Login Screen
    ↓
    ├─→ Direct Login (user@example.com) → Home Screen
    ├─→ MFA Login (mfa@example.com) → MFA Screen → Home Screen
    └─→ Biometric → Home Screen
    
Home Screen
    ↓
    └─→ Logout → Login Screen
```

---

## ⚙️ Configuration

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to quickly authenticate.</string>
```

---

## 🧩 State Management

### LoginBloc
```dart
Events:
  - LoginButtonPressed(email, password)
  - BiometricButtonPressed()

States:
  - idle, loading, success, error, mfaRequired
```

### MfaBloc
```dart
Events:
  - CodeChanged(code)
  - SubmitPressed()
  - ResendPressed()

States:
  - idle, loading, success, error, codeSent
```

---

## 🎨 UI Components

### Login Screen
- Email input with validation
- Password input with visibility toggle
- Sign In button
- Biometric button
- Error messages
- Loading indicator

### MFA Screen
- 6-digit code input (numeric-only)
- Verify button
- Resend button with countdown
- Error/success messages
- Back button

### Home Screen
- Success icon
- Authentication status
- Feature list
- Logout button

---

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Navigation not working | Check routes in `app.dart` |
| Biometric error | Check platform permissions |
| MFA code not accepting input | Ensure numeric-only input |
| Home screen not showing | Verify `/home` route registered |

---

## 📚 Documentation

| Document | Content |
|----------|---------|
| `README.md` | Feature overview |
| `QUICK_START.md` | Setup guide |
| `HOME_SCREEN_TESTING.md` | 13 test scenarios |
| `IMPLEMENTATION_COMPLETE.md` | Project status |
| `NEXT_STEPS.md` | Future enhancements |

---

## ✅ Test Checklist

- [ ] Direct login works
- [ ] MFA flow works
- [ ] Biometric works
- [ ] Error messages display
- [ ] Logout works
- [ ] Theme switching works
- [ ] Responsive design works
- [ ] No crashes

---

## 🚀 Next Steps

1. Run the app: `flutter run`
2. Test all scenarios
3. Verify on real devices
4. Integrate API when ready
5. Add additional features

---

## 💡 Tips

- Use demo credentials for testing
- Test on real devices for biometrics
- Check console logs for debugging
- Use hot reload for quick iteration
- Test theme switching

---

## 📞 Quick Help

**Q: How do I test MFA?**
A: Use email `mfa@example.com` and code `123456`

**Q: How do I test biometric?**
A: Click "Sign in with Biometrics" button

**Q: How do I logout?**
A: Click logout button on Home Screen

**Q: How do I go back from MFA?**
A: Click back button (top-left)

**Q: How do I toggle password visibility?**
A: Click eye icon in password field

---

**Status**: ✅ Ready for Testing

**Version**: v2.0 (Enhanced UI + MFA + Real Biometrics)

---

*For detailed information, see the full documentation files.*
