import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_source.dart';
import 'download_manager_service.dart';
import 'dart:io';

/// Enhanced Translation service with downloadable translations
class TranslationService {
  final Dio _dio = Dio();
  final DownloadManagerService _downloadManager = DownloadManagerService();
  
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  /// Get all available languages
  List<String> getAvailableLanguages() {
    return [
      'en', 'ar', 'ur', 'bn', 'hi', 'id', 'tr', 'fr', 'de', 'es',
      'ru', 'fa', 'ms', 'zh', 'ja', 'ko', 'ta', 'th', 'sw', 'pt',
      'nl', 'it', 'sq', 'bs', 'uz', 'az', 'kk', 'so', 'ha',
    ];
  }

  /// Get language display name
  String getLanguageDisplayName(String code) {
    final names = {
      'en': 'English',
      'ar': 'العربية (Arabic)',
      'ur': 'اردو (Urdu)',
      'bn': 'বাংলা (Bengali)',
      'hi': 'हिन्दी (Hindi)',
      'id': 'Bahasa Indonesia',
      'tr': 'Türkçe (Turkish)',
      'fr': 'Français (French)',
      'de': 'Deutsch (German)',
      'es': 'Español (Spanish)',
      'ru': 'Русский (Russian)',
      'fa': 'فارسی (Persian)',
      'ms': 'Bahasa Melayu (Malay)',
      'zh': '中文 (Chinese)',
      'ja': '日本語 (Japanese)',
      'ko': '한국어 (Korean)',
      'ta': 'தமிழ் (Tamil)',
      'th': 'ไทย (Thai)',
      'sw': 'Kiswahili (Swahili)',
      'pt': 'Português (Portuguese)',
      'nl': 'Nederlands (Dutch)',
      'it': 'Italiano (Italian)',
      'sq': 'Shqip (Albanian)',
      'bs': 'Bosanski (Bosnian)',
      'uz': 'Oʻzbek (Uzbek)',
      'az': 'Azərbaycan (Azerbaijani)',
      'kk': 'Қазақ (Kazakh)',
      'so': 'Soomaali (Somali)',
      'ha': 'Hausa',
    };
    return names[code] ?? code.toUpperCase();
  }

  /// Get available translation sources
  Future<List<TranslationSource>> getAvailableTranslations() async {
    // Always return default sources to ensure they're available
    // API sources can be merged later if needed
    return _getDefaultTranslationSources();
  }

  /// Get translations by language
  Future<List<TranslationSource>> getTranslationsByLanguage(String language) async {
    final all = await getAvailableTranslations();
    return all.where((t) => t.language == language).toList();
  }

  /// Download translation source
  Future<bool> downloadTranslation(TranslationSource source) async {
    try {
      final path = await _downloadManager.downloadFile(
        url: source.downloadUrl,
        taskId: 'translation_${source.id}',
        fileName: '${source.id}.json',
        category: 'translation',
        metadata: source.toJson(),
      );

      return path != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if translation is downloaded
  Future<bool> isTranslationDownloaded(String translationId) async {
    return await _downloadManager.isDownloaded('translation_$translationId');
  }

  /// Delete downloaded translation
  Future<bool> deleteTranslation(String translationId) async {
    return await _downloadManager.deleteDownload('translation_$translationId');
  }

  /// Get translation text for ayah
  Future<String?> getTranslationText({
    required int surahNumber,
    required int ayahNumber,
    required String translationId,
  }) async {
    try {
      // Check local download first
      final path = await _downloadManager.getDownloadedPath('translation_$translationId');
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final content = await file.readAsString();
          final data = json.decode(content);
          final ayahKey = '${surahNumber}_$ayahNumber';
          return data[ayahKey] as String?;
        }
      }

      // Fetch from API
      final response = await _dio.get(
        '$_baseUrl/quran/translations/$translationId',
        queryParameters: {
          'verse_key': '$surahNumber:$ayahNumber',
        },
      );

      if (response.statusCode == 200) {
        return response.data['translations']?[0]?['text'] as String?;
      }
    } catch (e) {
      // Error
    }
    return null;
  }

  /// Get downloaded translations
  Future<List<TranslationSource>> getDownloadedTranslations() async {
    final allSources = await getAvailableTranslations();
    final downloaded = <TranslationSource>[];
    
    for (final source in allSources) {
      if (await isTranslationDownloaded(source.id)) {
        downloaded.add(source.copyWith(isDownloaded: true));
      }
    }
    
    return downloaded;
  }

  List<TranslationSource> _parseTranslationSources(dynamic data) {
    final List<TranslationSource> sources = [];
    
    if (data is Map && data['translations'] != null) {
      for (final item in data['translations']) {
        sources.add(TranslationSource(
          id: item['id'].toString(),
          name: item['name'] ?? '',
          language: item['language_name']?.toLowerCase() ?? 'en',
          translator: item['author_name'] ?? '',
          downloadUrl: 'https://cdn.quran.com/translations/${item['id']}.json',
          fileSize: 2 * 1024 * 1024, // Estimate 2MB
        ));
      }
    }
    
    return sources;
  }

