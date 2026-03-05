import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance utilities for optimization
class PerformanceUtils {
  /// Debounce function calls to prevent excessive executions
  static Timer? _debounceTimer;
  
  static void debounce(
    Duration duration,
    VoidCallback action,
  ) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleTime;
  
  static void throttle(
    Duration duration,
    VoidCallback action,
  ) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      action();
    }
  }

  /// Run expensive operations in isolate
  static Future<R> runInIsolate<R>(
    ComputeCallback<dynamic, R> callback,
    dynamic message,
  ) async {
    return await compute(callback, message);
  }

  /// Lazy load data with pagination
  static List<T> paginateList<T>(
    List<T> items, {
    required int page,
    int pageSize = 20,
  }) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, items.length);
    
    if (startIndex >= items.length) {
      return [];
    }
    
    return items.sublist(startIndex, endIndex);
  }

  /// Cache manager for expensive computations
  static final Map<String, dynamic> _cache = {};
  
  static T? getFromCache<T>(String key) {
    return _cache[key] as T?;
  }
  
  static void saveToCache<T>(String key, T value) {
    _cache[key] = value;
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  static void removeFromCache(String key) {
    _cache.remove(key);
  }

  /// Memory-efficient list builder
  static bool shouldRebuild(int oldIndex, int newIndex, int viewportSize) {
    return (newIndex - oldIndex).abs() <= viewportSize;
  }
}

/// Memoization decorator
class Memoize<T> {
  final Map<String, T> _cache = {};
  final T Function() _computation;

  Memoize(this._computation);

  T call([String key = 'default']) {
    if (!_cache.containsKey(key)) {
      _cache[key] = _computation();
    }
    return _cache[key]!;
  }

  void clear() {
    _cache.clear();
  }
}

/// Lazy value wrapper
class Lazy<T> {
  final T Function() _initializer;
  T? _value;
  bool _initialized = false;

  Lazy(this._initializer);

  T get value {
    if (!_initialized) {
      _value = _initializer();
      _initialized = true;
    }
    return _value!;
  }

  bool get isInitialized => _initialized;

  void reset() {
    _value = null;
    _initialized = false;
  }
}
