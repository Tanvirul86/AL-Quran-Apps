import 'package:flutter/material.dart';

enum AppThemeType {
  light,
  dark,
  goldenHour,
  oceanBlue,
  forestGreen,
  sunset,
}

class AppTheme {
  // Font constants
  static const String arabicFont = 'Scheherazade'; // Premium Quranic font (best diacritics)
  static const String arabicFontAlt = 'Amiri'; // Alternative Arabic font
  static const String banglaFont = 'NotoSansBengali'; // Bangla translations
  static const String englishFont = 'Roboto'; // System default for English
  
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

  // Theme selector method
  static ThemeData getTheme(AppThemeType themeType) {
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
    }
  }
  
  // Helper methods for language-specific text styles
  static TextStyle arabicTextStyle({
    double fontSize = 28.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 2.0, // Enhanced line height for better Arabic readability
  }) {
    return TextStyle(
      fontFamily: arabicFont,
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
  }) {
    return TextStyle(
      fontFamily: banglaFont,
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
}