  List<TranslationSource> _getDefaultTranslationSources() {
    return [
      // ============================================
      // ENGLISH TRANSLATIONS (Most Popular)
      // ============================================
      TranslationSource(
        id: '131',
        name: 'Sahih International',
        language: 'en',
        translator: 'Saheeh International',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/131',
        fileSize: 2 * 1024 * 1024,
      ),
      TranslationSource(
        id: '203',
        name: 'Abdullah Yusuf Ali',
        language: 'en',
        translator: 'Abdullah Yusuf Ali',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/203',
        fileSize: 2 * 1024 * 1024,
      ),
      TranslationSource(
        id: '19',
        name: 'Pickthall',
        language: 'en',
        translator: 'Mohammed Marmaduke Pickthall',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/19',
        fileSize: (1.8 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '20',
        name: 'Dr. Mustafa Khattab (The Clear Quran)',
        language: 'en',
        translator: 'Dr. Mustafa Khattab',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/20',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '85',
        name: 'Hilali & Khan',
        language: 'en',
        translator: 'Muhammad Taqi-ud-Din al-Hilali & Muhammad Muhsin Khan',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/85',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '84',
        name: 'Mufti Taqi Usmani',
        language: 'en',
        translator: 'Mufti Taqi Usmani',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/84',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '22',
        name: 'Dr. Ghali',
        language: 'en',
        translator: 'Dr. Muhammad Mahmoud Ghali',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/22',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '57',
        name: 'Transliteration',
        language: 'en',
        translator: 'Transliteration',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/57',
        fileSize: (1.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // ARABIC TAFSIRS (Simplified Arabic)
      // ============================================
      TranslationSource(
        id: '90',
        name: 'التفسير الميسر',
        language: 'ar',
        translator: 'King Fahd Complex - Al-Muyassar',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/90',
        fileSize: 3 * 1024 * 1024,
      ),
      
      // ============================================
      // URDU TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '97',
        name: 'محمد جوناگڑھی',
        language: 'ur',
        translator: 'Muhammad Junagarhi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/97',
        fileSize: 3 * 1024 * 1024,
      ),
      TranslationSource(
        id: '234',
        name: 'مولانا مودودی - تفہیم القرآن',
        language: 'ur',
        translator: 'Abul Ala Maududi - Tafheem ul Quran',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/234',
        fileSize: (3.5 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '158',
        name: 'احمد علی',
        language: 'ur',
        translator: 'Ahmed Ali',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/158',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '156',
        name: 'فتح محمد جالندھری',
        language: 'ur',
        translator: 'Fateh Muhammad Jalandhry',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/156',
        fileSize: (2.9 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // BANGLA/BENGALI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '161',
        name: 'মুহিউদ্দীন খান',
        language: 'bn',
        translator: 'Muhiuddin Khan',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/161',
        fileSize: 3 * 1024 * 1024,
      ),
      TranslationSource(
        id: '213',
        name: 'আবু বকর জাকারিয়া',
        language: 'bn',
        translator: 'Dr. Abu Bakr Zakaria',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/213',
        fileSize: (3.2 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '163',
        name: 'তাইসীরুল কুরআন',
        language: 'bn',
        translator: 'Taisirul Quran',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/163',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '120',
        name: 'রওয়াই আল-বয়ান',
        language: 'bn',
        translator: 'Rawai Al-Bayan',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/120',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // HINDI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '122',
        name: 'मुहम्मद फ़ारूक़ ख़ान',
        language: 'hi',
        translator: 'Muhammad Farooq Khan & Nadeem Ahmed',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/122',
        fileSize: 3 * 1024 * 1024,
      ),
      TranslationSource(
        id: '151',
        name: 'सूरह हिंदी',
        language: 'hi',
        translator: 'Suhel Farooq Khan & Saifur Rahman Nadwi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/151',
        fileSize: (2.9 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // INDONESIAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '33',
        name: 'Bahasa Indonesia',
        language: 'id',
        translator: 'Indonesian Ministry of Religious Affairs',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/33',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '134',
        name: 'Tafsir Jalalayn Indonesia',
        language: 'id',
        translator: 'Tafsir Jalalayn - Indonesian',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/134',
        fileSize: 3 * 1024 * 1024,
      ),
      
      // ============================================
      // TURKISH TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '77',
        name: 'Diyanet İşleri',
        language: 'tr',
        translator: 'Diyanet Isleri (Turkish Religious Affairs)',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/77',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '52',
        name: 'Süleymaniye Vakfı',
        language: 'tr',
        translator: 'Süleymaniye Vakfı',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/52',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '124',
        name: 'Elmalılı Hamdi Yazır',
        language: 'tr',
        translator: 'Elmalılı Hamdi Yazır',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/124',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // FRENCH TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '31',
        name: 'Muhammad Hamidullah',
        language: 'fr',
        translator: 'Muhammad Hamidullah',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/31',
        fileSize: (2.4 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '136',
        name: 'Rashid Maash',
        language: 'fr',
        translator: 'Rashid Maash',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/136',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // GERMAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '27',
        name: 'Abu Rida Muhammad',
        language: 'de',
        translator: 'Abu Rida Muhammad ibn Ahmad ibn Rassoul',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/27',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '208',
        name: 'Frank Bubenheim',
        language: 'de',
        translator: 'Frank Bubenheim & Nadeem Elyas',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/208',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // SPANISH TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '83',
        name: 'Julio Cortés',
        language: 'es',
        translator: 'Julio Cortés',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/83',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '140',
        name: 'Muhammad Isa García',
        language: 'es',
        translator: 'Muhammad Isa García',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/140',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // RUSSIAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '45',
        name: 'Эльмир Кулиев',
        language: 'ru',
        translator: 'Elmir Kuliev',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/45',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      TranslationSource(
        id: '79',
        name: 'Абу Адель',
        language: 'ru',
        translator: 'Abu Adel',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/79',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // PERSIAN/FARSI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '135',
        name: 'آیت الله مکارم شیرازی',
        language: 'fa',
        translator: 'Ayatollah Makarem Shirazi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/135',
        fileSize: 3 * 1024 * 1024,
      ),
      TranslationSource(
        id: '29',
        name: 'حسین انصاریان',
        language: 'fa',
        translator: 'Hussain Ansarian',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/29',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // MALAY TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '39',
        name: 'Abdullah Muhammad Basmeih',
        language: 'ms',
        translator: 'Abdullah Muhammad Basmeih',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/39',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // CHINESE TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '56',
        name: '马坚',
        language: 'zh',
        translator: 'Ma Jian (Traditional Chinese)',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/56',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // JAPANESE TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '35',
        name: '三田了一',
        language: 'ja',
        translator: 'Mita Ryoichi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/35',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // KOREAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '219',
        name: '한국어',
        language: 'ko',
        translator: 'Korean Translation',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/219',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // TAMIL TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '229',
        name: 'ஜான் டிரஸ்ட்',
        language: 'ta',
        translator: 'Jan Trust Foundation',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/229',
        fileSize: 3 * 1024 * 1024,
      ),
      TranslationSource(
        id: '50',
        name: 'அப்துல் ஹமீத்',
        language: 'ta',
        translator: 'Abdul Hameed Baqavi & Kunhi Muhammad',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/50',
        fileSize: (2.8 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // THAI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '53',
        name: 'ภาษาไทย',
        language: 'th',
        translator: 'Thai Translation - King Fahd Complex',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/53',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // SWAHILI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '49',
        name: 'Al-Hikmah',
        language: 'sw',
        translator: 'Ali Muhsin Al-Barwani',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/49',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // PORTUGUESE TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '43',
        name: 'Samir El-Hayek',
        language: 'pt',
        translator: 'Samir El-Hayek',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/43',
        fileSize: (2.4 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // DUTCH TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '235',
        name: 'Sofian Siregar',
        language: 'nl',
        translator: 'Sofian Siregar',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/235',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // ITALIAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '153',
        name: 'Roberto Hamza Piccardo',
        language: 'it',
        translator: 'Roberto Hamza Piccardo',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/153',
        fileSize: (2.4 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // ALBANIAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '47',
        name: 'Hasan Efendi Nahi',
        language: 'sq',
        translator: 'Hasan Efendi Nahi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/47',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // BOSNIAN TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '25',
        name: 'Besim Korkut',
        language: 'bs',
        translator: 'Besim Korkut',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/25',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // UZBEK TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '55',
        name: 'Алоуддин Мансур',
        language: 'uz',
        translator: 'Alauddin Mansour',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/55',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // AZERBAIJANI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '23',
        name: 'Məmmədəliyev & Bünyadov',
        language: 'az',
        translator: 'Alikhan Musayev',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/23',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // KAZAKH TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '222',
        name: 'Халифа Алтай',
        language: 'kk',
        translator: 'Khalifah Altai',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/222',
        fileSize: (2.5 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // SOMALI TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '46',
        name: 'Abdullaahi Yuusuf',
        language: 'so',
        translator: 'Abdullaahi Yuusuf Ali',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/46',
        fileSize: (2.2 * 1024 * 1024).toInt(),
      ),
      
      // ============================================
      // HAUSA TRANSLATIONS
      // ============================================
      TranslationSource(
        id: '32',
        name: 'Abubakar Mahmoud Gumi',
        language: 'ha',
        translator: 'Abubakar Mahmoud Gumi',
        downloadUrl: 'https://api.quran.com/api/v4/quran/translations/32',
        fileSize: (2.3 * 1024 * 1024).toInt(),
      ),
    ];
  }
}

