import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'translations_selector_screen.dart';

void _showThemeSelector(BuildContext context, SettingsProvider settings) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Theme',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Select your preferred color scheme',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Theme Options
          ...AppThemeType.values.map((theme) {
            final isSelected = settings.currentTheme == theme;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    settings.setTheme(theme);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected 
                          ? Theme.of(context).primaryColor.withOpacity(0.05)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Theme Preview
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _getThemeGradient(theme),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        
                        // Theme Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTheme.getThemeName(theme),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected 
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppTheme.getThemeDescription(theme),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Selection Indicator
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

LinearGradient _getThemeGradient(AppThemeType theme) {
  switch (theme) {
    case AppThemeType.light:
      return LinearGradient(
        colors: [Colors.grey[100]!, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.dark:
      return LinearGradient(
        colors: [Colors.grey[800]!, Colors.grey[900]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.goldenHour:
      return LinearGradient(
        colors: [AppTheme.goldenSecondary, AppTheme.goldenPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.oceanBlue:
      return LinearGradient(
        colors: [AppTheme.oceanTertiary, AppTheme.oceanPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.forestGreen:
      return LinearGradient(
        colors: [AppTheme.forestTertiary, AppTheme.forestPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.sunset:
      return LinearGradient(
        colors: [AppTheme.sunsetTertiary, AppTheme.sunsetPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Appearance Section
              _SectionHeader(
                title: 'Appearance',
                icon: Icons.palette_outlined,
              ),
              _SettingsCard(
                children: [
                  ListTile(
                    title: const Text('Theme Selection'),
                    subtitle: Text('Current: ${AppTheme.getThemeName(settings.currentTheme)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeSelector(context, settings),
                  ),
                  Divider(height: 1, indent: 16),
                  SwitchListTile(
                    title: const Text('High Contrast Mode'),
                    subtitle: const Text('Enhanced visibility for accessibility'),
                    value: settings.highContrastMode,
                    onChanged: (value) => settings.setHighContrastMode(value),
                  ),
                  Divider(height: 1, indent: 16),
                  SwitchListTile(
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Vibration feedback for interactions'),
                    value: settings.hapticFeedbackEnabled,
                    onChanged: (value) => settings.setHapticFeedbackEnabled(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Translation Display Section
              _SectionHeader(
                title: 'Translations',
                icon: Icons.language,
              ),
              _SettingsCard(
                children: [
                  SwitchListTile(
                    title: const Text('Show Bangla Translation'),
                    subtitle: const Text('Display Bengali translations'),
                    value: settings.showBangla,
                    onChanged: (value) => settings.setShowBangla(value),
                  ),
                  Divider(height: 1, indent: 16),
                  SwitchListTile(
                    title: const Text('Show English Translation'),
                    subtitle: const Text('Display English translations'),
                    value: settings.showEnglish,
                    onChanged: (value) => settings.setShowEnglish(value),
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Select Translations'),
                    subtitle: const Text('Choose translation sources'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TranslationsSelectorScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Font Sizes Section
              _SectionHeader(
                title: 'Font Sizes',
                icon: Icons.text_fields,
              ),
              _SettingsCard(
                children: [
                  _FontSizeSlider(
                    title: 'Arabic Font Size',
                    value: settings.arabicFontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    onChanged: (value) => settings.setArabicFontSize(value),
                  ),
                  Divider(height: 1, indent: 16),
                  _FontSizeSlider(
                    title: 'Bangla Font Size',
                    value: settings.banglaFontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    onChanged: (value) => settings.setBanglaFontSize(value),
                  ),
                  Divider(height: 1, indent: 16),
                  _FontSizeSlider(
                    title: 'English Font Size',
                    value: settings.englishFontSize,
                    min: AppConstants.minFontSize,
                    max: AppConstants.maxFontSize,
                    onChanged: (value) => settings.setEnglishFontSize(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Audio Settings Section
              _SectionHeader(
                title: 'Audio',
                icon: Icons.music_note_outlined,
              ),
              _SettingsCard(
                children: [
                  _PlaybackSpeedSlider(
                    value: settings.playbackSpeed,
                    min: AppConstants.minPlaybackSpeed,
                    max: AppConstants.maxPlaybackSpeed,
                    onChanged: (value) => settings.setPlaybackSpeed(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // About Section
              _SectionHeader(
                title: 'About',
                icon: Icons.info_outlined,
              ),
              _SettingsCard(
                children: [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.hasData 
                          ? snapshot.data!.version 
                          : AppConstants.appVersion;
                      return ListTile(
                        title: const Text('App Version'),
                        subtitle: const Text('Al-Quran Pro'),
                        trailing: Text(
                          version,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('About'),
                    subtitle: const Text(
                      'A modern, accurate, and respectful Qur\'an application',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reset Settings
              _SettingsCard(
                children: [
                  ListTile(
                    title: const Text('Reset to Defaults'),
                    subtitle: const Text('Restore all settings to default values'),
                    trailing: const Icon(Icons.refresh_rounded),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Settings?'),
                          content: const Text(
                            'Are you sure you want to reset all settings to their default values?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                // TODO: Implement reset settings in provider
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Settings reset to defaults'),
                                  ),
                                );
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _FontSizeSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 1).toInt(),
            label: '${value.toInt()}',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PlaybackSpeedSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;

  const _PlaybackSpeedSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            label: '${value.toStringAsFixed(1)}x',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
