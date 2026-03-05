import 'package:vibration/vibration.dart';
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
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 10);
    }
  }

  /// Medium haptic feedback
  static Future<void> mediumImpact(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20);
    }
  }

  /// Heavy haptic feedback
  static Future<void> heavyImpact(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 30);
    }
  }

  /// Success feedback
  static Future<void> success(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 50, 50, 50]);
    }
  }

  /// Error feedback
  static Future<void> error(BuildContext? context) async {
    if (context != null) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (!settings.hapticFeedbackEnabled) return;
    }
    
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }
}
