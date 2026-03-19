import '../models/ayah.dart';
import 'quran_service.dart';

/// AI Service for semantic search and spiritual insights
class AIService {
  final QuranService _quranService = QuranService();

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

  /// AI-Generated Tafsir Summary
  Future<String> getAISummary(int surahNumber, int ayahNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock high-quality AI generated spiritual insight
    return "This Verse reminds us that every challenge we face is accompanied by a divine ease that often remains unseen at first. The repetition in Surah Ash-Sharh emphasizes that the relief is not just following the hardship, but is intrinsically tied to it. Spiritually, it teaches us to look for the 'Yusr' (ease) within the 'Usr' (hardship) itself, fostering resilience and deep trust in Allah's wisdom.";
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
