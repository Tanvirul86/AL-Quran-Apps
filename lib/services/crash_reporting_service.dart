import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crash reporting service
class CrashReportingService {
  static final CrashReportingService _instance = CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  FirebaseCrashlytics? _crashlytics;

  void initialize(FirebaseCrashlytics crashlytics) {
    _crashlytics = crashlytics;
    
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      _crashlytics?.recordFlutterFatalError(errorDetails);
    };
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics?.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics?.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> log(String message) async {
    await _crashlytics?.log(message);
  }

  Future<void> setUserId(String userId) async {
    await _crashlytics?.setUserIdentifier(userId);
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics?.setCustomKey(key, value);
  }
}
