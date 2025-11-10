import 'package:logger/logger.dart';

class TLoggerHelper {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
    level: Level.debug, // Adjust log level as needed
  );

  /// Log a debug message
  static void debug(String message) => _logger.d(message);

  /// Log an info message
  static void info(String message) => _logger.i(message);

  /// Log a warning message
  static void warning(String message) => _logger.w(message);

  /// Log an error message with optional error details
  static void error(String message, [dynamic error]) =>
      _logger.e(message, error: error, stackTrace: StackTrace.current);
}
