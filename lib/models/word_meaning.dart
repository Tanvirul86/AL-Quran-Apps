/// Word-by-word meaning model
class WordMeaning {
  final String arabicWord;
  final String transliteration;
  final String englishMeaning;
  final String banglaMeaning;
  final String rootWord;
  final int position; // Position in ayah

  WordMeaning({
    required this.arabicWord,
    required this.transliteration,
    required this.englishMeaning,
    required this.banglaMeaning,
    required this.rootWord,
    required this.position,
  });

  factory WordMeaning.fromJson(Map<String, dynamic> json) {
    return WordMeaning(
      arabicWord: json['arabicWord'] as String,
      transliteration: json['transliteration'] as String,
      englishMeaning: json['englishMeaning'] as String,
      banglaMeaning: json['banglaMeaning'] as String,
      rootWord: json['rootWord'] as String? ?? '',
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arabicWord': arabicWord,
      'transliteration': transliteration,
      'englishMeaning': englishMeaning,
      'banglaMeaning': banglaMeaning,
      'rootWord': rootWord,
      'position': position,
    };
  }
}
