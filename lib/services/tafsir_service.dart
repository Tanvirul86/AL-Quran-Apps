import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tafsir.dart';
import '../models/tafsir_source.dart';
import 'download_manager_service.dart';
import 'dart:io';

/// Enhanced Tafsir service with downloadable tafsirs
class TafsirService {
  final Dio _dio = Dio();
  final DownloadManagerService _downloadManager = DownloadManagerService();
  
  // API endpoints (replace with actual API)
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  static const String _tafsirSourcesEndpoint = '/resources/tafsirs';

  /// Get available tafsir sources
  Future<List<TafsirSource>> getAvailableTafsirs() async {
    try {
      // First check cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('tafsir_sources');
      
      if (cached != null) {
        final List<dynamic> data = json.decode(cached);
        return data.map((json) => TafsirSource.fromJson(json)).toList();
      }

      // Fetch from API
      final response = await _dio.get('$_baseUrl$_tafsirSourcesEndpoint');
      
      if (response.statusCode == 200) {
        // Parse and cache
        final sources = _parseTafsirSources(response.data);
        await prefs.setString('tafsir_sources', json.encode(
          sources.map((s) => s.toJson()).toList(),
        ));
        return sources;
      }
      
      // Fallback to default sources
      return _getDefaultTafsirSources();
    } catch (e) {
      return _getDefaultTafsirSources();
    }
  }

  /// Get tafsir for specific ayah
  Future<List<Tafsir>> getTafsirForAyah({
    required int surahNumber,
    required int ayahNumber,
    String? tafsirSourceId,
    String? language,
  }) async {
    try {
      // Check if tafsir is downloaded locally
      if (tafsirSourceId != null) {
        final localTafsir = await _getLocalTafsir(
          surahNumber,
          ayahNumber,
          tafsirSourceId,
        );
        if (localTafsir != null) {
          return [localTafsir];
        }
      }

      // Fetch from API
      final tafsirs = await _fetchTafsirFromAPI(
        surahNumber,
        ayahNumber,
        tafsirSourceId,
        language,
      );
      
      return tafsirs;
    } catch (e) {
      // Return sample data for testing
      return _getSampleTafsir(surahNumber, ayahNumber, language);
    }
  }

  /// Download complete tafsir source
  Future<bool> downloadTafsirSource(TafsirSource source) async {
    try {
      final path = await _downloadManager.downloadFile(
        url: source.downloadUrl,
        taskId: 'tafsir_${source.id}',
        fileName: '${source.id}.json',
        category: 'tafsir',
        metadata: source.toJson(),
      );

      return path != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if tafsir source is downloaded
  Future<bool> isTafsirDownloaded(String tafsirId) async {
    return await _downloadManager.isDownloaded('tafsir_$tafsirId');
  }

  /// Delete downloaded tafsir
  Future<bool> deleteTafsir(String tafsirId) async {
    return await _downloadManager.deleteDownload('tafsir_$tafsirId');
  }

  /// Get downloaded tafsir sources
  Future<List<TafsirSource>> getDownloadedTafsirs() async {
    final allSources = await getAvailableTafsirs();
    final downloaded = <TafsirSource>[];
    
    for (final source in allSources) {
      if (await isTafsirDownloaded(source.id)) {
        downloaded.add(source.copyWith(isDownloaded: true));
      }
    }
    
    return downloaded;
  }

  // Private helper methods

  Future<Tafsir?> _getLocalTafsir(
    int surahNumber,
    int ayahNumber,
    String tafsirId,
  ) async {
    try {
      final path = await _downloadManager.getDownloadedPath('tafsir_$tafsirId');
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final content = await file.readAsString();
          final data = json.decode(content);
          
          // Find specific ayah tafsir in the file
          final ayahKey = '${surahNumber}_$ayahNumber';
          if (data[ayahKey] != null) {
            return Tafsir.fromJson(data[ayahKey]);
          }
        }
      }
    } catch (e) {
      // Error reading local file
    }
    return null;
  }

