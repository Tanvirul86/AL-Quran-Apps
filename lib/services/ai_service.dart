import '../models/ayah.dart';
import 'quran_service.dart';

/// AI Service for semantic search and spiritual insights
class AIService {
  final QuranService _quranService = QuranService();
  final Map<String, String> _insightCache = {};

  /// Semantic search based on emotion or context
  Future<List<Ayah>> semanticSearch(String query) async {
    // Simulate complex AI embedding/semantic mapping
    await Future.delayed(const Duration(seconds: 2));
    
    final normalizedQuery = query.toLowerCase();
    
    // Mapping common emotions/contexts to relevant Ayahs (Mocking the AI behavior)
    if (normalizedQuery.contains('sad') || normalizedQuery.contains('depressed') || normalizedQuery.contains('hardship')) {
      return await _getAyahsByNumbers([(94, 5), (94, 6), (2, 155)]); // Ash-Sharh, Al-Baqarah
    } else if (normalizedQuery.contains('happy') || normalizedQuery.contains('gratitude') || normalizedQuery.contains('blessing')) {
      return await _getAyahsByNumbers([(55, 13), (14, 7), (16, 18)]); // Ar-Rahman, Ibrahim, An-Nahl
    } else if (normalizedQuery.contains('anxiety') || normalizedQuery.contains('peace') || normalizedQuery.contains('calm')) {
      return await _getAyahsByNumbers([(13, 28), (2, 186), (48, 4)]); // Ar-Ra'd, Al-Baqarah, Al-Fath
    } else if (normalizedQuery.contains('guidance') || normalizedQuery.contains('lost') || normalizedQuery.contains('purpose')) {
      return await _getAyahsByNumbers([(1, 6), (2, 2), (93, 7)]); // Al-Fatihah, Al-Baqarah, Ad-Duha
    }
    
    // Fallback to keyword search if no semantic match found
    return await _quranService.searchAyahs(query);
  }

  /// AI-Generated ayah-specific spiritual summary
  Future<String> getAISummary(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    final cached = _insightCache[key];
    if (cached != null) return cached;

    await Future.delayed(const Duration(milliseconds: 450));

    final ayahs = await _quranService.loadAyahs(surahNumber);
    final ayah = ayahs.firstWhere(
      (a) => a.ayahNumber == ayahNumber,
      orElse: () => ayahs.first,
    );

    final ar = ayah.arabicText;
    final en = ayah.englishTranslation.toLowerCase();

    String theme =
        "This ayah calls for sincere reflection, steady faith, and action rooted in Allah's guidance.";

    if (en.contains('mercy') || en.contains('merciful') || ar.contains('رحم')) {
      theme =
          "This ayah highlights Allah's mercy and reminds the heart to return to Him with hope, humility, and gratitude.";
    } else if (en.contains('forgive') ||
        en.contains('forgiveness') ||
        ar.contains('غفر')) {
      theme =
          "This ayah invites sincere tawbah, showing that turning back to Allah is always a path of healing and elevation.";
    } else if (en.contains('believe') || en.contains('faith') || ar.contains('آمن')) {
      theme =
          "This ayah strengthens iman by calling for trust in Allah, consistency in worship, and steadfastness in tests.";
    } else if (en.contains('patience') ||
        en.contains('patient') ||
        ar.contains('صبر')) {
      theme =
          "This ayah teaches sabr with dignity: endure with reliance on Allah, and continue doing what is right.";
    } else if (en.contains('pray') || en.contains('prayer') || ar.contains('صل')) {
      theme =
          "This ayah emphasizes salah as a direct lifeline to Allah and a source of inner calm and discipline.";
    } else if (en.contains('paradise') ||
        en.contains('garden') ||
        ar.contains('جنة')) {
      theme =
          "This ayah motivates long-term obedience by reminding us that eternal reward is greater than temporary ease.";
    } else if (en.contains('fire') ||
        en.contains('punishment') ||
        ar.contains('نار')) {
      theme =
          "This ayah is a wake-up call toward repentance, justice, and conscious obedience before accountability.";
    }

    final insight = 'Surah $surahNumber, Ayah $ayahNumber: $theme';
    _insightCache[key] = insight;
    return insight;
  }

  Future<List<Ayah>> _getAyahsByNumbers(List<(int, int)> numbers) async {
    List<Ayah> results = [];
    for (var (surah, ayah) in numbers) {
      final ayahs = await _quranService.loadAyahs(surah);
      results.add(ayahs.firstWhere((a) => a.ayahNumber == ayah));
    }
    return results;
  }
}
