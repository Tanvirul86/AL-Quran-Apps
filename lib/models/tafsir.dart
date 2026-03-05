/// Tafsir (commentary) model
class Tafsir {
  final int surahNumber;
  final int ayahNumber;
  final String source; // e.g., "Ibn Kathir", "Tafseer-e-Usmani"
  final String text;
  final String language; // "en", "bn", "ar"
  final String? author;

  Tafsir({
    required this.surahNumber,
    required this.ayahNumber,
    required this.source,
    required this.text,
    required this.language,
    this.author,
  });

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    return Tafsir(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      source: json['source'] as String,
      text: json['text'] as String,
      language: json['language'] as String,
      author: json['author'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'source': source,
      'text': text,
      'language': language,
      'author': author,
    };
  }
}
