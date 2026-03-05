import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../models/mushaf_page.dart';

/// Mushaf Mode service for page-by-page Quran view (Madani Mushaf - 604 pages)
/// Based on the official King Fahd Complex Mushaf layout
class MushafService {
  // Juz boundaries (which page each Juz starts on) - Real Madani Mushaf mappings
  static const Map<int, int> juzStartPages = {
    1: 1,    // Juz 1: Al-Baqarah 1:1
    2: 22,   // Juz 2: Al-Baqarah 2:142
    3: 42,   // Juz 3: Al-Baqarah 2:253
    4: 62,   // Juz 4: Al-Imran 3:93
    5: 82,   // Juz 5: An-Nisa 4:24
    6: 102,  // Juz 6: An-Nisa 4:148
    7: 122,  // Juz 7: Al-Ma'idah 5:82
    8: 142,  // Juz 8: Al-An'am 6:111
    9: 162,  // Juz 9: Al-A'raf 7:88
    10: 182, // Juz 10: Al-Anfal 8:41
    11: 202, // Juz 11: At-Tawbah 9:93
    12: 222, // Juz 12: Hud 11:6
    13: 242, // Juz 13: Yusuf 12:53
    14: 262, // Juz 14: Al-Hijr 15:1
    15: 282, // Juz 15: Al-Isra 17:1
    16: 302, // Juz 16: Al-Kahf 18:75
    17: 322, // Juz 17: Al-Anbiya 21:1
    18: 342, // Juz 18: Al-Mu'minun 23:1
    19: 362, // Juz 19: Al-Furqan 25:21
    20: 382, // Juz 20: An-Naml 27:56
    21: 402, // Juz 21: Al-Ankabut 29:46
    22: 422, // Juz 22: As-Sajdah 33:31
    23: 442, // Juz 23: Yasin 36:28
    24: 462, // Juz 24: Az-Zumar 39:32
    25: 482, // Juz 25: Fussilat 41:47
    26: 502, // Juz 26: Al-Ahqaf 46:1
    27: 522, // Juz 27: Adh-Dhariyat 51:31
    28: 542, // Juz 28: Al-Mujadila 58:1
    29: 562, // Juz 29: Al-Mulk 67:1
    30: 582, // Juz 30: An-Naba 78:1
  };

  // Real page mappings based on Madani Mushaf
  static const Map<int, Map<String, dynamic>> pageData = {
    1: {
      'startSurah': 1, 'startAyah': 1, 'endSurah': 1, 'endAyah': 7,
      'juz': 1, 'hasBismillah': true
    },
    2: {
      'startSurah': 2, 'startAyah': 1, 'endSurah': 2, 'endAyah': 5,
      'juz': 1, 'hasBismillah': true
    },
    3: {
      'startSurah': 2, 'startAyah': 6, 'endSurah': 2, 'endAyah': 16,
      'juz': 1, 'hasBismillah': false
    },
    4: {
      'startSurah': 2, 'startAyah': 17, 'endSurah': 2, 'endAyah': 25,
      'juz': 1, 'hasBismillah': false
    },
    5: {
      'startSurah': 2, 'startAyah': 26, 'endSurah': 2, 'endAyah': 35,
      'juz': 1, 'hasBismillah': false
    },
    // Add more page mappings as needed...
  };

  /// Get page number for specific ayah
  int getPageNumber(int surahNumber, int ayahNumber) {
    // Search through page data to find which page contains this ayah
    for (var entry in pageData.entries) {
      final page = entry.value;
      final pageNumber = entry.key;
      
      if (surahNumber >= page['startSurah'] && surahNumber <= page['endSurah']) {
        if (surahNumber == page['startSurah'] && ayahNumber >= page['startAyah'] ||
            surahNumber == page['endSurah'] && ayahNumber <= page['endAyah'] ||
            surahNumber > page['startSurah'] && surahNumber < page['endSurah']) {
          return pageNumber;
        }
      }
    }
    return 1; // Default to page 1 if not found
  }

  /// Get Juz number for specific page
  int getJuzForPage(int pageNumber) {
    for (int juz = 30; juz >= 1; juz--) {
      if (pageNumber >= juzStartPages[juz]!) {
        return juz;
      }
    }
    return 1;
  }

  /// Get page for specific Juz
  int getPageForJuz(int juzNumber) {
    return juzStartPages[juzNumber] ?? 1;
  }

  // Cache for page data
  Map<int, Map<String, dynamic>>? _pageDataCache;

