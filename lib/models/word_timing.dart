/// Model for word timing information
class WordTiming {
  final int position; // Word position in ayah (0-based)
  final String arabicText;
  final int startMillis; // Start time in milliseconds
  final int endMillis;   // End time in milliseconds
  final String? transliteration;
  final Map<String, String>? translations; // Language code -> translation

  WordTiming({
    required this.position,
    required this.arabicText,
    required this.startMillis,
    required this.endMillis,
    this.transliteration,
    this.translations,
  });

  Duration get startDuration => Duration(milliseconds: startMillis);
  Duration get endDuration => Duration(milliseconds: endMillis);
  int get durationMillis => endMillis - startMillis;

  factory WordTiming.fromJson(Map<String, dynamic> json) {
    return WordTiming(
      position: json['position'] as int,
      arabicText: json['arabicText'] as String,
      startMillis: json['startMillis'] as int,
      endMillis: json['endMillis'] as int,
      transliteration: json['transliteration'] as String?,
      translations: json['translations'] != null
          ? Map<String, String>.from(json['translations'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'arabicText': arabicText,
      'startMillis': startMillis,
      'endMillis': endMillis,
      'transliteration': transliteration,
      'translations': translations,
    };
  }

  /// Check if a given duration falls within this word's timing
  bool contains(Duration duration) {
    final ms = duration.inMilliseconds;
    return ms >= startMillis && ms < endMillis;
  }
}

/// Collection of word timings for an entire ayah
class AyahTimings {
  final int surahNumber;
  final int ayahNumber;
  final List<WordTiming> words;
  final int totalDurationMillis; // Total duration of the ayah

  AyahTimings({
    required this.surahNumber,
    required this.ayahNumber,
    required this.words,
    required this.totalDurationMillis,
  });

  /// Get the current word index based on playback position
  int getCurrentWordIndex(Duration position) {
    for (int i = 0; i < words.length; i++) {
      if (words[i].contains(position)) {
        return i;
      }
    }
    return -1; // No word is currently playing
  }

  /// Get word at specific index
  WordTiming? getWord(int index) {
    if (index >= 0 && index < words.length) {
      return words[index];
    }
    return null;
  }

  factory AyahTimings.fromJson(Map<String, dynamic> json) {
    final List<dynamic> wordsList = json['words'] as List<dynamic>? ?? [];
    return AyahTimings(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      words: wordsList
          .map((w) => WordTiming.fromJson(w as Map<String, dynamic>))
          .toList(),
      totalDurationMillis: json['totalDurationMillis'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'words': words.map((w) => w.toJson()).toList(),
      'totalDurationMillis': totalDurationMillis,
    };
  }
}
