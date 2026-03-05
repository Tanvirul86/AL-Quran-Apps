/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Qur\'an App';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String dbName = 'quran_app.db';
  static const int dbVersion = 1;
  
  // Storage Keys
  static const String keyLastReadSurah = 'last_read_surah';
  static const String keyLastReadAyah = 'last_read_ayah';
  static const String keyShowBangla = 'show_bangla';
  static const String keyShowEnglish = 'show_english';
  static const String keyDarkMode = 'dark_mode';
  static const String keyArabicFontSize = 'arabic_font_size';
  static const String keyBanglaFontSize = 'bangla_font_size';
  static const String keyEnglishFontSize = 'english_font_size';
  static const String keyPlaybackSpeed = 'playback_speed';
  
  // Default Values
  static const double defaultArabicFontSize = 24.0;
  static const double defaultBanglaFontSize = 16.0;
  static const double defaultEnglishFontSize = 16.0;
  static const double defaultPlaybackSpeed = 1.0;
  
  // Font Sizes Range
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  
  // Playback Speed Range
  static const double minPlaybackSpeed = 0.5;
  static const double maxPlaybackSpeed = 2.0;
  
  // Audio Configuration
  // Using everyayah.com - reliable source for ayah-by-ayah recitation
  static const String audioBaseUrl = 'https://everyayah.com/data/Alafasy_128kbps/';
  
  // Alternative reciters (change audioBaseUrl to use):
  // Abdul Basit (Murattal): 'https://everyayah.com/data/Abdul_Basit_Murattal_128kbps/'
  // Abdul Basit (Mujawwad): 'https://everyayah.com/data/Abdul_Basit_Mujawwad_128kbps/'
  // Mishary Rashid Alafasy: 'https://everyayah.com/data/Alafasy_128kbps/'
  // Saad Al-Ghamdi: 'https://everyayah.com/data/Ghamadi_40kbps/'
  // Mahmoud Khalil Al-Husary: 'https://everyayah.com/data/Husary_128kbps/'
  
  // Audio URL format for everyayah.com: {surah:03d}{ayah:03d}.mp3
  static String getAudioUrl(int surahNumber, int ayahNumber) {
    // Format: 001001.mp3 for Surah 1, Ayah 1
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');
    return '$audioBaseUrl$surah$ayah.mp3';
  }
  
  // Supported reciters (for future use)
  static const List<String> supportedReciters = [
    'Abdul_Basit_Murattal',
    'Mishary_Rashid',
    'Saad_Al_Ghamdi',
    'Abdullah_Basfar',
  ];
  
  // Colors (Islamic Palette)
  static const int primaryColorLight = 0xFF2E7D32; // Green
  static const int primaryColorDark = 0xFF4CAF50;
  static const int accentColor = 0xFF1B5E20;
  static const int backgroundColorLight = 0xFFF5F5F5;
  static const int backgroundColorDark = 0xFF121212;
}