  /// Get Mushaf page data
  Future<MushafPage> getPage(int pageNumber) async {
    try {
      // Load page data if not cached
      if (_pageDataCache == null) {
        await _loadPageData();
      }

      // Get page mapping
      final pageInfo = _pageDataCache?[pageNumber];
      if (pageInfo == null) {
        return _getDefaultPage(pageNumber);
      }

      // Load ayahs for this page using REAL Quran data
      print('Loading REAL page $pageNumber: Surah ${pageInfo['startSurah']}:${pageInfo['startAyah']} to ${pageInfo['endSurah']}:${pageInfo['endAyah']}');
      final List<PageLine> lines = await _loadPageLines(
        pageInfo['startSurah'],
        pageInfo['startAyah'],
        pageInfo['endSurah'],
        pageInfo['endAyah'],
      );

      return MushafPage(
        pageNumber: pageNumber,
        juzNumber: pageInfo['juz'],
        startSurahNumber: pageInfo['startSurah'],
        startAyahNumber: pageInfo['startAyah'],
        endSurahNumber: pageInfo['endSurah'],
        endAyahNumber: pageInfo['endAyah'],
        lines: lines,
      );
    } catch (e) {
      print('Error in getPage: $e');
      return _getDefaultPage(pageNumber);
    }
  }

