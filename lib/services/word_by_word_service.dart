import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_meaning.dart';

/// Word-by-word translation service
class WordByWordService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  
  /// Get word-by-word meanings for an ayah
  Future<List<WordMeaning>> getWordMeanings({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'words_${surahNumber}_$ayahNumber';
      final cached = prefs.getString(cacheKey);
      
      if (cached != null) {
        final List<dynamic> data = json.decode(cached);
        return data.map((json) => WordMeaning.fromJson(json)).toList();
      }

      // Fetch from API
      final response = await _dio.get(
        '$_baseUrl/quran/verses/$surahNumber:$ayahNumber',
        queryParameters: {
          'words': true,
          'translations': '131,20', // English and Bangla word translations
        },
      );

      if (response.statusCode == 200) {
        final words = _parseWordMeanings(response.data, surahNumber, ayahNumber);
        
        // Cache the result
        await prefs.setString(cacheKey, json.encode(
          words.map((w) => w.toJson()).toList(),
        ));
        
        return words;
      }

      return _getSampleWordMeanings(surahNumber, ayahNumber);
    } catch (e) {
      return _getSampleWordMeanings(surahNumber, ayahNumber);
    }
  }

  /// Get word meaning by position in ayah
  Future<WordMeaning?> getWordMeaning({
    required int surahNumber,
    required int ayahNumber,
    required int position,
  }) async {
    final words = await getWordMeanings(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );
    
    if (position >= 0 && position < words.length) {
      return words[position];
    }
    
    return null;
  }

  /// Search word meanings across all ayahs
  Future<List<Map<String, dynamic>>> searchWord(String arabicWord) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': arabicWord,
          'size': 20,
        },
      );

      if (response.statusCode == 200) {
        return _parseSearchResults(response.data);
      }
    } catch (e) {
      // Search error
    }
    return [];
  }

  /// Get root word information
  Future<Map<String, dynamic>?> getRootWordInfo(String rootWord) async {
    try {
      // This would connect to a morphology API
      // For now, return sample data
      return {
        'root': rootWord,
        'meaning': 'Sample root meaning',
        'derivedWords': [],
        'occurrences': 0,
      };
    } catch (e) {
      return null;
    }
  }

  List<WordMeaning> _parseWordMeanings(
    dynamic data,
    int surahNumber,
    int ayahNumber,
  ) {
    final List<WordMeaning> words = [];
    
    if (data is Map && data['verse'] != null && data['verse']['words'] != null) {
      int position = 0;
      for (final word in data['verse']['words']) {
        words.add(WordMeaning(
          arabicWord: word['text_uthmani'] ?? '',
          transliteration: word['transliteration']?['text'] ?? '',
          englishMeaning: word['translation']?['text'] ?? '',
          banglaMeaning: word['bangla_translation'] ?? '',
          rootWord: word['root'] ?? '',
          position: position++,
        ));
      }
    }
    
    return words;
  }

  List<Map<String, dynamic>> _parseSearchResults(dynamic data) {
    final List<Map<String, dynamic>> results = [];
    
    if (data is Map && data['verses'] != null) {
      for (final verse in data['verses']) {
        results.add({
          'surahNumber': verse['verse_key']?.split(':')[0],
          'ayahNumber': verse['verse_key']?.split(':')[1],
          'text': verse['text_uthmani'],
        });
      }
    }
    
    return results;
  }

  List<WordMeaning> _getSampleWordMeanings(int surahNumber, int ayahNumber) {
    // Sample word meanings for Bismillah (1:1)
    if (surahNumber == 1 && ayahNumber == 1) {
      return [
        WordMeaning(
          arabicWord: 'بِسْمِ',
          transliteration: 'bismi',
          englishMeaning: 'In the name',
          banglaMeaning: 'নামে',
          rootWord: 'س م و',
          position: 0,
        ),
        WordMeaning(
          arabicWord: 'ٱللَّهِ',
          transliteration: 'allāhi',
          englishMeaning: 'of Allah',
          banglaMeaning: 'আল্লাহর',
          rootWord: 'ا ل ه',
          position: 1,
        ),
        WordMeaning(
          arabicWord: 'ٱلرَّحْمَٰنِ',
          transliteration: 'ar-raḥmāni',
          englishMeaning: 'the Most Gracious',
          banglaMeaning: 'পরম করুণাময়',
          rootWord: 'ر ح م',
          position: 2,
        ),
        WordMeaning(
          arabicWord: 'ٱلرَّحِيمِ',
          transliteration: 'ar-raḥīmi',
          englishMeaning: 'the Most Merciful',
          banglaMeaning: 'অসীম দয়ালু',
          rootWord: 'ر ح م',
          position: 3,
        ),
      ];
    }
    
    return [];
  }
}
