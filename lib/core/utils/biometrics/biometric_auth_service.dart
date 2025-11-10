import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Result model for biometric authentication
class BiometricResult {
  final bool success;
  final String? error;

  BiometricResult({
    required this.success,
    this.error,
  });
}

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      print('[BiometricAuthService] canCheckBiometrics: $canCheckBiometrics');
      print('[BiometricAuthService] isDeviceSupported: $isDeviceSupported');

      return canCheckBiometrics || isDeviceSupported;
    } catch (e) {
      print('[BiometricAuthService] Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      print('[BiometricAuthService] Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      print('[BiometricAuthService] Error getting biometric types: $e');
      return [];
    }
  }

  /// Authenticate using biometrics with detailed error handling
  Future<BiometricResult> authenticate({
    String reason = 'Authenticate to continue',
    bool stickyAuth = true,
  }) async {
    try {
      print('[BiometricAuthService] Starting biometric authentication...');
      print('[BiometricAuthService] Reason: $reason');

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: false, // Allow device credentials as fallback
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
      );

      print('[BiometricAuthService] Authentication result: $authenticated');

      return BiometricResult(
        success: authenticated,
        error: null,
      );
    } on PlatformException catch (e) {
      print('[BiometricAuthService] Platform exception: ${e.code} - ${e.message}');
      print('[BiometricAuthService] Details: ${e.details}');

      final errorMessage = _getPlatformErrorMessage(e.code);
      return BiometricResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      print('[BiometricAuthService] Unexpected error: $e');
      return BiometricResult(
        success: false,
        error: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Parse platform-specific error codes and return user-friendly messages
  String _getPlatformErrorMessage(String code) {
    switch (code) {
      case 'no_fragment_activity':
        return 'Biometric service initialization failed. Please restart the app.';
      case 'NotAvailable':
        return 'Biometric authentication is not available on this device.';
      case 'NotEnrolled':
        return 'No biometric data enrolled. Please set up biometrics in device settings.';
      case 'LockedOut':
        return 'Too many failed attempts. Please try again later.';
      case 'PermanentlyLockedOut':
        return 'Biometric is permanently locked. Please use password login.';
      case 'UserCanceled':
        return 'Authentication was canceled.';
      case 'GoToSettingsButton':
        return 'Please enable biometrics in device settings.';
      case 'PasscodeNotSet':
        return 'Device passcode is not set. Please set a passcode first.';
      case 'NoDevicePin':
        return 'Device PIN is not set. Please set a PIN first.';
      case 'NoFingerprint':
        return 'No fingerprint enrolled. Please add a fingerprint in settings.';
      case 'NoFaceID':
        return 'Face ID is not available. Please set up Face ID in settings.';
      case 'HardwareNotPresent':
        return 'Biometric hardware is not available on this device.';
      case 'NegativeButton':
        return 'Authentication was canceled.';
      case 'DeviceCredentialNotAvailable':
        return 'Device credentials are not available.';
      default:
        return 'Biometric authentication failed: $code';
    }
  }

  /// Stop any ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      print('[BiometricAuthService] Stopping authentication...');
      await _auth.stopAuthentication();
      print('[BiometricAuthService] Authentication stopped');
    } catch (e) {
      print('[BiometricAuthService] Error stopping authentication: $e');
    }
  }

  /// Get detailed biometric information for debugging
  Future<Map<String, dynamic>> getBiometricInfo() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      final biometrics = await _auth.getAvailableBiometrics();

      return {
        'canCheckBiometrics': canCheckBiometrics,
        'isDeviceSupported': isDeviceSupported,
        'availableBiometrics': biometrics.map((b) => b.toString()).toList(),
        'hasBiometrics': biometrics.isNotEmpty,
      };
    } catch (e) {
      print('[BiometricAuthService] Error getting biometric info: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}
