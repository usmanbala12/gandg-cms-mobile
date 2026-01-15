import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

/// Service for capturing device location.
class LocationService {
  final Logger _logger;

  LocationService({Logger? logger}) : _logger = logger ?? Logger();

  /// Gets the current device location.
  /// Returns a Map with latitude, longitude, accuracy, and capturedAt.
  /// Throws an exception if location services are disabled or permissions denied.
  Future<Map<String, dynamic>> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _logger.e('Location services are disabled');
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _logger.i('Requesting location permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _logger.e('Location permission denied');
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _logger.e('Location permission permanently denied');
      throw Exception(
        'Location permissions are permanently denied. Please enable in settings.',
      );
    }

    // Get the current position
    _logger.i('Getting current position...');
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    final locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'capturedAt': DateTime.now().toUtc().toIso8601String(),
    };

    _logger.i('📍 Location captured: ${position.latitude}, ${position.longitude}');
    return locationData;
  }

  /// Gets current location or returns a fallback with just address if location unavailable.
  /// This is a safer version that won't throw but may return incomplete data.
  Future<Map<String, dynamic>> getCurrentLocationOrFallback({
    String? fallbackAddress,
  }) async {
    try {
      return await getCurrentLocation();
    } catch (e) {
      _logger.w('Could not get location, using fallback: $e');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': fallbackAddress ?? 'Unknown',
        'capturedAt': DateTime.now().toUtc().toIso8601String(),
      };
    }
  }
}
