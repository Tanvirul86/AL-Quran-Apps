/// Helper utilities for data processing and validation
class DataHelper {
  /// Validate Arabic text (basic check for Uthmani characters)
  static bool isValidArabicText(String text) {
    // Basic validation - check for Arabic Unicode range
    final arabicPattern = RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');
    return arabicPattern.hasMatch(text);
  }

  /// Format surah reference (e.g., "1:7")
  static String formatSurahReference(int surahNumber, int ayahNumber) {
    return '$surahNumber:$ayahNumber';
  }

  /// Format ayah count text
  static String formatAyahCount(int count) {
    return '$count ${count == 1 ? 'Ayah' : 'Ayahs'}';
  }

  /// Get revelation type display name
  static String getRevelationTypeDisplay(String type) {
    return type == 'Meccan' ? 'Meccan' : 'Medinan';
  }

  /// Sanitize search query
  static String sanitizeSearchQuery(String query) {
    return query.trim().toLowerCase();
  }

  /// Highlight search terms in text (for future use)
  static String highlightSearchTerms(String text, String query) {
    if (query.isEmpty) return text;
    final regex = RegExp(query, caseSensitive: false);
    return text.replaceAllMapped(
      regex,
      (match) => '**${match.group(0)}**',
    );
  }
}