  Future<List<Tafsir>> _fetchTafsirFromAPI(
    int surahNumber,
    int ayahNumber,
    String? tafsirId,
    String? language,
  ) async {
    try {
      // Use correct Quran.com API endpoint format
      final tafsirIdToUse = tafsirId ?? '169'; // Default to Ibn Kathir English
      final verseKey = '$surahNumber:$ayahNumber';
      // Correct endpoint: /tafsirs/{id}/by_ayah/{verse_key}
      final endpoint = '$_baseUrl/tafsirs/$tafsirIdToUse/by_ayah/$verseKey';
      
      print('Fetching tafsir from: $endpoint');
      
      final response = await _dio.get(endpoint);
      
      if (response.statusCode == 200 && response.data['tafsir'] != null) {
        final tafsirData = response.data['tafsir'];
        final text = tafsirData['text'] ?? '';
        final resourceName = tafsirData['resource_name'] ?? tafsirData['translated_name']?['name'] ?? 'Tafsir';
        
        return [
          Tafsir(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            source: resourceName,
            text: _stripHtml(text),
            language: language ?? 'en',
            author: tafsirData['author_name'] ?? resourceName,
          ),
        ];
      }
    } catch (e) {
      print('Tafsir API error: $e');
    }
    return [];
  }
  
  /// Remove HTML tags from tafsir text
  String _stripHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  List<TafsirSource> _parseTafsirSources(dynamic data) {
    // Parse API response to TafsirSource list
    final List<TafsirSource> sources = [];
    
    if (data is Map && data['tafsirs'] != null) {
      for (final item in data['tafsirs']) {
        // Map API response to TafsirSource model
        sources.add(TafsirSource(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          language: item['language_name']?.toLowerCase() ?? 'en',
          author: item['author_name'] ?? '',
          description: '',
          downloadUrl: 'https://cdn.quran.com/tafsirs/${item['id']}.json',
          fileSize: 5 * 1024 * 1024, // Estimate 5MB
        ));
      }
    }
    
    return sources;
  }

