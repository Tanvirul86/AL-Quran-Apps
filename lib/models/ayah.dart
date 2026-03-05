/// Ayah model representing a verse of the Qur'an
class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final int globalAyahNumber; // Sequential number across all surahs
  final String arabicText; // Uthmani text
  final String englishTranslation;
  final String banglaTranslation;
  final String? transliteration; // Optional
  
  // Dynamic translations map for multiple languages
  final Map<String, String> translations;

  Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.globalAyahNumber,
    required this.arabicText,
    required this.englishTranslation,
    required this.banglaTranslation,
    this.transliteration,
    Map<String, String>? translations,
  }) : translations = translations ?? {};

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      globalAyahNumber: json['globalAyahNumber'] as int,
      arabicText: json['arabicText'] as String,
      englishTranslation: json['englishTranslation'] as String,
      banglaTranslation: json['banglaTranslation'] as String,
      transliteration: json['transliteration'] as String?,
      translations: json['translations'] != null 
          ? Map<String, String>.from(json['translations']) 
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'globalAyahNumber': globalAyahNumber,
      'arabicText': arabicText,
      'englishTranslation': englishTranslation,
      'banglaTranslation': banglaTranslation,
      'transliteration': transliteration,
      'translations': translations,
    };
  }
  
  /// Get translation for a specific language/translator ID
  String? getTranslation(String translationId) {
    return translations[translationId];
  }
  
  /// Create a copy with additional translations
  Ayah copyWithTranslation(String translationId, String text) {
    final newTranslations = Map<String, String>.from(translations);
    newTranslations[translationId] = text;
    return Ayah(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      globalAyahNumber: globalAyahNumber,
      arabicText: arabicText,
      englishTranslation: englishTranslation,
      banglaTranslation: banglaTranslation,
      transliteration: transliteration,
      translations: newTranslations,
    );
  }

  /// Get formatted ayah reference (e.g., "2:255")
  String get reference => '$surahNumber:$ayahNumber';
}
