import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

/// Service for loading and managing Quran data
class QuranService {
  static final QuranService _instance = QuranService._internal();
  factory QuranService() => _instance;
  QuranService._internal();

  List<Surah>? _surahs;
  Map<int, List<Ayah>>? _ayahsBySurah;

  /// Load all Surahs from assets
  Future<List<Surah>> loadSurahs() async {
    if (_surahs != null) return _surahs!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/surahs.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _surahs = jsonList.map((json) => Surah.fromJson(json)).toList();
      return _surahs!;
    } catch (e) {
      // Fallback: Return sample data structure
      return _getDefaultSurahs();
    }
  }

  /// Load ayahs for a specific surah
  Future<List<Ayah>> loadAyahs(int surahNumber) async {
    if (_ayahsBySurah != null && _ayahsBySurah!.containsKey(surahNumber)) {
      return _ayahsBySurah![surahNumber]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/surah_$surahNumber.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // Map to Ayah objects
      List<Ayah> ayahs = jsonList.map((json) => Ayah.fromJson(json)).toList();
      
      // Sanitize the first ayah of every surah (except Al-Fatiha and At-Tawbah)
      // to remove prepended Bismillah that causes duplication in UI headers.
      if (surahNumber != 1 && surahNumber != 9 && ayahs.isNotEmpty) {
        final firstAyah = ayahs[0];
        ayahs[0] = _sanitizeAyahWithBismillah(firstAyah);
      }
      
      _ayahsBySurah ??= {};
      _ayahsBySurah![surahNumber] = ayahs;
      return ayahs;
    } catch (e) {
      // Fallback: Return sample data
      return _getDefaultAyahs(surahNumber);
    }
  }

  /// Search ayahs by keyword in translations
  Future<List<Ayah>> searchAyahs(String query) async {
    final List<Ayah> results = [];
    final List<Surah> surahs = await loadSurahs();
    
    final String lowerQuery = query.toLowerCase();
    
    for (final surah in surahs) {
      final List<Ayah> ayahs = await loadAyahs(surah.number);
      
      for (final ayah in ayahs) {
        if (ayah.englishTranslation.toLowerCase().contains(lowerQuery) ||
            ayah.banglaTranslation.toLowerCase().contains(lowerQuery) ||
            ayah.arabicText.contains(query)) {
          results.add(ayah);
        }
      }
    }
    
    return results;
  }

  /// Get ayah by surah and ayah number
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final List<Ayah> ayahs = await loadAyahs(surahNumber);
    try {
      return ayahs.firstWhere((ayah) => ayah.ayahNumber == ayahNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get surah by number
  Future<Surah?> getSurah(int surahNumber) async {
    final List<Surah> surahs = await loadSurahs();
    try {
      return surahs.firstWhere((surah) => surah.number == surahNumber);
    } catch (e) {
      return null;
    }
  }

  // Default/fallback data (sample structure)
  List<Surah> _getDefaultSurahs() {
    return [
      Surah(
        number: 1,
        arabicName: 'الفاتحة',
        englishName: 'Al-Fatiha',
        banglaName: 'আল-ফাতিহা',
        revelationType: 'Meccan',
        totalAyahs: 7,
        startAyahNumber: 1,
      ),
      Surah(
        number: 2,
        arabicName: 'البقرة',
        englishName: 'Al-Baqarah',
        banglaName: 'আল-বাকারা',
        revelationType: 'Medinan',
        totalAyahs: 286,
        startAyahNumber: 8,
      ),
    ];
  }

  List<Ayah> _getDefaultAyahs(int surahNumber) {
    if (surahNumber == 1) {
      return [
        Ayah(
          surahNumber: 1,
          ayahNumber: 1,
          globalAyahNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          uthmaniText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
          tajweedText: '<tajweed class=ghunna>بِ</tajweed>সْمِ <tajweed class=ham_wasl>ٱ</tajweed>للَّهِ <tajweed class=ham_wasl>ٱ</tajweed>لرَّحْمَـٰنِ <tajweed class=ham_wasl>ٱ</tajweed>لرَّحِيمِ',
          indopakText: 'بِسْمِ اللہِ الرَّحْمٰنِ الرَّحِیْمِ',
          englishTranslation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          banglaTranslation: 'আল্লাহর নামে, যিনি পরম করুণাময়, অতি দয়ালু।',
        ),
        Ayah(
          surahNumber: 1,
          ayahNumber: 2,
          globalAyahNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          uthmaniText: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ',
          tajweedText: '<tajweed class=ham_wasl>ٱ</tajweed>لْحَمْدُ لِلَّهِ رَبِّ <tajweed class=ham_wasl>ٱ</tajweed>لْعَـٰلَمِينَ',
          indopakText: 'اَلْحَمْدُ لِلہِ رَبِّ الْعٰلَمِیْنَ',
          englishTranslation: '[All] praise is [due] to Allah, Lord of the worlds.',
          banglaTranslation: 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি বিশ্বজগতের প্রতিপালক।',
        ),
      ];
    }
    return [];
  }

  /// Sanitize first ayah by removing prepended Bismillah
  Ayah _sanitizeAyahWithBismillah(Ayah ayah) {
    if (ayah.ayahNumber != 1) return ayah;

    return Ayah(
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.ayahNumber,
      globalAyahNumber: ayah.globalAyahNumber,
      arabicText: _stripLeadingBismillah(ayah.arabicText),
      uthmaniText: _stripLeadingBismillahNullable(ayah.uthmaniText),
      indopakText: _stripLeadingBismillahNullable(ayah.indopakText),
      tajweedText: _stripLeadingBismillahNullable(ayah.tajweedText),
      englishTranslation: ayah.englishTranslation,
      banglaTranslation: ayah.banglaTranslation,
      transliteration: ayah.transliteration,
      translations: ayah.translations,
    );
  }

  String? _stripLeadingBismillahNullable(String? text) {
    if (text == null) return null;
    final stripped = _stripLeadingBismillah(text.trim());
    return stripped.isEmpty ? null : stripped;
  }

  String _stripLeadingBismillah(String text) {
    var clean = text.trim();

    // 1. Precise check: Does it start with Bismillah (normalized)?
    final normalized = _normalizeArabicForMatch(clean);
    
    // Check for "Bism" (بسم) and "Allah" (الله) and "Rahman" (الرحمن) and "Rahim" (الرحیم/الرحيم)
    final hasBism = normalized.startsWith('بسم');
    final hasAllah = normalized.contains('الله');
    final hasRahman = normalized.contains('الرحمن');
    final hasRahim = normalized.contains('الرحیم') || normalized.contains('الرحيم');

    if (hasBism && hasAllah && (hasRahman || hasRahim)) {
      // Find the end of "Rahim" in the actual text to know where to cut.
      // We look for رح[يی]م variants.
      final rahimMatch = RegExp(r'رح[يی]م').firstMatch(clean);
      if (rahimMatch != null && rahimMatch.start <= 100) {
        final cut = rahimMatch.end;
        final tail = clean.substring(cut).trim();
        if (tail.isNotEmpty) {
          return tail;
        }
      }
    }

    // 2. Fallback: Check for specific suffix strings of Bismillah
    final endings = <String>[
      'ٱلرَّحِيمِ',
      'ٱلرَّحِیمِ',
      'الرَّحِيمِ',
      'الرَّحِیمِ',
      'الرَّحِيْمِ',
      'الرَّحِیْمِ',
      'الرحيم',
      'الرحیم',
    ];

    for (final endWord in endings) {
      if (clean.contains(endWord)) {
        final idx = clean.indexOf(endWord);
        if (idx != -1 && idx < 60) {
          final cut = idx + endWord.length;
          final tail = clean.substring(cut).trim();
          if (tail.isNotEmpty) {
            return tail;
          }
        }
      }
    }

    return clean;
  }

  String _normalizeArabicForMatch(String input) {
    // Remove common tajweed/html markers for matching only.
    var out = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'\{[^\}]*\}'), '');

    // Remove Arabic diacritics and symbols.
    // 064B-065F: Harakat, 0670: Superscript Alef, 06D6-06ED: Quranic marks, 0640: Tatweel
    out = out
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
        .replaceAll(RegExp(r'\s+'), '');

    return out;
  }
}
