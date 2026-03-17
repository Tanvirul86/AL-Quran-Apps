import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

/// Provider for app settings
class SettingsProvider with ChangeNotifier {
  bool _showBangla = true;
  bool _showEnglish = true;
  AppThemeType _currentTheme = AppThemeType.light;
  double _arabicFontSize = AppConstants.defaultArabicFontSize;
  double _banglaFontSize = AppConstants.defaultBanglaFontSize;
  double _englishFontSize = AppConstants.defaultEnglishFontSize;
  double _playbackSpeed = AppConstants.defaultPlaybackSpeed;
  String _selectedEnglishTranslation = 'sahih_international';
  String _selectedBanglaTranslation = 'taqi_usmani';
  bool _highContrastMode = false;
  bool _hapticFeedbackEnabled = true;
  Color _customSeedColor = const Color(0xFF009688);
  
  // Multi-language translation support (up to 2 languages)
  List<Map<String, String>> _selectedTranslations = [];

  bool get showBangla => _showBangla;
  bool get showEnglish => _showEnglish;
  AppThemeType get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppThemeType.dark; // Backward compatibility
  double get arabicFontSize => _arabicFontSize;
  double get banglaFontSize => _banglaFontSize;
  double get englishFontSize => _englishFontSize;
  double get playbackSpeed => _playbackSpeed;
  String get selectedEnglishTranslation => _selectedEnglishTranslation;
  String get selectedBanglaTranslation => _selectedBanglaTranslation;
  bool get highContrastMode => _highContrastMode;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  Color get customSeedColor => _customSeedColor;
  List<Map<String, String>> get selectedTranslations => List.unmodifiable(_selectedTranslations);
  
  // Legacy getters for backward compatibility
  String get selectedTranslationId => _selectedTranslations.isNotEmpty ? _selectedTranslations[0]['id']! : '';
  String get selectedTranslationLanguage => _selectedTranslations.isNotEmpty ? _selectedTranslations[0]['language']! : '';

  SettingsProvider() {
    _loadSettings();
  }

  void _syncLegacyVisibilityWithSelections({required bool updateWhenEmpty}) {
    if (_selectedTranslations.isEmpty && !updateWhenEmpty) {
      return;
    }

    _showEnglish = _selectedTranslations.any((t) => t['language'] == 'en');
    _showBangla = _selectedTranslations.any((t) => t['language'] == 'bn');
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _showBangla = prefs.getBool(AppConstants.keyShowBangla) ?? true;
    _showEnglish = prefs.getBool(AppConstants.keyShowEnglish) ?? true;
    
    // Load theme with backward compatibility
    final themeIndex = prefs.getInt('selected_theme') ?? 0;
    final isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    
    if (themeIndex == 0 && isDarkMode) {
      _currentTheme = AppThemeType.dark;
    } else {
      _currentTheme = AppThemeType.values[themeIndex.clamp(0, AppThemeType.values.length - 1)];
    }
    
    _arabicFontSize = prefs.getDouble(AppConstants.keyArabicFontSize) ?? AppConstants.defaultArabicFontSize;
    _banglaFontSize = prefs.getDouble(AppConstants.keyBanglaFontSize) ?? AppConstants.defaultBanglaFontSize;
    _englishFontSize = prefs.getDouble(AppConstants.keyEnglishFontSize) ?? AppConstants.defaultEnglishFontSize;
    _playbackSpeed = prefs.getDouble(AppConstants.keyPlaybackSpeed) ?? AppConstants.defaultPlaybackSpeed;
    
    // Load selected translations list (stored as StringList: "id:language")
    try {
      final rawList = prefs.getStringList('selected_translations_list') ?? [];
      _selectedTranslations = rawList.map((s) {
        final parts = s.split(':');
        if (parts.length >= 2) {
          return {'id': parts[0], 'language': parts[1]};
        }
        return <String, String>{};
      }).where((m) => m.isNotEmpty).toList();
    } catch (e) {
      _selectedTranslations = [];
    }

    // If any new translation selection is present, reflect it in legacy toggles.
    _syncLegacyVisibilityWithSelections(updateWhenEmpty: false);

    _customSeedColor = Color(prefs.getInt('custom_seed_color') ?? 0xFF009688);
    notifyListeners();
  }

