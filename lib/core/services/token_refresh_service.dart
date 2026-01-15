import 'dart:async';
import 'package:logger/logger.dart';
import 'token_storage_service.dart';
import '../../features/authentication/domain/usecases/refresh_token_usecase.dart';

/// Service responsible for proactive token renewal based on expiration time.
/// 
/// It schedules a refresh operation before the current access token expires
/// to ensure a seamless user experience without request interruptions.
class TokenRefreshService {
  final TokenStorageService tokenStorageService;
  final RefreshTokenUseCase refreshTokenUseCase;
  final Logger _logger = Logger();

  Timer? _refreshTimer;
  bool _isStarted = false;

  TokenRefreshService({
    required this.tokenStorageService,
    required this.refreshTokenUseCase,
  });

  /// Start the monitoring and auto-refresh process.
  void start() {
    if (_isStarted) return;
    _isStarted = true;
    _scheduleNextRefresh();
    _logger.i('🚀 [TokenRefreshService] Started');
  }

  /// Stop the auto-refresh process.
  void stop() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isStarted = false;
    _logger.i('🛑 [TokenRefreshService] Stopped');
  }

  /// Manually trigger a refresh check.
  Future<void> checkNow() async {
    await _scheduleNextRefresh();
  }

  Future<void> _scheduleNextRefresh() async {
    _refreshTimer?.cancel();
    
    if (!_isStarted) return;

    final expiry = await tokenStorageService.getTokenExpiry();
    if (expiry == null) {
      _logger.d('ℹ️ [TokenRefreshService] No token expiry found');
      return;
    }

    final now = DateTime.now();
    final timeUntilExpiry = expiry.difference(now);
    
    // Refresh 1 minute before expiry, or immediately if already expiring
    final refreshDelay = timeUntilExpiry - const Duration(minutes: 1);
    
    if (refreshDelay.isNegative) {
      _logger.i('🔄 [TokenRefreshService] Token expiring soon or already expired. Refreshing now.');
      await _performRefresh();
    } else {
      _logger.d('⏳ [TokenRefreshService] Next refresh scheduled in ${refreshDelay.inMinutes} minutes (${expiry.toLocal()})');
      _refreshTimer = Timer(refreshDelay, _performRefresh);
    }
  }

  Future<void> _performRefresh() async {
    try {
      final refreshToken = await tokenStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('⚠️ [TokenRefreshService] Cannot refresh: No refresh token found');
        stop();
        return;
      }

      _logger.i('🔄 [TokenRefreshService] Performing proactive token refresh...');
      final result = await refreshTokenUseCase(refreshToken);
      
      result.fold(
        (failure) {
          _logger.e('❌ [TokenRefreshService] Proactive refresh failed: ${failure.message}');
          // Retry later or stop if it's a permanent failure
          _refreshTimer = Timer(const Duration(minutes: 1), _performRefresh);
        },
        (_) {
          _logger.i('✅ [TokenRefreshService] Token refreshed successfully');
          _scheduleNextRefresh();
        },
      );
    } catch (e) {
      _logger.e('❌ [TokenRefreshService] Unexpected error during refresh: $e');
      _refreshTimer = Timer(const Duration(minutes: 5), _performRefresh);
    }
  }
}
