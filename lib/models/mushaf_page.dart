/// Mushaf page model for page-by-page Quran view
class MushafPage {
  final int pageNumber; // 1-604 for Madani Mushaf
  final int juzNumber;
  final int startSurahNumber;
  final int startAyahNumber;
  final int endSurahNumber;
  final int endAyahNumber;
  final List<PageLine> lines;

  MushafPage({
    required this.pageNumber,
    required this.juzNumber,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahNumber,
    required this.endAyahNumber,
    required this.lines,
  });

  factory MushafPage.fromJson(Map<String, dynamic> json) {
    return MushafPage(
      pageNumber: json['pageNumber'] as int,
      juzNumber: json['juzNumber'] as int,
      startSurahNumber: json['startSurahNumber'] as int,
      startAyahNumber: json['startAyahNumber'] as int,
      endSurahNumber: json['endSurahNumber'] as int,
      endAyahNumber: json['endAyahNumber'] as int,
      lines: (json['lines'] as List<dynamic>)
          .map((line) => PageLine.fromJson(line as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'juzNumber': juzNumber,
      'startSurahNumber': startSurahNumber,
      'startAyahNumber': startAyahNumber,
      'endSurahNumber': endSurahNumber,
      'endAyahNumber': endAyahNumber,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}

/// Represents a single line in Mushaf page (typically 15 lines)
class PageLine {
  final int lineNumber; // 1-15
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;

  PageLine({
    required this.lineNumber,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
  });

  factory PageLine.fromJson(Map<String, dynamic> json) {
    return PageLine(
      lineNumber: json['lineNumber'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      arabicText: json['arabicText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lineNumber': lineNumber,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'arabicText': arabicText,
    };
  }
}
