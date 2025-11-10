import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerUtil {
  /// Request biometric permission on Android
  static Future<bool> requestBiometricPermission() async {
    try {
      print('[PermissionHandler] Requesting biometric permission...');
      final status = await Permission.sensors.request();
      print('[PermissionHandler] Biometric permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('[PermissionHandler] Error requesting biometric permission: $e');
      return false;
    }
  }

  /// Check if biometric permission is granted
  static Future<bool> isBiometricPermissionGranted() async {
    try {
      final status = await Permission.sensors.status;
      print('[PermissionHandler] Biometric permission status: $status');
      return status.isGranted;
    } catch (e) {
      print('[PermissionHandler] Error checking biometric permission: $e');
      return false;
    }
  }

  /// Check if biometric permission is denied
  static Future<bool> isBiometricPermissionDenied() async {
    try {
      final status = await Permission.sensors.status;
      return status.isDenied;
    } catch (e) {
      print('[PermissionHandler] Error checking biometric permission: $e');
      return false;
    }
  }

  /// Check if biometric permission is permanently denied
  static Future<bool> isBiometricPermissionPermanentlyDenied() async {
    try {
      final status = await Permission.sensors.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      print('[PermissionHandler] Error checking biometric permission: $e');
      return false;
    }
  }

  /// Open app settings to allow user to grant permission
  static Future<void> openAppSettings() async {
    try {
      print('[PermissionHandler] Opening app settings...');
      await openAppSettings();
    } catch (e) {
      print('[PermissionHandler] Error opening app settings: $e');
    }
  }

  /// Get permission status description
  static String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.restricted:
        return 'Permission restricted';
      case PermissionStatus.limited:
        return 'Permission limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied';
      case PermissionStatus.provisional:
        return 'Permission provisional';
    }
  }
}
