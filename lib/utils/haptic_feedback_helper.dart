import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Helper for haptic feedback throughout the app
class HapticFeedbackHelper {
  /// Light haptic feedback
  static Future<void> lightImpact(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback
  static Future<void> mediumImpact(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback
  static Future<void> heavyImpact(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    HapticFeedback.heavyImpact();
  }

  /// Success feedback
  static Future<void> success(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    HapticFeedback.mediumImpact();
  }

  /// Error feedback
  static Future<void> error(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    HapticFeedback.heavyImpact();
  }
}
