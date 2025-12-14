import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Application-wide logger for error tracking and debugging.
///
/// In release mode: Only logs warnings and errors
/// In debug mode: Logs everything including debug messages
///
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error: e, stackTrace: st);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  /// Debug log - only in debug mode
  static void d(dynamic message) {
    _logger.d(message);
  }

  /// Info log
  static void i(dynamic message) {
    _logger.i(message);
  }

  /// Warning log
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error log - always logged even in release
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Fatal error log
  static void f(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
