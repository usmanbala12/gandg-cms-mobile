import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  // In-memory cache for runtime performance
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  TokenStorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  /// Save access and refresh tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      print('🔐 [TokenStorage] Saving tokens...');
      print('🔐 [TokenStorage] Access token length: ${accessToken.length}');
      print('🔐 [TokenStorage] Refresh token length: ${refreshToken.length}');

      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;

      print('✅ [TokenStorage] Tokens saved successfully');

      // Immediate verification
      final savedAccessToken = await _secureStorage.read(key: _accessTokenKey);
      final savedRefreshToken = await _secureStorage.read(
        key: _refreshTokenKey,
      );

      if (savedAccessToken != null && savedRefreshToken != null) {
        print('✅ [TokenStorage] Verification: Tokens persisted correctly');
      } else {
        print(
          '❌ [TokenStorage] Verification FAILED: Tokens not found after save!',
        );
        print('   Access token present: ${savedAccessToken != null}');
        print('   Refresh token present: ${savedRefreshToken != null}');
      }
    } catch (e) {
      print('❌ [TokenStorage] Failed to save tokens: $e');
      throw Exception('Failed to save tokens: $e');
    }
  }

  /// Get access token from cache or secure storage
  Future<String?> getAccessToken() async {
    try {
      if (_cachedAccessToken != null) {
        print('🔑 [TokenStorage] Access token retrieved from cache');
        return _cachedAccessToken;
      }

      print('🔍 [TokenStorage] Fetching access token from secure storage...');
      final token = await _secureStorage.read(key: _accessTokenKey);

      if (token != null) {
        _cachedAccessToken = token;
        print(
          '✅ [TokenStorage] Access token found in storage (length: ${token.length})',
        );
      } else {
        print('⚠️ [TokenStorage] No access token found in storage');
      }

      return token;
    } catch (e) {
      print('❌ [TokenStorage] Failed to get access token: $e');
      throw Exception('Failed to get access token: $e');
    }
  }

  /// Get refresh token from cache or secure storage
  Future<String?> getRefreshToken() async {
    try {
      if (_cachedRefreshToken != null) {
        return _cachedRefreshToken;
      }
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null) {
        _cachedRefreshToken = token;
      }
      return token;
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  /// Clear all tokens and cached data
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
      ]);
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
    } catch (e) {
      throw Exception('Failed to clear tokens: $e');
    }
  }

  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _sharedPreferences.setBool(_isBiometricEnabledKey, enabled);
    } catch (e) {
      throw Exception('Failed to set biometric enabled: $e');
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return _sharedPreferences.getBool(_isBiometricEnabledKey) ?? false;
    } catch (e) {
      throw Exception('Failed to check biometric enabled: $e');
    }
  }

  /// Save user email for biometric re-login
  Future<void> setUserEmail(String email) async {
    try {
      await _sharedPreferences.setString(_userEmailKey, email);
    } catch (e) {
      throw Exception('Failed to set user email: $e');
    }
  }

  /// Get saved user email
  Future<String?> getUserEmail() async {
    try {
      return _sharedPreferences.getString(_userEmailKey);
    } catch (e) {
      throw Exception('Failed to get user email: $e');
    }
  }

  /// Clear user email
  Future<void> clearUserEmail() async {
    try {
      await _sharedPreferences.remove(_userEmailKey);
    } catch (e) {
      throw Exception('Failed to clear user email: $e');
    }
  }

  /// Check if user is authenticated (has valid access token)
  Future<bool> isAuthenticated() async {
    try {
      print('🔐 [TokenStorage] Checking authentication status...');
      final accessToken = await getAccessToken();
      final isAuth = accessToken != null && accessToken.isNotEmpty;

      if (isAuth) {
        print('✅ [TokenStorage] User IS authenticated (token present)');
      } else {
        print('❌ [TokenStorage] User NOT authenticated (no token found)');
      }

      return isAuth;
    } catch (e) {
      print('❌ [TokenStorage] Error checking authentication: $e');
      return false;
    }
  }

  /// Check if user has both access and refresh tokens
  Future<bool> hasValidTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      return accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
