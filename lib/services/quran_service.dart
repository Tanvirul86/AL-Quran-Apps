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
      final List<Ayah> ayahs = jsonList.map((json) => Ayah.fromJson(json)).toList();
      
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
          englishTranslation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          banglaTranslation: 'আল্লাহর নামে, যিনি পরম করুণাময়, অতি দয়ালু।',
        ),
        Ayah(
          surahNumber: 1,
          ayahNumber: 2,
          globalAyahNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          englishTranslation: '[All] praise is [due] to Allah, Lord of the worlds.',
          banglaTranslation: 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি বিশ্বজগতের প্রতিপালক।',
        ),
      ];
    }
    return [];
  }
}
