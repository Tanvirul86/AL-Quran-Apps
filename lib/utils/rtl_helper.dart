import 'package:flutter/material.dart';

/// Helper for RTL (Right-to-Left) support
class RTLHelper {
  /// Check if text is Arabic
  static bool isArabic(String text) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicPattern.hasMatch(text);
  }

  /// Get text direction based on content
  static TextDirection getTextDirection(String text) {
    return isArabic(text) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get alignment for Arabic text
  static TextAlign getTextAlign(String text) {
    return isArabic(text) ? TextAlign.right : TextAlign.left;
  }

  /// Wrap widget with RTL support
  static Widget wrapRTL(Widget child, {bool forceRTL = false}) {
    return Directionality(
      textDirection: forceRTL ? TextDirection.rtl : TextDirection.ltr,
      child: child,
    );
  }

  /// Get flex alignment for Arabic
  static MainAxisAlignment getMainAxisAlignment(String text) {
    return isArabic(text) ? MainAxisAlignment.end : MainAxisAlignment.start;
  }

  /// Get cross alignment for Arabic
  static CrossAxisAlignment getCrossAxisAlignment(String text) {
    return isArabic(text) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }
}
