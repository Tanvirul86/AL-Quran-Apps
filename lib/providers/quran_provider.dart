import 'package:flutter/foundation.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../services/quran_service.dart';

/// Provider for Quran data state management
class QuranProvider with ChangeNotifier {
  final QuranService _quranService = QuranService();

  List<Surah> _surahs = [];
  final Map<int, List<Ayah>> _ayahsBySurah = {};
  bool _isLoading = false;
  String? _error;

  List<Surah> get surahs => _surahs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all surahs
  Future<void> loadSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _quranService.loadSurahs();
      _error = null;
    } catch (e) {
      _error = 'Failed to load surahs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load ayahs for a surah
  Future<List<Ayah>> loadAyahs(int surahNumber) async {
    if (_ayahsBySurah.containsKey(surahNumber)) {
      return _ayahsBySurah[surahNumber]!;
    }

    try {
      final ayahs = await _quranService.loadAyahs(surahNumber);
      _ayahsBySurah[surahNumber] = ayahs;
      return ayahs;
    } catch (e) {
      return [];
    }
  }

  /// Get surah by number
  Surah? getSurah(int surahNumber) {
    try {
      return _surahs.firstWhere((surah) => surah.number == surahNumber);
    } catch (e) {
      return null;
    }
  }

  /// Search ayahs
  Future<List<Ayah>> searchAyahs(String query) async {
    if (query.isEmpty) return [];
    return await _quranService.searchAyahs(query);
  }
}
