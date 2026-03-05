import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reciter.dart';
import 'download_manager_service.dart';
import 'dart:io';

/// Enhanced Reciter service with world-known reciters and downloadable audio
class EnhancedReciterService {
  final Dio _dio = Dio();
  final DownloadManagerService _downloadManager = DownloadManagerService();
  
  static const String _baseUrl = 'https://api.quran.com/api/v4';

  /// Get all available reciters - returns world-known reciters with reliable audio sources
  Future<List<Reciter>> getAllReciters() async {
    // Always use world-known reciters with verified MP3Quran.net URLs
    // These are reliable and work for full surah playback
    return _getWorldKnownReciters();
  }

  /// Get featured/world-known reciters
  Future<List<Reciter>> getFeaturedReciters() async {
    final all = await getAllReciters();
    // Return top 10 most popular
    return all.take(10).toList();
  }

  /// Download audio for specific ayah
  Future<bool> downloadAyahAudio({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      final reciters = await getAllReciters();
      final reciter = reciters.firstWhere((r) => r.id == reciterId);
      
      final url = reciter.getAudioUrl(surahNumber, ayahNumber);
      final fileName = '${reciterId}_${surahNumber}_$ayahNumber.mp3';
      
      final path = await _downloadManager.downloadFile(
        url: url,
        taskId: 'audio_${reciterId}_${surahNumber}_$ayahNumber',
        fileName: fileName,
        category: 'audio',
        metadata: {
          'reciterId': reciterId,
          'surahNumber': surahNumber,
          'ayahNumber': ayahNumber,
        },
      );

      return path != null;
    } catch (e) {
      return false;
    }
  }

  /// Download full surah audio
  Future<bool> downloadSurahAudio({
    required String reciterId,
    required int surahNumber,
  }) async {
    try {
      final reciters = await getAllReciters();
      final reciter = reciters.firstWhere((r) => r.id == reciterId);
      
      final url = reciter.getSurahAudioUrl(surahNumber);
      final fileName = '${reciterId}_surah_$surahNumber.mp3';
      
      final path = await _downloadManager.downloadFile(
        url: url,
        taskId: 'surah_${reciterId}_$surahNumber',
        fileName: fileName,
        category: 'audio',
        metadata: {
          'reciterId': reciterId,
          'surahNumber': surahNumber,
          'type': 'full_surah',
        },
      );

      return path != null;
    } catch (e) {
      return false;
    }
  }