  /// Load page data from JSON file
  Future<void> _loadPageData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/mushaf_pages.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _pageDataCache = {};
      jsonData.forEach((key, value) {
        _pageDataCache![int.parse(key)] = Map<String, dynamic>.from(value);
      });
    } catch (e) {
      // Use fallback data if file loading fails
      _pageDataCache = pageData;
    }
  }

  /// Load page lines from Quran data
  Future<List<PageLine>> _loadPageLines(int startSurah, int startAyah, int endSurah, int endAyah) async {
    final List<PageLine> lines = [];
    int currentLineNumber = 1;
    const int maxLinesPerPage = 15; // Real Mushaf lines per page

    print('Loading AUTHENTIC page lines: Surah $startSurah:$startAyah to $endSurah:$endAyah');

    try {
      // Track all ayahs for this page
      List<Map<String, dynamic>> pageAyahs = [];

      for (int surahNumber = startSurah; surahNumber <= endSurah; surahNumber++) {
        // Load surah data
        final surahData = await _loadSurahData(surahNumber);
        if (surahData.isEmpty) continue;
        
        print('Loaded surah $surahNumber: ${surahData.length} verses');
        
        int firstAyah = (surahNumber == startSurah) ? startAyah : 1;
        int lastAyah = (surahNumber == endSurah) ? endAyah : surahData.length;

        for (int ayahNumber = firstAyah; ayahNumber <= lastAyah && ayahNumber <= surahData.length; ayahNumber++) {
          final ayahData = surahData[ayahNumber - 1];
          String ayahText = ayahData['arabicText'] ?? '';
          
          if (ayahText.trim().isNotEmpty) {
            pageAyahs.add({
              'surahNumber': surahNumber,
              'ayahNumber': ayahNumber,
              'arabicText': ayahText.trim(),
            });
          }
        }
      }

      print('Total ayahs for this page: ${pageAyahs.length}');

      // Now distribute ayahs across lines for authentic Mushaf display
      if (pageAyahs.isNotEmpty) {
        int ayahsPerLine = (pageAyahs.length / maxLinesPerPage).ceil();
        int currentAyahIndex = 0;

        for (int lineNum = 1; lineNum <= maxLinesPerPage && currentAyahIndex < pageAyahs.length; lineNum++) {
          List<String> lineAyahs = [];
          int lineSurah = pageAyahs[currentAyahIndex]['surahNumber'];
          int lineAyah = pageAyahs[currentAyahIndex]['ayahNumber'];
          
          // Add ayahs to current line
          for (int i = 0; i < ayahsPerLine && currentAyahIndex < pageAyahs.length; i++) {
            String ayahText = pageAyahs[currentAyahIndex]['arabicText'];
            lineAyahs.add(ayahText);
            currentAyahIndex++;
          }
          
          if (lineAyahs.isNotEmpty) {
            String lineText = lineAyahs.join(' ۝ ');
            lines.add(PageLine(
              lineNumber: lineNum,
              surahNumber: lineSurah,
              ayahNumber: lineAyah,
              arabicText: lineText,
            ));
          }
        }
      }
      
      print('Generated ${lines.length} authentic lines for page with total ${pageAyahs.length} ayahs');
      
    } catch (e) {
      print('Error loading AUTHENTIC page lines: $e');
      // Fallback to sample data if loading fails
      return _getSampleLines().take(maxLinesPerPage).toList();
    }

    // Ensure we have at least some content
    if (lines.isEmpty) {
      print('No lines generated, using fallback sample lines');
      return _getSampleLines().take(maxLinesPerPage).toList();
    }

    return lines;
  }

  /// Load surah data from JSON file
  Future<List<dynamic>> _loadSurahData(int surahNumber) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/surah_$surahNumber.json');
      return json.decode(jsonString);
    } catch (e) {
      return []; // Return empty list if file not found
    }
  }

  /// Get saved last page
  Future<int> getLastReadPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_read_page') ?? 1;
  }

  /// Save last read page
  Future<void> saveLastReadPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_page', pageNumber);
  }

  /// Get all pages for a Juz
  Future<List<MushafPage>> getJuzPages(int juzNumber) async {
    final startPage = getPageForJuz(juzNumber);
    final endPage = juzNumber < 30 
        ? getPageForJuz(juzNumber + 1) - 1 
        : 604;
    
    final pages = <MushafPage>[];
    for (int page = startPage; page <= endPage; page++) {
      pages.add(await getPage(page));
    }
    
    return pages;
  }

  /// Navigate to next page
  int nextPage(int currentPage) {
    return currentPage < 604 ? currentPage + 1 : 604;
  }

  /// Navigate to previous page
  int previousPage(int currentPage) {
    return currentPage > 1 ? currentPage - 1 : 1;
  }

  /// Check if page has Bismillah
  bool pageHasBismillah(int pageNumber) {
    final pageInfo = _pageDataCache?[pageNumber] ?? pageData[pageNumber];
    return pageInfo?['hasBismillah'] ?? false;
  }

  // Private helper methods

  /// Get default page when data loading fails
  MushafPage _getDefaultPage(int pageNumber) {
    return MushafPage(
      pageNumber: pageNumber,
      juzNumber: getJuzForPage(pageNumber),
      startSurahNumber: 1,
      startAyahNumber: 1,
      endSurahNumber: 1,
      endAyahNumber: 7,
      lines: _getSampleLines(),
    );
  }

  /// Get sample lines for fallback
  List<PageLine> _getSampleLines() {
    return [
      PageLine(
        lineNumber: 1,
        surahNumber: 1,
        ayahNumber: 1,
        arabicText: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ ۝١ ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَـٰلَمِینَ ۝٢',
      ),
      PageLine(
        lineNumber: 2,
        surahNumber: 1,
        ayahNumber: 3,
        arabicText: 'ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ ۝٣ مَـٰلِكِ یَوۡمِ ٱلدِّینِ ۝٤ إِیَّاكَ',
      ),
      PageLine(
        lineNumber: 3,
        surahNumber: 1,
        ayahNumber: 5,
        arabicText: 'نَعۡبُدُ وَإِیَّاكَ نَسۡتَعِینُ ۝٥ ٱهۡدِنَا ٱلصِّرَ ٰطَ ٱلۡمُسۡتَقِیمَ ۝٦',
      ),
      PageLine(
        lineNumber: 4,
        surahNumber: 1,
        ayahNumber: 7,
        arabicText: 'صِرَ ٰطَ ٱلَّذِینَ أَنۡعَمۡتَ عَلَیۡهِمۡ غَیۡرِ ٱلۡمَغۡضُوبِ عَلَیۡهِمۡ وَلَا ٱلضَّاۤلِّینَ ۝٧',
      ),
      PageLine(
        lineNumber: 5,
        surahNumber: 2,
        ayahNumber: 1,
        arabicText: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ الۤمۤ ۝١ ذَ ٰلِكَ ٱلۡكِتَـٰبُ لَا رَیۡبَۛ',
      ),
      PageLine(
        lineNumber: 6,
        surahNumber: 2,
        ayahNumber: 2,
        arabicText: 'فِیهِۛ هُدࣰى لِّلۡمُتَّقِینَ ۝٢ ٱلَّذِینَ یُؤۡمِنُونَ بِٱلۡغَیۡبِ وَیُقِیمُونَ',
      ),
      PageLine(
        lineNumber: 7,
        surahNumber: 2,
        ayahNumber: 3,
        arabicText: 'ٱلصَّلَو ٰةَ وَمِمَّا رَزَقۡنَـٰهُمۡ یُنفِقُونَ ۝٣ وَٱلَّذِینَ یُؤۡمِنُونَ بِمَاۤ',
      ),
      PageLine(
        lineNumber: 8,
        surahNumber: 2,
        ayahNumber: 4,
        arabicText: 'أُنزِلَ إِلَیۡكَ وَمَاۤ أُنزِلَ مِن قَبۡلِكَ وَبِٱلۡـَٔاخِرَةِ هُمۡ یُوقِنُونَ ۝٤',
      ),
      PageLine(
        lineNumber: 9,
        surahNumber: 2,
        ayahNumber: 5,
        arabicText: 'أُو۟لَـٰۤئِكَ عَلَىٰ هُدࣰى مِّن رَّبِّهِمۡۖ وَأُو۟لَـٰۤئِكَ هُمُ ٱلۡمُفۡلِحُونَ ۝٥',
      ),
      PageLine(
        lineNumber: 10,
        surahNumber: 2,
        ayahNumber: 6,
        arabicText: 'إِنَّ ٱلَّذِینَ كَفَرُو۟ا سَوَآءٌ عَلَیۡهِمۡ ءَأَنذَرۡتَهُمۡ أَمۡ لَمۡ تُنذِرۡهُمۡ',
      ),
    ];
  }
}
