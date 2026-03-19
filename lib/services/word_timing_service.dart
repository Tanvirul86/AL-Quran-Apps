import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_timing.dart';

/// Service to fetch and cache word-level timing data for audio playback
class WordTimingService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  
  /// Reciters mapping from app format to Quran.com format
  static const Map<String, String> _reciterMapping = {
    'mishary_alafasy': 'ar.alafasy', // Default
    'abdul_basit_murattal': 'ar.abdulbasit.murattal',
    'abdul_basit_mujawwad': 'ar.abdulbasit.mujawwad',
    'mahmoud_hussary': 'ar.hussary',
    'saad_alghamdi': 'ar.ghamadi',
    'abdurrahman_sudais': 'ar.sudais',
    'mishari_rashid': 'ar.alafasy', // Fallback
  };

  /// Get word timings for a specific ayah
  Future<AyahTimings?> getWordTimings({
    required int surahNumber,
    required int ayahNumber,
    required String reciterId,
  }) async {
    try {
      // Check cache first
      final cacheKey = 'timings_${reciterId}_${surahNumber}_$ayahNumber';
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(cacheKey);
      
      if (cached != null) {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return AyahTimings.fromJson(json);
      }

      // Convert to Quran.com reciter format
      final quranComReciter = _reciterMapping[reciterId] ?? _reciterMapping['mishary_alafasy']!;

      // Fetch from Quran.com API
      final response = await _dio.get(
        '$_baseUrl/quran/verses/$surahNumber:$ayahNumber',
        queryParameters: {
          'recitation': quranComReciter,
        },
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );

      if (response.statusCode == 200) {
        final timings = _parseWordTimings(
          response.data,
          surahNumber,
          ayahNumber,
        );

        if (timings != null) {
          // Cache the result (1 month)
          await prefs.setString(cacheKey, jsonEncode(timings.toJson()));
          return timings;
        }
      }

      return null;
    } catch (e) {
      print('Error fetching word timings: $e');
      return null;
    }
  }

  /// Get word timings for multiple ayahs in a surah
  Future<Map<int, AyahTimings>> getAyahWordTimings({
    required int surahNumber,
    required List<int> ayahNumbers,
    required String reciterId,
  }) async {
    final timings = <int, AyahTimings>{};

    // Fetch in parallel but with some throttling to avoid overloading API
    for (final ayahNumber in ayahNumbers) {
      try {
        final timing = await getWordTimings(
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          reciterId: reciterId,
        );
        if (timing != null) {
          timings[ayahNumber] = timing;
        }
      } catch (e) {
        print('Error fetching timing for $surahNumber:$ayahNumber: $e');
      }
      // Small delay to avoid hammering the API
      await Future.delayed(const Duration(milliseconds: 50));
    }

    return timings;
  }

  /// Parse word timing data from Quran.com API response
  AyahTimings? _parseWordTimings(
    dynamic data,
    int surahNumber,
    int ayahNumber,
  ) {
    try {
      if (data is! Map || data['verse'] == null) return null;

      final verse = data['verse'] as Map<String, dynamic>;
      final words = verse['words'] as List<dynamic>? ?? [];

      if (words.isEmpty) return null;

      final List<WordTiming> wordTimings = [];
      int maxEndTime = 0;

      for (int i = 0; i < words.length; i++) {
        final word = words[i] as Map<String, dynamic>;
        
        // Extract timing information
        final timing = word['audio'] as Map<String, dynamic>?;
        if (timing == null) continue;

        final startTime = _parseTimeString(timing['start'] as String?);
        final endTime = _parseTimeString(timing['end'] as String?);

        if (startTime == null || endTime == null) continue;

        final arabicText = word['text_uthmani'] as String? ?? '';
        final transliteration = word['transliteration']?['text'] as String?;

        wordTimings.add(
          WordTiming(
            position: i,
            arabicText: arabicText,
            startMillis: startTime,
            endMillis: endTime,
            transliteration: transliteration,
          ),
        );

        if (endTime > maxEndTime) {
          maxEndTime = endTime;
        }
      }

      if (wordTimings.isEmpty) return null;

      return AyahTimings(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        words: wordTimings,
        totalDurationMillis: maxEndTime,
      );
    } catch (e) {
      print('Error parsing word timings: $e');
      return null;
    }
  }

  /// Parse time string format "HH:MM:SS.mmm" to milliseconds
  int? _parseTimeString(String? timeStr) {
    if (timeStr == null) return null;

    try {
      final parts = timeStr.split(':');
      if (parts.length != 3) return null;

      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final secondsAndMs = parts[2].split('.');
      final seconds = int.parse(secondsAndMs[0]);
      final ms = secondsAndMs.length > 1
          ? int.parse(secondsAndMs[1].padRight(3, '0').substring(0, 3))
          : 0;

      return hours * 3600000 + minutes * 60000 + seconds * 1000 + ms;
    } catch (e) {
      print('Error parsing time: $timeStr - $e');
      return null;
    }
  }

  /// Clear cache for a specific reciter
  Future<void> clearCache(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final prefix = 'timings_$reciterId';
    
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Clear all timing cache
  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('timings_')) {
        await prefs.remove(key);
      }
    }
  }
}
