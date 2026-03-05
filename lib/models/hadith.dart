class Hadith {
  final int number;
  final String titleArabic;
  final String titleEnglish;
  final String titleBangla;
  final String textArabic;
  final String textEnglish;
  final String textBangla;
  final String narrator;
  final String reference;

  Hadith({
    required this.number,
    required this.titleArabic,
    required this.titleEnglish,
    required this.titleBangla,
    required this.textArabic,
    required this.textEnglish,
    required this.textBangla,
    required this.narrator,
    this.reference = '',
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      number: json['number'] ?? 0,
      titleArabic: json['title_arabic'] ?? '',
      titleEnglish: json['title_english'] ?? '',
      titleBangla: json['title_bangla'] ?? '',
      textArabic: json['text_arabic'] ?? '',
      textEnglish: json['text_english'] ?? '',
      textBangla: json['text_bangla'] ?? '',
      narrator: json['narrator'] ?? '',
      reference: json['reference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title_arabic': titleArabic,
      'title_english': titleEnglish,
      'title_bangla': titleBangla,
      'text_arabic': textArabic,
      'text_english': textEnglish,
      'text_bangla': textBangla,
      'narrator': narrator,
      'reference': reference,
    };
  }
}
