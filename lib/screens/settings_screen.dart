import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import 'about_screen.dart';
import 'translations_selector_screen.dart';

void _showThemeSelector(BuildContext context, SettingsProvider settings) {
  Color pickerColor = settings.customSeedColor;
  final presets = AppThemeType.values.where((t) => t != AppThemeType.custom).toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final primary = Theme.of(context).primaryColor;
        return DraggableScrollableSheet(
          initialChildSize: 0.80,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.palette_outlined, color: primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Theme',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pick a preset or create your own',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Presets label
                      _sectionLabel('PRESETS', primary),
                      const SizedBox(height: 12),

                      // Preset themes grid — 3 columns
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.80,
                        children: presets.map((theme) {
                          final isSelected = settings.currentTheme == theme;
                          return GestureDetector(
                            onTap: () {
                              settings.setTheme(theme);
                              Navigator.pop(ctx);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? primary : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: _getThemeGradient(theme),
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(Icons.check_circle, color: Colors.white, size: 26),
                                              )
                                            : null,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: Theme.of(context).cardColor,
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          AppTheme.getThemeName(theme),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? primary
                                                : Theme.of(context).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Custom color label
                      _sectionLabel('CUSTOM COLOR', primary),
                      const SizedBox(height: 12),

                      // Custom color card
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: settings.currentTheme == AppThemeType.custom
                                ? primary
                                : Colors.grey.withOpacity(0.3),
                            width: settings.currentTheme == AppThemeType.custom ? 2 : 1,
                          ),
                          boxShadow: settings.currentTheme == AppThemeType.custom
                              ? [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 10)]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Color circle
                                GestureDetector(
                                  onTap: () => _openColorPickerDialog(
                                    context,
                                    pickerColor,
                                    (color) => setSheetState(() => pickerColor = color),
                                  ),
                                  child: Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: pickerColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: pickerColor.withOpacity(0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.colorize, color: Colors.white, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your Color',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _openColorPickerDialog(
                                    context,
                                    pickerColor,
                                    (color) => setSheetState(() => pickerColor = color),
                                  ),
                                  icon: const Icon(Icons.palette, size: 16),
                                  label: const Text('Pick'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  settings.setCustomSeedColor(pickerColor);
                                  settings.setTheme(AppThemeType.custom);
                                  Navigator.pop(ctx);
                                },
                                icon: const Icon(Icons.check_rounded),
                                label: const Text(
                                  'Apply Custom Theme',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pickerColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}

Widget _sectionLabel(String text, Color color) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: 1.5,
    ),
  );
}

void _openColorPickerDialog(
  BuildContext context,
  Color currentColor,
  ValueChanged<Color> onColorPicked,
) {
  Color tempColor = currentColor;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a Color'),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: (color) => tempColor = color,
          pickerAreaHeightPercent: 0.8,
          enableAlpha: false,
          displayThumbColor: true,
          labelTypes: const [],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onColorPicked(tempColor);
            Navigator.pop(context);
          },
          child: const Text('Select'),
        ),
      ],
    ),
  );
}

LinearGradient _getThemeGradient(AppThemeType theme) {
  switch (theme) {
    case AppThemeType.light:
      return LinearGradient(
        colors: [Colors.grey[200]!, Colors.grey[50]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.dark:
      return LinearGradient(
        colors: [Colors.grey[700]!, Colors.grey[900]!],
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
    case AppThemeType.midnightNavy:
      return LinearGradient(
        colors: [AppTheme.navySecondary, AppTheme.navyPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.roseGold:
      return LinearGradient(
        colors: [AppTheme.roseSecondary, AppTheme.rosePrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.purpleMystic:
      return LinearGradient(
        colors: [AppTheme.mysticSecondary, AppTheme.mysticPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.emeraldDark:
      return LinearGradient(
        colors: [AppTheme.emeraldSecondary, AppTheme.emeraldPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.sandDunes:
      return LinearGradient(
        colors: [AppTheme.sandSecondary, AppTheme.sandPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case AppThemeType.custom:
      return const LinearGradient(
        colors: [Colors.purple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}

void _showFontPicker(
  BuildContext context,
  String title,
  List<Map<String, String>> fonts,
  String currentFamily,
  Function(String) onSelected,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...fonts.map((f) {
            final isSelected = f['family'] == currentFamily;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
              title: Text(
                f['name']!,
                style: TextStyle(
                  fontFamily: f['family'],
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(f['desc']!),
              onTap: () {
                onSelected(f['family']!);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    ),
  );
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
                  Divider(height: 1, indent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Glassmorphism Intensity',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${(settings.glassmorphismIntensity * 100).toInt()}%',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: settings.glassmorphismIntensity,
                          onChanged: (val) => settings.setGlassmorphismIntensity(val),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
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

              // Font Styles Section
              _SectionHeader(
                title: 'Font Styles',
                icon: Icons.font_download_outlined,
              ),
              _SettingsCard(
                children: [
                  ListTile(
                    title: const Text('Arabic Font'),
                    subtitle: Text(
                      AppTheme.availableArabicFonts.firstWhere(
                        (f) => f['family'] == settings.arabicFontFamily,
                        orElse: () => AppTheme.availableArabicFonts.first,
                      )['name']!,
                    ),
                    trailing: const Icon(Icons.title),
                    onTap: () => _showFontPicker(
                      context,
                      'Select Arabic Font',
                      AppTheme.availableArabicFonts,
                      settings.arabicFontFamily,
                      (family) => settings.setArabicFontFamily(family),
                    ),
                  ),
                  Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('Bangla Font'),
                    subtitle: Text(
                      AppTheme.availableBanglaFonts.firstWhere(
                        (f) => f['family'] == settings.banglaFontFamily,
                        orElse: () => AppTheme.availableBanglaFonts.first,
                      )['name']!,
                    ),
                    trailing: const Icon(Icons.translate),
                    onTap: () => _showFontPicker(
                      context,
                      'Select Bangla Font',
                      AppTheme.availableBanglaFonts,
                      settings.banglaFontFamily,
                      (family) => settings.setBanglaFontFamily(family),
                    ),
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
