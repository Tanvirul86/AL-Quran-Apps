import 'package:flutter/material.dart';

enum AppThemeType {
  light,
  dark,
  goldenHour,
  oceanBlue,
  forestGreen,
  sunset,
  midnightNavy,
  roseGold,
  purpleMystic,
  emeraldDark,
  sandDunes,
  custom,
}

class AppTheme {
  // Font constants
  static const String arabicFont = 'Scheherazade'; // Premium Quranic font (best diacritics)
  static const String arabicFontAlt = 'Amiri'; // Alternative Arabic font
  static const String banglaFont = 'NotoSansBengali'; // Bangla translations
  static const String englishFont = 'Roboto'; // System default for English
  
  static const List<Map<String, String>> availableArabicFonts = [
    {'name': 'Uthmani Hafs', 'family': 'UthmanicHafs', 'desc': 'Standard Madani Mushaf script (Recommended)'},
    {'name': 'Indo-Pak Saleem', 'family': 'PDMSSaleem', 'desc': 'Hafizi style Indo-Pak script'},
    {'name': 'Scheherazade New', 'family': 'Scheherazade', 'desc': 'Best diacritics & ligatures'},
    {'name': 'Amiri', 'family': 'Amiri', 'desc': 'Classic Bulaq style'},
    {'name': 'Noto Naskh', 'family': 'NotoNaskhArabic', 'desc': 'Modern and clean'},
  ];

  static const List<Map<String, String>> availableBanglaFonts = [
    {'name': 'Noto Sans Bengali', 'family': 'NotoSansBengali', 'desc': 'Google\'s standard'},
  ];
  
