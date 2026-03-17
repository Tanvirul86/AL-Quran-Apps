import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/memorization_provider.dart';
import 'providers/achievement_provider.dart';
import 'models/reading_goal.dart';
import 'widgets/app_initializer.dart';
import 'theme/app_theme.dart';
import 'theme/high_contrast_theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ReadingGoalProvider()),
        ChangeNotifierProvider(create: (_) => MemorizationProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp(
            title: 'Al-Quran Pro',
            debugShowCheckedModeBanner: false,
            theme: settingsProvider.highContrastMode
                ? HighContrastTheme.lightTheme
                : AppTheme.getTheme(settingsProvider.currentTheme, customSeedColor: settingsProvider.customSeedColor),
            darkTheme: settingsProvider.highContrastMode
                ? HighContrastTheme.darkTheme
                : AppTheme.darkTheme,
            themeMode: settingsProvider.currentTheme == AppThemeType.dark 
                ? ThemeMode.dark 
                : ThemeMode.light,
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}