  List<TafsirSource> _getDefaultTafsirSources() {
    // Comprehensive list of world-prominent tafsirs from Quran.com API
    return [
      // ═══════════════════════════════════════════════════════════════
      // ENGLISH TAFSIRS
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '169',
        name: 'Tafsir Ibn Kathir (Abridged)',
        language: 'en',
        author: 'Hafiz Ibn Kathir',
        description: 'Classical tafsir by the renowned 14th century scholar',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/169',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '168',
        name: "Ma'ariful Qur'an",
        language: 'en',
        author: 'Mufti Muhammad Shafi',
        description: 'Comprehensive 8-volume modern tafsir by former Grand Mufti of Pakistan',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/168',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '817',
        name: 'Tazkirul Quran',
        language: 'en',
        author: 'Maulana Wahiduddin Khan',
        description: 'Modern tafsir focusing on peaceful interpretation',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/817',
        fileSize: 0,
        isDownloaded: true,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // ARABIC TAFSIRS (Classical Scholarly Works)
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '14',
        name: 'تفسير ابن كثير',
        language: 'ar',
        author: 'Hafiz Ibn Kathir',
        description: 'Tafsir Ibn Kathir - One of the most authoritative tafsirs',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/14',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '15',
        name: 'تفسير الطبري',
        language: 'ar',
        author: 'Imam al-Tabari',
        description: 'Jami al-Bayan - The earliest and most comprehensive classical tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/15',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '90',
        name: 'تفسير القرطبي',
        language: 'ar',
        author: 'Imam al-Qurtubi',
        description: 'Al-Jami li-Ahkam al-Quran - Focuses on legal rulings',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/90',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '91',
        name: 'تفسير السعدي',
        language: 'ar',
        author: 'Sheikh Abdur-Rahman al-Sa\'di',
        description: 'Taysir al-Karim ar-Rahman - Modern accessible tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/91',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '93',
        name: 'التفسير الوسيط',
        language: 'ar',
        author: 'Muhammad Sayyid Tantawi',
        description: 'Al-Tafsir al-Wasit - By former Grand Imam of Al-Azhar',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/93',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '94',
        name: 'تفسير البغوي',
        language: 'ar',
        author: 'Imam al-Baghawi',
        description: 'Ma\'alim al-Tanzil - Classical Shafi\'i tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/94',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '16',
        name: 'التفسير الميسر',
        language: 'ar',
        author: 'King Fahd Complex',
        description: 'Tafsir Muyassar - Simplified tafsir for easy understanding',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/16',
        fileSize: 0,
        isDownloaded: true,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // URDU TAFSIRS
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '160',
        name: 'تفسیر ابنِ کثیر',
        language: 'ur',
        author: 'Hafiz Ibn Kathir',
        description: 'Urdu translation of the famous Ibn Kathir tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/160',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '159',
        name: 'بیان القرآن',
        language: 'ur',
        author: 'Dr. Israr Ahmad',
        description: 'Bayan ul Quran - Popular modern Urdu tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/159',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '157',
        name: 'فی ظلال القرآن',
        language: 'ur',
        author: 'Sayyid Qutb',
        description: 'Fi Zilal al-Quran - Influential modern tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/157',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '818',
        name: 'تذکیر القرآن',
        language: 'ur',
        author: 'Maulana Wahiduddin Khan',
        description: 'Tazkir ul Quran - Modern peaceful interpretation',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/818',
        fileSize: 0,
        isDownloaded: true,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // BENGALI/BANGLA TAFSIRS
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '164',
        name: 'তাফসীর ইবনে কাসীর',
        language: 'bn',
        author: 'Tawheed Publication',
        description: 'Bengali translation of Tafsir Ibn Kathir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/164',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '165',
        name: 'তাফসীর আহসানুল বায়ান',
        language: 'bn',
        author: 'Bayaan Foundation',
        description: 'Tafsir Ahsanul Bayaan - Popular Bengali tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/165',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '166',
        name: 'তাফসীর আবু বকর জাকারিয়া',
        language: 'bn',
        author: 'Dr. Abu Bakr Zakaria',
        description: 'Comprehensive Bengali tafsir',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/166',
        fileSize: 0,
        isDownloaded: true,
      ),
      TafsirSource(
        id: '381',
        name: 'তাফসীর ফাতহুল মাজিদ',
        language: 'bn',
        author: 'AbdulRahman Bin Hasan Al-Alshaikh',
        description: 'Tafsir Fathul Majid in Bengali',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/381',
        fileSize: 0,
        isDownloaded: true,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // RUSSIAN TAFSIRS
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '170',
        name: 'Тафсир Ас-Саади',
        language: 'ru',
        author: 'Sheikh Abdur-Rahman al-Sa\'di',
        description: 'Russian translation of Tafsir al-Sa\'di',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/170',
        fileSize: 0,
        isDownloaded: true,
      ),
      
      // ═══════════════════════════════════════════════════════════════
      // KURDISH TAFSIRS
      // ═══════════════════════════════════════════════════════════════
      TafsirSource(
        id: '804',
        name: 'تەفسیری ڕێبار',
        language: 'ku',
        author: 'Rebar Kurdish Tafsir',
        description: 'Kurdish Quran commentary',
        downloadUrl: 'https://api.quran.com/api/v4/tafsirs/804',
        fileSize: 0,
        isDownloaded: true,
      ),
    ];
  }
  
  /// Get tafsirs grouped by language for easy selection
  Map<String, List<TafsirSource>> getTafsirsByLanguage() {
    final sources = _getDefaultTafsirSources();
    final Map<String, List<TafsirSource>> grouped = {};
    
    for (final source in sources) {
      final lang = source.language;
      if (!grouped.containsKey(lang)) {
        grouped[lang] = [];
      }
      grouped[lang]!.add(source);
    }
    
    return grouped;
  }
  
  /// Get language display name
  String getLanguageDisplayName(String code) {
    const languageNames = {
      'en': 'English',
      'ar': 'العربية (Arabic)',
      'ur': 'اردو (Urdu)',
      'bn': 'বাংলা (Bengali)',
      'ru': 'Русский (Russian)',
      'ku': 'کوردی (Kurdish)',
    };
    return languageNames[code] ?? code.toUpperCase();
  }

  List<Tafsir> _getSampleTafsir(int surahNumber, int ayahNumber, String? language) {
    return [
      Tafsir(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        source: 'Sample Tafsir',
        text: 'This is a sample tafsir. Please download tafsir sources for full content.',
        language: language ?? 'en',
        author: 'Sample Author',
      ),
    ];
  }
}
