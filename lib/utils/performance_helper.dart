import 'package:flutter/widgets.dart';

/// Performance optimization helpers
class PerformanceHelper {
  /// Create a lazy list builder for better performance
  static Widget lazyListBuilder({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      cacheExtent: 500, // Cache 500 pixels
    );
  }

  /// Debounce function calls
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    // Implementation would use Timer
    callback();
  }

  /// Memoize expensive computations
  static T? memoize<T>(String key, T Function() computation) {
    // In production, use a proper cache
    return computation();
  }

  /// Optimize image loading
  static Widget optimizedImage(String path, {double? width, double? height}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}