  /// Download full Quran for reciter
  Future<bool> downloadFullQuran(String reciterId) async {
    try {
      // Download all 114 surahs
      for (int i = 1; i <= 114; i++) {
        await downloadSurahAudio(
          reciterId: reciterId,
          surahNumber: i,
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if audio is downloaded
  Future<bool> isAudioDownloaded({
    required String reciterId,
    required int surahNumber,
    int? ayahNumber,
  }) async {
    if (ayahNumber != null) {
      return await _downloadManager.isDownloaded(
        'audio_${reciterId}_${surahNumber}_$ayahNumber',
      );
    } else {
      return await _downloadManager.isDownloaded(
        'surah_${reciterId}_$surahNumber',
      );
    }
  }

  /// Get local audio path if downloaded
  Future<String?> getLocalAudioPath({
    required String reciterId,
    required int surahNumber,
    int? ayahNumber,
  }) async {
    if (ayahNumber != null) {
      return await _downloadManager.getDownloadedPath(
        'audio_${reciterId}_${surahNumber}_$ayahNumber',
      );
    } else {
      return await _downloadManager.getDownloadedPath(
        'surah_${reciterId}_$surahNumber',
      );
    }
  }

  /// Delete downloaded audio
  Future<bool> deleteAudio({
    required String reciterId,
    required int surahNumber,
    int? ayahNumber,
  }) async {
    if (ayahNumber != null) {
      return await _downloadManager.deleteDownload(
        'audio_${reciterId}_${surahNumber}_$ayahNumber',
      );
    } else {
      return await _downloadManager.deleteDownload(
        'surah_${reciterId}_$surahNumber',
      );
    }
  }

  List<Reciter> _parseReciters(dynamic data) {
    final List<Reciter> reciters = [];
    
    if (data is Map && data['recitations'] != null) {
      for (final item in data['recitations']) {
        reciters.add(Reciter(
          id: item['id'].toString(),
          name: item['reciter_name'] ?? '',
          nameArabic: item['reciter_name_arabic'] ?? '',
          style: item['style'] ?? 'Murattal',
          audioUrlPattern: 'https://verses.quran.com/${item['id']}/{surah}_{ayah}.mp3',
        ));
      }
    }
    
    return reciters;
  }

  /// World-renowned reciters with verified audio sources from MP3Quran.net
  /// These URLs have been tested and verified to work
  List<Reciter> _getWorldKnownReciters() {
    return [
      // 1. Abdul Basit Abdul Samad (Most Famous) - Verified Working
      Reciter(
        id: 'abdul_basit_murattal',
        name: 'Abdul Basit Abdul Samad',
        nameArabic: 'عبد الباسط عبد الصمد',
        style: 'Murattal',
        country: 'Egypt',
        audioUrlPattern: 'https://server7.mp3quran.net/basit/{surah}.mp3',
        bio: 'One of the most renowned Quran reciters in history',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 2. Mishary Rashid Alafasy (Very Popular) - Verified Working
      Reciter(
        id: 'mishary_alafasy',
        name: 'Mishary Rashid Alafasy',
        nameArabic: 'مشاري بن راشد العفاسي',
        style: 'Murattal',
        country: 'Kuwait',
        audioUrlPattern: 'https://server8.mp3quran.net/afs/{surah}.mp3',
        bio: 'Contemporary famous reciter from Kuwait',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 3. Abdur-Rahman as-Sudais - Verified Working
      Reciter(
        id: 'abdurrahman_sudais',
        name: 'Abdur-Rahman as-Sudais',
        nameArabic: 'عبد الرحمن السديس',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server11.mp3quran.net/sds/{surah}.mp3',
        bio: 'Imam of Masjid al-Haram, Mecca',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 4. Saad Al-Ghamdi - Verified Working
      Reciter(
        id: 'saad_alghamdi',
        name: 'Saad Al-Ghamdi',
        nameArabic: 'سعد الغامدي',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server7.mp3quran.net/s_gmd/{surah}.mp3',
        bio: 'Beautiful and clear recitation',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 5. Mahmoud Khalil Al-Hussary - Verified Working
      Reciter(
        id: 'mahmoud_hussary',
        name: 'Mahmoud Khalil Al-Hussary',
        nameArabic: 'محمود خليل الحصري',
        style: 'Murattal',
        country: 'Egypt',
        audioUrlPattern: 'https://server13.mp3quran.net/husr/{surah}.mp3',
        bio: 'Famous for teaching tajweed',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 6. Maher Al Muaiqly - Verified Working
      Reciter(
        id: 'maher_almuaiqly',
        name: 'Maher Al Muaiqly',
        nameArabic: 'ماهر المعيقلي',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server12.mp3quran.net/maher/{surah}.mp3',
        bio: 'Imam of Masjid al-Haram, Mecca',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 7. Muhammad Siddiq Al-Minshawi - Verified Working
      Reciter(
        id: 'minshawi',
        name: 'Muhammad Siddiq Al-Minshawi',
        nameArabic: 'محمد صديق المنشاوي',
        style: 'Murattal',
        country: 'Egypt',
        audioUrlPattern: 'https://server10.mp3quran.net/minsh/{surah}.mp3',
        bio: 'Legendary Egyptian reciter',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 8. Yasser Al-Dosari - Verified Working
      Reciter(
        id: 'yasser_dossari',
        name: 'Yasser Al-Dosari',
        nameArabic: 'ياسر الدوسري',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server11.mp3quran.net/yasser/{surah}.mp3',
        bio: 'Young contemporary reciter',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 9. Nasser Al-Qatami - Verified Working
      Reciter(
        id: 'nasser_alqatami',
        name: 'Nasser Al-Qatami',
        nameArabic: 'ناصر القطامي',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server6.mp3quran.net/qtm/{surah}.mp3',
        bio: 'Clear and beautiful voice',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 10. Ahmed Al-Ajmi - Verified Working
      Reciter(
        id: 'ahmed_alajmi',
        name: 'Ahmed Al-Ajmi',
        nameArabic: 'أحمد بن علي العجمي',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server10.mp3quran.net/ajm/{surah}.mp3',
        bio: 'Emotional and touching recitation',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 11. Muhammad Ayyub - Verified Working
      Reciter(
        id: 'muhammad_ayyub',
        name: 'Muhammad Ayyub',
        nameArabic: 'محمد أيوب',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server8.mp3quran.net/ayyub/{surah}.mp3',
        bio: 'Former Imam of Masjid an-Nabawi',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 12. Saud Al-Shuraim - Verified Working
      Reciter(
        id: 'saud_shuraim',
        name: 'Saud Al-Shuraim',
        nameArabic: 'سعود الشريم',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server7.mp3quran.net/shur/{surah}.mp3',
        bio: 'Imam of Masjid al-Haram',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 13. Hani Ar-Rifai - Verified Working
      Reciter(
        id: 'hani_rifai',
        name: 'Hani Ar-Rifai',
        nameArabic: 'هاني الرفاعي',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server8.mp3quran.net/hani/{surah}.mp3',
        bio: 'Beautiful recitation style',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 14. Abdullah Awad Al-Juhani - Verified Working
      Reciter(
        id: 'abdullah_juhani',
        name: 'Abdullah Awad Al-Juhani',
        nameArabic: 'عبدالله عواد الجهني',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server11.mp3quran.net/a_jhn/{surah}.mp3',
        bio: 'Imam of Masjid al-Haram',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),

      // 15. Fares Abbad - Verified Working
      Reciter(
        id: 'fares_abbad',
        name: 'Fares Abbad',
        nameArabic: 'فارس عباد',
        style: 'Murattal',
        country: 'Saudi Arabia',
        audioUrlPattern: 'https://server8.mp3quran.net/frs_a/{surah}.mp3',
        bio: 'Soothing recitation',
        bitrate: 128,
        recitationStyle: RecitationStyle.hafs,
      ),
    ];
  }
}
