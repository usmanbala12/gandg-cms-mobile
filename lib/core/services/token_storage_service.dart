import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/authentication/data/models/auth_response_model.dart';
import '../../features/authentication/data/models/user_model.dart';

class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userDataKey = 'user_data';
  static const String _isBiometricEnabledKey = 'is_biometric_enabled';
  static const String _userEmailKey = 'user_email';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;
  final Logger _logger = Logger();

  // In-memory cache for runtime performance
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  UserModel? _cachedUser;

  TokenStorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  // Stream for signaling force logout
  final _logoutController = StreamController<void>.broadcast();
  Stream<void> get logoutStream => _logoutController.stream;

  /// Trigger a force logout across the app
  Future<void> triggerLogout() async {
    _logger.e('🚨 [TokenStorageService] Triggering force logout');
    await clearTokens();
    _logoutController.add(null);
  }

  /// Save access and refresh tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    print('🔑 [TokenStorageService] Saving tokens (access length: ${accessToken.length})');
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;
      print('✅ [TokenStorageService] Tokens saved and cached in memory');
    } catch (e) {
      print('❌ [TokenStorageService] Error saving tokens: $e');
      throw Exception('Failed to save tokens: $e');
    }
  }

  /// Get access token from cache or secure storage
  Future<String?> getAccessToken() async {
    try {
      if (_cachedAccessToken != null) {
        // print('📖 [TokenStorageService] Returning cached access token');
        return _cachedAccessToken;
      }

      print('📖 [TokenStorageService] Reading access token from secure storage...');
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null) {
        _cachedAccessToken = token;
        final preview = token.length > 8 ? '${token.substring(0, 8)}...' : 'short';
        print('✅ [TokenStorageService] Access token retrieved and cached ($preview)');
      } else {
        print('⚠️ [TokenStorageService] No access token found in secure storage');
      }
      return token;
    } catch (e) {
      print('❌ [TokenStorageService] Error reading access token: $e');
      throw Exception('Failed to get access token: $e');
    }
  }

  /// Get refresh token from cache or secure storage
  Future<String?> getRefreshToken() async {
    try {
      if (_cachedRefreshToken != null) {
        return _cachedRefreshToken;
      }
      print('📖 [TokenStorageService] Reading refresh token from secure storage...');
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null) {
        _cachedRefreshToken = token;
      }
      return token;
    } catch (e) {
      throw Exception('Failed to get refresh token: $e');
    }
  }

  /// Save token expiry time
  Future<void> saveTokenExpiry(DateTime expiry) async {
    print('⏰ [TokenStorageService] Saving token expiry: $expiry');
    await _sharedPreferences.setString(
      _tokenExpiryKey,
      expiry.toIso8601String(),
    );
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    final value = _sharedPreferences.getString(_tokenExpiryKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  /// Check if token is expired or about to expire
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return true;
    // Buffer of 30 seconds
    final isExpired = DateTime.now().add(const Duration(seconds: 30)).isAfter(expiry);
    if (isExpired) {
      print('⏰ [TokenStorageService] Token IS EXPIRED (Expiry: $expiry)');
    }
    return isExpired;
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    print('👤 [TokenStorageService] Saving user data for: ${user.email}');
    try {
      await _sharedPreferences.setString(
        _userDataKey,
        jsonEncode(user.toJson()),
      );
      _cachedUser = user;
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  /// Get saved user data
  Future<UserModel?> getUser() async {
    try {
      if (_cachedUser != null) {
        return _cachedUser;
      }
      final value = _sharedPreferences.getString(_userDataKey);
      if (value != null) {
        _cachedUser = UserModel.fromJson(jsonDecode(value));
        return _cachedUser;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Convenience method to save complete auth response
  Future<void> saveAuthResponse(AuthResponseModel response) async {
    print('📦 [TokenStorageService] Processing auth response...');
    if (response.accessToken != null && response.refreshToken != null) {
      await saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );
    }
    
    final expiry = response.tokenExpiry;
    if (expiry != null) {
      await saveTokenExpiry(expiry);
    }
    
    if (response.user != null) {
      await saveUser(response.user!);
      await setUserEmail(response.user!.email);
    }
  }

  /// Clear all tokens and cached data
  Future<void> clearTokens() async {
    print('🧹 [TokenStorageService] Clearing all tokens and cache');
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _sharedPreferences.remove(_tokenExpiryKey),
        _sharedPreferences.remove(_userDataKey),
      ]);
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      _cachedUser = null;
    } catch (e) {
      print('❌ [TokenStorageService] Error clearing tokens: $e');
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
      final accessToken = await getAccessToken();
      final authed = accessToken != null && accessToken.isNotEmpty;
      print('🔐 [TokenStorageService] isAuthenticated check: $authed');
      return authed;
    } catch (e) {
      print('❌ [TokenStorageService] isAuthenticated error: $e');
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