  Future<void> setShowBangla(bool value) async {
    _showBangla = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShowBangla, value);
    notifyListeners();
  }

  Future<void> setShowEnglish(bool value) async {
    _showEnglish = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyShowEnglish, value);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_theme', theme.index);
    // Backward compatibility
    await prefs.setBool(AppConstants.keyDarkMode, theme == AppThemeType.dark);
    notifyListeners();
  }

  // Backward compatibility method
  Future<void> setDarkMode(bool value) async {
    final theme = value ? AppThemeType.dark : AppThemeType.light;
    await setTheme(theme);
  }

  Future<void> setArabicFontSize(double value) async {
    _arabicFontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyArabicFontSize, value);
    notifyListeners();
  }

  Future<void> setBanglaFontSize(double value) async {
    _banglaFontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyBanglaFontSize, value);
    notifyListeners();
  }

  Future<void> setEnglishFontSize(double value) async {
    _englishFontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyEnglishFontSize, value);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double value) async {
    _playbackSpeed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyPlaybackSpeed, value);
    notifyListeners();
  }

  Future<void> setSelectedEnglishTranslation(String value) async {
    _selectedEnglishTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_english_translation', value);
    notifyListeners();
  }

  Future<void> setSelectedBanglaTranslation(String value) async {
    _selectedBanglaTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_bangla_translation', value);
    notifyListeners();
  }

  Future<void> setHighContrastMode(bool value) async {
    _highContrastMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast_mode', value);
    notifyListeners();
  }

  Future<void> setHapticFeedbackEnabled(bool value) async {
    _hapticFeedbackEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_feedback_enabled', value);
    notifyListeners();
  }

  Future<void> setCustomSeedColor(Color color) async {
    _customSeedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('custom_seed_color', color.value);
    notifyListeners();
  }

  Future<void> setSelectedTranslation(String id, String language) async {
    await selectTranslation(id, language);
  }

  /// Selects a translation: toggles off if same ID already selected,
  /// replaces existing entry for the same language, or adds (max 2).
  Future<void> selectTranslation(String id, String language) async {
    final existingIndex = _selectedTranslations.indexWhere(
      (t) => t['language'] == language,
    );

    if (existingIndex != -1) {
      if (_selectedTranslations[existingIndex]['id'] == id) {
        // Same translator tapped again → deselect
        _selectedTranslations.removeAt(existingIndex);
      } else {
        // Different translator in same language → replace
        _selectedTranslations[existingIndex] = {'id': id, 'language': language};
      }
    } else {
      // New language — add (max 2, replace oldest if full)
      if (_selectedTranslations.length >= 2) {
        _selectedTranslations.removeAt(0);
      }
      _selectedTranslations.add({'id': id, 'language': language});
    }

    // Translation tab should control Bangla/English visibility immediately.
    _syncLegacyVisibilityWithSelections(updateWhenEmpty: true);
    
    final prefs = await SharedPreferences.getInstance();
    final stringList = _selectedTranslations.map((t) => '${t['id']}:${t['language']}').toList();
    await prefs.setStringList('selected_translations_list', stringList);
    await prefs.setBool(AppConstants.keyShowEnglish, _showEnglish);
    await prefs.setBool(AppConstants.keyShowBangla, _showBangla);
    notifyListeners();
  }
  
  bool isTranslationSelected(String language) {
    return _selectedTranslations.any((t) => t['language'] == language);
  }
  
  Future<void> clearAllTranslations() async {
    _selectedTranslations.clear();
    _syncLegacyVisibilityWithSelections(updateWhenEmpty: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_translations_list');
    await prefs.setBool(AppConstants.keyShowEnglish, _showEnglish);
    await prefs.setBool(AppConstants.keyShowBangla, _showBangla);
    notifyListeners();
  }
}