  // Color Palette - Islamic & Modern
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFEF5350);
  
  // Golden Hour Theme Colors - Warm & Luxurious
  static const Color goldenPrimary = Color(0xFFB8860B);
  static const Color goldenSecondary = Color(0xFFDAA520);
  static const Color goldenTertiary = Color(0xFFF4E4BC);
  static const Color goldenBackground = Color(0xFFFDF6E3);
  static const Color goldenSurface = Color(0xFFFAF0DC);
  
  // Ocean Blue Theme Colors - Calming & Spiritual
  static const Color oceanPrimary = Color(0xFF1565C0);
  static const Color oceanSecondary = Color(0xFF1976D2);
  static const Color oceanTertiary = Color(0xFF64B5F6);
  static const Color oceanBackground = Color(0xFFF3F8FF);
  static const Color oceanSurface = Color(0xFFE8F4FD);
  
  // Forest Green Theme Colors - Natural & Serene
  static const Color forestPrimary = Color(0xFF2E7D32);
  static const Color forestSecondary = Color(0xFF388E3C);
  static const Color forestTertiary = Color(0xFF66BB6A);
  static const Color forestBackground = Color(0xFFF1F8E9);
  static const Color forestSurface = Color(0xFFE8F5E8);
  
  // Sunset Theme Colors - Warm & Elegant
  static const Color sunsetPrimary = Color(0xFFD84315);
  static const Color sunsetSecondary = Color(0xFFFF5722);
  static const Color sunsetTertiary = Color(0xFFFFAB91);
  static const Color sunsetBackground = Color(0xFFFFF8E1);
  static const Color sunsetSurface = Color(0xFFFFF3C4);

  // Midnight Navy Theme Colors - Dark & Sophisticated
  static const Color navyPrimary = Color(0xFF1A3A5C);
  static const Color navySecondary = Color(0xFF2563A8);
  static const Color navyBackground = Color(0xFF0D2137);
  static const Color navySurface = Color(0xFF152B45);

  // Rose Gold Theme Colors - Elegant & Warm
  static const Color rosePrimary = Color(0xFFC2747A);
  static const Color roseSecondary = Color(0xFFE8A0A5);
  static const Color roseBackground = Color(0xFFFFF0F1);
  static const Color roseSurface = Color(0xFFFFE4E6);

  // Purple Mystic Theme Colors - Spiritual & Deep
  static const Color mysticPrimary = Color(0xFF6A1B9A);
  static const Color mysticSecondary = Color(0xFF9C27B0);
  static const Color mysticBackground = Color(0xFFF8F0FF);
  static const Color mysticSurface = Color(0xFFF3E5F5);

  // Emerald Dark Theme Colors - Rich & Verdant
  static const Color emeraldPrimary = Color(0xFF1B4332);
  static const Color emeraldSecondary = Color(0xFF2D6A4F);
  static const Color emeraldBackground = Color(0xFF0D2B1E);
  static const Color emeraldSurface = Color(0xFF1A3D2B);

  // Sand Dunes Theme Colors - Desert & Earthy
  static const Color sandPrimary = Color(0xFFA0522D);
  static const Color sandSecondary = Color(0xFFCD853F);
  static const Color sandBackground = Color(0xFFFFF8F0);
  static const Color sandSurface = Color(0xFFFFF0DC);

  // Gradients
  static const LinearGradient islamicGradient = LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static const BoxShadow elevatedShadow = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );
  
  // Light Theme - Soft Islamic Palette
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      fontFamily: englishFont, // Default font for UI
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: darkGreen,
        tertiary: accentGold,
        surface: Colors.white,
        background: const Color(0xFFFAFAFA),
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        shadowColor: Colors.black12,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGreen,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkGreen,
          fontFamily: englishFont,
          letterSpacing: 0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
          fontFamily: englishFont,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGreen,
          fontFamily: englishFont,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          fontFamily: englishFont,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: englishFont,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontFamily: englishFont,
        ),
      ),
    );
  }

  // Dark Theme - Night Reading Mode
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: lightGreen,
      fontFamily: englishFont, // Default font for UI
      colorScheme: ColorScheme.dark(
        primary: lightGreen,
        secondary: successGreen,
        tertiary: accentGold,
        surface: const Color(0xFF2A2A2A),
        background: const Color(0xFF121212),
        error: Colors.redAccent,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF2A2A2A),
        shadowColor: Colors.black45,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightGreen,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: lightGreen, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightGreen,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: lightGreen,
          fontFamily: englishFont,
          letterSpacing: 0.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: successGreen,
          fontFamily: englishFont,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightGreen,
          fontFamily: englishFont,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          fontFamily: englishFont,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          fontFamily: englishFont,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white54,
          fontFamily: englishFont,
        ),
      ),
    );
  }

  // Golden Hour Theme - Warm & Luxurious
  static ThemeData get goldenHourTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: goldenPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: goldenPrimary,
        secondary: goldenSecondary,
        tertiary: goldenTertiary,
        surface: goldenSurface,
        background: goldenBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF8B4513),
        onBackground: const Color(0xFF8B4513),
      ),
      scaffoldBackgroundColor: goldenBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: goldenPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: goldenSurface,
        shadowColor: goldenPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF8B4513), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF8B4513), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: goldenPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Ocean Blue Theme - Calming & Spiritual
  static ThemeData get oceanBlueTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: oceanPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: oceanPrimary,
        secondary: oceanSecondary,
        tertiary: oceanTertiary,
        surface: oceanSurface,
        background: oceanBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF0D47A1),
        onBackground: const Color(0xFF0D47A1),
      ),
      scaffoldBackgroundColor: oceanBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: oceanPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: oceanSurface,
        shadowColor: oceanPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF0D47A1), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF0D47A1), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: oceanPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Forest Green Theme - Natural & Serene
  static ThemeData get forestGreenTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: forestPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: forestPrimary,
        secondary: forestSecondary,
        tertiary: forestTertiary,
        surface: forestSurface,
        background: forestBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1B5E20),
        onBackground: const Color(0xFF1B5E20),
      ),
      scaffoldBackgroundColor: forestBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: forestPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: forestSurface,
        shadowColor: forestPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1B5E20), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF1B5E20), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: forestPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Sunset Theme - Warm & Elegant
  static ThemeData get sunsetTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: sunsetPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: sunsetPrimary,
        secondary: sunsetSecondary,
        tertiary: sunsetTertiary,
        surface: sunsetSurface,
        background: sunsetBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFBF360C),
        onBackground: const Color(0xFFBF360C),
      ),
      scaffoldBackgroundColor: sunsetBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: sunsetPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: sunsetSurface,
        shadowColor: sunsetPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFBF360C), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFFBF360C), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: sunsetPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Midnight Navy Theme - Dark & Sophisticated
  static ThemeData get midnightNavyTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: navySecondary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.dark(
        primary: navySecondary,
        secondary: const Color(0xFF4A90D9),
        surface: navySurface,
        background: navyBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSurface: Colors.white70,
        onBackground: Colors.white70,
      ),
      scaffoldBackgroundColor: navyBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: true, backgroundColor: navyPrimary, foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: englishFont, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: navySurface,
        shadowColor: navySecondary.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70, fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Colors.white70, fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navySecondary, fontFamily: englishFont),
      ),
    );
  }

  // Rose Gold Theme - Elegant & Warm
  static ThemeData get roseGoldTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: rosePrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: rosePrimary,
        secondary: roseSecondary,
        surface: roseSurface,
        background: roseBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF8B3A3D),
        onBackground: const Color(0xFF8B3A3D),
      ),
      scaffoldBackgroundColor: roseBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: true, backgroundColor: rosePrimary, foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: englishFont, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: roseSurface,
        shadowColor: rosePrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF8B3A3D), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF8B3A3D), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: rosePrimary, fontFamily: englishFont),
      ),
    );
  }

  // Purple Mystic Theme - Spiritual & Deep
  static ThemeData get purpleMysticTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: mysticPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: mysticPrimary,
        secondary: mysticSecondary,
        surface: mysticSurface,
        background: mysticBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF4A0072),
        onBackground: const Color(0xFF4A0072),
      ),
      scaffoldBackgroundColor: mysticBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: true, backgroundColor: mysticPrimary, foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: englishFont, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: mysticSurface,
        shadowColor: mysticPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF4A0072), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF4A0072), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: mysticPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Emerald Dark Theme - Rich & Verdant
  static ThemeData get emeraldDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: emeraldSecondary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.dark(
        primary: emeraldSecondary,
        secondary: const Color(0xFF52B788),
        surface: emeraldSurface,
        background: emeraldBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSurface: Colors.white70,
        onBackground: Colors.white70,
      ),
      scaffoldBackgroundColor: emeraldBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: true, backgroundColor: emeraldPrimary, foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: englishFont, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: emeraldSurface,
        shadowColor: emeraldSecondary.withOpacity(0.3),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70, fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Colors.white70, fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: emeraldSecondary, fontFamily: englishFont),
      ),
    );
  }

  // Sand Dunes Theme - Desert & Earthy
  static ThemeData get sandDunesTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: sandPrimary,
      fontFamily: englishFont,
      colorScheme: ColorScheme.light(
        primary: sandPrimary,
        secondary: sandSecondary,
        surface: sandSurface,
        background: sandBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF7B3A1A),
        onBackground: const Color(0xFF7B3A1A),
      ),
      scaffoldBackgroundColor: sandBackground,
      appBarTheme: const AppBarTheme(
        elevation: 0, centerTitle: true, backgroundColor: sandPrimary, foregroundColor: Colors.white,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: englishFont, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: sandSurface,
        shadowColor: sandPrimary.withOpacity(0.2),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF7B3A1A), fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFF7B3A1A), fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: sandPrimary, fontFamily: englishFont),
      ),
    );
  }

  // Custom Seed Theme — generated from a single user-chosen color via Material 3
  static ThemeData customSeedTheme(Color seed) {
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      primaryColor: scheme.primary,
      fontFamily: englishFont,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onPrimary,
          fontFamily: englishFont,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: scheme.onSurface, fontFamily: englishFont, height: 1.5),
        bodyMedium: TextStyle(color: scheme.onSurface, fontFamily: englishFont, height: 1.5),
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: scheme.primary, fontFamily: englishFont),
      ),
    );
  }

  // Theme selector method
  static ThemeData getTheme(AppThemeType themeType, {Color customSeedColor = const Color(0xFF009688)}) {
    switch (themeType) {
      case AppThemeType.light:
        return lightTheme;
      case AppThemeType.dark:
        return darkTheme;
      case AppThemeType.goldenHour:
        return goldenHourTheme;
      case AppThemeType.oceanBlue:
        return oceanBlueTheme;
      case AppThemeType.forestGreen:
        return forestGreenTheme;
      case AppThemeType.sunset:
        return sunsetTheme;
      case AppThemeType.midnightNavy:
        return midnightNavyTheme;
      case AppThemeType.roseGold:
        return roseGoldTheme;
      case AppThemeType.purpleMystic:
        return purpleMysticTheme;
      case AppThemeType.emeraldDark:
        return emeraldDarkTheme;
      case AppThemeType.sandDunes:
        return sandDunesTheme;
      case AppThemeType.custom:
        return customSeedTheme(customSeedColor);
    }
  }

  // Theme name mapping
  static String getThemeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Light';
      case AppThemeType.dark:
        return 'Dark';
      case AppThemeType.goldenHour:
        return 'Golden Hour';
      case AppThemeType.oceanBlue:
        return 'Ocean Blue';
      case AppThemeType.forestGreen:
        return 'Forest Green';
      case AppThemeType.sunset:
        return 'Sunset';
      case AppThemeType.midnightNavy:
        return 'Midnight Navy';
      case AppThemeType.roseGold:
        return 'Rose Gold';
      case AppThemeType.purpleMystic:
        return 'Purple Mystic';
      case AppThemeType.emeraldDark:
        return 'Emerald Dark';
      case AppThemeType.sandDunes:
        return 'Sand Dunes';
      case AppThemeType.custom:
        return 'Custom';
    }
  }

  // Theme description mapping
  static String getThemeDescription(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return 'Clean and bright';
      case AppThemeType.dark:
        return 'Easy on the eyes';
      case AppThemeType.goldenHour:
        return 'Warm and luxurious';
      case AppThemeType.oceanBlue:
        return 'Calm and spiritual';
      case AppThemeType.forestGreen:
        return 'Natural and serene';
      case AppThemeType.sunset:
        return 'Warm and elegant';
      case AppThemeType.midnightNavy:
        return 'Dark & sophisticated';
      case AppThemeType.roseGold:
        return 'Elegant & warm';
      case AppThemeType.purpleMystic:
        return 'Spiritual & deep';
      case AppThemeType.emeraldDark:
        return 'Rich & verdant';
      case AppThemeType.sandDunes:
        return 'Desert & earthy';
      case AppThemeType.custom:
        return 'Your personal color';
    }
  }
  
  // Helper methods for language-specific text styles
  static TextStyle arabicTextStyle({
    double fontSize = 28.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 2.0, // Enhanced line height for better Arabic readability
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? arabicFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: 0.8, // Enhanced spacing for better diacritic display
    );
  }
  
  static TextStyle banglaTextStyle({
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.8,
    String? fontFamily,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? banglaFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: 0.3,
    );
  }
  
  static TextStyle englishTextStyle({
    double fontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 1.6,
  }) {
    return TextStyle(
      fontFamily: englishFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: 0.3,
    );
  }

  // Glassmorphism effect properties
  static double get glassBlur => 15.0;
  static double get glassOpacity => 0.12;
  static double get glassBorderOpacity => 0.25;
  
  static Color glassColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light 
        ? Colors.white 
        : Colors.black;
  }
}
