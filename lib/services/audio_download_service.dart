import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/reciter.dart';
import '../utils/constants.dart';

/// Service for downloading and managing offline audio
class AudioDownloadService {
  static final AudioDownloadService _instance = AudioDownloadService._internal();
  factory AudioDownloadService() => _instance;
  AudioDownloadService._internal();

  Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/quran_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  Future<String?> getLocalAudioPath(
    int surahNumber,
    int ayahNumber,
    Reciter reciter,
  ) async {
    final audioDir = await getAudioDirectory();
    final file = File(
      '${audioDir.path}/${reciter.id}_${surahNumber}_$ayahNumber.mp3',
    );
    
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<bool> downloadAyah(
    int surahNumber,
    int ayahNumber,
    Reciter reciter,
    Function(int, int)? onProgress,
  ) async {
    try {
      final audioDir = await getAudioDirectory();
      final url = reciter.getAudioUrl(surahNumber, ayahNumber);
      
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final file = File(
          '${audioDir.path}/${reciter.id}_${surahNumber}_$ayahNumber.mp3',
        );
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> downloadSurah(
    int surahNumber,
    Reciter reciter,
    int totalAyahs,
    Function(int, int)? onProgress,
  ) async {
    int downloaded = 0;
    for (int ayah = 1; ayah <= totalAyahs; ayah++) {
      final success = await downloadAyah(surahNumber, ayah, reciter, null);
      if (success) {
        downloaded++;
        onProgress?.call(downloaded, totalAyahs);
      }
    }
    return downloaded == totalAyahs;
  }

  Future<void> deleteAyah(int surahNumber, int ayahNumber, Reciter reciter) async {
    try {
      final audioDir = await getAudioDirectory();
      final file = File(
        '${audioDir.path}/${reciter.id}_${surahNumber}_$ayahNumber.mp3',
      );
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<int> getDownloadedSize(Reciter reciter) async {
    try {
      final audioDir = await getAudioDirectory();
      int totalSize = 0;
      
      await for (final entity in audioDir.list()) {
        if (entity is File && entity.path.contains(reciter.id)) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}
