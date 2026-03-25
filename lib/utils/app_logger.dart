import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app.
/// Only logs in debug mode — completely silent in release builds.
/// Ready to forward to Crashlytics or any remote logging service.
class AppLogger {
  AppLogger._();

  /// Log informational messages (only in debug mode)
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $prefix$message');
    }
  }

  /// Log warning messages (only in debug mode)
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $prefix$message');
    }
  }

  /// Log error messages (only in debug mode, but also forwards to crash reporting)
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   StackTrace: $stackTrace');
      }
    }
    // TODO: Forward to CrashReportingService when Firebase is configured
    // CrashReportingService().recordError(error, stackTrace, reason: message);
  }

  /// Log debug messages (only in debug mode, verbose)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🔍 $prefix$message');
    }
  }
}
